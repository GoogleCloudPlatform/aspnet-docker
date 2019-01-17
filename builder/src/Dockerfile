# This builder will ensure that the .NET Core project that was
# published to the /workspace directory has a Dockerfile. If one
# exists it will be used, otherwise a new one will be created.
FROM gcr.io/google_appengine/debian9

# We need python to run the builder script.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         python \
    && apt-get clean

RUN mkdir -p /builder
ADD . /builder

WORKDIR /workspace
ENTRYPOINT [ "/builder/prepare_project.py" ]
