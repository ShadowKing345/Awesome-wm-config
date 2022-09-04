LUA = $(shell lua -e 'if type(jit) == "table" then print "luajit" else print "lua" end')
PKGS      = libpulse $(LUA)

INCS     := $(shell pkg-config --cflags --print-errors $(PKGS)) -I./
CFLAGS   := -std=gnu99 -ggdb -W -Wall -Wextra -fPIC -pedantic $(INCS) $(CFLAGS)

LIBS     := $(shell pkg-config --libs --print-errors $(PKGS))
LDFLAGS  := $(LIBS) $(LDFLAGS) $(LIBFLAG) -Wl,--export-dynamic

SRCS  = $(wildcard *.c)
HEADS = $(wildcard *.h)
OBJS  = $(foreach obj,$(SRCS:.c=.o),$(obj))

init.so: $(OBJS)
	@echo $(CC) -o $@ $(OBJS)
	@$(CC) -shared -o $@ $(OBJS) $(LDFLAGS)

$(OBJS): $(HEADS)

.c.o:
	@echo $(CC) -c $< -o $@
	@$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

clean:
	rm -f init.so $(OBJS)

test:
	lua -e "require('init')"

all: init.so
