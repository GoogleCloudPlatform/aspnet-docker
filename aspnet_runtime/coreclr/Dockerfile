# This docker file installs the CoreCLR runtime and the DNX runtime on top of
# that. The apps are expected to be published before being added to the
# container to avoid having to resolve properties furing the Docker build
# process.
# The app should contain an entry point called kestrel, to launch the kestrel
# server on port 8080, which this container exposes.

# This is an official app engine image.
FROM gcr.io/google_appengine/base

# In order to run .Net Core we need libunwin8 and libssl.

# Note: This is installing libssl-dev which installs the development
# environment, sdk, gcc, etc... and that is not necessary to run the app, but it
# is the current requirement to run CoreCLR (sight), this makes the image quite
# big.
RUN apt-get update; apt-get install \
    curl \
    ca-certificates \
    gettext \
    libcurl3-gnutls \
    libicu-dev \
    libssl-dev \
    libunwind8 \
    unzip \
    zip \
    zlib1g \
    -y --force-yes --no-install-recommends

# Add the grpc runtime, built from the latest sources and clean up.
RUN mkdir -p /app/dependencies
ADD ./grpc_runtime.tar.gz /usr/local/lib/

# Build and install libuv from source.
RUN LIBUV_VERSION=1.4.2 \
    && apt-get -y install autoconf automake build-essential libtool \
    && mkdir -p $HOME/libuv/ \
    && curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C $HOME/libuv/ \
    && cd $HOME/libuv/libuv-$LIBUV_VERSION \
    && ./autogen.sh && ./configure && make && make install \
    && cd - \
    && rm -rf $HOME/libuv/ \
    && ldconfig \
    && apt-get -y purge autoconf automake build-essential libtool \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

# Add the path where the .so file are added to the loader path so it can be
# found by Kestrel.
ENV LD_LIBRARY_PATH=/usr/local/lib

# Configure the precise version and branch that is going to be used.
ENV DNVM_COMMIT_ID="87e970d8122494e8b88b3bbc13dd665834ec4e81"
ENV DNVM_SOURCE="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvm.sh"
ENV DNVM_INSTALL_URL="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvminstall.sh"
ENV DNX_BRANCH=dev
ENV DNX_RUNTIME_VERSION=1.0.0-rc1-update1
ENV DNX_RUNTIME_ENV=coreclr

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
