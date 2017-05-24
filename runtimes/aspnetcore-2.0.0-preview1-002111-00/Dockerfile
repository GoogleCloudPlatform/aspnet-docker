# This docker file installs the .NET core runtime.. The apps are expected to be
# published before being added to the container to avoid having to resolve
# properties furing the Docker build process.

# This is an official app engine image.
FROM gcr.io/google_appengine/debian8

# Install .NET Core dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gettext \
        libunwind8 \
    && apt-get clean

# Install the package.
RUN mkdir -p /usr/share/dotnet && \
    curl -sL https://storage.googleapis.com/gcp-aspnetcore-packages/dotnet-linux-x64.2.0.0-preview1-002111-00.tar.gz | tar -xz -C /usr/share/dotnet/ && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Expose the port for the app.
EXPOSE $PORT
