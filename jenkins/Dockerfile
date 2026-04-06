FROM jenkins/jenkins:lts

USER root

# Basis-Tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        docker.io \
        docker-cli && \
    rm -rf /var/lib/apt/lists/*

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs && \
        node -v && npm -v && \
    rm -rf /var/lib/apt/lists/*

# Docker-Group
RUN groupadd -f docker && usermod -aG docker jenkins

# Git Safe Directory
RUN git config --system --add safe.directory '*'

# Jenkins Setup
USER jenkins

RUN jenkins-plugin-cli --plugins configuration-as-code
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
