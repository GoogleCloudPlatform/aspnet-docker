# .NET Core runtime images
This directory contains the build definition for all of the supported .NET Core runtimes. The main structure is:
* The `cloudbuild.yaml` file contains the instructions to build and test all of the runtime images. This `cloudbuild.yaml` needs two substitutions to succeed, `_DOCKER_NAMESPACE` which is the name of the Docker repository where to store the image, and `_TAG` which is the tag to append to the image name to make it unique, typically this `_TAG` will be date based.
* The `versions` directory contains the definition for each .NET Core version supported. In each version you will find:
  + The `image` directory, which contains the `Dockerfile` that defines the runtime image.
  + The `structural_tests` directory, which contains the file called `aspnet.yaml`, this file defines what structural tests to run as part of the build for that version. These tests typically check that the right dotnet binary is included in the image and the licenses for all packages used in building the image.
  + The `functional_tests` directory, which contains the functional tests (unit tests) for the runtime. These tests are implemented as a simple console app that prints "Hello World <version>!" to stdout. The build script will check that the app succeeded to run (had an exit code of 0) and that is has the expected output.
* The `dockerfile_generator` directory, which contains the a `Dockerfile` generator to build test app images during the build process to test the runtimes.

## Updating tests
To update the tests, edit the source code in the `functional_tests/app` directory and then run the [`udpate_runtimes_tests.sh`](../tools/update_runtimes_tests.sh). The script will take care of building all of the apps and publishing them to the `functional_tests/published` directory for each supported runtime.

To update the test you can use a command line like the following from the root of the repo:
```bash
./tools/update_runtimes_tests.sh
```

## Updating the runtimes.
From time to time Microsoft will release new versions of the runtimes. To update the existing images just point the Dockerfile to the latest bits. We use a private GCP bucket to ensure that the bits remain stable.

You might also need to update the `functional_tests` to be built with the latest .NET Core SDK that corresponds to the new .NET Core runtime being wrapped. This will ensure that the latest .NET Core SDK is correctly supported.

## Adding a new version of the runtime.
As new major versions of the runtimes are released we will need to add new build steps to the [`cloudbuid.yaml`](./cloudbuild.yaml) to build it.

Also following Microsoft's support policy we will be removing old versions of .NET Core that are no longer supported.
