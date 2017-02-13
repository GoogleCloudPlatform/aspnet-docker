#! /usr/bin/env python
"""This script prepares the project to be packaged up in a docker image.

This script will make any necessary transformation into the published
directory for the project so it can be wrapped up into a Docker image.

It is assumed that the current directory is the published directory.

"""

from __future__ import print_function

import glob
import json
import os
import sys
import textwrap


ASSEMBLY_NAME_TEMPLATE = '{0}.dll'
DEPS_PATTERN = '*.deps.json'
DEPS_EXTENSION = '.deps.json'
DOCKERFILE_NAME = 'Dockerfile'
DOCKERFILE_CONTENTS = textwrap.dedent(
    """\
    FROM b.gcr.io/aspnet-docker/aspnet:1.0.3
    ADD ./ /app
    ENV ASPNETCORE_URLS=http://*:${{PORT}}
    WORKDIR /app
    ENTRYPOINT [ "dotnet", "{0}.dll" ]
    """)


def get_project_name(deps_path):
    """Returns the project name given the .deps.json file name."""
    return deps_path[:-len(DEPS_EXTENSION)]


def get_deps_path():
    """Finds the .deps.json file for the project."""
    files = glob.glob(DEPS_PATTERN)
    if len(files) != 1:
        return None
    return files[0]


def main():
    """Ensures that a Dockerfile exists in the current directory."""
    if os.path.isfile(DOCKERFILE_NAME):
        print('Dockerfile already exists.')
        return

    deps_path = get_deps_path()
    if deps_path is None:
        print('No .deps.json file found, invalid project.')
        sys.exit(1)
    project_name = get_project_name(deps_path)
    assembly_name = ASSEMBLY_NAME_TEMPLATE.format(project_name)
    if not os.path.isfile(assembly_name):
        print('Cannot find entry point assembly %s' % assembly_name)
        sys.exit(1)

    # Need to create the Dockerfile, we need to get the name of the
    # project to use.
    contents = DOCKERFILE_CONTENTS.format(project_name)
    with open(DOCKERFILE_NAME, 'wt') as out:
        out.write(contents)


# Start the script.
if __name__ == '__main__':
    main()
