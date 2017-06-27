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

# This script will run the tests for the project.

# Exit on error or undefined variable
set -eu

readonly workspace=$(dirname $0)/..
readonly pipeline_dir=${workspace}/build_pipelines/aspnetcorebuild/
readonly tests_dir=${workspace}/tests/bins/

readonly supported_runtimes=(
    "1.0.5=version:1.0"
    "1.1.2=version:1.1"
    "2.0.0=version:2.0"
)

for deps_file in $(ls ${tests_dir}/*/*.deps.json); do
    app_dir=$(dirname ${deps_file})
    app_version=$(echo ${app_dir} | cut -d '-' -f 2-)
    app_name=$(basename ${app_dir})
    dockerfile_contents=
    from_line=$(${pipeline_dir}/prepare_project.py \
        -r ${app_dir} \
        -m ${supported_runtimes[@]} \
        -o /dev/stdout | head -n1)
    entrypoint_line=$(${pipeline_dir}/prepare_project.py \
        -r ${app_dir} \
        -m ${supported_runtimes[@]} \
        -o /dev/stdout | tail -n1)
    echo "Verifying .NET Core ${app_version}"
    if [[ ${from_line} != "FROM version:${app_version}" ]]; then
        echo "Failed to produce right Dockerfile for ${app_dir}"
        exit 1
    fi
    if [[ ${entrypoint_line} != "ENTRYPOINT [ \"dotnet\", \"${app_name}.dll\" ]" ]];then
        echo "Failed to produce right entrypoint for ${app_dir}"
        exit 1
    fi
done

echo "Success!!!"
exit 0
