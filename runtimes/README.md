# .NET Core runtime images
This directory contains the major versions of .NET Core supported by this repo. Each directory has the following structure:
* The `cloudbuild.yaml` file contains the instructions to build and test all of the images for the particular .NET Core major version. This `cloudbuild.yaml` needs two substitutions to succeed, `_DOCKER_NAMESPACE` which is the name of the Docker repository where to store the image, and `_TAG` which is the tag to append to the image name to make it unique, typically this `_TAG` will be date based.
* The `versions` directory, which contains a directory for each supported minor version. Each directory contains the Dockerfile to build the image for the minor version.
* The `structural_tests` directory, which again contains a directory for each supported minor version. Each directory contains a file called `aspnet.yaml` which defines what structural tests to run as part of the build for that minor version. These tests typically check that the right dotnet binary is included in the image and the licenses for all packages used in building the image.
* The `functional_tests` directory, which contains the functional tests (unit tests) for each of the minor versions of the runtime. These tests are implemented as a simple console app that prints "Hello World!" to stdout. The build script will check that the app suceeded to run (had an exit code of 0).
  + To update the tests, edit the source code in the `functional_tests/apps` directory and then run the [`udpate_runtime_functional_tests.sh`](../tools/update_runtime_functional_tests.sh) script on the corresponding `aspnetcore-<version>` directory. The script will take care of building the app and publishing it to the `functional_tests/published` directory for you.

## Adding a new major version
To add a new major version create a new directory following the same naming convention, `aspnetcore-<version>`. Replicate the same structure as the existing major versions, and create the `cloudbuild.yaml` file that defines how to build and push the resulting images.

It is highly recommended that the parallel build feature of the cloud builder is used, so assign ids to each build step and use the `waitFor:` key to ensure the dependencies are met correctly.

## Adding a new minor version
Adding a new minor version will consist then on adding a new directory under the `versions` directory which will contain the `Dockerfile` to build that minor version, as well as adding the structural testing for that minor version. You should also add an app under the `functional_tests` directory that specifically targets the new minor version runtime, this can be accomplished by adding the `RuntimeFrameworkVersion` property with the minor version of the runtime to the `.csproj` for the app.
