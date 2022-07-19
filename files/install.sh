#!/usr/bin/env bash

# Date of Build
echo "Built at" $(date) > /etc/built_at

cd /install
# File locations
chmod a+x 01worksuite.boot.sh
mv 01worksuite.boot.sh /boot.d/

# Anwendungen
apt-get update
apt-get install -y \
    openssh-server \
    git git-crypt \
    zsh \
    tmux \
    dialog \
    apt-utils \
    sudo \
    traceroute \
    iputils-ping \
    dnsutils

# Konfiguration
useradd -ms /bin/bash ubuntu
adduser ubuntu sudo

# SSH Konfiguration
mkdir /var/run/sshd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/'                   /etc/ssh/sshd_config
sed -i 's/PermitRootLogin PermitRootLogin prohibit-password/PermitRootLogin yes/'  /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
chsh -s $( which zsh )
sh -c "$( curl -fsSL "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" )"
# exit 0

# Ansible
pip3 install --upgrade pip
pip install python3-keyczar
ln -s /usr/bin/python3 /usr/bin/python
mkdir /etc/ansible/
echo '[local]\nlocalhost\n' > /etc/ansible/hosts
pip3 install ansible

# Specific User stuff
sudo -u ubuntu echo xfce4-session > /home/ubuntu/.xsession
sudo -u ubuntu chsh -s $( which zsh )
sudo -u ubuntu sh -c "$( curl -fsSL "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" )"
