LUA = $(shell lua -e 'if type(jit) == "table" then print "luajit" else print "lua" end')
PKGs      = libpulse $(LUA)

INCS     := $(shell pkg-config --cflags --print-errors $(PKGs)) -I./
FLAGS   := -std=gnu99 -ggdb -W -Wall -Wextra -fPIC -pedantic $(INCS) $(FLAGS)

LIBS     := $(shell pkg-config --libs --print-errors $(PKGs))
LDFLAGS  := $(LIBS) $(LDFLAGS) $(LIBFLAG) -Wl,--export-dynamic

SRCS  = $(wildcard *.c)
HEADS = $(wildcard *.h)
OBJs  = $(foreach obj,$(SRCS:.c=.o),$(obj))

init.so: $(OBJs)
	@echo $(CC) -o $@ $(OBJs)
	@$(CC) -shared -o $@ $(OBJs) $(LDFLAGS)

$(OBJs): $(HEADS)

.c.o:
	@echo $(CC) -c $< -o $@
	@$(CC) -c $(FLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f init.so $(OBJs)

test:
	lua test.lua

all: init.so
