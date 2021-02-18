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

### Environments


## Build and Run

We need to have the frontend build prior to build the docker image:

```
flutter build web
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
   -v /var/tmp/la-toolkit/.ssh/:/home/ubuntu/.ssh/ \
   -t -d --name la-toolkit -h la-toolkit -p 2010:2010 la-toolkit:latest
```

To start using the LA Toolkit visit:
http://localhost:2010/

Stop it with:
```
docker stop la-toolkit
```

### Screenshots
