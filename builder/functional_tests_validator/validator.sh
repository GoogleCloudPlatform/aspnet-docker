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
#   $1, the path to the Dockerfile to validate.

# Exit on error or undefined variable
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the Dockerfile to validate."
    exit 1
fi

readonly app_version=$(echo $1 | cut -d '-' -f 2-)
readonly app_name=$(basename $1)

readonly from_line=$(cat $1/Dockerfile | head -n1)
readonly entrypoint_line=$(cat $1/Dockerfile | tail -n1)

if [[ ${from_line} != "FROM aspnetcore:${app_version}" ]]; then
    echo "Failed to produce right FROM line for $1: ${from_line}"
    exit 1
fi
if [[ ${entrypoint_line} != "ENTRYPOINT [ \"dotnet\", \"${app_name}.dll\" ]" ]]; then
    echo "Failed to produce right entrypoint for $1: ${entrypoint_line}"
    exit 1
fi

echo "Success!!!"
exit 0
