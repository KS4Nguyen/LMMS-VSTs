#!/usr/bin/env bash

# Exit on unset variable, non-zero exit code or pipe failure
set -euo pipefail

trap 'echo "Error: $BASH_COMMAND" >&2; exit 1' ERR

# Moved repo at github - Attention! Non-commercial license:
#       https://github.com/R-Tur/VST_SDK_2.4.git
#       * locally stored:
#               ./lib/VST_SDK_2.4.tgz
#

VST_SDK=https://r-tur@bitbucket.org/r-tur/vst_sdk_2.4.git

OLDDIR=$(pwd)

cmake --version

filename="$(basename "$VST_SDK")"
dir="${filename%.*}"

if [ ! -d "$dir" ]; then
  git clone "$VST_SDK"
  sync

  cd "$dir"

  # Inside SDK directory
  git pull
fi

if [ -d "$dir" ]; then
  cd "$dir"

  # Inside SDK directory

  if [ ! -d ./build ]; then
    mkdir -p build/cmake.run.linux.x86_64.Local
  fi
  cd build/cmake.run.linux.x86_64.Local

  # Inside the build directory
  cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -G "Unix Makefiles" ../..

  make VST_SDK

  # Leave build-directory and go back to SDK directory
  cd ../..
fi


cd $OLDDIR

# End-of-File
