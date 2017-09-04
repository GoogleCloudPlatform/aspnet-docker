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

# This script will validate the Dockerfile generated during the
# functional tests for the builder.
#   $1, the path to the directory to validate.

# Exit on error or undefined variable
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the directory to validate."
    exit 1
fi

readonly actual_path=$1/Dockerfile
readonly expected_path=$1/Dockerfile.expected

readonly actual_sha1=$(openssl sha1 ${actual_path} | cut -d '=' -f 2)
readonly expected_sha1=$(openssl sha1 ${expected_path} | cut -d '=' -f 2)

if [[ "${expected_sha1}" != "${actual_sha1}" ]]; then
    echo "The generated Dockerfile and the expected do not match: $1"
    diff ${actual_path} ${expected_path}
    exit 1
fi

# Success.
echo "Success: $1"
exit 0
