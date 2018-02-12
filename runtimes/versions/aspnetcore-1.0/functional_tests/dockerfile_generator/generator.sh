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

# This script will generate a simple Dockerfile in the given target
# directory.
#   $1, the path to the directory where to generate the Dockerfile
#   $2, the base image for the Dockerfile.

# Exit on error or undefined variable
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the directory where to generate the Dockerfile."
    exit 1
fi

if [ -z "${2:-}" ]; then
    echo "Must specify the base image."
    exit 1
fi

readonly output=$1/Dockerfile
readonly app_name=$(basename $1)

# Generate the dockerfile.
echo "FROM $2" > ${output}
echo "ADD ./ /app" >> ${output}
echo "ENTRYPOINT [ \"dotnet\", \"/app/${app_name}.dll\" ]" >> ${output}

exit 0
