#! /usr/bin/env bash

# Custom integration tests script for the aspnetcore images. This script needs
# to be custom because we have multiple versions of the .NET Core runtime
# described in this directory and we need to run multiple integraiton tests.

set -ex

source $KOKORO_GFILE_DIR/common.sh
cd $KOKORO_GFILE_DIR/integration_tests

export GOOGLE_CLOUD_PROJECT=gcp-runtimes

sudo /usr/local/bin/pip install --upgrade -r requirements.txt

flags=""

if [ "${SKIP_STANDARD_LOGGING_TESTS}" = "true" ]; then
  flags="$flags --skip-standard-logging-tests"
fi

if [ "${SKIP_CUSTOM_LOGGING_TESTS}" = "true" ]; then
  flags="$flags --skip-custom-logging-tests"
fi

if [ "${SKIP_MONITORING_TESTS}" = "true" ]; then
  flags="$flags --skip-monitoring-tests"
fi

if [ "${SKIP_EXCEPTION_TESTS}" = "true" ]; then
  flags="$flags --skip-exception-tests"
fi

if [ "${SKIP_CUSTOM_TESTS}" = "true" ]; then
  flags="$flags --skip-custom-tests"
fi

# We're always going to use the builder.
flags="$flags --builder ${BUILDER}"
gcloud config set app/use_runtime_builders True

# Test the major versions of .NET Core supported.

# Test the .NET Core 1.0 image.
app_dir=${INTEGRATION_TEST_APPS}/test-1.0
gcloud config set app/runtime_builders_root file://${app_dir}
testsuite/driver.py -d ${app_dir} ${flags} -y ${app_dir}/${APP_YAML_NAME}

# Test the .NET Core 1.1 image.
app_dir=${INTEGRATION_TEST_APPS}/test-1.1
gcloud config set app/runtime_builders_root file://${app_dir}
testsuite/driver.py -d ${app_dir} ${flags} -y ${app_dir}/${APP_YAML_NAME}

# Test the .NET Core 2.0 image.
app_dir=${INTEGRATION_TEST_APPS}/test-2.0
gcloud config set app/runtime_builders_root file://${app_dir}
testsuite/driver.py -d ${app_dir} ${flags} -y ${app_dir}/${APP_YAML_NAME}

# Test the .NET Core 2.1 image.
app_dir=${INTEGRATION_TEST_APPS}/test-2.1
gcloud config set app/runtime_builders_root file://${app_dir}
testsuite/driver.py -d ${app_dir} ${flags} -y ${app_dir}/${APP_YAML_NAME}

# Test the .NET Core 2.2 image.
app_dir=${INTEGRATION_TEST_APPS}/test-2.2
gcloud config set app/runtime_builders_root file://${app_dir}
testsuite/driver.py -d ${app_dir} ${flags} -y ${app_dir}/${APP_YAML_NAME}
