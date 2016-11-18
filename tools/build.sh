#! /usr/bin/env bash
# This script will build the ASP.NET Core image.
#   $1, the image to build.
#   $2, repository for the resulting image.

if [ -z "$1" ]; then
    echo "Must specify the directory of the image to build."
    echo 1
fi

export REPO=$2
if [ -z "$REPO" ]; then
    echo "Must specify the name of the repository."
    exit 1
fi

readonly stage_dir=$(mktemp -d build.XXXXX)

# Process the template.
envsubst < "$1/cloudbuild.yaml.inc" > "${stage_dir}/cloudbuild.yaml"

# Start the build.
gcloud beta container builds submit "$1"  --config="${stage_dir}/cloudbuild.yaml"

# Cleanup.
rm -rf "${stage_dir}"

