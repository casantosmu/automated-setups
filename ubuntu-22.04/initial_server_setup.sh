#!/bin/bash

# Name of the user to create and grant sudo privileges
USERNAME=carlos

# Updates the package list and upgrades installed packages to the latest versions
apt-get update
apt-get upgrade

# Add sudo user and grant privileges
useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"

# Delete password for user
passwd --delete "${USERNAME}"

# Expire the sudo user's password immediately to force a change
chage --lastday 0 "${USERNAME}"

# Copy `autorized_keys` files from root and adjust ownership and permissions
rsync --archive --chown="${USERNAME}":"${USERNAME}" ~/.ssh /home/"${USERNAME}"

# Add exception for SSH and then enable UFW firewall
ufw allow OpenSSH
ufw --force enable

# Update the apt package index and install packages to allow apt to use a repository over HTTPS
apt-get update
apt-get install ca-certificates curl gnupg

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Setup Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the system and its packages
apt-get update

# Install Docker Engine, containerd, and Docker Compose.
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create the docker group
groupadd docker

# Add user to docker group
usermod -aG docker "${USERNAME}"

echo "Initial setup successful. Reboot the system."
