UNAME_S := $(shell uname -s)

CC ?= cc
CFLAGS ?= -std=c11 -Wall -Wextra -Wpedantic -O2
LDFLAGS ?=

ifeq ($(UNAME_S),Darwin)
SDKROOT ?= $(shell xcrun --sdk macosx --show-sdk-path)
CFLAGS += -isysroot $(SDKROOT)
CURSES_LIBS ?= -lncurses
else
CURSES_LIBS ?= $(shell if command -v ncursesw6-config >/dev/null 2>&1; then ncursesw6-config --libs; elif command -v ncurses6-config >/dev/null 2>&1; then ncurses6-config --libs; else printf '%s' '-lncursesw'; fi)

# Some Linux hosts ship 32-bit linker scripts in /usr/lib while the 64-bit
# shared libraries live in /lib64, so prefer the concrete 64-bit .so files when
# they are available.
ifneq ($(wildcard /lib64/libncursesw.so.6),)
ifneq ($(wildcard /lib64/libtinfo.so.6),)
CURSES_LIBS := /lib64/libncursesw.so.6 /lib64/libtinfo.so.6
endif
endif

ifneq ($(wildcard /usr/lib64/libncursesw.so.6),)
ifneq ($(wildcard /usr/lib64/libtinfo.so.6),)
CURSES_LIBS := /usr/lib64/libncursesw.so.6 /usr/lib64/libtinfo.so.6
endif
endif

ifneq ($(wildcard /usr/lib/x86_64-linux-gnu/libncursesw.so.6),)
ifneq ($(wildcard /usr/lib/x86_64-linux-gnu/libtinfo.so.6),)
CURSES_LIBS := /usr/lib/x86_64-linux-gnu/libncursesw.so.6 /usr/lib/x86_64-linux-gnu/libtinfo.so.6
endif
endif
endif

LDLIBS ?= $(CURSES_LIBS)

BIN := ncdiff
SRC := src/main.c

.PHONY: all clean install

PREFIX ?= /usr/local
bindir ?= $(PREFIX)/bin

all: $(BIN)

$(BIN): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $@ $(LDFLAGS) $(LDLIBS)

install: $(BIN)
	install -d $(DESTDIR)$(bindir)
	install -m 0755 $(BIN) $(DESTDIR)$(bindir)/$(BIN)

clean:
	rm -f $(BIN)
