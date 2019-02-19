#!/bin/bash

set -ex

source $KOKORO_GFILE_DIR/common.sh
cd $KOKORO_GFILE_DIR/integration_tests

sudo /usr/local/bin/pip install --upgrade -r requirements.txt

export DEPLOY_LATENCY_PROJECT='cloud-deploy-latency'

# Test and deploy the test-1.0 app.
python deploy_check.py -d ${INTEGRATION_TEST_APPS}/test-1.0 -l ${LANGUAGE} --skip-xrt

# Test and deploy the test-1.1 app.
python deploy_check.py -d ${INTEGRATION_TEST_APPS}/test-1.1 -l ${LANGUAGE} --skip-xrt

# Test and deploy the test-2.0 app.
python deploy_check.py -d ${INTEGRATION_TEST_APPS}/test-2.0 -l ${LANGUAGE} --skip-xrt

# Test and deploy the test-2.1 app.
python deploy_check.py -d ${INTEGRATION_TEST_APPS}/test-2.1 -l ${LANGUAGE} --skip-xrt

# Test and deploy the test-2.2 app.
python deploy_check.py -d ${INTEGRATION_TEST_APPS}/test-2.2 -l ${LANGUAGE} --skip-xrt
