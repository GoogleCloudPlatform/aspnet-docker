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

# This script assumes one of the following two situations:
#   * That ${PWD} represents the root of the app's sources, and that
#     either a .csproj or a .sln file is present in this location so
#     the app's sources can be built and published.
#   * That ${PWD} represents and already published app, and that a
#     corresponding *.deps.json file can be found.

# The parameters are the list of versions to be used.

# Exit on error or undefined variable
set -eu

# Allow overriding the builder script location.
readonly builder=${WORKSPACE_OVERRIDE:-/builder}

# Allow overriding the output location.
readonly output=${OUTPUT_OVERRIDE:-/published}

# Allow overriding the configuration to publish.
readonly configuration=${CONFIGURATION_OVERRIDE:-Release}

# Detect if this directory contains an app that was already published.
readonly deps_json=$(find . -maxdepth 1 -name '*.deps.json' -type f)

# Build the app if necessary, ensure its output is in the output.
if [ -z "${deps_json}" ]; then
    readonly solution=$(find . -maxdepth 1 -name '*.sln')
    if [ -z "${solution}" ]; then
	echo "Building project."
	dotnet restore
	dotnet publish -c ${configuration} -o ${output}
    else
	readonly entrypoint_project=$(python ${builder}/parse_yaml.py -f ./app.yaml -p runtime_config.entrypoint)
	if [ -z "${entrypoint_project}" ]; then
	    echo "Must specify entry point project when deploying a solution."
	    exit 1
	fi
	echo "Building solution."
	dotnet restore
	dotnet publish -c ${configuration} -o ${output} ${entrypoint_project}
    fi
else
    echo "Packaging the app."
    cp -r ./* ${output}
fi

# Generate the Dockerfile for the app.
${builder}/prepare_project.py -r ${output} -o ${output}/Dockerfile -m $*
