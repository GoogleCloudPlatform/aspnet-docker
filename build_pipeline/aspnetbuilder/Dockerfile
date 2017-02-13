# This builder will ensure that the .NET Core project that was
# published to the /workspace directory has a Dockerfile. If one
# exists it will be used, otherwise a new one will be created.
FROM 

RUN mkdir -p /builder
ADD . /builder

WORKDIR /workspace
ENTRYPOINT [ "/builder/prepare_project.py" ]
