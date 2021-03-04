FROM ubuntu:18.04

# Install some dependencies via APT
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y software-properties-common python-docopt sudo curl byobu && \
        apt-get install -y python-dev git python-pip python3-minimal 'python2.*-minimal' && \
        apt-get install -y python-docopt nagios-plugins iputils-ping openjdk-8-jre && \
        apt-get install -y gnupg2 python3-pip sshpass openssh-client openssh-server vim && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

# Install ansible via PIP
RUN python3 -m pip install --upgrade pip cffi \
    pip install setuptools && \
    pip install ansible==2.10.3 && \
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

# Ansible working directory
RUN mkdir /home/ubuntu/ansible
COPY docker/ansible.cfg /home/ubuntu/.ansible.cfg
RUN mkdir /home/ubuntu/ansible/la-inventories && \
        mkdir /home/ubuntu/ansible/ala-install
RUN chown ubuntu:ubuntu /home/ubuntu/.ansible.cfg
RUN chown -R ubuntu:ubuntu /home/ubuntu/ansible/
WORKDIR /home/ubuntu/ansible

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

# yeoman, LA generator, sails and related
RUN su - ubuntu -c 'mkdir -p "/home/ubuntu/.npm-packages/lib"'
RUN su - ubuntu -c 'npm config set prefix "/home/ubuntu/.npm-packages"'
RUN su - ubuntu -c 'npm install -g yo'
RUN su - ubuntu -c 'npm install -g generator-living-atlas'
RUN su - ubuntu -c 'npm install -g sails'

# assh install
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/moul/assh.git'
# For non interactive shell cmds
RUN echo 'export GOPATH=$HOME/go' >> /home/ubuntu/.profile
RUN echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> /home/ubuntu/.profile
RUN echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> /home/ubuntu/.bashrc
RUN echo 'alias ssh="assh wrapper ssh --"' >> /home/ubuntu/.bashrc
RUN su -l ubuntu -c 'cd assh; go get -u moul.io/assh/v2'

# ttyd
RUN curl -o /usr/local/bin/ttyd --location --remote-header-name --remote-name https://github.com/tsl0922/ttyd/releases/download/1.6.3/ttyd.x86_64
RUN chmod +x /usr/local/bin/ttyd

# byobu
RUN echo '_byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true' >> /home/ubuntu/.bashrc

# ansible-list-tags (not used by the api right now)
COPY docker/ansible-list-tags /usr/local/bin/ansible-list-tags
RUN chmod +x /usr/local/bin/ansible-list-tags

# server launch script
COPY docker/launch.sh /usr/local/bin/la-toolkit-launch
RUN chmod +x /usr/local/bin/la-toolkit-launch

# base-branding
RUN mkdir -p /home/ubuntu/base-branding
RUN chown -R ubuntu:ubuntu /home/ubuntu/base-branding
RUN echo "2021022401 (change this date to rebuild & repeat this and the following steps)"
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/living-atlases/base-branding.git /home/ubuntu/base-branding'

# ala-install
RUN echo "2020112401 (change this date to rebuild & repeat this and the following steps)"
RUN  su - ubuntu -c 'git clone --depth 1 --branch v2.0.5 https://github.com/AtlasOfLivingAustralia/ala-install.git /home/ubuntu/ansible/ala-install'

# la-toolkit backend
RUN mkdir -p /home/ubuntu/la-toolkit
RUN chown -R ubuntu:ubuntu /home/ubuntu/la-toolkit
RUN echo "2021021804 (change this date to rebuild & repeat this and the following steps)"
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/living-atlases/la-toolkit-backend.git /home/ubuntu/la-toolkit'
RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm install'

# la-toolkit frontend
RUN echo "2021021805 (change this date to rebuild & repeat this and the following steps)"
COPY build/web/ /home/ubuntu/la-toolkit/assets/
COPY assets/.env.production  /home/ubuntu/la-toolkit/assets/assets/env.production.txt
RUN chown -R ubuntu:ubuntu /home/ubuntu/la-toolkit/assets/

# We'll use env variables instead
# RUN echo 'export ANSIBLE_LOG_PATH=/home/ubuntu/ansible.log' >> /home/ubuntu/.bashrc
# RUN echo 'export ANSIBLE_LOG_PATH=/home/ubuntu/ansible.log' >> /home/ubuntu/.profile

# The year of ALA Portal launch ;-)
EXPOSE 2010

# launch the backend
CMD /usr/local/bin/la-toolkit-launch
