# The frontend and the MCP server are built from this checkout and the backend
# is cloned at BACKEND_REF, so build the image from the commit or tag it is for.
# Jenkinsfile builds it; the *-test targets run the suites in the same toolchains.

# The MCP server (packages/la_toolkit_mcp): an AOT binary with no runtime
# dependencies.
FROM dart:3.11.5 AS mcp
WORKDIR /src
COPY packages/la_toolkit_core packages/la_toolkit_core
COPY packages/la_toolkit_mcp packages/la_toolkit_mcp
WORKDIR /src/packages/la_toolkit_mcp
RUN dart pub get --enforce-lockfile && \
        dart compile exe bin/la_toolkit_mcp.dart -o /la_toolkit_mcp

FROM mcp AS mcp-test
# The core suite reads the sample projects from the app's assets.
COPY assets/la-toolkit-templates.json /src/assets/la-toolkit-templates.json
WORKDIR /src/packages/la_toolkit_core
RUN dart pub get --enforce-lockfile && dart analyze && dart test
WORKDIR /src/packages/la_toolkit_mcp
RUN dart analyze && dart test

# The Flutter web frontend, served by the backend from its assets/ directory.
FROM ghcr.io/cirruslabs/flutter:3.41.9 AS web
WORKDIR /src
COPY packages/la_toolkit_core packages/la_toolkit_core
COPY pubspec.yaml pubspec.lock analysis_options.yaml ./
RUN flutter pub get --enforce-lockfile
COPY lib lib
COPY web web
COPY assets assets
COPY fonts fonts
COPY env.development.txt env.production.txt env.production-demo.txt ./
RUN flutter build web --no-tree-shake-icons --release --source-maps

FROM web AS web-test
COPY test test
# demo_mode_test checks that the demo target below swaps in the demo env.
COPY docker/u22/Dockerfile docker/u22/Dockerfile
RUN flutter analyze && flutter test

# The backend-less demo (toolkit-demo.l-a.site): the same web build with the
# bundled env swapped for the demo one. main.dart loads env.production.txt in
# release builds; the assets/ copy is swapped too so both bundled envs agree.
# Export it with --output type=local (docker/ci/publish-demo.sh publishes it).
FROM web AS demo-build
RUN cp assets/env.production-demo.txt build/web/assets/env.production.txt && \
        cp assets/env.production-demo.txt build/web/assets/assets/env.production.txt && \
        grep -q '^DEMO=true' build/web/assets/env.production.txt && \
        grep -q '^DEMO=true' build/web/assets/assets/env.production.txt

FROM scratch AS demo
COPY --from=demo-build /src/build/web/ /

FROM ubuntu:22.04

# Install some dependencies via APT. ca-certificates is listed so that a rebuild
# after a CA distrust (eMudhra, 2026-10-17) always gets the fixed package; the
# check at the end of this stage fails the build otherwise.
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install -y \
        ca-certificates software-properties-common python3-docopt sudo curl byobu jq rsync \
        python3-dev git python3-pip python3-minimal 'python2.*-minimal' \
        nagios-plugins iputils-ping openjdk-8-jre zip unzip \
        gnupg2 sshpass openssh-client openssh-server vim netcat expect less \
        bash-completion cron-apt python-is-python3 && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

# Docker CLI + buildx for the fast deploy (la-docker-compose scripts/bundle/render.sh renders
# each docker-compose host in a throwaway container). It talks to the host's daemon through
# /var/run/docker.sock, mounted in docker-compose.yml. No daemon in here.
RUN install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu jammy stable" \
          > /etc/apt/sources.list.d/docker.list && \
        DEBIAN_FRONTEND=noninteractive apt-get update && \
        DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y docker-ce-cli docker-buildx-plugin && \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

# Install ansible via PIP
RUN python3 -m pip install --upgrade pip cffi
RUN python3 -m pip install setuptools
RUN python3 -m pip install ansible==10.3.0 ansible-core==2.17.3

# Install node via APT
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
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
RUN curl -L -o /tmp/assh.tar.gz -O https://github.com/moul/assh/releases/download/v2.16.0/assh_2.16.0_linux_amd64.tar.gz
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
RUN su - ubuntu -c 'npm install -g migrate-mongo'
RUN echo "2021060901"
RUN su - ubuntu -c 'npm install -g generator-living-atlas'

# base-branding deps
RUN su - ubuntu -c 'cd /home/ubuntu/base-branding && npm install'

# ala-install
RUN su - ubuntu -c 'git clone --branch v2.4.1 https://github.com/AtlasOfLivingAustralia/ala-install.git /home/ubuntu/ansible/ala-install'

# la-docker-compose (checked out/updated at deploy time by docker-compose-select)
RUN su - ubuntu -c 'git clone --recurse-submodules https://github.com/living-atlases/la-docker-compose.git /home/ubuntu/ansible/la-docker-compose'

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
# BACKEND_REF is a branch or tag of la-toolkit-backend; BACKEND_SHA, when given,
# is the commit it must resolve to. A new SHA also invalidates this layer, so an
# image never ships a cached older backend.
ARG BACKEND_REF=master
ARG BACKEND_SHA=
RUN sudo -u ubuntu -H git clone --depth 1 --branch "${BACKEND_REF}" \
          https://github.com/living-atlases/la-toolkit-backend.git /home/ubuntu/la-toolkit && \
        if [ -n "${BACKEND_SHA}" ]; then \
          test "$(sudo -u ubuntu git -C /home/ubuntu/la-toolkit rev-parse HEAD)" = "${BACKEND_SHA}" || \
            { echo "backend ${BACKEND_REF} is not at ${BACKEND_SHA}" >&2; exit 1; }; \
        fi
RUN su - ubuntu -c 'cd /home/ubuntu/la-toolkit && npm install'

# la-toolkit frontend
COPY --from=web /src/build/web/ /home/ubuntu/la-toolkit/assets/
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
# Agents reach it with: docker exec -i la-toolkit la_toolkit_mcp
# (stdio; its default backend, localhost:2010, is this container's). Backups of
# the projects it changes go to the logs volume, so they outlive the container.
COPY --from=mcp /la_toolkit_mcp /usr/local/bin/la_toolkit_mcp
ENV LA_TOOLKIT_MCP_BACKUP_DIR=/home/ubuntu/ansible/logs/mcp-backups

# The year of ALA Portal launch ;-)
EXPOSE 2010

# Used by ttyd
EXPOSE 2011

# No trust store in the image may keep a distrusted root (system bundle, Java
# cacerts, certifi, Node).
COPY docker/u22/ca-distrust-check.sh /usr/local/bin/ca-distrust-check
RUN /usr/local/bin/ca-distrust-check

USER ubuntu

VOLUME ["/home/ubuntu/.ssh/"]
VOLUME ["/home/ubuntu/ansible/logs/"]
VOLUME ["/home/ubuntu/ansible/la-inventories/"]
VOLUME ["/home/ubuntu/ansible/ala-install/"]
VOLUME ["/home/ubuntu/ansible/la-docker-compose/"]

# launch the backend
CMD /usr/local/bin/la-toolkit-launch
