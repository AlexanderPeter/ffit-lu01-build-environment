#!/usr/bin/env bash
set -euo pipefail

### Required variables
SONAR_URL="http://127.0.0.1:9000/sonarqube"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TOKEN_FILE="$SCRIPT_DIR/token.txt"

### Load .env if present
if [ -f "$ROOT_DIR/.env" ]; then
  echo "== Loading .env file =="
  set -a
  source "$ROOT_DIR/.env"
  set +a
fi
echo "DEBUG username is: $SONAR_ADMIN_USERNAME"
echo "DEBUG password is: $SONAR_ADMIN_PASSWORD"

### Validate required username
if [ -z "${SONAR_ADMIN_USERNAME:-}" ]; then
  echo "ERROR: SONAR_ADMIN_USERNAME is not set"
  echo "Set it via environment variable or .env file"
  exit 1
fi

### Validate required secret
if [ -z "${SONAR_ADMIN_PASSWORD:-}" ]; then
  echo "ERROR: SONAR_ADMIN_PASSWORD is not set"
  echo "Set it via environment variable or .env file"
  exit 1
fi

echo "== Wait until SonarQube is started =="
until curl -sf "$SONAR_URL/api/system/status" \
  | jq -e '.status=="UP"' >/dev/null; do
  sleep 5
done
echo "== SonarQube is UP =="

### Check if default admin/admin is still valid
echo "== Check if default admin password is active =="
DEFAULT_AUTH=$(curl -s -u admin:admin \
  "$SONAR_URL/api/authentication/validate")

if echo "$DEFAULT_AUTH" | jq -e '.valid == true' >/dev/null; then
  echo "== Default admin password detected, changing password =="
  curl -sf -X POST "$SONAR_URL/api/users/change_password" \
    -u admin:admin \
    -d "login=$SONAR_ADMIN_USERNAME&password=$SONAR_ADMIN_PASSWORD"
  echo "== Admin password changed successfully =="
else
  echo "== Default admin password already changed =="
fi

### Validate admin credentials
echo "== Validate admin credentials =="
ADMIN_AUTH=$(curl -s -u "$SONAR_ADMIN_USERNAME:$SONAR_ADMIN_PASSWORD" \
  "$SONAR_URL/api/authentication/validate")

echo "$ADMIN_AUTH" | jq -e '.valid == true' >/dev/null \
  || { echo "ERROR: Admin authentication failed: $ADMIN_AUTH"; exit 1; }

echo "== Admin authentication OK =="

echo "DEBUG username is: $PADAWAN_USERNAME"
echo "DEBUG password is: $PADAWAN_PASSWORD"

### Validate required username
if [ -z "${PADAWAN_USERNAME:-}" ]; then
  echo "ERROR: PADAWAN_USERNAME is not set"
  echo "Set it via environment variable or .env file"
  exit 1
fi

### Validate required secret
if [ -z "${PADAWAN_PASSWORD:-}" ]; then
  echo "ERROR: PADAWAN_PASSWORD is not set"
  echo "Set it via environment variable or .env file"
  exit 1
fi

USER_EXISTS=$(curl -s -u "$SONAR_ADMIN_USERNAME:$SONAR_ADMIN_PASSWORD" \
  "$SONAR_URL/api/users/search?login=$PADAWAN_USERNAME" \
  | jq -r '.users | length')

if [ "$USER_EXISTS" -eq 0 ]; then
  echo "== Creating CI user $PADAWAN_USERNAME =="
  curl -s -u "$SONAR_ADMIN_USERNAME:$SONAR_ADMIN_PASSWORD" \
    -X POST "$SONAR_URL/api/users/create" \
    -d "login=$PADAWAN_USERNAME&name=Padawan&password=$PADAWAN_PASSWORD"
else
  echo "== CI user $PADAWAN_USERNAME already exists =="
fi

curl -s -u "$SONAR_ADMIN_USERNAME:$SONAR_ADMIN_PASSWORD" \
  -X POST "$SONAR_URL/api/user_groups/add_user" \
  -d "login=$PADAWAN_USERNAME&name=sonar-users"

### Generate token if missing
if [ ! -s "$TOKEN_FILE" ]; then
  echo "== Generating token for $PADAWAN_USERNAME =="

  TOKEN_RESPONSE=$(curl -s -u "$PADAWAN_USERNAME:$PADAWAN_PASSWORD" \
    -X POST "$SONAR_URL/api/user_tokens/generate" \
    -d "name=ci-token")

  echo "$TOKEN_RESPONSE" | jq -e '.token' >/dev/null \
    || { echo "ERROR: Token generation failed: $TOKEN_RESPONSE"; exit 1; }

  TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token')
  echo "$TOKEN" > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE"

  echo "== Token written to $TOKEN_FILE =="
else
  echo "== Token file already exists, skipping generation =="
  TOKEN=$(cat "$TOKEN_FILE")
fi

### Validate token
echo "== Validate SonarQube token =="
TOKEN_AUTH=$(curl -s -u "$TOKEN:" \
  "$SONAR_URL/api/authentication/validate")

echo "$TOKEN_AUTH" | jq -e '.valid == true' >/dev/null \
  || { echo "ERROR: Token validation failed: $TOKEN_AUTH"; exit 1; }
echo "DEBUG token is: $TOKEN"
