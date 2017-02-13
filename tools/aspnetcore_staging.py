#! /usr/bin/env python
"""This script prepares the project to be packaged up in a docker image.

This script will create the publish directory into the output
directory and supply the Dockerfile if necessary.

Args:
  yaml, the path to the yaml to publish.
  staging, the output directory where to stage the app.

"""

from __future__ import print_function


import argparse
import json
import os
import shutil
import subprocess
import sys
import textwrap


PROJECT_JSON_NAME = 'project.json'
PROGRAMFILES_ENV = 'ProgramFiles(x86)'
DOTNET_TOOLS_PATH = r'Microsoft Visual Studio 14.0\Web\External'


def _get_project_path(yaml):
    """Calculates the path to the project.json."""
    base = os.path.dirname(yaml)
    return os.path.join(base, PROJECT_JSON_NAME)


def _get_project_name(path):
    """Calculates the name to use."""
    with open(path, 'rt') as src:
        content = json.load(src)

    base = os.path.dirname(path)
    result = os.path.basename(base)
    if 'name' in content:
        result = content['name']
    return result


def _get_tools_environment():
    """Returns an environment suitable to invoke tools, will preturn None if the current
    environment is good enough.
    """
    new_env = None
    if PROGRAMFILES_ENV in os.environ:
        tools_path = os.path.join(os.environ[PROGRAMFILES_ENV], DOTNET_TOOLS_PATH)
        if os.path.isdir(tools_path):
            print('Adding path to tools: %s' % tools_path)
            new_env = os.environ.copy()
            new_env['PATH'] = os.environ['PATH'] + os.pathsep + tools_path
    return new_env


def _publish_project(project_root, staging):
    """Publishes the project to the staging directory."""
    args = ['dotnet', 'publish', '-o', staging, '-c', 'Release']
    tools_env = _get_tools_environment()
    process = subprocess.Popen(args, cwd=project_root, env=tools_env)
    result = process.wait()
    if result != 0:
        raise Exception('Failed to publish project')


class Project(object):
    def __init__(self, yaml):
        """Initializes the project from the yaml location."""
        self.project_path = _get_project_path(yaml)
        self.project_root = os.path.dirname(self.project_path)
        if not os.path.isfile(self.project_path):
            raise Exception('No project.json found.')
        self.name = _get_project_name(self.project_path)


    def stage(self, staging):
        """Stages the project to the staging directory."""
        print('Staging to %s' % staging)
        _publish_project(self.project_root, staging)


def main(yaml, staging):
    project = Project(yaml)
    print('Path: %s, Name: %s' % (project.project_path, project.name))
    project.stage(staging)


# Start the script.
if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
