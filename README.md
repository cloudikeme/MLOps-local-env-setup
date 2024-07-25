Local Quick DevOps Environment Setup

This repository contains scripts to set up a DevOps environment on an Ubuntu-based system with one click. It installs the latest versions of Docker, Docker Engine, KinD Kubernetes, kubectl, kubectx, kubens, and Go.

Prerequisites:
- An Ubuntu-based system (tested on Ubuntu 20.04 LTS and later)
- sudo privileges on your system

Quick Start:

1. Clone this repository:
   git clone https://github.com/cloudikeme/local-dev-setup.git
   cd local-dev-setup

2. Make the setup script executable:
   chmod +x setup_devops.sh

3. Run the setup script:
   ./setup_devops.sh

4. Enter your sudo password when prompted.

5. After running the script, you need to run "source /etc/profile.d/go.sh" to apply the changes in your current session.

This setup will now install the latest versions of Docker and Docker Engine, KinD Kubernetes, kubectl, kubectx, kubens, and Go on your local Ubuntu-based system.

What's Included:
- Docker and Docker Engine
- KinD (Kubernetes in Docker)
- kubectl (Kubernetes command-line tool)
- kubectx and kubens (tools for switching between Kubernetes contexts and namespaces)
- Go programming language

Customization:
If you need to modify the versions of the installed tools or add new ones, edit the setup_devops.sh script.

Troubleshooting:
- If you encounter any issues, check the console output for error messages.
- Ensure you have a stable internet connection, as the script downloads packages and binaries.
- If a specific tool fails to install, you can comment out its section in the script and re-run.

Contributing:
Contributions are welcome! Please feel free to submit a Pull Request.

License:
This project is licensed under the MIT License - see the LICENSE file for details.




















m.



