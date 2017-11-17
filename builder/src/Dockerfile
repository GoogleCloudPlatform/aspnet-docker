# This builder will ensure that the .NET Core project that was
# published to the /workspace directory has a Dockerfile. If one
# exists it will be used, otherwise a new one will be created.
FROM gcr.io/google_appengine/debian8

# We need python to run the builder script.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         python \
         python-pip \
    && apt-get clean

# Install the PyYaml library.
RUN pip install PyYaml

RUN mkdir -p /builder
ADD . /builder

ENTRYPOINT [ "/builder/prepare_project.py" ]
