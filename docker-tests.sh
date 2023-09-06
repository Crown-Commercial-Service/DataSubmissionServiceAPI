#!/bin/bash

COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH

docker build -t datasubmissionserviceapi:$COMMIT_HASH .

docker compose --file docker-compose.test.yml --env-file docker-compose.env build
docker compose --file docker-compose.test.yml --env-file docker-compose.env up -d db-test
docker compose --file docker-compose.test.yml --env-file docker-compose.env up -d test

docker exec -it data-submission-service-api_test bundle exec rake default

if [ $? -ne 0 ]; then
  echo "Tests failed! Exiting with status 1..."
  exit 1
fi

docker compose --file docker-compose.test.yml --env-file docker-compose.env down
