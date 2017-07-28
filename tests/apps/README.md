# Integration tests.
This directory contains the apps to be used as integration tests for the runtime images. These apps conform to the integration test protocol defined in the [runtime-common integration tests](https://github.com/GoogleCloudPlatform/runtimes-common/blob/master/integration_tests/README.md).

Each app contains:
* The application source code, the `Controllers` directory contains a `TestController` class that defines all of the test logic.
* The file `run_tests.yaml`, which is a cloud build file that defines how to run the tests for this particular app. This file is only used when running the tests locally.
* The files `runtimes.yaml` and `test.yaml.in` which define the runtime builder metadata used to select the right builder image to use for the tests.
* The `app.yaml` file, which defines how to deploy the test app to Google App Engine Flexible environment. This is the minimal `app.yaml`, only defining that the apps use the `aspnetcore` runtime.

The script [`test.sh`](../../tools/test.sh) expects these files to be present in order to run the tests locally. When adding a new app for a new major version of the .NET Core runtime make sure to follow the same structure so you can run the tests locally.
