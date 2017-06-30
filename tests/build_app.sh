#! /usr/bin/env bash

# This script will build a single app and publish it to the given directory.
#   $1, the path to the app to build.
#   $2, the absolute directory where to publish the app.

# Exit on error or undefined variable
set -eu

echo "Building app $1 and publishing to $2"

pushd $1
dotnet restore
dotnet publish -o $2
popd
