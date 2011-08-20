.PHONY: all install

DESTDIR=~/.vim

all:

install:
	@for dir in compiler ftdetect ftplugin snippets syntax; do \
		mkdir -p $(DESTDIR)/$$dir/ ; \
		cp -rv $$dir/* $(DESTDIR)/$$dir/ ; \
	done
