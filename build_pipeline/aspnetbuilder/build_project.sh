#! /usr/bin/env bash
# Entry point for the builder step. Assume that the current directory
# is the root of the project.

# Restore and package the app.
dotnet restore
dotnet publish -c release



