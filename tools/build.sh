#! /usr/bin/env bash
# This script will build the ASP.NET Core image.
#   $1, the image to build.
#   $2, repository for the resulting image.

# Exit on error or undefined variable
set -eu

export readonly STAGE_DIR=$(mktemp -d .build.XXXXX)

trap cleanup 0 1 2 3 13 15 # EXIT HUP INT QUIT PIPE TERM

cleanup() {
	rm -rf "$STAGE_DIR"
}

readonly image_name="aspnet"
readonly tag="1.0.3"

export IMAGE_DIR="$1"

if [ -z "$IMAGE_DIR" ]; then
    echo "Must specify the directory of the image to build."
    echo 1
fi
if [ ! -f "$IMAGE_DIR/cloudbuild.yaml.in" ]; then
    echo "The file $IMAGE_DIR/cloudbuild.yaml.in does not exist."
    exit 1
fi

readonly repo=$2
if [ -z "$repo" ]; then
    echo "Must specify the name of the repository."
    exit 1
fi

export IMAGE="${repo}/${image_name}:${tag}"


# Process the template.
envsubst < "${IMAGE_DIR}/cloudbuild.yaml.in" > "${STAGE_DIR}/cloudbuild.yaml"

# Start the build.
# Use alpha build command since some jenkins machines are on old versions of gcloud.
gcloud alpha container builds create "$IMAGE_DIR" --config="${STAGE_DIR}/cloudbuild.yaml"
