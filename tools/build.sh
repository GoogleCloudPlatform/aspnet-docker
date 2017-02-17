#! /usr/bin/env bash
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

readonly cloudbuild_template="$1/cloudbuild.yaml.in"
if [ ! -f "${cloudbuild_template}" ]; then
    echo "The file ${cloudbuild_template} does not exist."
    exit 1
fi

# Stage dir for the build.
readonly stage_dir=$(mktemp -d .build.XXXXX)
readonly cloudbuild_expanded="${stage_dir}/cloudbuild.yaml"

# Ensure cleanup of the stage dir.
trap cleanup 0 1 2 3 13 15 # EXIT HUP INT QUIT PIPE TERM
cleanup() {
	rm -rf "${stage_dir}"
}

# Process the template.
export readonly VERSION=$(date +"%Y-%m-%d_%H_%M")
export readonly REPO=$2
envsubst < "${cloudbuild_template}" > "${cloudbuild_expanded}"

# Start the build.
gcloud alpha container builds create "$1" --config="${cloudbuild_expanded}"
