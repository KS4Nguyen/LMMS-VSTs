#!/usr/bin/env bash

# Exit on unset variable, non-zero exit code or pipe failure
set -euo pipefail

trap 'echo "Error: $BASH_COMMAND" >&2; exit 1' ERR

if [ "$(doxygen --version)" = ="" ]; then
	sudo apt update
	sudo apt install -y doxygen
fi

if [ ! -d doc ]; then
	mkdir doc
fi

doxygen -u
doxygen

