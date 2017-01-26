#! /usr/bin/env bash
# Entry point for the builder step. Assume that the current directory
# is the root of the project.

# Restore and package the app.
dotnet restore
dotnet publish -c release

# Prepare the project for deployment.
/builder/prepare_project.py -s ./ -p ./bin/release/netcoreapp1.0/publish/
