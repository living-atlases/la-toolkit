#!/usr/bin/env bash
imageName="la-toolkit"
projectName="la-toolkit"

# Kills all running containers of an image and then removes them.
cleanAll () {
  if [[ -z $ENVIRONMENT ]]; then
      ENVIRONMENT="release"
  fi

  composeFileName="docker-compose.yml"
  if [[ $ENVIRONMENT != "release" ]]; then
    composeFileName="docker-compose.$ENVIRONMENT.yml"
  fi

  if [[ ! -f $composeFileName ]]; then
    echo "$ENVIRONMENT is not a valid parameter. File '$composeFileName' does not exist."
  else
    docker-compose -f $composeFileName -p $projectName down --rmi all

    # Remove any dangling images (from previous builds)
    danglingImages=$(docker images -q --filter 'dangling=true')
    if [[ ! -z $danglingImages ]]; then
      docker rmi -f $danglingImages
    fi
  fi
}

# Builds the Docker image.
buildImage () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="release"
  fi

  composeFileName="docker-compose.yml"
  if [[ $ENVIRONMENT != "release" ]]; then
    composeFileName="docker-compose.$ENVIRONMENT.yml"
  fi

  if [[ ! -f $composeFileName ]]; then
    echo "$ENVIRONMENT is not a valid parameter. File '$composeFileName' does not exist."
  else
    echo "Building the image $imageName ($ENVIRONMENT)."
    docker-compose -f $composeFileName -p $projectName build
  fi
}

# Runs docker-compose.
compose () {
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT="release"
  fi

  composeFileName="docker-compose.yml"
  if [[ $ENVIRONMENT != "release" ]]; then
      composeFileName="docker-compose.$ENVIRONMENT.yml"
  fi

  if [[ ! -f $composeFileName ]]; then
    echo "$ENVIRONMENT is not a valid parameter. File '$composeFileName' does not exist."
  else
    echo "Running compose file $composeFileName"
    docker-compose -f $composeFileName -p $projectName kill
    docker-compose -f $composeFileName -p $projectName up -d
  fi
}

update () {
    if [[ -z $ENVIRONMENT ]]; then
        ENVIRONMENT="release"
    fi

    composeFileName="docker-compose.yml"
    if [[ $ENVIRONMENT != "release" ]]; then
        composeFileName="docker-compose.$ENVIRONMENT.yml"
    fi

    if [[ ! -f $composeFileName ]]; then
        echo "$ENVIRONMENT is not a valid parameter. File '$composeFileName' does not exist."
    else
        echo "Running compose file $composeFileName"
        docker-compose -f $composeFileName -p $projectName kill
        docker-compose -f $composeFileName -p $projectName rm -f
        docker-compose -f $composeFileName -p $projectName pull
        docker-compose -f $composeFileName -p $projectName up -d
    fi
}

openSite () {
  printf 'Opening site'
  publicPort=2010
  if [[ $ENVIRONMENT != "release" ]]; then
    publicPort=20010
  fi
  url="http://localhost:$publicPort"
  until $(curl --output /dev/null --silent --fail $url); do
    printf '.'
    sleep 1
  done

  # Open the site.
  case "$OSTYPE" in
    darwin*) open $url ;;
    linux*) xdg-open $url ;;
    *) printf "\nUnable to open site on $OSTYPE" ;;
  esac
}

# Shows the usage for the script.
showUsage () {
  echo "Usage: dockerTask.sh [COMMAND] (ENVIRONMENT)"
  echo "    Runs build or compose using specific environment (if not provided, develop environment is used)"
  echo ""
  echo "Commands:"
  echo "    build: Builds a Docker image ('$imageName')."
  echo "    compose: Runs docker-compose."
  echo "    update: rm the previous la-toolkit image and pulls the latest version"
  echo "    clean: Removes the image '$imageName' and kills all containers based on that image."
  echo "    composeForDevelop: Builds the image and runs docker-compose."
  echo ""
  echo "Environments:"
  echo "    develop: Uses develop environment."
  echo "    release: Uses release environment."
  echo ""
  echo "Example:"
  echo "    ./dockerTask.sh build develop"
  echo ""
  echo "    This will:"
  echo "        Build a Docker image named $imageName using develop environment."
}

if [ $# -eq 0 ]; then
  showUsage
else
  case "$1" in
    "compose")
            ENVIRONMENT=$(echo $2 | tr "[:upper:]" "[:lower:]")
            compose
            openSite
            ;;
    "composeForDevelop")
            ENVIRONMENT=$(echo $2 | tr "[:upper:]" "[:lower:]")
            buildImage
            compose
            ;;
    "build")
            ENVIRONMENT=$(echo $2 | tr "[:upper:]" "[:lower:]")
            buildImage
            ;;
    "update")
        ENVIRONMENT=$(echo $2 | tr "[:upper:]" "[:lower:]")
        update
        openSite
        ;;
    "clean")
            ENVIRONMENT=$(echo $2 | tr "[:upper:]" "[:lower:]")
            cleanAll
            ;;
    *)
            showUsage
            ;;
  esac
fi
