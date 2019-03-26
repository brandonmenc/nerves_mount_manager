# Makefile for building port binaries
#
# Makefile targets:
#
# all/install   build and install the NIF
# clean         clean build products and intermediates
#
# Variables to override:
#
# MIX_COMPILE_PATH path to the build's ebin directory
#
# CC            C compiler
# CROSSCOMPILE	crosscompiler prefix, if any
# CFLAGS	compiler flags for compiling all C files
# ERL_CFLAGS	additional compiler flags for files using Erlang header files
# ERL_EI_INCLUDE_DIR include path to ei.h (Required for crosscompile)
# ERL_EI_LIBDIR path to libei.a (Required for crosscompile)
# LDFLAGS	linker flags for linking all binaries
# ERL_LDFLAGS	additional linker flags for projects referencing Erlang libraries

ifeq ($(MIX_COMPILE_PATH),)
	$(error MIX_COMPILE_PATH should be set by elixir_make!)
endif

PREFIX = $(MIX_COMPILE_PATH)/../priv
BUILD  = $(MIX_COMPILE_PATH)/../obj

# Check that we're on a supported build platform
ifeq ($(CROSSCOMPILE),)
    # Not crosscompiling, so check that we're on Linux.
    ifneq ($(shell uname -s),Linux)
        $(warning nerves_runtime only works on Linux, but crosscompilation)
        $(warning is supported by defining $$CROSSCOMPILE, $$ERL_EI_INCLUDE_DIR,)
        $(warning and $$ERL_EI_LIBDIR. See Makefile for details. If using Nerves,)
        $(warning this should be done automatically.)
        $(warning .)
        $(warning Skipping C compilation unless targets explicitly passed to make.)
	DEFAULT_TARGETS = $(PREFIX)
    endif
endif
DEFAULT_TARGETS ?= $(PREFIX) $(PREFIX)/mountevent

# Set Erlang-specific compile and linker flags
ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR) -lei

LDFLAGS += -lmnl
CFLAGS ?= -O2 -Wall -Wextra -Wno-unused-parameter -pedantic
CC ?= $(CROSSCOMPILE)-gcc

# Enable for debug messages
# CFLAGS += -DDEBUG

CFLAGS += -std=gnu99

ifeq ($(origin CROSSCOMPILE), undefined)
SUDO_ASKPASS ?= /usr/bin/ssh-askpass
SUDO ?= sudo

# If not cross-compiling, then run sudo and suid the port binary
# so that it's possible to debug
update_perms = \
	SUDO_ASKPASS=$(SUDO_ASKPASS) $(SUDO) -- sh -c 'chown root:root $(1); chmod +s $(1)'
else
# If cross-compiling, then permissions need to be set some build system-dependent way
update_perms =
endif

calling_from_make:
	mix compile

all: install

install: $(BUILD) $(DEFAULT_TARGETS)

$(BUILD)/%.o: src/%.c
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

$(PREFIX)/mountevent: $(BUILD)/mountevent.o
	$(CC) $^ $(ERL_LDFLAGS) $(LDFLAGS) -o $@
	$(call update_perms, $@)

$(PREFIX):
	mkdir -p $@

$(BUILD):
	mkdir -p $@

clean:
	$(RM) $(PREFIX)/mountevent $(BUILD)/*.o

.PHONY: all clean calling_from_make install
