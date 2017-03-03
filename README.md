# Docker image for ASP.NET Core apps on App Engine Flex
This repo containes the definition of the Docker images for the .NET runtime to be able to run ASP.NET Core apps on App Engine Flex as well as the runtime builder which will generate the necessary `Dockerfile` to build ASP.NET Core apps pushed to App Engine Flex.

The repo is divided in two sections:
* The [runtimes](./runtimes) section, which will contain the definition for all of the supported .NET Core runtimes. Currently only the 1.0.x (or LTS) is supported.
* The [build_pipelines](./build_pipeline) section which contains the definition for the runtime builders associated with the various runtimes. Currently onthe 1.0 version is supported.

## The runtimes
As mentioned before only the .NET Core 1.0.x (LTS branch) is supported at the moment, so only that runtime is defined.

The runtime defines a templatized file called `cloudbuild.yaml.in`, which contains a Cloud Builder build definition with placeholders for the gcr.io repo where the resulting image must be pushed and the version to tag it with. This will allow the image to be pushed to test projects and, with the right credentials, be pushed to the final location.

Note that building the image with the Cloud Builder is not required, if you have Docker installed locally you can just run:
```bash
docker build -t tag-of-your-choice runtimes/aspnetcore-1.0
```

And that will produce a valid image for you to use.

## The build pipeline
The build pipeline defines the build step that will ensure that a published ASP.NET Core app is ready to be published.

## Building and pushing
The image is being built and deployed using the Google Container Builder service, a cloudbuild.yaml file is provided to do so. To build and test the image locally you will need to have Docker installed.

The build of the image has been tested with Docker 1.10.

## Support
To get help on using the aspnet runtime, please log an issue in this repo

Patches are encouraged, and may be submitted by forking this project and submitting a Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License
Apache 2.0. See [LICENSE](LICENSE) for more information.
