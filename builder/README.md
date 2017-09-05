# Runtime builder image for .NET Core in GCP
This directory contains the definition for the runtime builder for the `aspnetcore` runtime for Google App Engine Flexible environment. The runtime builder image will generate an appropriate `Dockerfile` given a published .NET Core application. The image is designed to be used as a build step in a [Google Cloud Container Builder](https://cloud.google.com/container-builder/docs/) `cloudbuild.yaml` file, before the step to build the app's image, as it will output the `Dockerfile` in the app's directory.

The structure of the directory is as follows:
* The [`cloudbuild.yaml`](./cloudbuild.yaml) file contains the instructions on how to build the image. During the build process structural and functional tests will run to ensure that the image contains the expected contents and that the main script, [`prepare_project.py`](./src/prepare_project.py) is working as expected.
* The [`functional_tests`](./functional_tests) directory contains stubbed .NET Core published applications, used to generate `Dockerfile` for various supported runtimes. There are some specific classes of test apps being used:
  + The ['published_apps'](./functional_tests/published_apps) directory contains stubbed out published apps. These apps are used to ensure that the `prepare_project.py` script keeps working with these apps, as these are the ones sent by existing tools.
  + The ['single_project_apps'](./functional_tests/single_project_apps) directory contain stubbed out apps consisting of a single project, either a .csproj or (for .NET Core 2.0) .fsproj.
  + The ['solution_apps'](./functional_tests/solution_apps) directory contains stubbed out apps consisting of a .sln and one ore more projects. These apps contain an app.yaml that also points to the start project for the app. See this [`app.yaml`](./functional_tests/solution_apps/solution-2.0/app.yaml) for an example of this.
* The [`dockerfile_validator`](./dockerfile_validator) directory contains a small Docker image that is used during the functional tests to validate that the generated `Dockerfile` for each test matches the `Dockerfile.expected` in each test. The [`validator.sh`](./dockerfile_validator/validator.sh) script compares the `Dockerfile.expected` in the test directory with the generated one. If the files are different then it will show the differences.
  + The comparison is done by comparing SHA1 hashes, care whould be taken when creating the `Dockerfile.expected`.
* The [`src`](./src) directory contains the source for the runtime image, including the [`prepare_project.py`](./src/prepare_project.py) which implements the logic for the runtime builder.
* The [`structural_tests`](./structural_tests) directory contains the structural tests for the runtime image, which verify that the contents of the image match what we expect.

To use the image you add a step to the `cloudbuild.yaml` that looks like this:
```yaml
- name: 'gcr.io/gcp-runtimes/aspnetcorebuild:latest'
  args: [ '--version-map',
          '1.1.2=gcr.io/google-appengine/aspnetcore:1.1.2',
          '1.0.5=gcr.io/google-appengine/aspnetcore:1.0.5',
          '2.0.0=gcr.io/google-appengine/aspnetcore:2.0.0' ]
```

This step assumes that the root of the app is the workspace, it will inspect it and produce a `Dockerfile` that uses one of the provided base images depending on the version of .NET Core being targeted. The runtime builder will fail (return non-zero exit code) if the app targets a version of .NET Core that is not supported.
