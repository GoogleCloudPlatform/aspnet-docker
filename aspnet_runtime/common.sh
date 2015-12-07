# This library contains the common settings for building and pushing the Asp.NET
# runtime containers.

# The current version of the runtime.
readonly RUNTIME_VERSION=1.0.0-rc1-update1
readonly REPOSITORY=b.gcr.io/aspnet-docker

# Prints out the tag to use to build the container for the given runtime.
# Args:
#  $1, the name of the runtime, mono or coreclr.
#  $2, the version name to use.
get_docker_tag () {
    # Echo it so it can be read from the caller.
    echo "${REPOSITORY}/aspnet-$1:$2"
}

# Builds the docker image given the directory where the various runtime are
# stored, and mark it as the latest.
# Args:
#  $1, the root for all runtimes.
#  $2, the name of the runtime to use, mono or coreclr.
build_docker_image () {
    # Build the container, tagged with the runtime version.
    local runtime_tag="$(get_docker_tag $2 ${RUNTIME_VERSION})"
    echo Building the tag ${runtime_tag}
    docker build -t "${runtime_tag}" "$1/$2"

    # Tag the runtime version as the latest version.
    local latest_tag="$(get_docker_tag $2 latest)"
    echo Tagging ${runtime_tag} as ${latest_tag}
    docker tag -f ${runtime_tag} ${latest_tag}
}

# Pushes the container to the repository indicated by the tag.
# Args:
#   $1, the runtime to push, mono or coreclr.
push_docker_image () {
    gcloud docker push "$(get_docker_tag $1)"
}

# Run the image with the given name.
# Args:
#   $1, the name of the runtime to use, mono or coreclr.
run_docker_image () {
    # TODO: Maybe build the image as well?
    docker run -it --entrypoint bash "$(get_docker_tag $1 latest)"
}
