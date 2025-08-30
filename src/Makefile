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

CC := gcc

# Sources and Libraries:
SRC_DIR := .
LIB_DIR := ./lib

# Get all .c sources and compile them:
SRCS    := $(wildcard $(SRC_DIR)/*.c)
VSTS    := $(patsubst $(SRC_DIR)/%.c,%,$(SRCS))

LIBS    := $(wildcard $(LIB_DIR)/*.a)

.PHONY: all clean

%: $(SRC_DIR)/%.c $(LIBS)
    @echo "Compiling $< → $@"
    $(CC) $(CFLAGS) -I$(SRC_DIR) $< $(LIBS) -o $@

install:
	sh -c "./install_vst_plugins.sh"

sdk:
	sh -c "./build_vst-sdk_2.4.sh"

clean:
	sh -c "rm -rf ./lib/VST_SDK_2.4/"
@$(RM) $(PROGS)

all: sdk $(VSTS)
