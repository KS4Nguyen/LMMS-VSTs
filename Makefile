# @Author:      KS4Nguyen <sebastian.nguyen86@gmail.com>
# @Date:        2025-09-16

# Compiler Flags
CXX		:= g++
CC		:= gcc
CXXFLAGS	:= -Wall -fPIC -fpermissive
CCFLAGS		:= -Wall

ifeq ($(debug),on)
	CXXFLAGS += -O0 -DDEBUG -Werror -g
else
	CXXFLAGS += -O2 -Wno-unused -Wnonnull \
	-fstack-protector \
	-Wstringop-overflow
endif

# SDK
SRC_DIR  := .
SDK      := ./vst_sdk_2.4
LIB_DIR  := $(SDK)/build

# Include Paths
INCLUDES :=	-I$(SDK)/pluginterfaces/vst2.x \
		-I$(SDK)/public.sdk/source/vst2.x

# Source Code
SRCS_C		:= $(wildcard $(SRC_DIR)/*.c)
SRCS_CPP	:= $(wildcard $(SRC_DIR)/*.cpp)
SRCS		:= $(SRCS_C) $(SRCS_CPP)

OBJS_C		:= $(SRCS_C:.c=.o)
OBJS_CPP	:= $(SRCS_CPP:.cpp=.o)
OBJS		:= $(OBJS_C) $(OBJS_CPP)

PROGS_C		:= $(patsubst $(SRC_DIR)/%.c,%,$(SRCS_C))
PROGS_CPP	:= $(patsubst $(SRC_DIR)/%.cpp,%,$(SRCS_CPP))
PROGS		:= $(PROGS_C) $(PROGS_CPP)

# VST Library
LIBS	:= $(wildcard $(LIB_DIR)/*.a)

.PHONY: all clean install sdk doc

# Default Build Targets
all: $(PROGS)

# Compile objects with includes
%.o: %.cpp
	@echo "Compiling objects from .cpp sources ..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

%.o: %.c
	@echo "Compiling objects from .c sources ..."
	$(CC) $(CCFLAGS) $(INCLUDES) -c $< -o $@

# Link everything to shared library (no-main-function permitted)
$(PROGS): $(OBJS) $(LIBS)
	@echo "Linking $@"
	$(CC) -shared -o $@ $^

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
