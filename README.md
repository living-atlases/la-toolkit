# la_toolkit

Living Atlases Toolkit - Frontend

## Introduction

This is a the frontend of the LA Toolkit. It uses [this repo](https://github.com/living-atlases/la-toolkit-backend) as backend and both components are packaged together in a docker image with all the dependencies to deploy and maintain a LA Portal.

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

### Environments

## Build and Run

We need to have the frontend build prior to build the docker image:

```

flutter test && flutter build web
```

### Docker 

Build the image (or download it from Docker Hub):

```
docker build . -t la-toolkit
```

Run the image exposing the port `2010` that is were the la-toolkit web interface is listen to, and configuring the volumes for:

- your ssh keys
- your inventories and configuration


```
docker run --rm \
   -v YOUR_SSH_KEYS_DIRECTORY:/home/ubuntu/.ssh/ \
   -v YOUR_CONFIG_DIRECTORY:/home/ubuntu/ansible/la-inventories \
   -v YOUR_LOGS_DIRECTORY:/home/ubuntu/ansible/logs \
   -t -d --name la-toolkit -h la-toolkit -p 2010:2010 -p 2011:2011 la-toolkit:latest
```

During development some test directory like `/var/tmp/la-toolkit/.ssh/`.

Optionally you can mount a different `ala-install` repository (for instance a modified one):

```
   (...)
   -v /home/youruser/dev/my-ala-install/:/home/ubuntu/ansible/ala-install/ \
   (...)
```
In this case, use `custom` in the ala-install releases version dropdown.

To start using the LA Toolkit visit:
http://localhost:2010/

Stop it with:
```
docker stop la-toolkit
```

### Screenshots

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
