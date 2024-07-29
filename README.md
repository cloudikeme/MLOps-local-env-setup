# My Local Quick MLOps Environment Setup

## 🔨 Break Stuff, Learn Faster: Your Personal MLOps Playground Awaits

You know what they say - the best way to learn is to break things!  

This repo's my personal toolkit for setting up a fresh MLOps/DevOps environment on any Ubuntu machine... because who wants to waste time wrestling with dependencies when there's cool stuff to build?  

So this is not just some generic setup script – **it's the exact one I use myself**, battle-tested and refined through countless "oops" moments (don't worry, I've ironed out most of the kinks 😉).  

**Think of it as your own personal MLOps playground:**

- **One-click install:**  Get Conda, Docker, Kubernetes, Go, and other essential tools up and running with a single command. No more copy-pasting from outdated tutorials!
- **Always fresh, always ready:** I'm constantly tweaking and updating this repo to make sure it's using the latest and greatest versions. Consider it your shortcut to staying ahead of the curve.
- **Bash or Zsh, take your pick:**  We all have our preferences – choose the shell that speaks to your soul and let's get this party started.

**Whether you're a complete beginner or a seasoned pro looking for a quick and painless setup, this repo's got you covered.**  

So go ahead, clone it, break it, fix it, and most importantly, **learn something new along the way!**  And hey, if you find any bugs (or just want to say hi), feel free to open an issue. Let's conquer the world of MLOps together, one command at a time. 💪

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Clone the Repository](#step-1-clone-the-repository)
3. [Step 2: Choose Your Shell](#step-2-choose-your-shell)
4. [Step 3: Run the Setup Script](#step-3-run-the-setup-script)
    - [For Bash Users](#for-bash-users)
    - [For Zsh Users](#for-zsh-users)
5. [Step 4: Wait for Installation](#step-4-wait-for-installation)
6. [Step 5: Restart Your Shell](#step-5-restart-your-shell)
7. [Step 6: Verify Installation](#step-6-verify-installation)
8. [Step 7: Configure GitHub CLI (Optional)](#step-7-configure-github-cli-optional)
9. [Troubleshooting](#troubleshooting)
10. [Next Steps](#next-steps)

---
This guide provides a step-by-step process that should be easy for beginners to follow. It covers everything from cloning the repository to verifying the installation and suggests next steps. You can add this to your README.md file or create a separate SETUP.md file in your repository for this detailed guide.

## Quick Setup Instructions

This guide will walk you through setting up a DevOps environment on your Ubuntu-based system using the scripts and playbooks from this repository.

### Prerequisites

- An Ubuntu-based system (Ubuntu 20.04 LTS or later recommended)
- Internet connection
- Sudo privileges on your system

### Step 1: Clone the Repository

1. Open your terminal.
2. Run the following command to clone the repository:

   ```bash
   git clone https://github.com/cloudikeme/MLOps_env_setup.git
   ```

3. Navigate into the cloned directory:

   ```bash
   cd devops-environment-setup
   ```

### Step 2: Choose Your Shell

Decide whether you want to set up your environment for Bash (default shell) or Zsh. If you're not sure, stick with Bash.

### Step 3: Run the Setup Script

#### For Bash Users

1. Make the Bash setup script executable:

   ```bash
   chmod +x scripts/setup_env_bash.sh
   ```

2. Run the script:

   ```bash
   sudo ./scripts/setup_env_bash.sh
   ```

#### For Zsh Users

1. Make the Zsh setup script executable:

   ```bash
   chmod +x scripts/setup_env_zsh.sh
   ```

2. Run the script:

   ```bash
   sudo ./scripts/setup_env_zsh.sh
   ```

### Step 4: Wait for Installation

The script will now run and install various tools and configurations. This process may take some time, depending on your internet speed. You might be prompted for your password or to confirm certain actions.

### Step 5: Restart Your Shell

After the script completes:

1. Close your current terminal.
2. Open a new terminal to ensure all changes take effect.

### Step 6: Verify Installation

To check if the setup was successful, try running some of these commands:

- `docker --version`
- `kubectl version --client`
- `go version`
- `gh --version`

If these commands return version information, your setup was successful!

### Step 7: Configure GitHub CLI (Optional)

If you plan to use GitHub CLI:

1. Run:

   ```bash
   gh auth login
   ```

2. Follow the prompts to authenticate with your GitHub account.

### Troubleshooting

If you encounter any issues:

1. Check your network connection and also check the terminal output for error messages.
2. Ensure your system meets the prerequisites.
3. Try running the script again.
4. If problems persist, open an issue in this repository with details about the error.

### Next Steps

Now that your DevOps environment is set up, you're ready to start working on projects! Consider exploring:

- Docker containers and Kubernetes clusters
- MLOps Projects
- Go programming
- GitHub Actions for CI/CD
- Python development with Miniconda

Happy coding!

---