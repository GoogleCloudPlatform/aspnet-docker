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

# This script run all of the integration tests in the repo.
#   $1, the Docker repository to use to build the images.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
source ${workspace}/tools/common.inc
readonly tools=${workspace}/tools

readonly repo=$(get_docker_namespace "${1:-}")

# Run the integration tests.
export readonly BUILDER_OVERRIDE=${repo}/aspnetcorebuild:latest

for ver in $(find ${workspace}/integration_tests/published -type d -maxdepth 1 -name 'test-*'); do
    echo "Testing ${ver}"
    ${tools}/test.sh ${ver}
done
