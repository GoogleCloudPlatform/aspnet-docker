# Tools for the repo.
This directory contains tools to be used throught the repo. These tools expect to be invoked within the repo directory.

## The submit_build.sh script
The [`submit_build.sh`](./submit_build.sh) script is a helper script to submit builds to Google Cloud Container Builder that require the `_DOCKER_NAMESPACE` and `_TAG` substitutions. The script will calculate the default Docker namespace by using the ambient project and a default tag based on the current time.

## The test.sh script
The [`test.sh`](./test.sh) script is a helper script to run integration tests on a particular app. This script determines what GCP project you are running under, creating the right file structure for the runtime builders metadata (the `runtimes.yaml`) and setting up the right environment to deploy and test the integration test application.

This script does not perform cleanup, the idea being that you might want to need to debug tests, re-run the tests manually after you are done, etc... To clean up you can just use `gcloud` to delete the versions created by this script. The versions are named after the directory name.
