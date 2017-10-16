#! /usr/bin/env bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

# This script will run the integration tests for the given app.
#   $1, the path to the root of the app.
#   $2, the project to use.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..

if [ -z "${1:-}" ]; then
    echo "Must specify the root of the app."
    exit 1
fi

# If no project is given get the ambient project.
if [ -z "${2:-}" ]; then
    readonly project_id=$(gcloud config list core/project --format="csv[no-heading](core)" | cut -f 2 -d '=')
    echo "Warning: Using ambient project ${project_id}"
else
    readonly project_id=$2
fi

# Where to store the modified app definitions.
readonly temp_builders_root=$(mktemp -d -t test_run)

# Generate the builders root.
cp $1/runtimes.yaml ${temp_builders_root}
if [ -z "${BUILDER_OVERRIDE:-}" ]; then
    export readonly STAGING_BUILDER_IMAGE=gcr.io/aspnetcore-staging/aspnetcorebuild:${TAG:-latest}
else
    export readonly STAGING_BUILDER_IMAGE=${BUILDER_OVERRIDE}
fi
echo "Using builder: ${STAGING_BUILDER_IMAGE}"
envsubst '$STAGING_BUILDER_IMAGE' < $1/test.yaml.in > ${temp_builders_root}/test.yaml

# Configure gcloud to use the specified runtime builders.
export readonly CLOUDSDK_APP_USE_RUNTIME_BUILDERS=true
export readonly CLOUDSDK_APP_RUNTIME_BUILDERS_ROOT=file://${temp_builders_root}
export readonly CLOUDSDK_CORE_PROJECT=${project_id}

readonly app_name=$(basename $1)
readonly version_id=$(echo ${app_name} | tr "." "-")-$(date +"%Y%m%d%H%M")

# Use the override build script if provided, otherwise use the common one.
if [ -f $1/run_tests.yaml ]; then
    readonly run_script=$1/run_tests.yaml
else
    readonly run_script=${workspace}/integration_tests/run_tests.yaml
fi

# Choose the right .yaml file depending on whether we're deploying against the
# canary or not.
if [[ "${USE_FLEX_CANARY:-}" == "1" ]]; then
    echo "Warning: Deploying using the canary image."
    readonly app_yaml=$1/app-canary.yaml
else
    readonly app_yaml=$1/app.yaml
fi

# Deploy and run the tests.
gcloud app deploy ${app_yaml} --quiet --verbosity=info --version=${version_id} --no-promote
gcloud container builds submit \
    --config=${run_script} \
    --substitutions _VERSION_ID=${version_id} \
    --quiet \
    --verbosity=info \
    --no-source

# Cleanup the deployed version.
if [[ "${SKIP_CLEANUP:-}" == "1" ]]; then
    echo "Skipping cleanup of version: ${version_id}"
else
    echo "Cleaning up: ${version_id}"
    gcloud app versions delete ${version_id} --quiet
fi
