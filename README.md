<img src=".stuff/lmms_virt_logo.png" alt="LMMS Virtual Instruments Logo" width="200" />

# Audio Filters for LMMS

**Repository Status**

Ring Modulator
![Status: In Progress]( https://img.shields.io/badge/Status-InProgress-yellow )

Spartializer
![Status: Open]( https://img.shields.io/badge/Status-Open-gray )


# Installation Instruction

Install LMMS Audio Suite:

	sudo apt update
	sudo apt -y install lmms

Compile and install the VST-SDK (version 2.4) run:

	make sdk

Then make the plugins:

	make all

Copy the plugins in your LMMS subdirectory **plugins/**

To create code documentations in **./doc/html/index.html** run:

	make doc
	

# Sources

[DSP Filters](https://github.com/vinniefalco/DSPFilters)

[JFilters (C++)](https://github.com/Iunusov/JFilters)

Not used in this repo, but will be usefull:

[LibSndFile](https://github.com/libsndfile/libsndfile.git)
