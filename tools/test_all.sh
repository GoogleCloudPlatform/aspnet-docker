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

# This script will build all of the images in the repo and run all of the tests.
#   $1, the Docker repository to use to build the images.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
readonly tools=${workspace}/tools

if [ -z "{1:-}" ]; then
  echo "Need to specify the repo."
fi

# Determining the project from the ambient settings.
if [ -z "${1:-}" ]; then
    readonly project_id=$(gcloud config list core/project --format="csv[no-heading](core)" | cut -f 2 -d '=')
    readonly repo=gcr.io/${project_id}
    echo "Warning: Using repo ${repo} from ambient project."
else
    readonly repo=$1
fi

# Run the integration tests.
export readonly BUILDER_OVERRIDE=${repo}/aspnetcorebuild:latest

for ver in {1.0,1.1,2.0}; do
    ${tools}/test.sh ${workspace}/integration_tests/published/test-${ver}
done
