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

# This script will build, publish and package each functional test app
# for the .NET Core runtime major version.

# Exit on error or undefined variable
set -eu

# Returns the full path of the given relative path.
function get_absolute_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# Get the paths.
readonly workspace=$(dirname $0)/..
readonly runtime_versions=${workspace}/runtimes/versions

# Publishes the given app.
#   $1, the path to the apps source.
#   $2, where to store published bits.
function publish_app() {
    echo "Publishing $1 to $2"
    local readonly published=$(get_absolute_path $2)

    # Actually restore and build the app.
    pushd $1
    dotnet restore
    dotnet publish -o ${published}
    popd
}

# Now publish the test of all of the apps.
for ver in $(find ${runtime_versions} -maxdepth 1 -type d -name 'aspnetcore-*'); do
    echo "Publishing test for runtime ${ver}"
    if [ -d ${ver}/functional_tests/app/ ]; then
        publish_app ${ver}/functional_tests/app/ ${ver}/functional_tests/published/
    else
        echo "The runtime ${ver} does not have tests."
    fi
done
