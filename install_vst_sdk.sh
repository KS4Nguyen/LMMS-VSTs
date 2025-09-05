#!/usr/bin/env bash

# Exit on unset variable, non-zero exit code or pipe failure
set -euo pipefail

trap 'echo "Error: $BASH_COMMAND" >&2; exit 1' ERR

# Moved repo at github - Attention! Non-commercial license:
#       https://github.com/R-Tur/VST_SDK_2.4.git
#       * locally stored:
#               ./lib/VST_SDK_2.4.tgz
#
OLDDIR=$(pwd)
WDIR="."

cmake --version

cd $WDIR

tar -xzf VST_SDK_2.4.tgz
cd VST_SDK_2.4/
if [ ! -d ./build ]; then
  mkdir build
fi
cd build

cmake ../
make clean
make all
make VST_SDK

cd $OLDDIR
