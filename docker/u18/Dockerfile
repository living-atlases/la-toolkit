FROM ubuntu:18.04

# Install some dependencies via APT
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y software-properties-common python-docopt sudo curl byobu jq rsync && \
        apt-get install -y python-dev git 'python.*-pip' python3-minimal 'python2.*-minimal' && \
        apt-get install -y python-docopt nagios-plugins iputils-ping openjdk-8-jre && \
        apt-get install -y gnupg2 sshpass openssh-client openssh-server vim netcat expect && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

# Install ansible via PIP
RUN python3 -m pip install --upgrade pip cffi \
    pip install setuptools && \
    pip install ansible==2.10.3 ansible-base==2.10.3 && \
    pip install mitogen ansible-lint

# Install node via APT
RUN curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash - && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

# go install (needed by assh)
# https://golang.org/doc/install
RUN curl -s -O https://dl.google.com/go/go1.15.8.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.15.8.linux-amd64.tar.gz

# CAS utils
RUN curl -o /usr/local/bin/jwk-gen.jar --location --remote-header-name --remote-name https://raw.githubusercontent.com/apereo/cas/master/etc/jwk-gen.jar

# Be use 'ubuntu' user by default, let's create
RUN useradd -ms /bin/bash ubuntu
RUN adduser ubuntu sudo
# This helps ansible to run faster
RUN echo 'Defaults:ubuntu !requiretty' >> /etc/sudoers
# Configure sudo without password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# NPM global configuration for ubuntu
# https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md
RUN echo 'NPM_PACKAGES="/home/ubuntu/.npm-packages"' >> /home/ubuntu/.bashrc
RUN echo 'NPM_PACKAGES="/home/ubuntu/.npm-packages"' >> /home/ubuntu/.profile
RUN echo 'export PATH="$PATH:$NPM_PACKAGES/bin:/usr/local/go/bin"' >> /home/ubuntu/.bashrc
RUN echo 'export PATH="$PATH:$NPM_PACKAGES/bin:/usr/local/go/bin"' >> /home/ubuntu/.profile
# manpath is not installed
# RUN echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >> /home/ubuntu/.bashrc

# Assh and .ssh directories for ubuntu user
RUN mkdir -p /home/ubuntu/.ssh/assh.d && \
    chmod 0700 /home/ubuntu/.ssh && \
    chmod 0700 /home/ubuntu/.ssh/assh.d && \
    chown ubuntu:ubuntu -R /home/ubuntu/.ssh

# assh install
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/moul/assh.git'
# For non interactive shell cmds
RUN echo 'export GOPATH=$HOME/go' >> /home/ubuntu/.profile
RUN echo 'export GOPATH=$HOME/go' >> /home/ubuntu/.bashrc
RUN echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> /home/ubuntu/.profile
RUN echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> /home/ubuntu/.bashrc
RUN echo 'alias ssh="assh wrapper ssh --"' >> /home/ubuntu/.profile
RUN echo 'alias ssh="assh wrapper ssh --"' >> /home/ubuntu/.bashrc
RUN su -l ubuntu -c 'cd assh; go get -u moul.io/assh/v2'

# ttyd
RUN curl -o /usr/local/bin/ttyd --location --remote-header-name --remote-name https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64
RUN chmod +x /usr/local/bin/ttyd

# byobu
RUN echo '_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true' >> /home/ubuntu/.bashrc
RUN mkdir /home/ubuntu/.byobu
RUN echo 'set -g prefix F12\nunbind-key -n C-a\n' > /home/ubuntu/.byobu/keybindings.tmux
RUN chown ubuntu:ubuntu -R /home/ubuntu/.byobu

# ansible-list-tags (not used by the api right now)
COPY docker/ansible-list-tags /usr/local/bin/ansible-list-tags
RUN chmod +x /usr/local/bin/ansible-list-tags

# Ansible working directory
RUN mkdir /home/ubuntu/ansible
COPY docker/ansible.cfg /home/ubuntu/.ansible.cfg
RUN mkdir /home/ubuntu/ansible/la-inventories && \
        mkdir /home/ubuntu/ansible/ala-install && \
        mkdir /home/ubuntu/ansible-callbacks && \
        mkdir /home/ubuntu/ansible/logs
