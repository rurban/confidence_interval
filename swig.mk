
swig-all::

ifndef MODULE_NAME
$(error need MODULE_NAME)
endif

# freebsd: cd /usr/ports/devel/swig; sudo make install
# ubuntu: sudo apt-get install swig
SWIG=swig

#### language-specific flags
#### perl
PERL_ARCH_LIB:=$(shell eval `$(PERL) -V:archlib`; echo $$archlib)
PERL_CORE_INCLUDE=$(PERL_ARCH_LIB)/CORE
IFLAGS+=-I$(PERL_CORE_INCLUDE)
CFLAGS+=$(IFLAGS) $(shell eval `$(PERL) -V:ccflags`; echo $$ccflags)
LDFLAGS+=$(shell eval `$(PERL) -V:ldflags`; echo $$ldflags)
LDFLAGS+=$(shell eval `$(PERL) -V:libs`; echo $$libs) -L$(PERL_CORE_INCLUDE) -lperl#
DLEXT=$(shell eval `$(PERL) -V:dlext`; echo $$dlext)
###

#### platform-specific flangs
#CFLAGS+=-fPIC
# this fixes the off64_t error in perl.h on ubuntu. these are ugly flags..
#CFLAGS+=-D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 
#CFLAGS+=-D_REENTRANT -D_GNU_SOURCE -DDEBIAN 

#### generic flags
CFLAGS:=$(subst -Wall,,$(CFLAGS))
#SWIGFLAGS+=$(IFLAGS)

#### files
OBJ=$(MODULE_NAME)_wrap.o $(MODULE_NAME).o
GENERATED=$(MODULE_NAME).pm $(MODULE_NAME)_wrap.c
LIB=$(MODULE_NAME).$(DLEXT)
MODULE_H=$(MODULE_NAME).h

#### rules
.SUFFIXES:	.c .e .i .pm .o .$(DLEXT) _wrap.c _wrap.o .pl .run

.i_wrap.c: $(MODULE_H)
	$(SWIG) $(SWIGFLAGS) -perl5 $<

.i.pm: $(MODULE_H)
	$(SWIG) $(SWIGFLAGS) -perl5 $<

_wrap.o.$(DLEXT):
	$(CC) -shared -o $@ $(OBJ) $(LDFLAGS)

#### targets
swig-all:: $(OBJ) $(LIB)
swig-lib: $(LIB)

swig-clean::
	rm -f $(GENERATED)
	rm -f *.o *.$(DLEXT)

swig-gen:
	$(SWIG) $(SWIGFLAGS) -perl5 $(MODULE_NAME).i
