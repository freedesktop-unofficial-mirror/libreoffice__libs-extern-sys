#*************************************************************************
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
# 
# Copyright 2008 by Sun Microsystems, Inc.
#
# OpenOffice.org - a multi-platform office productivity suite
#
# $RCSfile: makefile.mk,v $
#
# $Revision: 1.48 $
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

PRJ=.

PRJNAME=nss
TARGET=nss

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------

.IF "$(ENABLE_NSS_MODULE)"!="YES"
all:
	@echo "NSS will not be built. ENABLE_NSS_MODULE is '$(ENABLE_NSS_MODULE)'"
.ENDIF	

TARFILE_NAME=nss_3_12_4
TARFILE_ROOTDIR=mozilla
PATCH_FILES=nss.patch

.IF "$(debug)" != ""
.ELSE
BUILD_OPT=1
.EXPORT: BUILD_OPT
.ENDIF


.IF "$(GUI)"=="UNX"
.IF "$(OS)$(COM)"=="LINUXGCC"
.IF "$(CPU)"=="X"
# force 64-bit buildmode
USE_64:=1
.EXPORT : USE_64
.ENDIF			# "$(CPU)"=="X"
.ENDIF                  # "$(OS)$(COM)"=="LINUXGCC"


.IF "$(OS)"=="MACOSX"
.IF "$(EXTRA_CFLAGS)"!=""
CPP:=gcc -E $(EXTRA_CFLAGS)
CXX:=g++ $(EXTRA_CFLAGS)
CC:=gcc $(EXTRA_CFLAGS)
.EXPORT : CPP
.ENDIF # "$(EXTRA_CFLAGS)"!=""
.ENDIF # "$(OS)"=="MACOSX"

OUT2LIB=dist$/out$/lib$/*$(DLLPOST)

BUILD_DIR=security$/nss
BUILD_ACTION= $(GNUMAKE) nss_build_all

.ENDIF			# "$(GUI)"=="UNX"


.IF "$(GUI)"=="WNT"

.IF "$(COM)"=="GCC"

PATCH_FILES+=nss.patch.mingw

moz_build:=$(shell cygpath -p $(MOZILLABUILD))
PATH!:=$(moz_build)/bin:$(PATH)

nss_CC=$(CC)
nss_CXX=$(CXX)
.IF "$(MINGW_SHARED_GCCLIB)"=="YES"
nss_CC+=-shared-libgcc
nss_CXX+=-shared-libgcc
.ENDIF

nss_LIBS=
.IF "$(MINGW_SHARED_GXXLIB)"=="YES"
nss_LIBS+=-lstdc++_s
.ENDIF


BUILD_DIR=security$/nss
BUILD_ACTION=NS_USE_GCC=1 CC="$(nss_CC)" CXX="$(nss_CXX)" OS_LIBS="$(nss_LIBS)" OS_TARGET=WIN95 _WIN32_IE=0x500 PATH="$(PATH)" DEFINES=-D_WIN32_IE=0x500 $(GNUMAKE) nss_build_all

OUT2LIB= \
	dist$/out$/lib$/libnspr4.a \
	dist$/out$/lib$/libnss3.a \
	dist$/out$/lib$/libnssdbm3.a \
	dist$/out$/lib$/libnssutil3.a \
	dist$/out$/lib$/libplc4.a \
	dist$/out$/lib$/libplds4.a \
	dist$/out$/lib$/libsmime3.a \
	dist$/out$/lib$/libsoftokn3.a \
	dist$/out$/lib$/libsqlite3.a \
	dist$/out$/lib$/libssl3.a

.ELSE			# "$(COM)"=="GCC"
MOZ_MSVCVERSION= 9
.EXPORT : MOZ_MSVCVERSION
.IF "$(USE_SHELL)"=="4nt"
PATH!:=$(MOZILLABUILD)/msys/bin;$(MOZILLABUILD)/moztools/bin;$(PATH)
.ELSE			# $(USE_SHELL)"=="4nt"
moz_build:=$(shell cygpath -p $(MOZILLABUILD))
PATH!:=$(moz_build)/msys/bin:$(moz_build)/moztools/bin:$(PATH)
.ENDIF			# $(USE_SHELL)"=="4nt"
.EXPORT : PATH

#Using WINNT will cause at least that nspr4.dll, plc4.dll, plds4.dll 
#become libnspr4.dll, libplc4.dll, libplds4.dll
#WINNT causes the use of Microsoft fibers (specific to Windows NT and Windows 2000). 
#OS_TARGET= WINNT
OS_TARGET=WIN95
.EXPORT : OS_TARGET

# make use of stlport headerfiles
EXT_USE_STLPORT=TRUE

#To build nss one has to call "make nss_build_all" in 
#mozilla/security/nss
NSS_BUILD_DIR= $(subst,\,/ $(PWD)/$(MISC)/build/mozilla/security/nss)
BUILD_ACTION= $(subst,/,$/ $(MOZILLABUILD)/msys/bin/bash) -i \
	-c "cd $(NSS_BUILD_DIR) && make nss_build_all"

OUT2LIB= \
 	dist$/out$/lib$/nspr4.lib \
 	dist$/out$/lib$/nss3.lib \
 	dist$/out$/lib$/nssdbm3.lib \
 	dist$/out$/lib$/nssutil3.lib \
 	dist$/out$/lib$/plc4.lib \
 	dist$/out$/lib$/plds4.lib \
 	dist$/out$/lib$/smime3.lib \
 	dist$/out$/lib$/softokn3.lib \
 	dist$/out$/lib$/sqlite3.lib \
 	dist$/out$/lib$/ssl3.lib

.ENDIF			# "$(COM)"=="GCC"

OUT2BIN=dist$/out$/lib$/*$(DLLPOST)
.ENDIF			# "$(GUI)"=="WNT"


OUTDIR2INC=dist$/public$/nss dist$/out$/include

# --- Targets ------------------------------------------------------

.INCLUDE : set_ext.mk
.INCLUDE :	target.mk
.INCLUDE :	tg_ext.mk


