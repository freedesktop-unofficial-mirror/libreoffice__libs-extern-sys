#*************************************************************************
#
#   $RCSfile: makefile.mk,v $
#
#   $Revision: 1.3 $
#
#   last change: $Author: obo $ $Date: 2005-07-20 09:49:11 $
#
#   The Contents of this file are made available subject to the terms of
#   either of the following licenses
#
#          - GNU Lesser General Public License Version 2.1
#          - Sun Industry Standards Source License Version 1.1
#
#   Sun Microsystems Inc., October, 2000
#
#   GNU Lesser General Public License Version 2.1
#   =============================================
#   Copyright 2000 by Sun Microsystems, Inc.
#   901 San Antonio Road, Palo Alto, CA 94303, USA
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Lesser General Public
#   License version 2.1, as published by the Free Software Foundation.
#
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public
#   License along with this library; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston,
#   MA  02111-1307  USA
#
#
#   Sun Industry Standards Source License Version 1.1
#   =================================================
#   The contents of this file are subject to the Sun Industry Standards
#   Source License Version 1.1 (the "License"); You may not use this file
#   except in compliance with the License. You may obtain a copy of the
#   License at http://www.openoffice.org/license.html.
#
#   Software provided under this License is provided on an "AS IS" basis,
#   WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
#   WITHOUT LIMITATION, WARRANTIES THAT THE SOFTWARE IS FREE OF DEFECTS,
#   MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE, OR NON-INFRINGING.
#   See the License for the specific provisions governing your rights and
#   obligations concerning the Software.
#
#   The Initial Developer of the Original Code is: Sun Microsystems, Inc.
#
#   Copyright: 2000 by Sun Microsystems, Inc.
#
#   All Rights Reserved.
#
#   Contributor(s): _______________________________________
#
#
#
#*************************************************************************

PRJ=.

PRJNAME=ooo_mozab
TARGET=ooo_mozab

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------
# ----- pkg-config start -------
.INCLUDE .IGNORE : pkgroot.mk

.IF "$(PKGCONFIG_ROOT)"!=""
PKG_CONFIG:=$(PKGCONFIG_ROOT)$/bin$/pkg-config
PKG_CONFIG_PATH:=$(PKGCONFIG_ROOT)$/lib$/pkgconfig
LD_LIBRARY_PATH!:=$(subst,$(SOLARLIBDIR),$(SOLARLIBDIR)$(PATH_SEPERATOR)$(PKGCONFIG_ROOT)$/lib $(LD_LIBRARY_PATH))
.EXPORT : PKG_CONFIG_PATH PKG_CONFIG LD_LIBRARY_PATH
.ENDIF          # "$(PKGCONFIG_ROOT)"!=""

.IF "$(BUILD_SPECIAL)"!=""
# reduce prerequisites by disabling mozilla binary
DISABLE_MOZ_EXECUTABLE=TRUE
.EXPORT : DISABLE_MOZ_EXECUTABLE
.ENDIF			# "$(BUILD_SPECIAL)"!=""

.IF "$(SYSBASE)"!="" && "$(OS)" == "LINUX"
CFLAGS:=-isystem $(SYSBASE)/usr/include
LDFLAGS:=-L$(SYSBASE)/lib -L$(SYSBASE)/usr/lib
SYSBASE_X11:=--x-includes=$(SYSBASE)/usr/include/X11 --x-libraries=$(SYSBASE)/usr/X11R6/lib
.EXPORT : CFLAGS LDFLAGS
.ENDIF			# "$(SYSBASE)"!="" && "$(OS)" == "LINUX"

# ----- pkg-config end -------

MOZILLA_VERSION*=1.7.5
.IF "$(MOZILLA_VERSION)"=="1.7b"
TARFILE_NAME=mozilla-source-1.7b-source
.ELSE
TARFILE_NAME=mozilla-source-$(MOZILLA_VERSION)
.ENDIF
TARFILE_ROOTDIR=mozilla

PATCH_FILE_NAME=mozilla-source-$(MOZILLA_VERSION).patch 

# These files are needed for the W32 build when BUILD_MOZAB is set
LIBIDL_VC71_ZIPFILE_NAME*=vc71-libIDL-0.6.8-bin.zip
LIBGLIB_VC71_ZIPFILE_NAME*=vc71-glib-1.2.10-bin.zip
WINTOOLS_ZIPFILE_NAME*=wintools.zip

