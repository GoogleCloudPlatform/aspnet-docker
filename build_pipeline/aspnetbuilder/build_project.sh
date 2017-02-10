#! /usr/bin/env bash
# Entry point for the builder step. Assume that the current directory
# is the root of the project.

# Clean the workspace to ensure succesfull build.
rm -rf ./bin ./obj ./project.lock.json

# Restore and package the app.
dotnet restore
dotnet publish -c release

# Prepare the project for deployment.
/builder/prepare_project.py -s ./ -p ./bin/release/netcoreapp1.0/publish/
