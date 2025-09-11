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
INCLUDES :=	-I$(SRC_DIR) \
		-I$(SDK)/pluginterfaces/vst2.x \
		-I$(SDK)/public.sdk/source/vst2.x

# Source Code
SRCS	:= $(wildcard $(SRC_DIR)/*.c)
SRCS	+= $(wildcard $(SRC_DIR)/*.cpp)
PROGS	:= $(patsubst $(SRC_DIR)/%.c,%,$(SRCS))
PROGS	+= $(patsubst $(SRC_DIR)/%.cpp,%,$(SRCS))

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
	@echo "Cleaning up..."
	@rm -rf $(LIB_DIR)
	#@rm -f $(PROGS)

total-clean: clean
	@rm -rf doc
	@rm -rf $(SDK)

doc:
	@./generate_documentation.sh
	@echo "Documentation located at: ./doc/html/index.html"
