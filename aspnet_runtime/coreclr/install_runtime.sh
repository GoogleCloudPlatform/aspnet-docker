#!/usr/bin/env bash
# Installs the DNX runtime in the current environment, sets the default runtime.

# Exit on error
set -o errexit

# Run the environment.
. /root/.dnx/dnvm/dnvm.sh

# Install the runtime and tag it as default.
dnvm install "${DNX_RUNTIME_VERSION}" -r coreclr
dnvm alias default "dnx-coreclr-linux-x64.${DNX_RUNTIME_VERSION}"
