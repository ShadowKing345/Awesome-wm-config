dirs := $(foreach dir, $(wildcard modules/**/),./$(dir))

build:
	@$(foreach dir, $(dirs),echo -e "$@ for dir $(dir)"; cd $(dir); $(MAKE);)

clean:
	@$(foreach dir, $(dirs),echo -e "$@ for dir $(dir)"; cd $(dir); $(MAKE) clean;)

test:
	@$(foreach dir, $(dirs),echo -e "$@ for dir $(dir)"; cd $(dir); $(MAKE) test;)

all:
	@$(foreach dir, $(dirs),echo -e "$@ for dir $(dir)"; cd $(dir); $(MAKE) all;)
