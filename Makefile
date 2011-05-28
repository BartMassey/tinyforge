BINDIR = /usr/local/bin

all:

install:
	cp tf-add.sh $(BINDIR)/tf-add
	chmod 755 $(BINDIR)/tf-add
	cp tf-index.sh $(BINDIR)/tf-index
	chmod 755 $(BINDIR)/tf-index
