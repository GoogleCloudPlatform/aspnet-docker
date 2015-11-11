# This library contains the common settings for building and pushing the Asp.NET
# runtime containers.

# The current version of the runtime.
readonly RUNTIME_VERSION=1.0.0-beta8
readonly REPOSITORY=gcr.io/tryinggce

# Prints out the tag to use to build the container for the given runtime.
# Args:
#  $1, the name of the runtime, mono or coreclr.
get_docker_tag () {
    # Echo it so it can be read from the caller.
    echo "${REPOSITORY}/aspnet_runtime:${RUNTIME_VERSION}-$1"
}

# Builds the docker image given the directory where the various runtime are
# stored.
# Args:
#  $1, the root for all runtimes.
#  $2, the name of the runtime to use, mono or coreclr.
build_docker_image () {
    local runtime_tag
    runtime_tag="$(get_docker_tag $2)"

    # Build the container.
    echo Building the tag ${runtime_tag}
    docker build -t "${runtime_tag}" "$1/$2"
}

# Pushes the container to the repository indicated by the tag.
# Args:
#   $1, the runtime to push, mono or coreclr.
push_docker_image () {
    gcloud docker push "$(get_docker_tag $1)"
}
