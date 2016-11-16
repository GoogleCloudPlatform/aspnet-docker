# Docker image for ASP.NET Core apps on App Engine Flex
This repo containes the definition of the Docker images for the .NET runtime to be able to run ASP.NET Core apps on App Engine Flex. The repo contains the Dockerfile that describes the image as well as scripts to help build it.

## Building and pushing
The image is being built and deployed using the Google Container Builder service, a cloudbuild.yaml file is provided to do so. To build and test the image locally you will need to have Docker installed.

The build of the image has been tested with Docker 1.10.

## Support
To get help on using the aspnet runtime, please log an issue in this repo

Patches are encouraged, and may be submitted by forking this project and submitting a Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License
Apache 2.0. See [LICENSE](LICENSE) for more information.
