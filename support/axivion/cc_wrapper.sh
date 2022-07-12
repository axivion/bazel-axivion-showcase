#!/bin/bash

set -eu

# -no_absolute_filenames: make cafeCC emit relative paths (needed for include scanning)
# --diag_suppress=1561: suppress predefined meaning of "__DATE__" discarded
BAUHAUS_CONFIG=/opt/bauhaus-suite/compiler_config \
    exec /opt/bauhaus-suite/bin/cafeCC \
        -no_absolute_filenames --diag_suppress=1561 "$@"