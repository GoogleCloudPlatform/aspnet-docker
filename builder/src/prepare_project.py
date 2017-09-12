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

from __future__ import print_function

import argparse
import glob
import json
import os
import sys
import textwrap
import xml.etree.ElementTree as ET
from distutils.version import StrictVersion
import yaml


APP_YAML_NAME = 'app.yaml'
ASSEMBLY_NAME_TEMPLATE = '{0}.dll'
CSPROJ_PATTERN = '*.csproj'
FSPROJ_PATTERN = '*.fsproj'
DEPS_PATTERN = '*.deps.json'
SOLUTION_PATTERN = '*.sln'
DEPS_EXTENSION = '.deps.json'
DOCKERFILE_NAME = 'Dockerfile'
GLOBALJSON_NAME = 'global.json'
NETCOREAPP_VERSION_PREFIX = 'netcoreapp'
NETCORE_APP_PREFIX = 'microsoft.netcore.app/'


def get_major_version(version):
    """Returns the major version of a parsed version.

    Args:
        version: A string with a .NET Core version.

    Returns:
        A string with the major version.
    """
    parsed_version = version.split('.')
    return '.'.join(parsed_version[0:2])


def get_file_from_pattern(root, pattern):
    """This function returns the file that matches the given pattern.

    This function uses the given pattern to find the single file that
    matches it. If more than one file is found then we act as if
    nothing was found.

    Args:
        root: A string with the path where to search.
        pattern: A string with the pattern to use to find the file.

    Returns:
        A string with the path to the file found or None if no file,
        or more than one, is found.
    """
    root_pattern = os.path.join(root, pattern)
    files = glob.glob(root_pattern)
    if len(files) != 1:
        return None
    return files[0]


def get_deps_path(root):
    """Finds the .deps.json file for the app.

       Looks for the .deps.json file for the app in the given
       directory, there should be only one such file per published
       project.

       Args:
           root: The path to the root of the app.

       Returns:
           The path to the .deps.json file for the project.

    """
    return get_file_from_pattern(root, DEPS_PATTERN)


def get_project_path(root):
    """Find the .csproj file for the app.

    Looks for the .csproj for the app in the given directory. There
    should be only one .csproj found.

    Args:
        root: A string with the path to the root of the app's sources.

    Returns:
        A string with the path to the .csproj for the app, or None if
        nothing or more than one file was found.
    """
    csproj_path = get_file_from_pattern(root, CSPROJ_PATTERN)
    fsproj_path = get_file_from_pattern(root, FSPROJ_PATTERN)
    if csproj_path and fsproj_path:
        print('The project contains both a .csproj and a .fsproj, this is not supported.')
        sys.exit(1)

    if csproj_path:
        return csproj_path
    if fsproj_path:
        return fsproj_path


def get_solution_path(root):
    """Find the .sln file for the app.

    Looks for the .sln for the app in the given directory. There
    should be only one .sln found.

    Args:
        root: A string with the path to the root of the app's sources.

    Returns:
        A string with the path to the .sln for the app, or None if
        nothing or more than one file was found.

    """
    return get_file_from_pattern(root, SOLUTION_PATTERN)


def get_startup_project(app_yaml):
    """Returns the startup_project setting stored in app.yaml

    Args:
        app_yaml: String with the path to the app.yaml file to parse.

    Returns:

        A string with the contents of the startup_project setting, or
        None if the setting cannot be found. If there's a path it will
        be transformed into a Unix style path.
    """
    with open(app_yaml, 'r') as src:
        content = yaml.load(src)
        try:
            result = content['runtime_config']['startup_project']
            return result.replace('\\', '/')
        except KeyError:
            return None


def is_supported_sdk(requested_sdk, sdks):
    """Validates the given SDK is a supported SDK.

    Args:
        requested_sdk: A string with the version of the SDK to check.
        sdks: A list of strings with the list of supported SDKs.

    Returns:
        A boolean with True if the sdk is supported, False if not.
    """
    if requested_sdk in sdks:
        return True

    # TODO: Check for the versions.
    return False


def validate_sdks(root, sdks):
    """Validates that the SDK required by the app.

    This function will ensure that the SDK required by the app, as
    indicated by the 'global.json' file, is in the list of supported
    SDKs.

    Args:
        root: String with the path to the root of the app.
        sdks: List of strings witht the versions of the SDKs supported.
    """
    globaljson_path = os.path.join(root, GLOBALJSON_NAME)
    if not os.path.isfile(globaljson_path):
        print('Warning, no global.json found. Will be using the latest version of the ' +
              '.NET core SDK installed')
        return

    # No SDKs are passed in, this means that validation is optional.
    if not sdks:
        return

    with open(globaljson_path, 'r') as src:
        content = json.load(src)
        try:
            requested_sdk = content['sdk']['version']
            if not is_supported_sdk(requested_sdk, sdks):
                print(('The requested version of the .NET Core SDK (%s) is ' +
                       'not supported.') % requested_sdk)
                sys.exit(1)
        except KeyError:
            print('The file %s is not a valid globa.json file.' % globaljson_path)
            sys.exit(1)


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


