#!/bin/bash

if [ -f "vst_hello_world" ]; then
	cp vst_cringmod ./plugins/vst/
fi

if [ -f "vst_cringmod" ]; then
	cp vst_cringmod ./plugins/vst/
fi

if [ -f "vst_spartializer" ]; then
	cp vst_cringmod ./plugins/vst/
fi

exit $?
