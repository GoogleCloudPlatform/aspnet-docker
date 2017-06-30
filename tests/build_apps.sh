#! /usr/bin/env bash

# This script will build all apps under the test/apps directory and update the
# binaries in the bins directory. To succesfully run this script you need to
# have installed the following .NET Core SDKs:
# 1.0.0-preview2-003156, for project.json apps.
# 1.0.1, for 1.0, 1.1 .NET Core apps.
# 2.0.0-preview2-006497, for 2.0 .NET core apps.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
readonly apps_dir=${workspace}/tests/apps
readonly bins_dir=${workspace}/tests/bins

# Calculates the full path for the parameter.
function get_absolute_path() {
    echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

for app in $(find ${apps_dir} -maxdepth 1 -type d -name 'clean*-*'); do
    publish_dir=$(get_absolute_path ${bins_dir}/$(basename ${app}))

    ${workspace}/tests/build_app.sh ${app} ${publish_dir}
done