class PublishedApp(object):
    """Represents a published app.

    This class represetns an app that has already been published. This
    is the simplest clase for an app. A very simple Dockerfile can be
    generated.
    """

    # Dockerfile template to be used when packaging up published apps.
    DOCKERFILE_CONTENTS = textwrap.dedent(
        """\
        FROM {runtime_image}
        ADD ./ /app
        ENV ASPNETCORE_URLS=http://*:${{PORT}}
        WORKDIR /app
        ENTRYPOINT [ "dotnet", "{dll_name}.dll" ]
        """)

    def __init__(self, root):
        """Initializes the PublishedApp instance.

        Args:
            root: A string with the path to the root of the published
                  app.
        """
        self.root = root
        self.deps_path = get_deps_path(root)

    def generate_dockerfile(self, version_map, output):
        """Generates the Dockerfile for this app.

        Generates a simple Dockerfile that will wrap an already
        published app. This Dockerfile will just take the files as is,
        no build will be attempted.

        Args:
            version_map: A dictionary that maps versions of the
                         runtime to the base Docker image to use.
            output: A string with the path where to save the resulting
                    Dockerfile.
        """
        minor_version = self._get_runtime_minor_version()
        if minor_version is None:
            print('No valid .NET Core runtime version found for the app or it is not a ' +
                  'supported app.')
            sys.exit(1)

        base_image = get_base_image(version_map, minor_version)
        if base_image is None:
            print('The app requires .NET Core runtime version {0} which is not supported at ' +
                  'this time.').format(minor_version)
            sys.exit(1)

        project_name = self._get_project_assembly_name()
        assembly_name = ASSEMBLY_NAME_TEMPLATE.format(project_name)
        if not os.path.isfile(os.path.join(self.root, assembly_name)):
            print('Cannot find entry point assembly {0} for ASP.NET Core project'
                  .format(assembly_name))
            sys.exit(1)

        contents = PublishedApp.DOCKERFILE_CONTENTS.format(runtime_image=base_image.image,
                                                           dll_name=project_name)
        with open(output, 'wt') as out:
            out.write(contents)

    def _get_project_assembly_name(self):
        """Returns the name of the entrypoint assembly given the .deps.json
        file name.

        Returns:
            The name of the entry point assembly.
        """
        filename = os.path.basename(self.deps_path)
        return filename[:-len(DEPS_EXTENSION)]

    def _get_runtime_minor_version(self):
        """Determines the target of the .NET Core runtime needed by the app.

        Reads the given .deps.json file and determines the version of the
        runtime used by the app.

        Returns:
            The version of the runtime used by the app.
        """
        with open(self.deps_path, 'r') as src:
            content = json.load(src)
            try:
                libraries = content['libraries']
                for key in libraries:
                    if key.lower().startswith(NETCORE_APP_PREFIX):
                        version = key[len(NETCORE_APP_PREFIX):]
                        return version.split('-')[0]
            except KeyError:
                return None


class SingleProjectApp(object):
    """An app that is composed of a single .csproj build file.

    This class represents an app that is composed of a single app, as
    it is with the apps generated using "dotnet new" by default.

    Since there is a single project, this project is considered to be
    the entry point for the app.
    """

    # Dockerfile template to be used when packaging .csproj based apps.
    DOCKERFILE_CONTENTS = textwrap.dedent(
        """\
        FROM gcr.io/cloud-builders/csharp/dotnet AS builder
        COPY . /src
        WORKDIR /src
        RUN dotnet restore --packages /packages
        RUN dotnet publish -c Release -o /published

        FROM {runtime_image}
        COPY --from=builder /published /app
        ENV ASPNETCORE_URLS=http://*:${{PORT}}
        WORKDIR /app
        ENTRYPOINT [ "dotnet", "{dll_name}.dll" ]
        """)

    def __init__(self, root, project):
        """Initializes the instance of SingleProjectApp.

        Args:
            root: A string with the path to the directory that contains the project.
            project: A string with the path to the project file.
        """
        self.root = root
        self.project = project

    def generate_dockerfile(self, version_map, output):
        """Generates the Dockerfile for the app.

        This method will generate a multi-stage Dockerfile that will
        first build the app (restore + publish) and then will package
        up the resulting file into a Docker image.

        Args:
            version_map: A dictionary that maps versions of the
                         runtime to the base Docker image to use.
            output: A string with the path where to save the resulting
                    Dockerfile.

        """
        minor_version = self._get_project_runtime_version()
        if minor_version is None:
            print('No valid .NET Core runtime version found for the app or it is not a ' +
                  'supported app.')
            sys.exit(1)

        base_image = get_base_image(version_map, minor_version)
        if base_image is None:
            print('The app requires .NET Core runtime version {0} which is not supported at ' +
                  'this time.').format(minor_version)
            sys.exit(1)

        project_name = self._get_project_assembly_name()
        contents = SingleProjectApp.DOCKERFILE_CONTENTS.format(runtime_image=base_image.image,
                                                               dll_name=project_name)
        with open(output, 'wt') as out:
            out.write(contents)

    def _get_project_assembly_name(self):
        """Returns the name of the main assembly for the project.

        This method will use the file path as the basis for the name
        of the assembly.

        Returns:
            A string with the name of the main assbemly for the project.
        """
        basename = os.path.basename(self.project)
        return os.path.splitext(basename)[0]

    def _get_project_runtime_version(self):
        """This method returns runtime targeted by this project.

        This method will parse the .csproj file and look for the
        TargetFramework property if present.

        Returns:
            A string with the target version.
        """
        tree = ET.parse(self.project)
        root = tree.getroot()
        framework_element = root.find('./PropertyGroup/TargetFramework')
        if framework_element is None:
            return None

        framework = framework_element.text
        if not framework.startswith(NETCOREAPP_VERSION_PREFIX):
            print('The app is not supported to release, must be an executable.')
            sys.exit(1)

        return framework[len(NETCOREAPP_VERSION_PREFIX):]


