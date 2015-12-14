# This image installs Mono and the CoreCLR runtimes, preparing the environment
# to run an ASP.NET v5 app in AppEngine.
# The app should contain an entry point called kestrel, to launch the kestrel
# server on port 8080, which this container exposes.

# This is an AppEngine image.
FROM gcr.io/google_appengine/base

# Install all of the apt dependencies.
# Note that the GRPC backports version is different because the package in
# jesse-backport's version is different than the release version and tag
# below. This is temporary.
RUN GRPC_VERSION_BACKPORTS=0.11.1-1~bpo8+1 \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.0.5.1 main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
    && echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
    && echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
    && echo "deb http://ftp.us.debian.org/debian jessie-backports main" | tee -a /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --force-yes --no-install-recommends \
      curl \
      libc6-dev \
      libgrpc0=${GRPC_VERSION_BACKPORTS} \
      mono-complete \
      openssl \
      unzip \
    && apt-get clean

# Install the GRPC C# native extension.
RUN GRPC_RELEASE_TAG=0_11_0 \
    GRPC_VERSION=0.11.0.0-1 \
    && mkdir -p ${HOME}/packages/ \
    && curl -sSL "https://github.com/grpc/grpc/releases/download/release-${GRPC_RELEASE_TAG}/libgrpc-csharp-ext0_${GRPC_VERSION}_amd64.deb" > ${HOME}/packages/libgrpc-csharp-ext0_${GRPC_VERSION}_amd64.deb \
    && dpkg -i ${HOME}/packages/libgrpc-csharp-ext0_${GRPC_VERSION}_amd64.deb \
    && rm -rf ${HOME}/packages/

# Build and install libuv from source. This will install the necessary
# development tools to build from source and then uninstall them, all within the
# same command to avoid growing the image size too much.
RUN LIBUV_VERSION=1.4.2 \
    && apt-get install -y \
      autoconf \
      automake \
      build-essential \
      libtool \
    && mkdir -p ${HOME}/libuv/ \
    && curl -sSL "https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz" | tar zxfv - -C ${HOME}/libuv/ \
    && cd ${HOME}/libuv/libuv-${LIBUV_VERSION} \
    && ./autogen.sh && ./configure && make && make install \
    && cd - \
    && rm -rf ${HOME}/libuv/ \
    && ldconfig \
    && apt-get purge -y \
      autoconf \
      automake \
      build-essential \
      libtool \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

# Configure the precise version and branch that is going to be used.
ENV DNVM_COMMIT_ID="87e970d8122494e8b88b3bbc13dd665834ec4e81"
ENV DNVM_SOURCE="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvm.sh"
ENV DNVM_INSTALL_URL="https://raw.githubusercontent.com/aspnet/Home/${DNVM_COMMIT_ID}/dnvminstall.sh"
ENV DNX_BRANCH=dev
ENV DNX_RUNTIME_VERSION=1.0.0-rc1-update1

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
