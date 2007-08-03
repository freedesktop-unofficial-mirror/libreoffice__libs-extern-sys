#*************************************************************************
#
#   OpenOffice.org - a multi-platform office productivity suite
#
#   $RCSfile: makefile.mk,v $
#
#   $Revision: 1.9 $
#
#   last change: $Author: hr $ $Date: 2007-08-03 12:41:11 $
#
#   The Contents of this file are made available subject to
#   the terms of GNU Lesser General Public License Version 2.1.
#
#
#     GNU Lesser General Public License Version 2.1
#     =============================================
#     Copyright 2005 by Sun Microsystems, Inc.
#     901 San Antonio Road, Palo Alto, CA 94303, USA
#
#     This library is free software; you can redistribute it and/or
#     modify it under the terms of the GNU Lesser General Public
#     License version 2.1, as published by the Free Software Foundation.
#
#     This library is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston,
#     MA  02111-1307  USA
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

LIBXSLTVERSION=1.1.16

TARFILE_NAME=$(PRJNAME)-$(LIBXSLTVERSION)
PATCH_FILE_NAME=$(TARFILE_NAME).patch

ADDITIONAL_FILES=libxml2-config

# This is only for UNX environment now

.IF "$(OS)"=="WNT"
.IF "$(COM)"=="GCC"
CONFIGURE_DIR=
CONFIGURE_ACTION=chmod 777 libxml2-config && .$/configure
CONFIGURE_FLAGS=--enable-ipv6=no --without-crypto --without-python --enable-static=no --with-sax1=yes --build=i586-pc-mingw32 --host=i586-pc-mingw32 CFLAGS="$(xslt_CFLAGS) -D_MT" LDFLAGS="$(xslt_LDFLAGS) -no-undefined -L$(ILIB:s/;/ -L/)" LIBS="-lmingwthrd"  LIBXML2LIB=$(LIBXML2LIB) ZLIB3RDLIB=$(ZLIB3RDLIB) OBJDUMP="$(WRAPCMD) objdump"
BUILD_ACTION=$(GNUMAKE)
BUILD_FLAGS+= -j$(EXTMAXPROCESS)
BUILD_DIR=$(CONFIGURE_DIR)
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
LDFLAGS:=-Wl,-rpath,'$$$$ORIGIN' -Wl,-noinhibit-exec -Wl,-z,noexecstack
.ENDIF                  # "$(OS)$(COM)"=="LINUXGCC"
.IF "$(OS)$(COM)"=="SOLARISC52"
LDFLAGS:=-Wl,-R'$$$$ORIGIN'
.ENDIF                  # "$(OS)$(COM)"=="SOLARISC52"

.IF "$(SYSBASE)"!=""
xslt_CFLAGS+=-I$(SYSBASE)$/usr$/include -I$(SOLARINCDIR)$/external
.IF "$(OS)"=="SOLARIS" || "$(OS)"=="LINUX"
LDFLAGS+=-L$(SYSBASE)$/lib -L$(SYSBASE)$/usr$/lib -L$(SOLARLIBDIR) -lpthread -ldl
.ENDIF
.ENDIF			# "$(SYSBASE)"!=""

.EXPORT: LDFLAGS

.IF "$(COMNAME)"=="sunpro5"
xslt_CFLAGS+=-xc99=none
.ENDIF                  # "$(COMNAME)"=="sunpro5"
CONFIGURE_DIR=
CONFIGURE_ACTION=chmod 777 libxml2-config && .$/configure
CONFIGURE_FLAGS=--enable-ipv6=no --without-crypto --without-python --enable-static=no --with-sax1=yes CFLAGS="$(xslt_CFLAGS)" LIBXML2LIB=$(LIBXML2LIB) ZLIB3RDLIB=$(ZLIB3RDLIB)
BUILD_ACTION=$(GNUMAKE)
BUILD_FLAGS+= -j$(EXTMAXPROCESS)
BUILD_DIR=$(CONFIGURE_DIR)
.ENDIF

OUT2INC=libxslt$/*.h

.IF "$(OS)"=="MACOSX"
OUT2LIB+=libxslt$/.libs$/libxslt.*.dylib
OUT2LIB+=libexslt$/.libs$/libexslt.*.dylib
OUT2BIN+=xsltproc$/.libs$/xsltproc
.ELIF "$(OS)"=="WNT"
.IF "$(COM)"=="GCC"
OUT2BIN+=libxslt$/.libs$/*.dll
OUT2BIN+=libexslt$/.libs$/*.dll
OUT2BIN+=xsltproc$/.libs$/*.exe*
.ELSE
OUT2LIB+=win32$/bin.msvc$/*.lib
OUT2BIN+=win32$/bin.msvc$/*.dll
OUT2BIN+=win32$/bin.msvc$/*.exe*
.ENDIF
.ELSE
OUT2LIB+=libxslt$/.libs$/libxslt.so*
OUT2LIB+=libexslt$/.libs$/libexslt.so*
OUT2BIN+=xsltproc$/.libs$/xsltproc
.ENDIF

# --- Targets ------------------------------------------------------

.INCLUDE : set_ext.mk
.INCLUDE : target.mk
.INCLUDE : tg_ext.mk

