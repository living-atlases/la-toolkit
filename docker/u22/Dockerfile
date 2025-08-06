FROM ubuntu:22.04

# Install some dependencies via APT
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        software-properties-common python3-docopt sudo curl byobu jq rsync \
        python3-dev git python3-pip python3-minimal 'python2.*-minimal' \
        nagios-plugins iputils-ping openjdk-8-jre zip unzip \
        gnupg2 sshpass openssh-client openssh-server vim netcat expect less \
        bash-completion cron-apt python-is-python3 && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

# Install ansible via PIP
RUN python3 -m pip install --upgrade pip cffi
RUN python3 -m pip install setuptools
RUN python3 -m pip install ansible==10.3.0 ansible-core==2.17.3

# Install node via APT
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && \
        DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y nodejs && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

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
RUN echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >> /home/ubuntu/.bashrc
RUN echo 'export PATH="$PATH:$NPM_PACKAGES/bin"' >> /home/ubuntu/.profile
# manpath is not installed
# RUN echo 'export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"' >> /home/ubuntu/.bashrc

# Assh and .ssh directories for ubuntu user
RUN mkdir -p /home/ubuntu/.ssh/assh.d && \
    chmod 0700 /home/ubuntu/.ssh && \
    chmod 0700 /home/ubuntu/.ssh/assh.d && \
    chown ubuntu:ubuntu -R /home/ubuntu/.ssh

# assh install
RUN curl -L -o /tmp/assh.tar.gz -O https://github.com/moul/assh/releases/download/v2.15.0/assh_2.15.0_linux_amd64.tar.gz
RUN cd /tmp/ && tar xfvz assh.tar.gz assh && mv assh /usr/local/bin/
RUN chown root:root /usr/local/bin/assh
RUN echo 'alias ssh="assh wrapper ssh --"' >> /home/ubuntu/.profile
RUN echo 'alias ssh="assh wrapper ssh --"' >> /home/ubuntu/.bashrc

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
RUN su - ubuntu -c 'cd /home/ubuntu/base-branding && git submodule update --init --recursive'

# yeoman, LA generator, sails and related
RUN su - ubuntu -c 'mkdir -p "/home/ubuntu/.npm-packages/lib"'
RUN su - ubuntu -c 'npm config set prefix "/home/ubuntu/.npm-packages"'
RUN su - ubuntu -c 'npm install -g yo@5.1.0'
RUN su - ubuntu -c 'npm install -g sails'
RUN su - ubuntu -c 'npm install -g forever'
RUN su - ubuntu -c 'npm install -g db-migrate'
RUN su - ubuntu -c 'npm install -g db-migrate-mongodb'
RUN echo "2021060901"
RUN su - ubuntu -c 'npm install -g generator-living-atlas'

# base-branding deps
RUN su - ubuntu -c 'cd /home/ubuntu/base-branding && npm install'

# ala-install
RUN su - ubuntu -c 'git clone --branch v2.3.0 https://github.com/AtlasOfLivingAustralia/ala-install.git /home/ubuntu/ansible/ala-install'

# apt.gbif.es LA pipelines and deps
RUN echo "deb [arch=amd64] https://apt.gbif.es/ bionic main" > /etc/apt/sources.list.d/ala.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F697D8D2ADB9E24A

# la-pipelines dependencies (commented right now as we only need to check the la-pipelines available)
# yq
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 && \
#         add-apt-repository ppa:rmescandon/yq && \
#         apt-get -y update && \
#         apt-get install --no-install-recommends -y -q yq && \
#         rm -rf /var/lib/apt/lists/* && \
#         apt-get clean

# docopts
# RUN curl -o /usr/local/bin/docopts -LJO https://github.com/docopt/docopts/releases/download/v0.6.3-rc2/docopts_linux_amd64
# RUN chmod +x /usr/local/bin/docopts
# RUN mkdir -p /data/pipelines-data
# RUN mkdir -p /data/pipelines-shp
# RUN mkdir -p /data/dwca-imports
# # 2021090901
# RUN apt-get -y update && \
#         apt-get install -y -q --no-install-recommends la-pipelines && \
#         rm -rf /var/lib/apt/lists/* && \
#         apt-get clean

# Enable bash autocompletion by default, useful for la-pipelines cmd autocompletion and others
RUN sed -i '/^#.*\. \/etc\/bash_completion/s/^#//' /etc/bash.bashrc
# This part is disabled for disk usage reasons
# RUN curl -o /data/pipelines-shp/pipelines-shapefiles.zip -O https://pipelines-shp.s3-ap-southeast-2.amazonaws.com/pipelines-shapefiles.zip
# RUN (cd /data/pipelines-shp/ && unzip pipelines-shapefiles.zip)
# RUN chown -R ubuntu:ubuntu /data/la-pipelines
# RUN chown -R ubuntu:ubuntu /data/pipelines*
# RUN chown -R ubuntu:ubuntu /data/dwca-imports

# la-toolkit backend
RUN mkdir -p /home/ubuntu/la-toolkit
RUN chown -R ubuntu:ubuntu /home/ubuntu/la-toolkit
RUN echo "1.6.5"
RUN su - ubuntu -c 'git clone --depth 1 https://github.com/living-atlases/la-toolkit-backend.git /home/ubuntu/la-toolkit'
RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm install'

RUN echo "2025072801"
# la-toolkit frontend
RUN curl -L https://github.com/living-atlases/la-toolkit/releases/download/v1.6.5/flutter-web-1.6.5.tgz | tar xfz - -C /home/ubuntu/la-toolkit/assets/ --strip-components=2
# RUN echo "2021032402"
# COPY build/web/ /home/ubuntu/la-toolkit/assets/
COPY assets/env.production.txt  /home/ubuntu/la-toolkit/assets/assets/env.production.txt
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