ADDITIONAL_FILES=mailnews$/addrbook$/src$/nsAbMD5sum.cpp

CONFIGURE_DIR=
MOZILLA_CONFIGURE_FLAGS= $(SYSBASE_X11) --disable-tests \
                --enable-ldap \
                --enable-crypto \
                --enable-optimize \
                --enable-strip \
                --disable-profilelocking \
                --disable-activex \
                --disable-activex-scripting \
                --disable-gnomevfs \
                --disable-debug \
                --disable-xprint \
                --disable-postscript \
                --disable-freetype2 \
                --without-system-zlib \
                --disable-installer \
                --disable-accessibility \
                 --disable-xpfe-components \
                --disable-mathml \
                --disable-oji \
                --disable-profilesharing \
                --disable-boehm \
                --disable-jsloader

#disable profilelocking to share profile with mozilla
#disable activex and activex-scripting to remove the dependence of Microsoft_SDK\src\mfc\atlbase.h
#disable gnomevfs to remove the needed of gnome develop files
#disable others to save build times

.IF "$(GUI)"=="UNX"
#We do not need mozilla ui, but libIDL version are decided by default toolkit.
#default-toolkit=xlib need libIDL < 0.68
#default-toolkit=gtk2 need libIDL > 0.8 (know as libIDL2)
.IF "x$(DEFAULT_MOZILLA_TOOLKIT)"=="x"
DEFAULT_MOZILLA_TOOLKIT=gtk2
.ENDIF
MOZILLA_CONFIGURE_FLAGS+= --enable-default-toolkit=$(DEFAULT_MOZILLA_TOOLKIT)
.ENDIF

CONFIGURE_ACTION=sh -c "./configure $(MOZILLA_CONFIGURE_FLAGS)"

BUILD_DIR=
.IF "$(USE_SHELL)"!="4nt"
BUILD_ACTION:=$(GNUMAKE)
.ELSE
# This construct is needed because unitools.mk defines GNUMAKE using $ENV_TOOLS.
# $ENV_TOOLS doesn't exist for OOo builds and the cygwin make is needed.
BUILD_ACTION:=make
.ENDIF

.IF "$(GUI)"=="UNX"
.IF "$(COMNAME)"=="sunpro5"
.IF "$(BUILD_TOOLS)$/cc"=="$(shell +-which cc)"
CC:=$(COMPATH)$/bin$/cc
CXX:=$(COMPATH)$/bin$/CC
CXXFLAGS:=-features=tmplife
.EXPORT : CXXFLAGS 
.ENDIF          # "$(COMNAME)"=="sunpro5"
.ENDIF          # "$(BUILD_TOOLS)$/cc"=="$(shell +-which cc)"
.ENDIF

MOZDIR=$(MISC)$/build$/mozilla
MOZTARGET=$(OS)$(COM)$(CPU)

.IF "$(GUI)"=="WNT"
# "Our" build environment uses "NO" for the environment variable that
# indicate if system libraries should be used, the mozilla build uses
# "" in this case. This conflicts (at least for W32) with mozilla (1.7b)
# because it disables the library checks for msvc so that
# --without-system-* is not evaluated. To build the included libraries
# the affected variables have to be empty and not NO.
.IF "$(SYSTEM_ZLIB)"=="NO"
SYSTEM_ZLIB:=
.EXPORT : SYSTEM_ZLIB
.ENDIF
.IF "$(SYSTEM_JPEG)"=="NO"
SYSTEM_JPEG:=
.EXPORT : SYSTEM_JPEG
.ENDIF

# For W32-tcsh CC and CXX must not contain the wrapper, and W32-4nt ( in
# some cases ) doesn't work with DOS path notation when building mozilla.
CC:=cl.exe
CXX:=cl.exe

