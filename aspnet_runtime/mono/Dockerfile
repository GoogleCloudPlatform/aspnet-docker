# This Dockerfile installs the Mono runtime and the DNX runtime on top of
# that. The apps are expected to be published before being added to the
# container to avoid having to resolve properties furing the Docker build
# process.
# The app should contain an entry point called kestrel, to launch the kestrel
# server on port 8080, which this container exposes.

# This is an AppEngine image.
FROM gcr.io/google_appengine/base

# Install all of the dependencies.
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF; \
    echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.0.5.1 main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list; \
    echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list; \
    echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list; \
    apt-get update; \
    apt-get install \
      curl \
      libc6-dev \
      mono-complete \
      openssl \
      unzip \
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

# Configure the precise version and branch that is going to be used.
ENV DNVM_COMMIT_ID="87e970d8122494e8b88b3bbc13dd665834ec4e81"
ENV DNVM_SOURCE="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvm.sh"
ENV DNVM_INSTALL_URL="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvminstall.sh"
ENV DNX_BRANCH=dev
ENV DNX_RUNTIME_VERSION=1.0.0-rc1-update1
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
