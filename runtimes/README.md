# .NET Core runtime images
This directory contains the major versions of .NET Core supported by this repo. Each directory has the following structure:
* The `cloudbuild.yaml` file contains the instructions to build and test all of the images for the particular .NET Core major version. This `cloudbuild.yaml` needs two substitutions to succeed, `_DOCKER_NAMESPACE` which is the name of the Docker repository where to store the image, and `_TAG` which is the tag to append to the image name to make it unique, typically this `_TAG` will be date based.
* The `versions` directory, which contains a directory for each supported minor version. Each directory contains the Dockerfile to build the image for the minor version.
* The `structural_tests` directory, which again contains a directory for each supported minor version. Each directory contains a file called `aspnet.yaml` which defines what structural tests to run as part of the build for that minor version. These tests typically check that the right dotnet binary is included in the image and the licenses for all packages used in building the image.

## Adding a new major version
To add a new major version create a new directory following the same naming convention, `aspnetcore-<version>`. Replicate the same structure as the existing major versions, and create the `cloudbuild.yaml` file that defines how to build and push the resulting images.

It is highly recommended that the parallel build feature of the cloud builder is used, so assign ids to each build step and use the `waitFor:` key to ensure the dependencies are met correctly.

## Adding a new minor version
Adding a new minor version will consist then on adding a new directory under the `versions` directory which will contain the `Dockerfile` to build that minor version, as well as adding the structural testing for that minor version.
