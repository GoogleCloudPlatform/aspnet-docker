# Tools for the repo.
This directory contains tools to be used throught the repo. These tools expect to be invoked within the repo directory.

## The submit_build.sh script
The [`submit_build.sh`](./submit_build.sh) script is a helper script to submit builds to Google Cloud Container Builder that require the `_DOCKER_NAMESPACE` and `_TAG` substitutions. The script will determine the default Docker namespace by using the ambient project and a default tag based on the current time.

## The test.sh script
The [`test.sh`](./test.sh) script is a helper script to run integration tests on a particular app. This script determines what GCP project you are running under, creating the right file structure for the runtime builders metadata (the `runtimes.yaml`) and setting up the right environment to deploy and test the integration test application.

This script does not perform cleanup, the idea being that you might want to need to debug tests, re-run the tests manually after you are done, etc... To clean up you can just use `gcloud` to delete the versions created by this script. The versions are named after the directory name.

## The build_all.sh script.
The [`build_all.sh`](./build_all.sh) script is a helper script to build all runtime images and the builder image in a single command. It will use the currently selected GCP project by default, but you can override the Docker namespace to use in the parameter.

## The test_all.sh script.
The [`test_all.sh`](./test_all.sh) script is a helper script to run all of the integration tests in a single command.

## The build_runtimes.sh script.
The [`build_runtimes.sh`](./build_runtimes.sh) script is a helper script to build all runtimes stored in the repo from a single command. It will also tag them if possible with the version numbers.

## The build_builder.sh script.
The [`build_builder.sh`](./build_builder.sh) script is a helper swcript to build the builder image. This script will also tag the builder as `latest` after it is done.