COPY docker/json-ansible-callback.py /home/ubuntu/ansible-callbacks/json-ansible-callback.py
COPY docker/logs-colorized-ansible-callback.py /home/ubuntu/ansible-callbacks/logs-colorized-ansible-callback.py
RUN chown ubuntu:ubuntu /home/ubuntu/.ansible.cfg
RUN chown -R ubuntu:ubuntu /home/ubuntu/ansible/
RUN chown -R ubuntu:ubuntu /home/ubuntu/ansible-callbacks
RUN chown -R ubuntu:ubuntu /home/ubuntu/ansible/logs
WORKDIR /home/ubuntu/ansible

# base-branding
RUN mkdir -p /home/ubuntu/base-branding
RUN chown -R ubuntu:ubuntu /home/ubuntu/base-branding
RUN echo "2021090201 (change this date to rebuild & repeat this and the following steps)"
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/living-atlases/base-branding.git /home/ubuntu/base-branding'

# yeoman, LA generator, sails and related
RUN su - ubuntu -c 'mkdir -p "/home/ubuntu/.npm-packages/lib"'
RUN su - ubuntu -c 'npm config set prefix "/home/ubuntu/.npm-packages"'
RUN su - ubuntu -c 'npm install -g yo'
RUN su - ubuntu -c 'npm install -g yarn'
RUN su - ubuntu -c 'npm install -g brunch'
RUN su - ubuntu -c 'npm install -g sails'
RUN su - ubuntu -c 'npm install -g forever'
RUN su - ubuntu -c 'npm install -g db-migrate'
RUN su - ubuntu -c 'npm install -g db-migrate-mongodb'
RUN echo "2021060901"
RUN su - ubuntu -c 'npm install -g generator-living-atlas'

# ala-install
RUN echo "2021032402 (change this date to rebuild & repeat this and the following steps)"
RUN su - ubuntu -c 'git clone --branch v2.0.10 https://github.com/AtlasOfLivingAustralia/ala-install.git /home/ubuntu/ansible/ala-install'

# la-toolkit backend
RUN mkdir -p /home/ubuntu/la-toolkit
RUN chown -R ubuntu:ubuntu /home/ubuntu/la-toolkit
RUN echo "1.2.1"
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/living-atlases/la-toolkit-backend.git /home/ubuntu/la-toolkit'
RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm install'

# la-toolkit frontend
RUN curl -L https://github.com/living-atlases/la-toolkit/releases/download/v1.2.1/flutter-web-1.2.1.tgz | tar xfz - -C /home/ubuntu/la-toolkit/assets/ --strip-components=2
# RUN echo "2021032402"
# COPY build/web/ /home/ubuntu/la-toolkit/assets/
COPY assets/.env.production  /home/ubuntu/la-toolkit/assets/assets/env.production.txt
RUN chown -R ubuntu:ubuntu /home/ubuntu/la-toolkit/assets/

# bash command with echo to show to the users
COPY docker/echo-bash.sh /usr/local/bin/echo-bash
RUN chmod +x /usr/local/bin/echo-bash
# copy nagios check_by_ssh (modified version without local host/IP check relaying on ssh config)
# https://github.com/living-atlases/nagios-plugins
COPY docker/check_by_ssh /usr/local/bin/check_by_ssh
RUN chmod +x /usr/local/bin/check_by_ssh

# server launch script
COPY docker/launch.sh /usr/local/bin/la-toolkit-launch
RUN chmod +x /usr/local/bin/la-toolkit-launch

# The year of ALA Portal launch ;-)
EXPOSE 2010

# Used by ttyd
EXPOSE 2011

USER ubuntu

VOLUME ["/home/ubuntu/.ssh/"]
VOLUME ["/home/ubuntu/ansible/logs/"]
VOLUME ["/home/ubuntu/ansible/la-inventories/"]
VOLUME ["/home/ubuntu/ansible/ala-install/"]

# launch the backend
CMD /usr/local/bin/la-toolkit-launch
