#*************************************************************************
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# Copyright 2000, 2010 Oracle and/or its affiliates.
#
# OpenOffice.org - a multi-platform office productivity suite
#
# This file is part of OpenOffice.org.
#
# OpenOffice.org is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3
# only, as published by the Free Software Foundation.
#
# OpenOffice.org is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License version 3 for more details
# (a copy is included in the LICENSE file that accompanied this code).
#
# You should have received a copy of the GNU Lesser General Public License
# version 3 along with OpenOffice.org.  If not, see
# <http://www.openoffice.org/license.html>
# for a copy of the LGPLv3 License.
#
#*************************************************************************

# TODO: enable warnings again when external module compiles without warnings on all platforms
EXTERNAL_WARNINGS_NOT_ERRORS := TRUE

PRJ=.

PRJNAME=graphite
TARGET=so_graphite

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------
.IF "$(ENABLE_GRAPHITE)"=="TRUE"
TARFILE_NAME=silgraphite-2.3.1
PATCH_FILES=graphite-2.3.1.patch

# convert line-endings to avoid problems when patching
CONVERTFILES=\
    engine/makefile.vc8

#.IF "$(OS)"=="WNT" && "$(COM)"!="GCC"
#CONFIGURE_DIR=win32
#.ELSE
#CONFIGURE_DIR=engine
#.ENDIF

CONFIGURE_DIR=engine

.IF "$(COM)"=="MSC"
.IF "$(COMEX)"=="10"
VCNUM=7
.ELSE
VCNUM=8
.ENDIF
# make use of stlport headerfiles
EXT_USE_STLPORT=TRUE
BUILD_ACTION=nmake VERBOSE=1
.IF "$(debug)"=="true"
BUILD_FLAGS= "CFG=DEBUG"
.ENDIF
### convert CFLAGS as cl.exe cannot handle OOO"s generic ones directly
### TODO: use "guw.exe" instead?
ALLCFLAGS= $(CFLAGS) $(CFLAGSCXX) $(CFLAGSEXCEPTIONS) $(CDEFS)
JUSTASLASH= /
CFLAGS2MSC= $(ALLCFLAGS:s/-Z/$(JUSTASLASH)Z/)
CFLAGS4MSC= $(CFLAGS2MSC:s/ -/ $(JUSTASLASH)/)
BUILD_FLAGS+= "MLIB=MD" "CFLAGS4MSC=$(CFLAGS4MSC)" /F makefile.vc$(VCNUM) dll
.ENDIF

.IF "$(COM)"=="GCC"

# Does linux want --disable-shared?
.IF "$(debug)"=="true"
GR_CONFIGURE_FLAGS= --enable-debug=yes --disable-final --enable-static --disable-shared
.ELSE
GR_CONFIGURE_FLAGS= --enable-final=yes --enable-static --disable-shared
.ENDIF
EXTRA_GR_CXX_FLAGS=-fPIC

.IF "$(USE_SYSTEM_STL)"!="YES"
EXTRA_GR_LD_FLAGS=$(LIBSTLPORT) -lm
GR_LIB_PATH=LD_LIBRARY_PATH=$(SOLARVERSION)/$(INPATH)/lib$(UPDMINOREXT)
.ELSE
GR_LIB_PATH=
.ENDIF

.IF "$(OS)"=="WNT"
PATCH_FILES+=graphite-2.3.1.patch.mingw
EXTRA_GR_CXX_FLAGS=-nostdinc
.IF "$(MINGW_SHARED_GCCLIB)"=="YES"
EXTRA_GR_CXX_FLAGS+=-shared-libgcc
.ENDIF
EXTRA_GR_LD_FLAGS+=-no-undefined
.ENDIF

# don't use SOLARLIB for LDFLAGS because it pulls in system graphite so build will fail
# 
CONFIGURE_ACTION=bash -c 'CXXFLAGS="$(INCLUDE) $(CFLAGSCXX) $(CFLAGSCOBJ) $(CDEFS) $(CDEFSOBJ) $(SOLARINC) $(LFS_CFLAGS) $(EXTRA_GR_CXX_FLAGS)" $(GR_LIB_PATH) LDFLAGS="-L$(SOLARVERSION)/$(INPATH)/lib$(UPDMINOREXT) $(EXTRA_GR_LD_FLAGS)" ./configure $(GR_CONFIGURE_FLAGS)'
.ENDIF

BUILD_DIR=$(CONFIGURE_DIR)

.IF "$(OS)"=="WNT" && "$(COM)"!="GCC"
#OUT2LIB=win32$/bin.msvc$/*.lib
.IF "$(debug)"=="true"
OUT2LIB=engine$/debug$/*.lib
.ELSE
OUT2LIB=engine$/release$/*.lib
.ENDIF
.ELSE
OUT2LIB=engine$/src$/.libs$/libgraphite*.a
.ENDIF

.IF "$(COM)"=="GCC"
BUILD_ACTION=$(GNUMAKE) -j$(EXTMAXPROCESS)
.ENDIF

.IF "$(OS)"=="MACOSX"
OUT2LIB+=src$/.libs$/libgraphite.*.dylib
.ELSE
.IF "$(OS)"=="WNT" && "$(COM)"!="GCC"
#OUT2LIB+=engine$/src$/.libs$/libgraphite*.dll
.IF "$(debug)"=="true"
OUT2BIN= \
    engine$/debug$/*.dll \
    engine$/debug$/*.pdb
.ELSE
OUT2BIN= \
    engine$/release$/*.dll
#    engine$/release$/*.pdb
.ENDIF
.ELSE
#OUT2LIB+=engine$/src$/.libs$/libgraphite.so.*.*.*
.ENDIF
.ENDIF


OUTDIR2INC= \
    engine$/include$/graphite

.IF "$(OS)"=="WNT"
OUT2INC=wrappers$/win32$/WinFont.h
.ENDIF
.ELSE
dddd:
    @echo Nothing to do
.ENDIF
# --- Targets ------------------------------------------------------


.INCLUDE :	set_ext.mk
.INCLUDE :	target.mk
.INCLUDE :	tg_ext.mk

