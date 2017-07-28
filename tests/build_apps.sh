#! /usr/bin/env bash

# This script will build all apps under the test/apps directory and update the
# binaries in the bins directory. To succesfully run this script you need to
# have installed the following .NET Core SDKs:
# 1.0.0-preview2-003156, for project.json apps.
# 1.0.1, for 1.0, 1.1 .NET Core apps.
# 2.0.0-preview1-005977, for 2.0 .NET core apps.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
readonly apps_dir=${workspace}/tests/apps
readonly bins_dir=${workspace}/tests/integration_tests

for app in $(find ${apps_dir} -maxdepth 1 -type d -name 'test*-*'); do
    publish_dir=${PWD}/${bins_dir}/$(basename ${app})

    echo "Building ${app} publishing to ${publish_dir}"
    pushd ${app}
    dotnet restore
    dotnet publish -o ${publish_dir}
    popd
done
