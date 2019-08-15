#!/bin/bash
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
docker push thedxw/ccs-rmi-api:latest
docker push thedxw/ccs-rmi-api:$TRAVIS_COMMIT
echo "Pushed new Docker image to Docker Hub…"
