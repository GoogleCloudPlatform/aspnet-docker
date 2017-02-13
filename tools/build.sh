#! /usr/bin/env bash
# This script will build the ASP.NET Core image.
#   $1, the image to build.
#   $2, repository for the resulting image.

# Exit on error or undefined variable
set -eu

readonly stage_dir=$(mktemp -d .build.XXXXX)

trap cleanup 0 1 2 3 13 15 # EXIT HUP INT QUIT PIPE TERM

cleanup() {
	rm -rf "${stage_dir}"
}

readonly image_dir="$1"

if [ -z "${image_dir}" ]; then
    echo "Must specify the directory of the image to build."
    echo 1
fi
if [ ! -f "${image_dir}/cloudbuild.yaml.in" ]; then
    echo "The file ${image_dir}/cloudbuild.yaml.in does not exist."
    exit 1
fi

export readonly REPO=$2
if [ -z "${REPO}" ]; then
    echo "Must specify the name of the repository."
    exit 1
fi

# Process the template.
envsubst < "${image_dir}/cloudbuild.yaml.in" > "${stage_dir}/cloudbuild.yaml"

# Start the build.
# Use alpha build command since some jenkins machines are on old versions of gcloud.
gcloud alpha container builds create "${image_dir}" --config="${stage_dir}/cloudbuild.yaml"
