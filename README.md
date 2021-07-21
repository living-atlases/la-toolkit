# Living Atlases Toolkit

_Under development tool_

* [Introduction](#introduction)
   * [How ?](#how-)
   * [Demo](#demo)
   * [How the code is organized](#how-the-code-is-organized)
* [Prerequisites](#prerequisites)
   * [Docker](#docker)
   * [Docker compose](#docker-compose)
   * [Data directories](#data-directories)
* [Running the la-toolkit](#running-the-la-toolkit)
   * [Using docker-compose](#using-docker-compose)
   * [Running the la-toolkit in an external server.](#running-the-la-toolkit-in-an-external-server)
* [Upgrade the toolkit](#upgrade-the-toolkit)
   * [Notes to upgrade to 1.1.X](#notes-to-upgrade-to-11X)
* [Logs and debugging](#logs-and-debugging)
* [Development](#development)
   * [Using flutter web](#using-flutter-web)
   * [Autogeneration of code](#autogeneration-of-code)
   * [Backend during development](#backend-during-development)
   * [Flutter build](#flutter-build)
   * [Ubuntu 20 vs Ubuntu 18](#ubuntu-20-vs-ubuntu-18)
   * [Docker image build](#docker-image-build)
* [Developed so far and Roadmap](#developed-so-far-and-roadmap)
* [Screenshots](#screenshots)
   * [Loading:](#loading)
   * [Intro page:](#intro-page)
   * [Intro continuation:](#intro-continuation)
   * [List of created projects:](#list-of-created-projects)
   * [Project Tools:](#project-tools)
   * [Editing the project:](#editing-the-project)
   * [Service definition:](#service-definition)
   * [Theme selection:](#theme-selection)
   * [Services in servers:](#services-in-servers)
   * [Servers connectivity:](#servers-connectivity)
   * [Project tunning:](#project-tunning)
   * [Project drawer with links to each service and admin interfaces:](#project-drawer-with-links-to-each-service-and-admin-interfaces)
   * [SSH keys administration:](#ssh-keys-administration)
   * [SSH Gateways configuration:](#ssh-gateways-configuration)
   * [Project configuration lint warnings](#project-configuration-lint-warnings)
   * [Testing connectivity with the project servers:](#testing-connectivity-with-the-project-servers)
   * [Deployment:](#deployment)
   * [Deployment Ansible terminal:](#deployment-ansible-terminal)
   * [Deployment results (success):](#deployment-results-success)
   * [Deployment results (failed):](#deployment-results-failed)
   * [History of deployments with repeat function](#history-of-deployments-with-repeat-function)
   * [Console for the intrepids:](#console-for-the-intrepids)
* [License](#license)
   * [Others](#others)

## Introduction

This tool facilitates the installation, maintenance and monitor of Living Atlases portals.

### How ?

A Living Atlas (LA) can be deployed and maintained using:

1) the [Atlas of Living Australia](https://ala.org.au/) (ALA) Free and Open Source Software, with
2) the [ala-install](https://github.com/AtlasOfLivingAustralia/ala-install/), the official [ansible](https://www.ansible.com/) code that automatically deploy and maintain a Living Atlas (LA) portal
3) some configuration that describes your LA portal that is used by ala-install

This LA Toolkit puts all these parts together with an user friendly interface, and an up-to-date environment to perform the common maintenance tasks of a LA portal.

### Demo

There is a non-functional demo of this tool in:

http://toolkit-demo.l-a.site/

this demo is not functional because is only the UI frontend and does not configure any server or portal. It's just for demostration purposes. You can have a look there and create some sample project to see how this tool works.

### How the code is organized 

This repository is a the frontend of the LA Toolkit. It uses [this repo](https://github.com/living-atlases/la-toolkit-backend) as backend and both components are packaged together in a docker image with all the dependencies to deploy and maintain a LA Portal. It's also uses the [ala-install](https://github.com/AtlasOfLivingAustralia/ala-install/) and the [LA Ansible Inventories Generator](https://github.com/living-atlases/generator-living-atlas).

## Prerequisites

### Docker 

To run the `la-toolkit` you need to [install docker](https://docs.docker.com/engine/install/) in the computer you want to use to deploy your LA Portal (like your laptop, or similar computer). 

### Docker compose

Optionally you'll need the [Docker Compose](https://docs.docker.com/compose/install/).

### Data directories

Your will need also some directories to store your config, logs and ssh configuration. In GNU/Linux you can use:

```
mkdir -p /data/la-toolkit/config/ /data/la-toolkit/logs/ /data/la-toolkit/ssh/ /data/la-toolkit/mongo /data/la-toolkit/backups
      
``` 
or similar to create it.  Something like:

```
/data/la-toolkit
         ├── config
         ├── logs
         ├── mongo
         ├── backups
         └── ssh 
```

If you use a different directory, you'll have to update the `docker-compose.yml` files accordinly.

This directories should be writable by your user and docker.

## Running the la-toolkit

### Using docker-compose

```
./dockerTask.sh compose
```

or directly:

```
docker-compose up -d
```

This will start three containers (la-toolkit, la-toolkit-mongo and la-toolkit-watchtower). You can see it with `docker ps`. Verify that they start correctly.

Open the toolkit in http://localhost:2010/

Run `./dockerTask.sh` for more options (like how to run a development environment).

In Windows, try `dockerTask.ps1` (feedback welcome).

### Running the la-toolkit in an external server.

You can run the la-toolkit in another server and redirect the ports via ssh like:

```
 ssh -L 2010:127.0.0.1:2010 -L 2011:127.0.0.1:2011 -L 2012:127.0.0.1:2012 yourUser@yourRemoteServer -N -f
```

Currently we use a range of ports for the terms (2011-2100), so depending on the number of users using this instance of the la-toolkit you'll [need more port redirections](https://unix.stackexchange.com/a/589259).

## Upgrade the toolkit

Get the latest version of the la-toolkit with:

```
./dockerTask.sh update
```

or :

```
docker-compose kill
docker-compose rm -f
docker-compose pull 
docker-compose up -d
```

TODO: Add the update task to the Windows script.

### Notes to upgrade to 1.1.X

- Copy the new `docker-compose.yml` as it includes new images and configurations
- Move your data to `/data/la-toolkit` and create an additional `/data/la-toolkit/mongo/`. If you want to use a different directories edit your `docker-compose.yml` volumes accordingly. You can also use symlinks.
- Change the mongo db user/passwords before start the container.
- A migration of your projects json configuration to mongo should be done at startup. Please verify that the `la-toolkit` start correctly. If not see the "Logs and debugging" section above.

## Migrate your old inventories to the toolkit 

If you were using other generated inventories, you can import it using the (+) button with some addiotional steps:
- Tune your imported project in the Edit and Tune tools. For instance, add your servers IPs, etc. See that there is a "Advanced" mode. There you can copy in the bottom text area your inventory local-extras.
- After enter in the Deploy Tool, some new inventories will be generated (and also a new password file). Substitute that generated local-password with your old one that you are using, to restore your passwords and not using new ones.

## Logs and debugging

Startup errors can be debuged running `docker-compose` without `-d`:

```
docker-compose -f ./docker-compose.yml up 
```

Runtime server errors during the use of the la-toolkit can be debugged looking the logs with:

```
docker logs la-toolkit
```

If the `la-toolkit` restart continuosly durint development, it can be debugged with:
```
docker run -it --network=la-toolkit_default --entrypoint /bin/bash  livingatlases/la-toolkit:latest -s
```

In some cases the [browser devtools console](https://developer.chrome.com/docs/devtools/open/) can show some info about browser code errors. 

Please [fill an issue](https://developer.chrome.com/docs/devtools/open/) with this information if you encounter some problem.

## Development

This frontend is developed using Flutter Web.

A few resources to get you started if your are new to Flutter:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Flutter Web support](https://flutter.dev/web)

### Using flutter web

https://flutter.dev/docs/get-started/web
```
$ flutter channel stable
$ flutter upgrade
```

### Autogeneration of code

There are some code (like the json serialization) that should be generated when some model changes. This is done with:
```
flutter pub run build_runner watch --delete-conflicting-outputs
``` 
### Backend during development

During development you'll need to have running [the backend](https://github.com/living-atlases/la-toolkit-backend) and also a docker container of the la-toolkit (with this name).
 
### Flutter build

We need to have the frontend build prior to build the docker image:

```
flutter test && flutter build web
```

### Ubuntu 20 vs Ubuntu 18

Right now there are two images based in Ubuntu 20.04 and 18.04 respectively. We have tested more u18 as deployment environment, but we are tryng to start using u20. So if you have some ansible issue during deploying (like python2/ptython3 issues), try 18.04 instead.

### Docker image build

You will need to build the flutter web as described below prior to build a `la-toolkit` image.

```
docker build . -f ./docker/u18/Dockerfile -t la-toolkit # for ubuntu 18.04
docker build . -f ./docker/u20/Dockerfile -t la-toolkit/u20 # for ubuntu 20.04 (testing right now)
```

## Developed so far and Roadmap

- [X] Basic configuration of LA Portals
- [X] Tunning of LA configurations with advanced mode
- [X] Software compatibility and other project checks and recommendations
- [X] Branding theme selection
- [X] Helper for configuration of ssh
- [X] Connectivity and other servers checks
- [X] Generation and update of inventories
- [X] CAS additional tasks (like keys generation)
- [X] Map helper to configure collections, spatial and regions homepages
- [X] Ansible deployment of portals
- [X] Inline help and descriptive commands that are executed for educational purposes
- [X] Terminal with deployment environment
- [X] Ansible use stats (number of tasks executed with success or failed,...)
- [X] Import of previous inventories
- [X] Template projects of existing LA Portals
- [X] Logs store and replay previous deploy tasks
- [X] Ansible task errors summary
- [X] Software dependencies release checking and notification of available upgrades
- [X] Pre-deploy tasks (wip)
- [X] Portal status tool
- [X] Branding deployment
- [X] Post-deploy tasks
- [ ] Support additional hubs configuration
- [ ] SSL support via letsencrypt (work in progress)
- [ ] LA pipelines support
- [ ] Services redundancy
- [ ] Improve ssh keys management

## Screenshots

### Loading:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s1.png)

### Intro page:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s2.png)

### Intro continuation:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s3.png)

### List of created projects:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s4.png)

### Project Tools:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s5.png)

### Editing the project:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s6.png)

### Service definition:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s7.png)

### Theme selection:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s15.png)

### Services in servers:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s8.png)

### Servers connectivity:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s9.png)

### Project tunning:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s10.png)

### Project drawer with links to each service and admin interfaces:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s11.png)

### SSH keys administration:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s12.png)

### SSH Gateways configuration:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s22.png)

### Project configuration lint warnings

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s12.png)

### Testing connectivity with the project servers:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s13.png)

### Deployment:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s16.png)

### Deployment Ansible terminal:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s17.png)

### Deployment results (success):

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s19.png)

### Deployment results (failed):

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s18.png)

### History of deployments with repeat function 

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s20.png)

### Software upgrade checks

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s23.png)

### Console for the intrepids:

![](https://raw.github.com/living-atlases/la-toolkit/master/screenshots/s14.png)


## License

MPL © [Living Atlases](https://living-atlases.gbif.org)

### Others

- `check_by_ssh` from https://github.com/nagios-plugins/nagios-plugins/ under GNU License
