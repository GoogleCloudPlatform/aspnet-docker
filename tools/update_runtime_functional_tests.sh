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
#   $1, path to the root of the .NET Core major version.

# Exit on error or undefined variable
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the root .NET Core version."
    exit 1
fi

# Returns the full path of the given relative path.
function get_absolute_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# Get the paths.
readonly apps_dir=$1/functional_tests/apps/
readonly published_dir=$1/functional_tests/published/

function publish_app() {
    local readonly app_name=$(basename $1)
    local readonly published=$(get_absolute_path ${published_dir}/${app_name})
    echo "Publishing ${app_name} to ${published}"

    # Actually restore and build the app.
    pushd $1
    dotnet restore
    dotnet publish -o ${published}
    popd
}

# Now publish all of the apps.
for app in $(find ${apps_dir} -maxdepth 1 -type d -name 'test-*'); do
    publish_app ${app}
done
