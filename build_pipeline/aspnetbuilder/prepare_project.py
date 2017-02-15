#! /usr/bin/env python
"""This script prepares the project to be packaged up in a docker image.

This script will make any necessary transformation into the published
directory for the project so it can be wrapped up into a Docker image.

It is assumed that the current directory is the published directory.

"""

import glob
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


def get_project_assembly_name(deps_path):
    """Returns the name of the entrypoint assembly given the .deps.json
    file name.

    Args:
        deps_path: The path to the .deps.json file for the project.

    Returns:
        The name of the entry point assembly.
    """
    return deps_path[:-len(DEPS_EXTENSION)]


def get_deps_path():
    """Finds the .deps.json file for the project.

    Looks for the .deps.json file for the project in the current
    directory, there should be only one such file per published
    project.

    Returns:
        The path to the .deps.json file for the project.
    """
    files = glob.glob(DEPS_PATTERN)
    if len(files) != 1:
        return None
    return files[0]


def main():
    """Ensures that a Dockerfile exists in the current directory.

    Assumest that the current directory is set to the root of the
    project's published (staged) directory. This also assumes that a
    .deps.json file exists in this directory with the same name as the
    main assembly for the project.

    """
    if os.path.isfile(DOCKERFILE_NAME):
        print 'Dockerfile already exists.'
        return

    deps_path = get_deps_path()
    if deps_path is None:
        print 'No .deps.json file found in this ASP.NET Core project.'
        sys.exit(1)
    project_name = get_project_assembly_name(deps_path)
    assembly_name = ASSEMBLY_NAME_TEMPLATE.format(project_name)
    if not os.path.isfile(assembly_name):
        print 'Cannot find entry point assembly %s for ASP.NET Core project' % assembly_name
        sys.exit(1)

    # Need to create the Dockerfile, we need to get the name of the
    # project to use.
    contents = DOCKERFILE_CONTENTS.format(project_name)
    with open(DOCKERFILE_NAME, 'wt') as out:
        out.write(contents)


# Start the script.
if __name__ == '__main__':
    main()
