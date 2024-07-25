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
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install required packages
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg
          - lsb-release
          - wget
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

    - name: Install KinD
      get_url:
        url: https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        dest: /usr/local/bin/kind
        mode: '0755'

    - name: Install kubectl
      get_url:
        url: https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl
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

    - name: Download Go tarball
      get_url:
        url: https://go.dev/dl/go1.21.6.linux-amd64.tar.gz
        dest: /tmp/go1.21.6.linux-amd64.tar.gz

    - name: Extract Go tarball
      unarchive:
        src: /tmp/go1.21.6.linux-amd64.tar.gz
        dest: /usr/local
        remote_src: yes

    - name: Set Go environment variables
      lineinfile:
        path: /etc/profile.d/go.sh
        line: "{{ item }}"
        create: yes
      loop:
        - 'export PATH=$PATH:/usr/local/go/bin'
        - 'export GOPATH=$HOME/go'
        - 'export PATH=$PATH:$GOPATH/bin'

    - name: Add current user to docker group
      user:
        name: "{{ ansible_user_id }}"
        groups: docker
        append: yes

    - name: Restart Docker service
      systemd:
        name: docker
        state: restarted
END_PLAYBOOK
)
EOF

echo "Running Ansible playbook"

# Run the Ansible playbook
ansible-playbook /tmp/devops_setup.yml --ask-become-pass

echo "Removing temporary playbook file"

# Remove the temporary playbook file
rm /tmp/devops_setup.yml

echo "DevOps environment setup complete!"
echo "Please log out and log back in for the Go environment variables to take effect."