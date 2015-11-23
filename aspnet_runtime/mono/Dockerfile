# This Dockerfile installs the Mono runtime and the DNX runtime on top of
# that. The apps are expected to be published before being added to the
# container to avoid having to resolve properties furing the Docker build
# process.
# The app should contain an entry point called kestrel, to launch the kestrel
# server on port 8080, which this container exposes.

# Using the Mono runtime to execute the app.
FROM mono:4.0.1

# Install the dependencies
RUN apt-get update; apt-get install \
    curl \
    libc6-dev \
    openssl \
    unzip \
    -y --no-install-recommends

# Add the grpc runtime, built from the latest sources and clean up.
RUN mkdir -p /app/dependencies
ADD ./grpc_runtime.tar.gz /usr/local/lib/

# Add the libuv library to be able to run the Kestrel webserver which depends on it.
# This library was built from the latest sources, if it needs to be rebuilt just
# follow the instructions at https://github.com/libuv/libuv.
ADD ./libuv.so.1.0.0 /usr/local/lib/
RUN ln -s /usr/local/lib/libuv.so.1.0.0 /usr/local/lib/libuv.so.1

# Add the path where the .so file are added to the loader path so it can be
# found by Kestrel.
ENV LD_LIBRARY_PATH=/usr/local/lib

# Configure the precise version and branch that is going to be used.
ENV DNVM_COMMIT_ID="55692574b4dad17326b46e0b09f954b2a99e1cab"
ENV DNVM_SOURCE="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvm.sh"
ENV DNVM_INSTALL_URL="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvminstall.sh"
ENV DNX_BRANCH=dev
ENV DNX_RUNTIME_VERSION=1.0.0-rc1-final
ENV DNX_RUNTIME_ENV=mono

# Install Asp.NET vNext
RUN curl -sSL "${DNVM_INSTALL_URL}" | bash

# Add the scripts to run the app.
RUN mkdir -p /app/scripts
ADD ./install_runtime.sh /app/scripts/

# Install the runtime
RUN /app/scripts/install_runtime.sh

# Run the app.
EXPOSE 8080
ENTRYPOINT ["/app/app_engine_start"]
