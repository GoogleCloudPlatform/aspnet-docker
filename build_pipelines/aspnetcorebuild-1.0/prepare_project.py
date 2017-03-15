#! /usr/bin/env python

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.

"""This script prepares the project to be packaged up in a docker image.

This script will make any necessary transformation into the published
directory for the project so it can be wrapped up into a Docker image.

It is assumed that the current directory is the published directory.

"""

import argparse
import glob
import os
import sys
import textwrap


# Arguments for the builder.
PARSER = argparse.ArgumentParser()
PARSER.add_argument('-r', '--runtime-image',
                    dest='runtime_image',
                    help='The runtime image to use for the Dockerfile.',
                    required=True)


ASSEMBLY_NAME_TEMPLATE = '{0}.dll'
DEPS_PATTERN = '*.deps.json'
DEPS_EXTENSION = '.deps.json'
DOCKERFILE_NAME = 'Dockerfile'
DOCKERFILE_CONTENTS = textwrap.dedent(
    """\
    FROM {0}
    ADD ./ /app
    ENV ASPNETCORE_URLS=http://*:${{PORT}}
    WORKDIR /app
    ENTRYPOINT [ "dotnet", "{1}.dll" ]
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


def main(params):
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
    contents = DOCKERFILE_CONTENTS.format(params.runtime_image, project_name)
    with open(DOCKERFILE_NAME, 'wt') as out:
        out.write(contents)


# Start the script.
if __name__ == '__main__':
    main(PARSER.parse_args())
