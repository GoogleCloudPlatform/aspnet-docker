# Integration tests for the runtimes.
This directory contains the integration test apps used to test the end-to-end functionality of the runtime images. You can use the [`test.sh`](../tools/test.sh) script to run the tests from your machine. The test will include deploying the app to Google App Engine Flexible and using the [integration tests framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests) to verify that the app is functional. This means that you need to run with [gcloud](https://cloud.google.com/sdk/gcloud/) configured correctly and with a project to which you can deploy Google App Engine Flexible environment apps.

The tests are run from the [`published`](./published) directory, where the .NET Core apps are published to by the [`update_integration_tests.sh`](../tools/update_integration_tests.sh) script. The source of the apps is stored in the [`apps`](./apps) directory. To update the tests then it is highly recommended that the [`update_integration_tests.sh`](../tools/update_integration_tests.sh) script is used, as it will take care of building and publishing to the right directory.

You can update the integration tests, which will rebuild the apps, using the following command line from the root of the repo:
```bash
./tools/update_integration_tests.sh
```

The test apps currently only implement the [Serving](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests#serving-root) protocol to verify that the app is correctly deployed and serving traffic. More tests will be added soon.

The test runner will use by default the [`run_tests.yaml`](./run_tests.yaml) build script to run the tests, this can be overriden by having a `run_tests.yaml` inside of the test app, which is useful in case different apps support different protocols from the [integration tests framework](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/integration_tests).
