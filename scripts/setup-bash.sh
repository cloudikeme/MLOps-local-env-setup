#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -x  # Print commands and their arguments as they are executed

echo "Starting DevOps environment setup script"

# Check if Ansible is installed
if ! command -v ansible &> /dev/null
then
    echo "Ansible is not installed. Installing Ansible..."
    sudo apt update
    sudo apt install -y ansible
fi

echo "Creating temporary Ansible playbook file"

# Create a temporary Ansible playbook file
cat << EOF > /tmp/setup_env.yml
---
- name: Set up DevOps environment
  hosts: localhost
  become: yes

  vars:
    username: "cloudikeme"
    user_uid: "{{ ansible_user_uid }}"
    user_gid: "{{ ansible_user_gid }}"
    git_email: "cloudikeme@gmail.com"
    git_name: "cloudikeme"
    miniconda_version: "latest"
    go_version: "1.22.5"
    kind_version: "v0.23.0"
    kubectl_version: "v1.30.0"

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install required packages
      apt:
        name:
          - sudo
          - curl
          - apt-transport-https
          - ca-certificates
          - gnupg
          - lsb-release
          - zsh
          - git
          - python3
          - python3-pip
          - ffmpeg
          - libsm6
          - libxext6
          - ghostscript
          - python3-tk
          - xvfb
          - libx11-6
          - libxext6
          - libxtst6
          - libxrender1
          - libxft2
          - libxpm4
          - libxmu6
          - libxaw7
          - lsb-release
          - wget
        state: present

    - name: Add user to sudo group
      user:
        name: "{{ username }}"
        groups: sudo
        append: yes

    - name: Allow sudo without password for user
      lineinfile:
        path: /etc/sudoers.d/{{ username }}
        line: "{{ username }} ALL=(ALL) NOPASSWD:ALL"
        create: yes
        mode: 0440

    - name: Configure Git
      become_user: "{{ username }}"
      git_config:
        name: "{{ item.name }}"
        scope: global
        value: "{{ item.value }}"
      loop:
        - { name: 'user.email', value: '{{ git_email }}' }
        - { name: 'user.name', value: '{{ git_name }}' }
        - { name: 'core.autocrlf', value: 'false' }

    - name: Install GitHub CLI
      block:
        - name: Download GitHub CLI GPG key
          get_url:
            url: https://cli.github.com/packages/githubcli-archive-keyring.gpg
            dest: /usr/share/keyrings/githubcli-archive-keyring.gpg
            mode: '0644'

        - name: Add GitHub CLI repository
          apt_repository:
            repo: "deb [arch={{ ansible_architecture }} signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main"
            state: present
            filename: github-cli

        - name: Install GitHub CLI
          apt:
            name: gh
            state: latest
            update_cache: yes

    - name: Set bash as default shell
      user:
        name: "{{ username }}"
        shell: /usr/bin/bash

    - name: Generate en_US.UTF-8 locale
      locale_gen:
        name: en_US.UTF-8
        state: present

    - name: Add Docker GPG key
      apt_key:
        url: https://download.docker.com/linux/ubuntu/gpg
        state: present

    - name: Add Docker repository
      apt_repository:
        repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable
        state: present

    - name: Install Docker
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: latest

    - name: Add user to docker group
      user:
        name: "{{ username }}"
        groups: docker
        append: yes

    - name: Install KinD
      block:
        - name: Download KinD
          get_url:
            url: "https://kind.sigs.k8s.io/dl/{{ kind_version }}/kind-linux-amd64"
            dest: "/usr/local/bin/kind"
            mode: '0755'

    - name: Install kubectl
      get_url:
        url: "https://dl.k8s.io/release/{{ kubectl_version }}/bin/linux/amd64/kubectl"
        dest: /usr/local/bin/kubectl
        mode: '0755'

    - name: Install kubectx and kubens
      get_url:
        url: "https://github.com/ahmetb/kubectx/releases/download/v0.9.5/{{ item }}"
        dest: "/usr/local/bin/{{ item }}"
        mode: '0755'
      loop:
        - kubectx
        - kubens

    - name: Install Miniconda
      become_user: "{{ username }}"
      block:
        - name: Download Miniconda installer
          get_url:
            url: "https://repo.anaconda.com/miniconda/Miniconda3-{{ miniconda_version }}-Linux-x86_64.sh"
            dest: "/tmp/miniconda.sh"
            mode: '0755'
        - name: Install Miniconda
          shell: "/tmp/miniconda.sh -b -p $HOME/miniconda"
          args:
            creates: "$HOME/miniconda"
        - name: Add Miniconda to PATH
          lineinfile:
            path: "/home/{{ username }}/.bashrc"
            line: 'export PATH="$HOME/miniconda/bin:$PATH"'

    - name: Install Go
      block:
        - name: Download Go
          get_url:
            url: "https://golang.org/dl/go{{ go_version }}.linux-amd64.tar.gz"
            dest: "/tmp/go.tar.gz"
        - name: Extract Go
          unarchive:
            src: "/tmp/go.tar.gz"
            dest: "/usr/local"
            remote_src: yes
        - name: Add Go to PATH
          lineinfile:
            path: "/home/{{ username }}/.bashrc"
            line: 'export PATH="$PATH:/usr/local/go/bin"'
        - name: Create Go workspace directories
          file:
            path: "/home/{{ username }}/go/{{ item }}"
            state: directory
            owner: "{{ username }}"
            group: "{{ username }}"
          loop:
            - src
            - pkg
            - bin
        - name: Set GOPATH
          lineinfile:
            path: "/home/{{ username }}/.bashrc"
            line: 'export GOPATH="$HOME/go"'

    - name: Configure bash
      become_user: "{{ username }}"
      blockinfile:
        path: "/home/{{ username }}/.bashrc"
        block: |
          # Ensure /usr/local/bin is in PATH
          'export PATH="$PATH:/usr/local/bin"'

          # Kubectl completion and alias
          if command -v kubectl &> /dev/null; then
            source <(kubectl completion bash)
            alias k="sudo kubectl"
            complete -F __start_kubectl k
          fi
          
          # Git aliases
          alias a="git add ."
          alias s='git commit -m "update"'
          alias d="git push -u origin main"
          alias k="sudo kubectl"

          # Go binaries
          'export PATH="$PATH:/usr/local/go/bin"'
          'export GOPATH="$HOME/go"'
          'export PATH="$PATH:$GOPATH/bin"'

    - name: Ensure .bashrc has correct permissions
      file:
        path: "/home/{{ username }}/.bashrc"
        owner: "{{ username }}"
        group: "{{ username }}"
        mode: '0644'

    - name: Source .bashrc
      become_user: "{{ username }}"
      shell: source /home/{{ username }}/.bashrc
      args:
        executable: /bin/bash

    - name: Restart Docker service
      systemd:
        name: docker
        state: restarted
EOF

echo "Running Ansible playbook"

# Run the Ansible playbook
ansible-playbook /tmp/setup_env.yml --ask-become-pass

echo "Removing temporary playbook file"

# Remove the temporary playbook file
rm /tmp/setup_env.yml

echo "DevOps environment setup complete!"
echo "Please log out and log back in for the environment variables to take effect."