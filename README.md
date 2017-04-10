# Docker image for ASP.NET Core apps on App Engine Flex
This repo containes the definition of the Docker images for the .NET runtime to be able to run ASP.NET Core apps on App Engine Flex as well as the runtime builder which will generate the necessary `Dockerfile` to build ASP.NET Core apps pushed to App Engine Flex.

The repo is divided in two sections:
* The [runtimes](./runtimes) section, which will contain the definition for all of the supported .NET Core runtimes. Currently only the 1.0.x (or LTS) is supported.
* The [build_pipelines](./build_pipelines) section which contains the definition for the runtime builders associated with the various runtimes. Currently onthe 1.0 version is supported.

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

## Using the image to deploy ASP.NET Core apps
This image is initially designed and tested to run apps on App Engine Flex but it can also be used to run .NET Core apps on other Docker hosts such as Container Engine or just plain Docker.

The image is designed to run self-contained .NET Core apps, which means that the app must be published before you can build the app's image. To publish the app run the following command at the root of your app's project:
```bash
dotnet publish -c Release
```

This will produce a directory, typically under `bin/release/netcoreapp1.0/publish/`. This is the directory where the `Dockerfile` for app's image should be placed.

### Using the runtime image in App Engine Flex
Typically you wont need to produce a `Dockerfile` when deploying ASP.NET Core apps to App Engine Flex, the deployment process will generate one for you when you specify the `aspnetcore` runtime in your `app.yaml` file. The minimal `app.yaml` file looks like this:
```yaml
runtime: aspnetcore
env: flex
```

You should copy the `app.yaml` file to the publish directory for your app and then to deploy you run the comand:
```bash
gcloud beta app deploy <path to app.yaml>
```

During the publishing process a Dockerfile will be generated and your app will be correctly packaged.

### Using the runtime image in other environments
The runtime image can be used as the base image for an ASP.NET Core apps and run in other environments suck as Google Container Engine (GKE) and any other Docker host.

To create a Docker image for your app create a `Dockerfile` that looks like this:
```Dockerfile
FROM gcr.io/google-appengine/aspnetcore:1.0
ADD ./ /app
ENV ASPNETCORE_URLS=http://*:${PORT}
WORKDIR /app
ENTRYPOINT [ "dotnet", "<dll_name>.dll" ]
```

Replace the `<dll_name>` with the name of your project, that should start your app listening on port 8080.

## Support
To get help on using the aspnet runtime, please log an issue in this repo

Patches are encouraged, and may be submitted by forking this project and submitting a Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License
Apache 2.0. See [LICENSE](LICENSE) for more information.
