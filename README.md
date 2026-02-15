# ffit-lu01-build-environment

### Diagram of the build environment

https://viewer.diagrams.net/?url=https://raw.githubusercontent.com/AlexanderPeter/ffit-lu01-build-environment/refs/heads/master/diagram_build_environment.drawio

### Setting up the build environment in a new instance

```bash
sudo dnf install git -y
git clone https://github.com/AlexanderPeter/ffit-lu01-build-environment
cd ffit-lu01-build-environment
find . -type f -name "*.sh" -exec chmod +x {} +
sh setup.sh
```
