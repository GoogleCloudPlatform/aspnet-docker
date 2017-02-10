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


PROJECT_JSON_NAME='project.json'
DOCKERFILE_NAME = "Dockerfile"
DOCKERFILE_CONTENTS = textwrap.dedent(
    """\
    FROM b.gcr.io/aspnet-docker/aspnet:1.0.3
    ADD ./ /app
    ENV ASPNETCORE_URLS=http://*:${{PORT}}
    WORKDIR /app
    ENTRYPOINT [ "dotnet", "{0}.dll" ]
    """)


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


def _publish_project(project_root, staging):
    args = ['dotnet', 'publish', '-o', staging, '-c', 'Release']
    process = subprocess.Popen(args, cwd=project_root)
    result = process.wait()
    if result != 0:
        raise Exception('Failed to publish project')


def _copy_or_generate_dockerfile(project_root, name, staging):
    src_dockerfile = os.path.join(project_root, DOCKERFILE_NAME)
    dest_dockerfile = os.path.join(staging, DOCKERFILE_NAME)

    # If the source project has a Dockerfile copy it.
    if os.path.isfile(src_dockerfile):
        print('Found source Dockerfile.')
        shutil.copyfile(src_dockerfile, dest_dockerfile)
        return

    # No Dockerfile was found, create a new one.
    contents = DOCKERFILE_CONTENTS.format(name)
    with open(dest_dockerfile, 'wt') as out:
        out.write(contents)


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
        _copy_or_generate_dockerfile(self.project_root, self.name, staging)


def main(yaml, staging):
    project = Project(yaml)
    print('Path: %s, Name: %s' % (project.project_path, project.name))
    project.stage(staging)


# Start the script.
if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
