# Docker images for ASP.NET Core apps on Google Cloud
This repo containes the definition of the Docker images for the .NET runtime to be able to run ASP.NET Core apps on App Engine Flexible environment as well as the runtime builder which will generate the necessary `Dockerfile` to build ASP.NET Core apps pushed to App Engine Flex.

The repo is divided in two sections:
* The [runtimes](./runtimes) section, which will contain the definition for all of .NET Core runtimes, grouped by major version.
* The [builder](./builder) section which contains the definition for the runtime builder image.

## The runtimes
The [runtimes](./runtimes) directory contains definition for the .NET Core runtime images grouped by major version. Each major version contains a `cloudbuild.yaml` file that defines how to build all of the images within that major version. To build each major version you will use the following command from the root of the repo:
```bash
./tools/submit_build.sh ./runtimes/aspnetcore-<version>/cloudbuild.yaml
```

This will build all of the minor version runtimes supported for that .NET Core `<version>`. Tests will run during the build to ensure that the images have the right contents.

## The runtime builder
The [builder](./builder) directory contains the definition for the builder image for the `aspnetcore` runtime for Google App Engine Flexible environment. This builder image is responsible for generating a `Dockerfile` for a given published .NET Core application. This `Dockerfile` is then used during the deployment process to generate the app's image that will ultimately run in Google App Engine Flexible environment.

## Using the images to deploy ASP.NET Core apps
This image is initially designed and tested to run apps on App Engine Flexible environment but it can also be used to run .NET Core apps on other Docker hosts such as Container Engine or just plain Docker.

The image is designed to run self-contained .NET Core apps, which means that the app must be published before you can build the app's image. To publish the app run the following command at the root of your app's project:
```bash
dotnet publish -c Release
```

This will produce a directory, typically under `bin/release/netcoreapp1.0/publish/`. This is the directory where the `Dockerfile` for app's image should be placed.

### Using the runtime image in App Engine Flex
Typically you won't need to produce a `Dockerfile` when deploying ASP.NET Core apps to App Engine Flex, the deployment process will generate one for you when you specify the `aspnetcore` runtime in your `app.yaml` file. The minimal `app.yaml` file looks like this:
```yaml
runtime: aspnetcore
env: flex
```

Typically you will have the `app.yaml` in the root of your project, we recommend that you add the `app.yaml` to your `.csproj` file with a line like this:
```XML
<None Include="app.yaml" CopyToOutputDirectory="Always" />
```

This will ensure that the file `app.yaml` is published with the rest of the app. To deploy you will run the comand (assuming you are running from the project's root):
```bash
gcloud beta app deploy ./bin/release/netcoreapp1.0/publish/app.yaml
```

The deployment process will automatically use the runtime builder, which will detect what version of .NET Core you are using and produce the appropriate `Dockerfile` for your app.

### Using the runtime image in other environments
The runtime image can be used as the base image for an ASP.NET Core apps and run in other environments such as Google Container Engine (GKE) and any other Docker host.

To create a Docker image for your app create a `Dockerfile` that looks like this:
```Dockerfile
FROM gcr.io/google-appengine/aspnetcore:1.0
ADD ./ /app
ENV ASPNETCORE_URLS=http://*:${PORT}
WORKDIR /app
ENTRYPOINT [ "dotnet", "<dll_name>.dll" ]
```

Replace the `<dll_name>` with the name of the entrypoing `.dll` in your project, that should start your app listening on port 8080.

We recommend that you store the `Dockerfile` on the root of your project and you add it to your `.csproj` so it is published with the rest of the app. You can add the `Dockerfile` with a line like this:
```XML
<None Include="Dockerfile" CopyToOutputDirectory="Always" />
```

## Support
To get help on using the aspnet runtime, please log an issue in this repo

Patches are encouraged, and may be submitted by forking this project and submitting a Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License
Apache 2.0. See [LICENSE](LICENSE) for more information.
