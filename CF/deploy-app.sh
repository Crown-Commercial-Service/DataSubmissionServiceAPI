#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h                    - help"
  echo "  -u <CF_USER>          - CloudFoundry user             (required)"
  echo "  -p <CF_PASS>          - CloudFoundry password         (required)"
  echo "  -o <CF_ORG>           - CloudFoundry org              (required)" 
  echo "  -s <CF_SPACE>         - CloudFoundry space to target  (required)" 
  echo "  -a <CF_API_ENDPOINT>  - CloudFoundry API endpoint     (default: https://api.london.cloud.service.gov.uk)"
  echo "  -f                    - Force a deploy of a non standard branch to staging or prod"
  exit 1
}

# if there are no arguments passed exit with usage
if [ $# -lt 0 ];
then
 usage
fi

MEMORY_LIMIT="512M"
INSTANCE_COUNT="1"

SIDEKIQ_MEMORY_LIMIT="512M"
SIDEKIQ_INSTANCE_COUNT="1"

SCRIPT_PATH="$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

CF_API_ENDPOINT="https://api.london.cloud.service.gov.uk"

while getopts "a:u:p:o:s:h" opt; do
  case $opt in
    u)
      CF_USER=$OPTARG
      ;;
    p)
      CF_PASS=$OPTARG
      ;;
    o)
      CF_ORG=$OPTARG
      ;;
    s)
      CF_SPACE=$OPTARG
      ;;
    a)
      CF_API_ENDPOINT=$OPTARG
      ;;
    f)
      FORCE=yes
      ;;
    h)
      usage
      exit;;
    *)
      usage
      exit;;
  esac
done

if [[ -z "$CF_USER" || -z "$CF_PASS" || -z "$CF_ORG" || -z "$CF_SPACE" ]]; then
  usage
fi

if [ ! -z ${TRAVIS_BRANCH+x} ]
then
 git checkout $TRAVIS_BRANCH
fi
echo "INFO: deploying $BRANCH to $CF_SPACE"
if [[ ! "$FORCE" == "yes" ]]
then

  if [[ "$CF_SPACE" == "staging" ]]
  then
    if [[ ! "$BRANCH" == "develop" ]]
    then
      echo "We only deploy the 'develop' branch to $CF_SPACE"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi
  
  if [[ "$CF_SPACE" == "prod" ]]
  then
    if [[ ! "$BRANCH" == "master" ]]
    then
      echo "We only deploy the 'master' branch to $CF_SPACE"
      echo "if you want to deploy $BRANCH to $CF_SPACE use -f"
      exit 1
    fi
  fi
fi
if [[ "$CF_SPACE" == "staging" || "$CF_SPACE" == "prod" ]]; then
  echo " *********************************************"
  echo "    The '$CF_SPACE' space will be selected"
  echo "     This deploys the apps as HA with"
  echo "      production like resource sizes"
  echo " For feature testing, choose a space with a"
  echo "      name other than staging / prod"
  echo " *********************************************"

  MEMORY_LIMIT="512M"
  INSTANCE_COUNT="3"
  SIDEKIQ_MEMORY_LIMIT="2048M"
  SIDEKIQ_INSTANCE_COUNT="3"
fi

cd "$SCRIPT_PATH" || exit

# login and target space
cf login -u "$CF_USER" -p "$CF_PASS" -o "$CF_ORG" -a "$CF_API_ENDPOINT" -s "$CF_SPACE"
cf target -o "$CF_ORG" -s "$CF_SPACE"

# generate manifest
sed "s/CF_SPACE/$CF_SPACE/g" manifest-template.yml | sed "s/MEMORY_LIMIT/$MEMORY_LIMIT/g" | sed "s/INSTANCE_COUNT/$INSTANCE_COUNT/g" > "$CF_SPACE.manifest.yml"
sed "s/CF_SPACE/$CF_SPACE/g" sidekiq-manifest-template.yml | sed "s/SIDEKIQ_MEMORY_LIMIT/$SIDEKIQ_MEMORY_LIMIT/g" | sed "s/SIDEKIQ_INSTANCE_COUNT/$SIDEKIQ_INSTANCE_COUNT/g" > "$CF_SPACE.sidekiq.manifest.yml"

# push API
cd .. || exit
if cf app ccs-rmi-api-"$CF_SPACE" > /dev/null; then
  cf blue-green-deploy ccs-rmi-api-"$CF_SPACE" -f CF/"$CF_SPACE".manifest.yml
else
  cf push -f CF/"$CF_SPACE".manifest.yml
fi

# push API sidekiq
# this is not a blue green deploy because that doesnt work with apps with not route
cf push -f CF/"$CF_SPACE".sidekiq.manifest.yml -b python_buildpack -b ruby_buildpack

# allow APP to access API
cf add-network-policy ccs-rmi-app-"$CF_SPACE" --destination-app ccs-rmi-api-"$CF_SPACE" --protocol tcp --port 8080
