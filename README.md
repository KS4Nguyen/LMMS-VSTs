<img src=".stuff/lmms_virt_logo.png" alt="LMMS Virtual Instruments Logo" width="200" />

# Audio Filters for LMMS


Ring Modulator

![Status: In Progress]( https://img.shields.io/badge/Status-InProgress-yellow )

Spartializer

![Status: Open]( https://img.shields.io/badge/Status-Open-gray )



# Installation Instructions


1) __Dependencies__

You can use the VST Plugins in Fruity-Loops, ...

To Install LMMS on Linux run:

	sudo apt update
	sudo apt -y install lmms

For compiling the VST SDK (see next section) you need:

* git

* CMake & Ninja

* build-essential package

Get them with:

	sudo apt update
	sudo apt install -y git build-essential ninja-build


2) __Compiling VST-SDK 2.4__

	make sdk


3) __Creating the VST Plugins__

	make

Copy the plugins in your LMMS subdirectory **plugins/**


# Code Documentations

Doxygen is needed and can be installed with

	sudo apt update 
	sudo apt install -y doxygen

The main page for the documentation will be generated at:
	
	./doc/html/index.html
	
Generate with:

	make doc
	

# Sources

[DSP Filters](https://github.com/vinniefalco/DSPFilters)

[JFilters (C++)](https://github.com/Iunusov/JFilters)

Not used in this repo, but will be usefull:

[LibSndFile](https://github.com/libsndfile/libsndfile.git)
