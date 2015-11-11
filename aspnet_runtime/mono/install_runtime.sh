#!/usr/bin/env bash
# Installs the DNX runtime in the current environment, sets the default runtime.

# Run the environment.
. /root/.dnx/dnvm/dnvm.sh

# Install the runtime and tag it as default.
dnvm install "${DNX_RUNTIME_VERSION}" -r mono
dnvm alias default "dnx-mono.${DNX_RUNTIME_VERSION}"

