# la_toolkit

Living Atlases Toolkit - Frontend

## Introduction

This is a the frontend of the LA Toolkit. It uses [this repo](https://github.com/living-atlases/la-toolkit-backend) as backend and both components are packaged together in a docker image with all the dependencies to deploy and maintain a LA Portal.

## Docker 

To run the `la-toolkit` you need to [install docker](https://docs.docker.com/engine/install/) in the computer you want to use to deploy your LA Portal (like your laptop, or similar computer).

### LA-Toolkit Image 

Download it from Docker Hub via:

```
docker pull livingatlases/la-toolkit:latest
```

you can also build yourself the images (see the Development section).

### Run the LA-Toolkit docker image

Run the image exposing the port `2010` that is were the la-toolkit web interface is listen to,  the `2011` port, used by interactive terminal commands, and configuring the volumes for:

- your ssh keys
- your inventories and configuration
- your logs

So create this directories or reuse existing ones and run:

```
docker run --rm \
   -v PUT_YOUR_SSH_KEYS_DIRECTORY_HERE:/home/ubuntu/.ssh/ \
   -v PUT_YOUR_CONFIG_DIRECTORY_HERE:/home/ubuntu/ansible/la-inventories \
   -v PUT_YOUR_LOGS_DIRECTORY_HERE:/home/ubuntu/ansible/logs \
   -t -d --name la-toolkit -h la-toolkit -p 2010:2010 -p 2011:2011 la-toolkit:latest
```

During development some test directory like `/var/tmp/la-toolkit/.ssh/`.

Optionally you can mount a different `ala-install` repository (for instance a modified one):

```
   (...)
   -v PUT_YOUR_ALA_INSTALL_DIRECTORY_HERE/:/home/ubuntu/ansible/ala-install/ \
   (...)
```
In this case, use `custom` in the ala-install releases version dropdown.

To start using the LA Toolkit visit:
http://localhost:2010/

Stop it with:
```
docker stop la-toolkit
```
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

### Flutter build

We need to have the frontend build prior to build the docker image:

```
flutter test && flutter build web
```

While we finish the null safety migration we have to use:
```
flutter build web --no-sound-null-safety 
```

### Docker image build

You will need to build the flutter web as described below prior to build a `la-toolkit` image.

```
docker build . -f ./docker/u18/Dockerfile -t la-toolkit # for ubuntu 18.04
docker build . -f ./docker/u20/Dockerfile -t la-toolkit/u20 # for ubuntu 20.04 (testing right now)
```

## Screenshots

Loading:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s1.png)

Intro page:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s2.png)

Intro continuation:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s3.png)

List of created projects:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s4.png)

Project Tools:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s5.png)

Editing the project:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s6.png)

Service definition:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s7.png)

Theme selection:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s15.png)

Services in servers:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s8.png)

Servers connectivity:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s9.png)

Project tunning:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s10.png)

Project drawer with links to each service and admin interfaces:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s11.png)

SSH keys administration:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s12.png)

Testing connectivity with the project servers:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s13.png)

Deployment:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s16.png)

Deployment Ansible terminal:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s17.png)

Deployment results (success):
![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s19.png)

Deployment results (failed):
![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s18.png)

Console for the intrepids:

![](https://raw.github.com/living-atlases/la-toolkit/dev/screenshots/s14.png)

