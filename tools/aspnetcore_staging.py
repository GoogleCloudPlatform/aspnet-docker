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

This script will stage the ASP.NET Core app to the staging_dir by
publishing the app to it, which will generate a self-contained version
of the app with all of the dependencies resolved and ready to be
packaged into a Docker image.

Args:
  yaml, the path to the yaml to publish.
  staging_dir, the output directory where to stage the app.

"""


import os
import subprocess
import sys


PROJECT_JSON_NAME = 'project.json'
PROGRAMFILES_ENV = 'ProgramFiles(x86)'
DOTNET_TOOLS_PATH = r'Microsoft Visual Studio 14.0\Web\External'
NO_PROJECT_JSON_ERROR = ('No project.json found in your ASP.NET Core project, '
                         'please ensure that the app.yaml is in'
                         'the same directory as the project.json for the project..')

def get_project_path(appyaml_path):
    """Calculates the path to the project.json.

    Args:
        appyaml_path: the path to the yaml file for the deployment.

    Returns:
        The path to the project.json that should live next to the
        app.yaml in the project's root
    """
    base = os.path.dirname(appyaml_path)
    return os.path.join(base, PROJECT_JSON_NAME)


def get_tools_environment():
    """Calculates environment to use for optional publishing tools.

    During the publish process the default template for an ASP.NET
    Core app will use the gulp and bower tools. These tools are not
    usually installed on Windows so they are provided by Visual
    Studio. This function attempts to locate said tools by adding them
    to the path. If the tools are not available the publishing process
    will fail with a clear indication that they must be installed.

    Returns:
        A new environment dictionary where the PATH has been augmented
        with the path to the tools if found. Will return None if no
        tools are found.
    """
    new_env = None
    if PROGRAMFILES_ENV in os.environ:
        tools_path = os.path.join(os.environ[PROGRAMFILES_ENV], DOTNET_TOOLS_PATH)
        if os.path.isdir(tools_path):
            print 'Adding path to tools: %s' % tools_path
            new_env = os.environ.copy()
            new_env['PATH'] = os.environ['PATH'] + os.pathsep + tools_path
    return new_env


def main(appyaml_path, staging_dir):
    """Stages the project to the staging directory.

    The stage process is preformed by publishing the app to the
    staging_dir, which will be a self-contained version of the app.

    Args:
        appyaml_path: The path to the app.yaml for the project.
        stage_dir: The path to the directory where to stage the
            project. It is assumed that this directory is empty.
    """
    project_path = get_project_path(appyaml_path)
    project_root = os.path.dirname(project_path)
    if not os.path.isfile(project_path):
        raise Exception(NO_PROJECT_JSON_ERROR)

    print 'Stating to %s' % staging_dir
    args = ['dotnet', 'publish', '-o', staging_dir, '-c', 'Release']
    tools_env = get_tools_environment()
    process = subprocess.Popen(args, cwd=project_root, env=tools_env)
    result = process.wait()
    if result != 0:
        raise Exception('Failed to stage ASP.NET Core project %s' % project_root)


# Start the script.
if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
