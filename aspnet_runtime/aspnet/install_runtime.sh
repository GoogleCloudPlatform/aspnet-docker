#!/usr/bin/env bash
# Installs the DNX runtime in the current environment, sets the default runtime.

# Exit on error
set -o errexit

# Run the environment.
. /root/.dnx/dnvm/dnvm.sh

echo "Installing version: ${DNX_RUNTIME_VERSION}"

# Install both the supported runtimes and tag them for easy retrieval later.
dnvm install "${DNX_RUNTIME_VERSION}" -r mono ${DNX_USE_UNSTABLE_FEED:+"-u"} -alias mono
dnvm install "${DNX_RUNTIME_VERSION}" -r coreclr ${DNX_USE_UNSTABLE_FEED:+"-u"} -alias coreclr
