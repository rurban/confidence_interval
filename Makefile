#
# usage: make clean all test
#

all::
PERL:=perl
MODULE_NAME=confidence_interval
EXE=$(MODULE_NAME)
include swig.mk
CC:=$(shell eval `perl -V:cc`; echo $$cc)

all:: swig-all $(EXE)

clean: swig-clean
	rm -f $(EXE)

CFLAGS+=-Wall
#LDFLAGS+=-lm

$(EXE):
	$(CC) -DBUILD_COMMAND  $(MODULE_NAME).c -lm -o $(EXE)

test: test-cmd test-pl

test-cmd: $(EXE)
	./$(EXE) 2     10 0.1
	./$(EXE) 20    100 0.1
	./$(EXE) 200   1000 0.1
	./$(EXE) 2000  10000 0.1
	./$(EXE) 20000 100000 0.1
	./$(EXE) 200000 1000000 0.1

tt:
	@echo $(IFLAGS)

test-pl:
	$(PERL) -I. test.pl

e:
	$(CC) -I$(PERL_CORE_INCLUDE) -Wall -E -o $(MODULE_NAME)_wrap.E $(MODULE_NAME)_wrap.c

