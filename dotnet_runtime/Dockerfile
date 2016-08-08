# This docker file installs the .NET core runtime.. The apps are expected to be
# published before being added to the container to avoid having to resolve
# properties furing the Docker build process.

# This is an official app engine image.
FROM gcr.io/google_appengine/base

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

# Install the .NET package.
ENV DOTNET_CORE_VERSION 1.0.0
RUN curl -SL https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/${DOTNET_CORE_VERSION}/dotnet-debian-x64.${DOTNET_CORE_VERSION}.tar.gz --output dotnet.tar.gz \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Expose the port for the app.
EXPOSE $PORT
