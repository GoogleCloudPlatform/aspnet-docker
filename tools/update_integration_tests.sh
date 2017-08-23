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

# This script will build all apps under the test/apps directory and update the
# binaries in the bins directory. To succesfully run this script you need to
# have installed the following .NET Core SDKs:
# * 1.0.4, for 1.0, 1.1 .NET Core apps.
# * 2.0.0, for .NET Core 2.0 apps.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
readonly apps_dir=${workspace}/integration_tests/apps
readonly published_dir=${workspace}/integration_tests/published

# Returns the full path of the given relative path.
function get_absolute_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

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

# Cleanup the existing files.
rm -rf ${published_dir}/*

# Now publish all of the apps.
for app in $(find ${apps_dir} -maxdepth 1 -type d -name 'test-*'); do
    publish_app ${app}
done