# Variables to install/use our own wintools
MOZTOOLSUNPACK:=$(MISC)$/build$/moztoolsunpack
MOZTOOLSINST:=$(MISC)$/build$/moztoolsinst
.IF "$(USE_SHELL)"!="4nt"
MOZ_TOOLS:=$(shell cygpath -ad "$(MISC)")\build\moztoolsinst
PATH!:=$(shell cygpath $(MOZ_TOOLS))/vc71/bin:$(shell cygpath $(MOZ_TOOLS))/bin:$(PATH)
.ELSE # "$(USE_SHELL)"!="4nt"
# MOZ_TOOLS must contain an absolute path
MOZ_TOOLS:=$(shell +echo %@SFN[$(MISC)])\build\moztoolsinst
PATH!:=$(MOZ_TOOLS)\vc71\bin;$(MOZ_TOOLS)\bin;$(PATH)
.ENDIF # "$(USE_SHELL)"!="4nt"
GLIB_PREFIX:=$(MOZ_TOOLS)\vc71
LIBIDL_PREFIX:=$(MOZ_TOOLS)\vc71

.EXPORT : PATH MOZ_TOOLS GLIB_PREFIX LIBIDL_PREFIX
.ENDIF # "$(GUI)"=="WNT"

# --- Targets ------------------------------------------------------

.IF "$(BUILD_MOZAB)"==""
all:
    @echo "Never Build Mozilla."
.ENDIF	

.INCLUDE : set_ext.mk
.INCLUDE : target.mk
.INCLUDE : tg_ext.mk

.IF "$(GUI)"=="WNT"
NEEDWINTOOLSFLAGFILE:=$(MISC)$/build$/wintools.complete
.ENDIF # "$(GUI)"=="WNT"

ALLTAR: $(NEEDWINTOOLSFLAGFILE) \
    $(MISC)$/remove_build.flag \
    extract_mozab_files

$(PACKAGE_DIR)$/$(UNTAR_FLAG_FILE) : $(MISC)$/remove_build.flag

# Since you never know what will be in a patch (for example, it may already
# patch at configure level), we remove the entire package directory if a patch
# is newer.
$(MISC)$/remove_build.flag : $(PATCH_FILE_NAME)
    $(REMOVE_PACKAGE_COMMAND)
    +$(TOUCH) $(MISC)$/remove_build.flag

# Unpack/setup Windows build tools
.IF "$(GUI)"=="WNT"
$(PACKAGE_DIR)$/$(UNTAR_FLAG_FILE) : $(MISC)$/build$/wintools.complete

$(MISC)$/build$/wintools.unpack : $(PRJ)$/download$/$(WINTOOLS_ZIPFILE_NAME)
    +-$(RENAME) $(MOZTOOLSUNPACK) $(MOZTOOLSUNPACK)_removeme
    +-$(RENAME) $(MOZTOOLSINST) $(MOZTOOLSINST)_removeme
    +-rm -rf $(MOZTOOLSUNPACK)_removeme $(MOZTOOLSINST)_removeme
    @+-$(MKDIR) $(MOZTOOLSUNPACK)
    unzip $(PRJ)$/download$/$(WINTOOLS_ZIPFILE_NAME) -d $(MOZTOOLSUNPACK)
    +$(TOUCH) $(MISC)$/build$/wintools.unpack

$(MISC)$/build$/wintools.install : $(MISC)$/build$/wintools.unpack
    +cd $(MOZTOOLSUNPACK)$/buildtools$/windows && cmd /c install.bat
    +$(TOUCH) $(MISC)$/build$/wintools.install

$(MISC)$/build$/wintools.complete : \
  $(MISC)$/build$/wintools.install \
  $(PRJ)$/download$/$(LIBIDL_VC71_ZIPFILE_NAME) \
  $(PRJ)$/download$/$(LIBGLIB_VC71_ZIPFILE_NAME)
    unzip $(PRJ)$/download$/$(LIBIDL_VC71_ZIPFILE_NAME) -d $(MOZTOOLSINST)
    unzip $(PRJ)$/download$/$(LIBGLIB_VC71_ZIPFILE_NAME) -d $(MOZTOOLSINST)
# chmod is also needed for W32-4nt build (when cygwin unzip is used)
    -chmod -R +x $(MOZTOOLSINST)$/vc71$/bin
    +$(TOUCH) $(MISC)$/build$/wintools.complete
.ENDIF # "$(GUI)"=="WNT"

zip:	\
    $(MISC)$/CREATETARBALL

.INCLUDE : extractfiles.mk
