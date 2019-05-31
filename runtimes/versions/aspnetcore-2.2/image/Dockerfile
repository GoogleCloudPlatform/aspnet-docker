# Copyright 2018 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM gcr.io/gcp-runtimes/ubuntu_16_0_4

# Install .NET Core dependencies and timezone data
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libc6 \
        libcurl3 \
        libgcc1 \
        libicu55 \
        liblttng-ust0 \
        libssl1.0.0 \
        libstdc++6 \
        libtinfo5 \
        libunwind8 \
        libuuid1 \
        zlib1g \
        ca-certificates \
        curl \
        tzdata \
    && apt-get upgrade -y \
    && apt-get clean

# Install the package.
RUN mkdir -p /usr/share/dotnet && \
    curl -sL https://storage.googleapis.com/gcp-aspnetcore-packages/dotnet-sdk-2.2.107-linux-x64.tar.gz | tar -xz -C /usr/share/dotnet/ && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Define the environment variables
ENV PORT=8080
ENV ASPNETCORE_URLS=http://*:${PORT}

# Expose the port for the app.
EXPOSE $PORT
