# Copyright 2017 Google Inc. All rights reserved.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    curl -sL https://storage.googleapis.com/gcp-aspnetcore-packages/dotnet-runtime-2.0.0-preview2-25407-01-linux-x64.tar.gz | tar -xz -C /usr/share/dotnet/ && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Expose the port for the app.
EXPOSE $PORT
