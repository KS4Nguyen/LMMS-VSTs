# @Author:      KS4Nguyen <sebastian.nguyen86@gmail.com>
# @Date:        2025-08-30

CFLAGS += -Wall
ifeq ($(debug),on)
	CFLAGS += -D=DEBUG
	CFLAGS += -Werror -g
#	CFLAGS += -fmax-errors=6
else
	CFLAGS += -O0 -Wno-unused -Wnonnull
	CFLAGS += -fstack-protector #-Wstack-protector
	CFLAGS += -Wstringop-overflow #-Wstringop-truncation
endif

GCC := gcc

SRC := .
LIBS += -L./lib # TODO: Identify VST .a and include

VSTS = $(SRC)/*.c

.PHONY: all clean $(VSTS)

$(VSTS):
	@echo "Compiling: $@"
	# TODO: Add VST lib.a here:
	$(GCC) $(CFLAGS) $(SRC)/lib/*.a $(SRC)/$@.c -o ./$@

install:
	sh -c "./install_vst_plugins.sh"

sdk:
	sh -c "./build_vst-sdk_2.4.sh"

clean:
	sh -c "rm -rf ./lib/VST_SDK_2.4/"

all: sdk $(VSTS)
