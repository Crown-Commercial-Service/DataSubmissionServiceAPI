#!/bin/bash
# script to set up a space.
# these are all probably idempotent

# login all users should have access to the sandbox
cf login -u $CF_USER -p $CF_PASS -o ccs-report-management-info -s sandbox
# space creation needs org admin
cf create-space bobtest # create a space
cf target -o "ccs-report-management-info" -s "bobtest" #target a space
cf marketplace # see all services
cf create-service aws-s3-bucket default test-s3-bucket # create a s3 bucket doesnt currently work
cf marketplace -s postgres # see available postgres services
cf create-service postgres tiny-unencrypted-10 ccs-rmi-app-bobtest # create a postgres for the app 
cf create-service postgres tiny-unencrypted-10 ccs-rmi-api-bobtest # create a postgres for the api 
cf create-service redis tiny-3.2 ccs-rmi-redis-bobtest # create a redis cluster

