# This Dockerfile defines the build step that restores and builds a
# .NET Core project.
FROM microsoft/dotnet:1.0.3-sdk-projectjson

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      node \
      npm \
    && apt-get clean

RUN npm install -g bower gulp

RUN mkdir -p /builder
ADD ./build_project.sh /builder

WORKDIR /workspace
ENTRYPOINT [ "/builder/build_project.sh" ]
