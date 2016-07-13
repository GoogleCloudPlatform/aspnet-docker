# This library contains the common settings for building and pushing the Asp.NET
# runtime containers.

# The current version of the runtime.
readonly REPOSITORY=b.gcr.io/aspnet-docker
readonly RUNTIME_VERSION=1.0.0

# Prints out the tag to use to build the container for the given runtime.
# Args:
#  $1, the version name to use.
get_docker_tag () {
    # Echo it so it can be read from the caller.
    echo "${REPOSITORY}/dotnet:$1"
}

# Builds the docker image given the directory where the various runtime are
# stored, and mark it as the latest.
# Args:
#  $1, the root for the image directory.
build_docker_image () {
    # Build the container, tagged with the runtime version.
    local runtime_tag="$(get_docker_tag ${RUNTIME_VERSION})"
    echo Building the tag ${runtime_tag}
    docker build -t "${runtime_tag}" "$1/docker"

    # Tag the runtime version as the latest version.
    local latest_tag="$(get_docker_tag latest)"
    echo Tagging ${runtime_tag} as ${latest_tag}
    docker tag ${runtime_tag} ${latest_tag}
}

# Pushes the container to the repository indicated by the tag. This function
# will also push the "latest" tag.
push_docker_image () {
    # Pushing the versioned tag.
    local versioned_tag="$(get_docker_tag ${RUNTIME_VERSION})"
    echo Pushing ${versioned_tag}
    gcloud docker push ${versioned_tag}

    # Pushing the latest tag as well.
    local latest_tag="$(get_docker_tag latest)"
    echo Pushing ${latest_tag}
    gcloud docker push ${latest_tag}
}

# Run the image with the given name.
run_docker_image () {
    # TODO: Maybe build the image as well?
    docker run -it --entrypoint bash "$(get_docker_tag latest)"
}
