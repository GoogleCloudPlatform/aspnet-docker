#! /usr/bin/env python
"""This script prepares the project to be packaged up in a docker image.

This script will make any necessary transformation into the published
directory for the project so it can be wrapped up into a Docker image.

"""

from __future__ import print_function

import argparse
import json
import os
import shutil
import sys
import textwrap

# Parser for the arguments for the program.
parser = argparse.ArgumentParser()
parser.add_argument('-s', '--source',
                    help='The source directory for the project.',
                    required=True)
parser.add_argument('-p', '--published',
                    help='The directory where the project was published.',
                    required=True)


PROJECT_NAME = "project.json"
DOCKERFILE_NAME = "Dockerfile"
DOCKERFILE_CONTENTS = textwrap.dedent(
    """\
    FROM b.gcr.io/aspnet-docker/aspnet:1.0.3
    ADD ./ /app
    ENV ASPNETCORE_URLS=http://*:${{PORT}}
    WORKDIR /app
    ENTRYPOINT [ "dotnet", "{0}.dll" ]
    """)


def get_project_name(project_path):
    with open(project_path, 'rt') as src:
        content = json.load(src)

    result = 'workspace'
    if 'name' in content:
        result = content['name']
    return result


def copy_or_create_dockerfile(project_root, published_root):
    project_path = os.path.join(project_root, PROJECT_NAME)
    src_dockerfile_path = os.path.join(project_root, DOCKERFILE_NAME)
    dest_dockerfile_path = os.path.join(published_root, DOCKERFILE_NAME)

    # Validate that this is indeed a .NET Core app project directory.
    if not os.path.isfile(project_path):
        print('No project.json found')
        sys.exit(1)

    # If a Dockerfile already exists in the project, use it.
    if os.path.isfile(src_dockerfile_path):
        print('Found source Dockerfile.')
        shutil.copyfile(src_dockerfile_path, dest_dockerfile_path)
        return None

    # Need to create the Dockerfile, we need to get the name of the
    # project to use.
    name = get_project_name(project_path)
    contents = DOCKERFILE_CONTENTS.format(name)
    with open(dest_dockerfile_path, 'wt') as out:
        out.write(contents)


def main():
    copy_or_create_dockerfile(params.source, params.published)


# Start the script.
if __name__ == '__main__':
    params = parser.parse_args()
    main()
