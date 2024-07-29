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
cat << EOF > /tmp/devops_setup.yml
$(cat << 'END_PLAYBOOK'
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
    docker_slim_version: "latest"
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

    - name: Add user to sudo and docker groups
      user:
        name: "{{ username }}"
        groups: sudo,docker
        append: yes

    - name: Allow sudo without password for user
      lineinfile:
        path: /etc/sudoers.d/{{ username }}
        line: "{{ username }} ALL=(ALL) NOPASSWD:ALL"
        create: yes
        mode: 0440

    - name: Install Oh My Zsh
      become_user: "{{ username }}"
      shell: sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
      args:
        creates: "/home/{{ username }}/.oh-my-zsh"

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

    - name: Set Zsh as default shell
      user:
        name: "{{ username }}"
        shell: /usr/bin/zsh

    - name: Install Docker
      block:
        - name: Add Docker GPG key
          apt_key:
            url: https://download.docker.com/linux/ubuntu/gpg
            state: present
        - name: Add Docker repository
          apt_repository:
            repo: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable
            state: present
        - name: Install Docker packages
          apt:
            name:
              - docker-ce
              - docker-ce-cli
              - containerd.io
            state: latest

    - name: Install Kubernetes tools
      block:
        - name: Install KinD
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

    - name: Install development tools
      block:
        - name: Install Miniconda
          become_user: "{{ username }}"
          shell: |
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
            bash /tmp/miniconda.sh -b -p $HOME/miniconda
            echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> $HOME/.zshrc
            $HOME/miniconda/bin/conda init zsh
          args:
            creates: "$HOME/miniconda"
        - name: Install Go
          unarchive:
            src: "https://golang.org/dl/go{{ go_version }}.linux-amd64.tar.gz"
            dest: "/usr/local"
            remote_src: yes
        - name: Set Go environment variables
          lineinfile:
            path: "/home/{{ username }}/.zshrc"
            line: "{{ item }}"
          loop:
            - 'export PATH=$PATH:/usr/local/go/bin'
            - 'export GOPATH=$HOME/go'
        - name: Install docker-slim
          unarchive:
            src: "https://downloads.dockerslim.com/releases/{{ docker_slim_version }}/dist_linux.tar.gz"
            dest: "/usr/local/bin"
            remote_src: yes
            extra_opts: [--strip-components=1]

    - name: Configure Zsh
      become_user: "{{ username }}"
      blockinfile:
        path: "/home/{{ username }}/.zshrc"
        block: |
          source <(kubectl completion zsh)
          alias k=kubectl
          complete -F __start_kubectl k
          source <(kind completion zsh)

    - name: Restart Docker service
      systemd:
        name: docker
        state: restarted
EOF

echo "Running Ansible playbook"

# Run the Ansible playbook
ansible-playbook /tmp/devdev_setup.yml --ask-become-pass

echo "Removing temporary playbook file"
rm /tmp/devdev_setup.yml

echo "DevOps environment setup complete!"
echo "Please restart your shell or run 'source ~/.zshrc' for the changes to take effect."