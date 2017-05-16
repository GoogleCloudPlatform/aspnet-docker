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

# This script will build the ASP.NET Core image.
#   $1, the image to build.
#   $2, repository for the resulting image.

# Exit on error or undefined variable
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the image directory."
    exit 1
fi

if [ -z "${2:-}" ]; then
    echo "Must specify the name of the repo."
    exit 1
fi

readonly cloudbuild_template="$1/cloudbuild.yaml"
if [ ! -f "${cloudbuild_template}" ]; then
    echo "The file ${cloudbuild_template} does not exist."
    exit 1
fi

# Process the template.
if [ -z "${TAG:-}" ]; then
  TAG=$(date +"%Y-%m-%d_%H_%M")
fi

export readonly VERSION="${TAG}"
export readonly REPO=$2

# Start the build.
gcloud beta container builds submit "$1" \
    --config="${cloudbuild_template}" \
    --substitutions _VERSION=${VERSION},_REPO=${REPO}
