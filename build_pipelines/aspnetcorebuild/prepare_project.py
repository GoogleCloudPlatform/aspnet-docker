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
import json
import os
import sys
import textwrap
from distutils.version import StrictVersion


ASSEMBLY_NAME_TEMPLATE = '{0}.dll'
DEPS_PATTERN = '*.deps.json'
DEPS_EXTENSION = '.deps.json'
DOCKERFILE_NAME = 'Dockerfile'
DOCKERFILE_CONTENTS = textwrap.dedent(
    """\
    FROM {runtime_image}
    ADD ./ /app
    ENV ASPNETCORE_URLS=http://*:${{PORT}}
    WORKDIR /app
    ENTRYPOINT [ "dotnet", "{dll_name}.dll" ]
    """)
NETCORE_APP_PREFIX = 'microsoft.netcore.app/'


def get_project_assembly_name(deps_path):
    """Returns the name of the entrypoint assembly given the .deps.json
    file name.

    Args:
        deps_path: The path to the .deps.json file for the project.

    Returns:
        The name of the entry point assembly.
    """
    filename = os.path.basename(deps_path)
    return filename[:-len(DEPS_EXTENSION)]


def get_deps_path(root):
    """Finds the .deps.json file for the project.

    Looks for the .deps.json file for the project in the current
    directory, there should be only one such file per published
    project.

    Args:
        root: The path to the root of the app.

    Returns:
        The path to the .deps.json file for the project.
    """
    app_root = os.path.join(root, DEPS_PATTERN)
    files = glob.glob(app_root)
    if len(files) != 1:
        return None
    return files[0]


def get_runtime_minor_version(deps_path):
    """Determines the target of the .NET Core runtime needed by the app.

    Reads the given .deps.json file and determines the version of the
    runtime used by the app.

    Returns:
        The version of the runtime used by the app.
    """
    with open(deps_path, 'r') as src:
        content = json.load(src)
        try:
            libraries = content['libraries']
            for key in libraries:
                if key.lower().startswith(NETCORE_APP_PREFIX):
                    version = key[len(NETCORE_APP_PREFIX):]
                    return version.split('-')[0]
        except KeyError:
            return None


def get_major_version(version):
    """Returns the major version of a parsed version.

    Args:
        version: A string with a .NET Core version.

    Returns:
        A string with the major version.
    """
    parsed_version = version.split('.')
    return '.'.join(parsed_version[0:2])


class BaseImage(object):
    """The information about the base image for a given .NET Core version."""

    def __init__(self, version, image):
        """Initializes the BaseImage object.

        Args:
            version: A string with the .NET Core version.
            image: A Docker image name
        """
        self.version = version
        self.major_version = get_major_version(self.version)
        self.image = image

    def supports(self, version):
        """Determines if this image can run the requested version.

        This method determines if this base image can run the
        requested .NET Core version. It will do so by:
        * Comparing version major verison numbers, major versions are
          not backwards compatible.
        * Within a major version an older minor version cannot run an
          app built against a newer minor version.

        Args:
            version: A string with the requested version to compare.

        Returns:
            True if the base image can support the requested version,
            False otherwise.
        """
        major_version = get_major_version(version)
        return (self.major_version == major_version and
                StrictVersion(self.version) >= StrictVersion(version))


def parse_version_map(version_map):
    """Produces a list of version to Docker tag from the map.

    Parses the given version_map and produces a list that contains all
    of the supported .NET Core runtime versions and their
    corresponding Docker images.

    Returns:
        The list with the supported versions of .NET Core runtime.

    """
    result = []
    for entry in version_map:
        try:
            key, value = entry.split('=')
            result.append(BaseImage(key, value))
        except ValueError:
            print 'Invalid version map entry {0}'.format(entry)
            sys.exit(1)
    # Returns the list sorted in descending order, this way the latest
    # minor version is always available first.
    result.sort(key=lambda x: x.version, reverse=True)
    return result


def get_base_image(version_map, version):
    """Selects the appropriate base image from the version map.

    This function takes into account the .NET Core versioning story to
    determine the appropriate base image for the given version. It
    will select from within the same major version and only if the
    minor version is >= than the required image.

    Note that this function assumes that the version_map is sorted
    according to the priority order of the versions.

    Args:p
        version_map: The container of all supported minor versions.
        version: The requested version string.

    Returns:
        The Docker image to use as the base image, None if no image
        could be found.

    """
    for entry in version_map:
        if entry.supports(version):
            return entry
    return None


def main(params):
    """Ensures that a Dockerfile exists in the current directory.

    Assumest that the current directory is set to the root of the
    project's published (staged) directory. This also assumes that a
    .deps.json file exists in this directory with the same name as the
    main assembly for the project.

    """
    version_map = parse_version_map(params.version_map)

    # The app cannot specify it's own Dockerfile when building with
    # the aspnetcore image, the builder is the one that has to build
    # it. To avoid any confusion the builder will fail with this
    # error.
    if os.path.isfile(DOCKERFILE_NAME):
        print ('A Dockerfile already exists in the workspace, this Dockerfile ' +
               'cannot be used with the aspnetcore runtime.')
        sys.exit(1)

    deps_path = get_deps_path(params.root)
    if deps_path is None:
        print 'No .deps.json file found for the app'
        sys.exit(1)

    minor_version = get_runtime_minor_version(deps_path)
    if minor_version is None:
        print ('No valid .NET Core runtime version found for the app or it is not a ' +
               'supported app.')
        sys.exit(1)

    base_image = get_base_image(version_map, minor_version)
    if base_image is None:
        print ('The app requires .NET Core runtime version {0} which is not supported at ' +
               'this time.').format(minor_version)
        sys.exit(1)

    project_name = get_project_assembly_name(deps_path)
    assembly_name = ASSEMBLY_NAME_TEMPLATE.format(project_name)
    if not os.path.isfile(os.path.join(params.root, assembly_name)):
        print 'Cannot find entry point assembly {0} for ASP.NET Core project'.format(assembly_name)
        sys.exit(1)

    contents = DOCKERFILE_CONTENTS.format(runtime_image=base_image.image, dll_name=project_name)
    with open(params.output, 'wt') as out:
        out.write(contents)


# Start the script.
if __name__ == '__main__':
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument('-m', '--version-map',
                        dest='version_map',
                        help='The mapping of supported versions to images.',
                        nargs='+',
                        required=True)
    PARSER.add_argument('-o', '--output',
                        help='The output for the Dockefile.',
                        default=DOCKERFILE_NAME,
                        required=False)
    PARSER.add_argument('-r', '--root',
                        help='The path to the root of the app.',
                        default='.',
                        required=False)
    main(PARSER.parse_args())
