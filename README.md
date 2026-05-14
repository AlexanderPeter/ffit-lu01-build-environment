# ffit-lu01-build-environment

### Diagram of the build environment

https://viewer.diagrams.net/?url=https://raw.githubusercontent.com/AlexanderPeter/ffit-lu01-build-environment/refs/heads/master/diagram_build_environment.drawio

### Setting up the build environment in a new instance

1. Set up a course in the "AWS Academy Learner Lab [154455]"
   https://awsacademy.instructure.com/courses/154455/modules/items/15036975
2. Start the lab by clicking "▶ Start Lab"
3. Open AWS UI by clicking on "AWS 🟢"
4. EC2 > Instances > Launch an instance
   - Create new EC2 instance
   - at least t3a.large
   - inclusive Key-Pair
   - Select existing security group (SSH & HTTP)
   - Disk space 30 GiB
   - "Launch an instance"
5. Associate Elastic IP address
6. ```bash
   ssh-keygen -R ec2-<DASH_SEPARATED_IP>.compute-1.amazonaws.com
   ```
7. ```bash
   ssh -i "<KEY_NAME>.pem" ec2-user@ec2-<DASH_SEPARATED_IP>.compute-1.amazonaws.com
   ```
8. ```bash
   sudo dnf install git -y
   git clone https://github.com/AlexanderPeter/ffit-lu01-build-environment
   cd ffit-lu01-build-environment
   cat <<'EOF' > .env
   ...
   EOF
   chmod 600 .env
   find . -type f -name "*.sh" -exec chmod +x {} +

   sudo ./setup.sh
   ```
