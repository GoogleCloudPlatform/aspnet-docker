# This docker file installs the .NET core runtime.. The apps are expected to be
# published before being added to the container to avoid having to resolve
# properties furing the Docker build process.

# This is an official app engine image.
FROM gcr.io/google_appengine/debian8

# Install .NET Core dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libicu52 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libtinfo5 \
        libunwind8 \
        libuuid1 \
        zlib1g \
        ca-certificates \
        curl \
    && apt-get clean

# Install the package.
RUN mkdir -p /usr/share/dotnet && \
    curl -sL https://storage.googleapis.com/gcp-aspnetcore-packages/dotnet-debian-x64.1.0.5.tar.gz | tar -xz -C /usr/share/dotnet/ && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Expose the port for the app.
EXPOSE $PORT
