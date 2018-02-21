# Common functionality for the scripts.

# Determines the Docker namespace to use given the parameter using the
# current GCP project selected for gcloud. If a value is provided in
# the parameter then that value will be used as the namespace.
#   $1, the namespace to use (optional).
function get_docker_namespace() {
    if [ -z "${1:-}" ]; then
        local -r project_id=$(get_current_project)
        local -r repo="gcr.io/${project_id}"
        echo "Warning: Using repo ${repo} from ambient project." 1>&2
    else
        local -r repo=$1
    fi
    echo "${repo}"
}

# Returns the currently selected project in gcloud.
function get_current_project() {
    gcloud config list --format="value(core.project)"
}
