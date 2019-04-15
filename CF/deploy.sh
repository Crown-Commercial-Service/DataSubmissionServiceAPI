#!/bin/bash

cf login -u $CF_USER -p $CF_PASS -o ccs-report-management-info -s bobtest
cf target -o ccs-report-management-info -s bobtest
cf push -f cf/bobtest.manifest.yml
cf push -f cf/admin.bobtest.manifest.yml
