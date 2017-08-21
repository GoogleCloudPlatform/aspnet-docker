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

"""This script parses the given .yaml file.

This script will parse the given .yaml file and prints the value of
the path.
"""

import argparse
import os
import sys
import yaml


def parse_yaml(path):
    """Parses the given .yaml file and returns the tree."""
    with open(path, 'r') as src:
        return yaml.load(src)

def apply_path(content, path):
    parts = path.split('.')
    current = content
    for item in parts:
        if item in current:
            current = current[item]
        else:
            return ""
    return current


def main(params):
    content = parse_yaml(params.file_path)
    print(apply_path(content, params.path))


# Start the script.
if __name__ == '__main__':
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument('-f', '--file_path',
                        dest='file_path',
                        help='The path to the .yaml file to parse.',
                        required=True)
    PARSER.add_argument('-p', '--path',
                        dest='path',
                        help='The path to parse.',
                        required=True)
    main(PARSER.parse_args())