class SolutionApp(SingleProjectApp):
    """An app that is composed of a solution and one, or more, projects.

    This class contains the information for an app that is composed of
    a .sln and one, or more, projects. One of the projects will be the
    startup project and thus the one used to launch the app in the
    generated Dockerfile.
    """

    # Dockerfile template to be used when packaging .sln based apps.
    DOCKERFILE_CONTENTS = textwrap.dedent(
        """\
        FROM gcr.io/cloud-builders/csharp/dotnet AS builder
        COPY . /src
        WORKDIR /src
        RUN dotnet restore --packages /packages
        RUN dotnet publish -c Release -o /published {main_project}

        FROM {runtime_image}
        COPY --from=builder /published /app
        ENV ASPNETCORE_URLS=http://*:${{PORT}}
        WORKDIR /app
        ENTRYPOINT [ "dotnet", "{dll_name}.dll" ]
        """)

    def __init__(self, root, app_yaml):
        main_project = get_startup_project(app_yaml)
        super(SolutionApp, self).__init__(root, get_startup_project(app_yaml))
        self.main_project = main_project

    def generate_dockerfile(self, version_map, output):
        """Generates the Dockerfile for the app.

        This method will generate a Dockerfile that will build/publish
        the app and then package it up.
        """
        minor_version = self._get_project_runtime_version()
        if minor_version is None:
            print('No valid .NET Core runtime version found for the app or it is not a ' +
                  'supported app.')
            sys.exit(1)

        base_image = get_base_image(version_map, minor_version)
        if base_image is None:
            print('The app requires .NET Core runtime version {0} which is not supported at ' +
                  'this time.').format(minor_version)
            sys.exit(1)

        project_name = self._get_project_assembly_name()
        contents = SolutionApp.DOCKERFILE_CONTENTS.format(runtime_image=base_image.image,
                                                          main_project=self.main_project,
                                                          dll_name=project_name)
        with open(output, 'wt') as out:
            out.write(contents)


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
            print('Invalid version map entry {0}'.format(entry))
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


def get_app(root, app_yaml, sdks):
    """Detects the kind of app given the sources.

    This function will inspect the app and determine what kind of app
    it is. Will return an instance of the appropriate class to handle
    that kind of app.
    """
    deps_path = get_deps_path(root)
    if deps_path:
        return PublishedApp(root)

    solution_path = get_solution_path(root)
    if solution_path:
        validate_sdks(root, sdks)
        return SolutionApp(root, app_yaml)

    project_path = get_project_path(root)
    if project_path:
        validate_sdks(root, sdks)
        return SingleProjectApp(root, project_path)

    return None


def main(params):

    """Ensures that a Dockerfile exists in the current directory.

    Assumest that the current directory is set to the root of the
    project's published (staged) directory. This also assumes that a
    .deps.json file exists in this directory with the same name as the
    main assembly for the project.

    """
    # The app cannot specify it's own Dockerfile when building with
    # the aspnetcore image, the builder is the one that has to build
    # it. To avoid any confusion the builder will fail with this
    # error.
    if os.path.isfile(DOCKERFILE_NAME):
        print('A Dockerfile already exists in the workspace, this Dockerfile ' +
              'cannot be used with the aspnetcore runtime.')
        sys.exit(1)

    # Detect the type of app being deployed.
    app = get_app(params.root, os.path.join(params.root, APP_YAML_NAME), params.sdks)
    if not app:
        print('The app is not supported for deployment.')
        sys.exit(1)

    # Generate the Dockerfile for the app.
    version_map = parse_version_map(params.version_map)
    app.generate_dockerfile(version_map, params.output)


# Start the script.
if __name__ == '__main__':
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument('-m', '--version-map',
                        dest='version_map',
                        help='The mapping of supported versions to images.',
                        nargs='+',
                        required=True)
    PARSER.add_argument('-s', '--supported-sdks',
                        dest='sdks',
                        help='The list of supported SDK versions.',
                        nargs='+',
                        required=False)
    PARSER.add_argument('-o', '--output',
                        help='The output for the Dockefile.',
                        default=DOCKERFILE_NAME,
                        required=False)
    PARSER.add_argument('-r', '--root',
                        help='The path to the root of the app.',
                        default='.',
                        required=False)
    main(PARSER.parse_args())
