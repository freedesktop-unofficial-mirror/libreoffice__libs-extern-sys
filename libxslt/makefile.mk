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

PRJ=.

PRJNAME=libxslt
TARGET=so_libxslt

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

.IF "$(SYSTEM_LIBXSLT)" == "YES"
all:
	@echo "An already available installation of libxslt should exist on your system."
	@echo "Therefore the version provided here does not need to be built in addition."
.ENDIF

# --- Files --------------------------------------------------------

.IF "$(L10N_framework)"==""

.INCLUDE :	libxsltversion.mk

LIBXSLTVERSION=$(LIBXSLT_MAJOR).$(LIBXSLT_MINOR).$(LIBXSLT_MICRO)

TARFILE_NAME=$(PRJNAME)-$(LIBXSLTVERSION)
TARFILE_MD5=e83ec5d27fc4c10c6f612879bea9a153
PATCH_FILES=$(TARFILE_NAME).patch $(TARFILE_NAME)_win_manifest.patch

# This is only for UNX environment now
.IF "$(OS)"=="WNT"
.IF "$(COM)"=="GCC"
xslt_CC=$(CC) -mthreads
.IF "$(MINGW_SHARED_GCCLIB)"=="YES"
xslt_CC+=-shared-libgcc
.ENDIF
xslt_LIBS=
.IF "$(MINGW_SHARED_GXXLIB)"=="YES"
xslt_LIBS+=-lstdc++_s
.ENDIF
CONFIGURE_DIR=
CONFIGURE_ACTION=.$/configure
CONFIGURE_FLAGS=--enable-ipv6=no --without-crypto --without-python --enable-static=no --with-sax1=yes --build=i586-pc-mingw32 --host=i586-pc-mingw32 CC="$(xslt_CC)" CFLAGS="$(xslt_CFLAGS)" LDFLAGS="-no-undefined -Wl,--enable-runtime-pseudo-reloc-v2 -L$(ILIB:s/;/ -L/)" LIBS="$(xslt_LIBS)"  LIBXML2LIB=$(LIBXML2LIB) OBJDUMP="$(WRAPCMD) objdump"
BUILD_ACTION=chmod 777 xslt-config && $(GNUMAKE)
BUILD_FLAGS+= -j$(EXTMAXPROCESS)
BUILD_DIR=$(CONFIGURE_DIR)
.IF "$(GUI)$(COM)"=="WNTGCC"
.EXPORT : PWD
.ENDIF
.ELSE
CONFIGURE_DIR=win32
CONFIGURE_ACTION=cscript configure.js
#CONFIGURE_FLAGS=iconv=no sax1=yes
.IF "$(debug)"!=""
CONFIGURE_FLAGS+=debug=yes
.ENDIF
BUILD_ACTION=nmake
BUILD_DIR=$(CONFIGURE_DIR)
.ENDIF
.ELSE

.IF "$(OS)$(COM)"=="LINUXGCC" || "$(OS)$(COM)"=="FREEBSDGCC"
LDFLAGS:=-Wl,-rpath,'$$$$ORIGIN:$$$$ORIGIN/../ure-link/lib' -Wl,-noinhibit-exec -Wl,-z,noexecstack
.ENDIF                  # "$(OS)$(COM)"=="LINUXGCC"
.IF "$(OS)$(COM)"=="SOLARISC52"
LDFLAGS:=-Wl,-R'$$$$ORIGIN:$$$$ORIGIN/../ure-link/lib'
.ENDIF                  # "$(OS)$(COM)"=="SOLARISC52"

.IF "$(SYSBASE)"!=""
CPPFLAGS+:=-I$(SOLARINCDIR)$/external -I$(SYSBASE)$/usr$/include $(EXTRA_CFLAGS)
.IF "$(OS)"=="SOLARIS" || "$(OS)"=="LINUX"
LDFLAGS+:=-L$(SOLARLIBDIR) -L$(SYSBASE)$/lib -L$(SYSBASE)$/usr$/lib -lpthread -ldl
.ENDIF
.ENDIF			# "$(SYSBASE)"!=""

.EXPORT: CPPFLAGS
.EXPORT: LDFLAGS
.EXPORT: LIBXML2LIB

.IF "$(COMNAME)"=="sunpro5"
CPPFLAGS+:=$(ARCH_FLAGS) -xc99=none
.ENDIF                  # "$(COMNAME)"=="sunpro5"
CONFIGURE_DIR=
CONFIGURE_ACTION=.$/configure
CONFIGURE_FLAGS=--enable-ipv6=no --without-crypto --without-python --enable-static=no --with-sax1=yes
BUILD_ACTION=chmod 777 xslt-config && $(GNUMAKE)
BUILD_FLAGS+= -j$(EXTMAXPROCESS)
BUILD_DIR=$(CONFIGURE_DIR)
.ENDIF

OUT2INC=libxslt$/*.h

.IF "$(OS)"=="MACOSX"
OUT2LIB+=libxslt$/.libs$/libxslt.*.dylib
OUT2LIB+=libexslt$/.libs$/libexslt.*.dylib
OUT2BIN+=xsltproc$/.libs$/xsltproc
OUT2BIN+=xslt-config
.ELIF "$(OS)"=="WNT"
.IF "$(COM)"=="GCC"
OUT2LIB+=libxslt$/.libs$/*.a
OUT2LIB+=libexslt$/.libs$/*.a
OUT2BIN+=libxslt$/.libs$/*.dll
OUT2BIN+=libexslt$/.libs$/*.dll
OUT2BIN+=xsltproc$/.libs$/*.exe*
OUT2BIN+=xslt-config
.ELSE
OUT2LIB+=win32$/bin.msvc$/*.lib
OUT2BIN+=win32$/bin.msvc$/*.dll
OUT2BIN+=win32$/bin.msvc$/*.exe
.ENDIF
.ELSE
OUT2LIB+=libxslt$/.libs$/libxslt.so*
OUT2LIB+=libexslt$/.libs$/libexslt.so*
OUT2BIN+=xsltproc$/.libs$/xsltproc
OUT2BIN+=xslt-config
.ENDIF

# --- Targets ------------------------------------------------------
.ENDIF 			# L10N_framework
.INCLUDE : set_ext.mk
.INCLUDE : target.mk
.INCLUDE : tg_ext.mk

