# Runtime builder image for .NET Core in GCP
This directory contains the definition for the runtime builder for the `aspnetcore` runtime for Google App Engine Flexible environment. The runtime builder image will generate an appropriate `Dockerfile` given a published .NET Core application. The image is designed to be used as a build step in a [Google Cloud Build](https://cloud.google.com/cloud-build/docs/) `cloudbuild.yaml` file, before the step to build the app's image, as it will output the `Dockerfile` in the app's directory.

The structure of the directory is as follows:
* The [`cloudbuild.yaml`](./cloudbuild.yaml) file contains the instructions on how to build the image. During the build process structural and functional tests will run to ensure that the image contains the expected contents and that the main script, [`prepare_project.py`](./src/prepare_project.py) is working as expected.
* The [p`functional_tests`](./functional_tests) directory contains stubbed .NET Core published applications, used to generate `Dockerfile` for various supported runtimes.
* The [`functional_tests_validator`](./functional_tests_validator) directory contains the definition of a small Docker image that is to be used during the build process to validate the result of running the functional tests. The script [`validator.sh`](./functional_tests_validator/validator.sh) ensures that the produced `Dockerfile` files have the expected `FROM` and `ENTRYPOINT` commands.
* The [`src`](./src) directory contains the source for the runtime image, including the [`prepare_project.py`](./src/prepare_project.py) which implements the logic for the runtime builder.
* The [`structural_tests`](./structural_tests) directory contains the structural tests for the runtime image, which verify that the contents of the image match what we expect.

To use the image you add a step to the `cloudbuild.yaml` that looks like this:
```yaml
- name: 'gcr.io/gcp-runtimes/aspnetcorebuild:latest'
  args: [ '--version-map',
          '1.1.2=gcr.io/google-appengine/aspnetcore:1.1.2',
          '1.0.5=gcr.io/google-appengine/aspnetcore:1.0.5',
          '2.0.0=gcr.io/google-appengine/aspnetcore:2.0.0-preview1' ]
```

This step assumes that the root of the app is the workspace, it will inspect it and produce a `Dockerfile` that uses one of the provided base images depending on the version of .NET Core being targeted. The runtime builder will fail (return non-zero exit code) if the app targets a version of .NET Core that is not supported.
