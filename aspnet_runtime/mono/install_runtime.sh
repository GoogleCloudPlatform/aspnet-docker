#!/usr/bin/env bash
# Installs the DNX runtime in the current environment, sets the default runtime.

# Exit on error
set -o errexit

# Run the environment.
. /root/.dnx/dnvm/dnvm.sh

echo "Installing version: ${DNX_RUNTIME_VERSION} for runtime: ${DNX_RUNTIME_ENV}"

# Install the runtime and tag it as default.
dnvm install "${DNX_RUNTIME_VERSION}" -r "${DNX_RUNTIME_ENV}"
dnvm alias default "${DNX_RUNTIME_VERSION}" -r "${DNX_RUNTIME_ENV}"
