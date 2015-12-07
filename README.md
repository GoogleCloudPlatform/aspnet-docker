# Docker image for ASP.NET v5 apps on AppEngine
This repo containes the definition of the Docker images for the "aspnet" runtime
to be able to run ASP.NET v5 apps on AppEngine. There are Dockerfile(s) and
supporting files included as part of this repo as well as the scripts to build
and publish said images.

## Building
The `build_container` script, under the [aspnet_runtime](aspnet_runtime) directory can be used to build
the images for both `mono` and `coreclr`, it will take care of using the right tags for the Docker
images produced. To be able to push to the repository you will need write access to the `b.gcr.io/aspnet-docker`
repository.

## Support
To get help on using the aspnet runtime, please log an issue with this
project. While we will eventually be able to offer support on Stack Overflow or
a Google+ community, for now your best bet is to contact the dev team directly.

Patches are encouraged, and may be submitted by forking this project and
submitting a Pull Request. See [CONTRIBUTING.md](CONTRIBUTING.md) for more
information.

## License
Apache 2.0. See [LICENSE](LICENSE) for more information.
