#! /usr/bin/env bash
# This script will build the pipeline for aspnet.
#   $1, the repo to use.

# Exit on errir or undefined variables.
set -eu

if [ -z "${1:-}" ]; then
    echo "Must specify the name of the repo."
    exit 1
fi

# Where to store the template.
readonly workspace=$(dirname $0)/..
readonly stage_dir=$(mktemp -d .build.XXXXX)

# Process the template.
export readonly VERSION=v0.5
export readonly REPO=$1
envsubst < "${workspace}/build_pipeline/cloudbuild.yaml.in" > "${stage_dir}/cloudbuild.yaml"

# Start the build.
gcloud alpha container builds create "${workspace}/build_pipeline" --config="${stage_dir}/cloudbuild.yaml"

# Cleanup.
rm -rf "${stage_dir}"
