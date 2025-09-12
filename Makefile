# @Author:      KS4Nguyen <sebastian.nguyen86@gmail.com>
# @Date:        2025-08-30

# C++-Compiler n'these Flags
CXX      := g++
CXXFLAGS := -Wall

ifeq ($(debug),on)
	CXXFLAGS += -DDEBUG -Werror -g
else
	CXXFLAGS += -O0 -Wno-unused -Wnonnull \
	-fstack-protector \
	-Wstringop-overflow
endif

# SDK
SRC_DIR  := .
SDK      := ./vst_sdk_2.4
LIB_DIR  := $(SDK)/build

# Include Paths
INCLUDES := -I$(SDK)/pluginterfaces/vst2.x
INCLUDES += -I$(SDK)/public.sdk/source/vst2.x

# Source Code
SRCS_C		:= $(wildcard $(SRC_DIR)/*.c)
SRCS_CPP	:= $(wildcard $(SRC_DIR)/*.cpp)
SRCS		:= $(SRCS_C) $(SRCS_CPP)

PROGS_C		:= $(patsubst $(SRC_DIR)/%.c,%,$(SRCS_C))
PROGS_CPP	:= $(patsubst $(SRC_DIR)/%.cpp,%,$(SRCS_CPP))
PROGS		:= $(PROGS_C) $(PROGS_CPP)

# VST Library
LIBS	:= $(wildcard $(LIB_DIR)/*.a)

.PHONY: all clean install sdk doc

# Default Build Targets
all: sdk $(PROGS)

%: $(SRC_DIR)/%.c $(SRC_DIR)/%.cpp $(LIBS)
	@echo "Building $(PROGS)"
	$(CXX) $(CXXFLAGS) $(INCLUDES) $< $(LIBS) -o $@

install:
	@./install_vst_plugins.sh

sdk:
	@./install_vst_sdk.sh

clean:
	@echo "Cleaning up $(LIB_DIR) ..."
	@rm -rf $(LIB_DIR)
	@echo "Removing build targets: $(PROGS)"
	@for i in $(PROGS); do \
		if [ -e $$i ]; then \
			rm $$i; \
		fi; \
	done

total-clean: clean
	@echo "Cleaning up./doc/ ..."
	@rm -rf doc
	@echo "Deleting $(SDK) ..."
	@rm -rf $(SDK)

doc:
	@./generate_documentation.sh
	@echo "Code documentation generated as HTML at:\n  ./doc/html/index.html"
