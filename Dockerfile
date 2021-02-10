FROM ubuntu:18.04

# Install some dependencies via APT

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        apt-get install -y software-properties-common python-docopt sudo curl && \
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

# go install
# https://golang.org/doc/install
RUN curl -s -O https://dl.google.com/go/go1.15.8.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.15.8.linux-amd64.tar.gz

# CAS utils

RUN curl -o /usr/local/bin/jwk-gen.jar --location --remote-header-name --remote-name https://raw.githubusercontent.com/apereo/cas/master/etc/jwk-gen.jar

# https://docs.docker.com/engine/examples/running_ssh_service/
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN mkdir -p /root/.ssh/config.d && \
    chmod 0700 /root/.ssh

# Generate a ssh key to use internally
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa
RUN echo "include config.d/*" > /root/.ssh/config

# Be use 'ubuntu' user by default, let's create
RUN useradd -ms /bin/bash ubuntu
RUN adduser ubuntu sudo
# This helps ansible to run faster
RUN echo 'Defaults:ubuntu !requiretty' >> /etc/sudoers
# Configure sudo without password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Ansible working directory

RUN mkdir /home/ubuntu/ansible
COPY ansible.cfg /home/ubuntu/.ansible.cfg
RUN mkdir /home/ubuntu/ansible/la-inventories && \
        mkdir /home/ubuntu/ansible/ala-install
WORKDIR /home/ubuntu/ansible

# NPM global configuration for ubuntu
# https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md

RUN echo 'NPM_PACKAGES="/home/ubuntu/.npm-packages"' >> /home/ubuntu/.bashrc
RUN echo 'export PATH="$PATH:$NPM_PACKAGES/bin:/usr/local/go/bin"' >> /home/ubuntu/.bashrc
# manpath is not installed
# RUN echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >> /home/ubuntu/.bashrc

# Authorize generated ssh key to ubuntu user
RUN mkdir -p /home/ubuntu/.ssh/assh.d && \
    chmod 0700 /home/ubuntu/.ssh && \
    chmod 0700 /home/ubuntu/.ssh/assh.d && \
    cp /root/.ssh/id_rsa.pub /home/ubuntu/.ssh/authorized_keys && \
    chown ubuntu:ubuntu -R /home/ubuntu/.ssh

# yeoman, LA generator and related
RUN su - ubuntu -c 'mkdir -p "/home/ubuntu/.npm-packages/lib"'
RUN su - ubuntu -c 'npm config set prefix "/home/ubuntu/.npm-packages"'
RUN su - ubuntu -c 'npm install -g yo'
RUN su - ubuntu -c 'npm install -g generator-living-atlas'
RUN su - ubuntu -c 'npm install -g pm2'
RUN su - ubuntu -c 'mkdir -p .config/insight-nodejs/'
RUN su - ubuntu -c 'echo "{\"optOut\": true}" > .config/insight-nodejs/insight-yo.json'

# Not necessary right now
# EXPOSE 22

RUN echo "2020112401 (change this date to rebuild & repeat this and the following steps)"

RUN git clone --depth 1 --branch v2.0.5 https://github.com/AtlasOfLivingAustralia/ala-install.git /home/ubuntu/ansible/ala-install

# assh install
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/moul/assh.git'
# For non interactive shell cmds
RUN echo 'export GOPATH=$HOME/go' >> /home/ubuntu/.profile
RUN echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> /home/ubuntu/.profile
RUN echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> /home/ubuntu/.bashrc
RUN echo 'alias ssh="assh wrapper ssh --"' >> /home/ubuntu/.bashrc
RUN su -l ubuntu -c 'cd assh; go get -u moul.io/assh/v2'

# https://github.com/moul/assh/#configuration
# We should build .ssh/assh.yml

# RUN mkdir -p /home/ubuntu/la-toolkit
# COPY . /home/ubuntu/la-toolkit
# RUN chown -R ubuntu:ubuntu /home/ubuntu/la-toolkit /home/ubuntu/.ansible.cfg
#> RUN su - ubuntu -c 'git clone --depth 1 https://github.com/living-atlases/la-toolkit.git /home/ubuntu/la-toolkit'
#> RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm install'
#> RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm run build'
#> RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm ci --prod'

# git clone

#> COPY run.sh /usr/local/bin/la-toolkit-launch

#> EXPOSE 2010

CMD ["/usr/sbin/sshd", "-D"]

#> CMD /usr/local/bin/la-toolkit-launch
