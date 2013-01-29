.PHONY: all install

prefix := ~/.vim

all:

install:
	@for dir in compiler ftdetect ftplugin indent snippets syntax; \
	do \
		mkdir -p $(DESTDIR)$(prefix)/$$dir/ ; \
		cp -rv $$dir/* $(DESTDIR)$(prefix)/$$dir/ ; \
	done
