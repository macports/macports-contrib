.PHONY: all install

all:

install:
	@for dir in compiler ftdetect ftplugin snippets syntax; do \
		cp -rv $$dir/* ~/.vim/$$dir/ ; \
	done
