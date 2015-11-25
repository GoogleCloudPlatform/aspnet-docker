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
    echo "deb http://download.mono-project.com/repo/debian wheezy main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list; \
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

# Add the libuv library to be able to run the Kestrel webserver which depends on it.
# This library was built from the latest sources, if it needs to be rebuilt just
# follow the instructions at https://github.com/libuv/libuv.
ADD ./libuv.so.1.0.0 /usr/local/lib/
RUN ln -s /usr/local/lib/libuv.so.1.0.0 /usr/local/lib/libuv.so

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
