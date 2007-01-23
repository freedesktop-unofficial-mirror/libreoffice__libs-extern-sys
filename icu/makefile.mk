#*************************************************************************
#
#   OpenOffice.org - a multi-platform office productivity suite
#
#   $RCSfile: makefile.mk,v $
#
#   $Revision: 1.32 $
#
#   last change: $Author: obo $ $Date: 2007-01-23 06:31:31 $
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

PRJNAME=icu
TARGET=so_icu

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------

.INCLUDE :	icuversion.mk

.IF "$(ICU_MICRO)"!="0"
TARFILE_NAME=icu-$(ICU_MAJOR).$(ICU_MINOR).$(ICU_MICRO)
.ELSE
TARFILE_NAME=icu-$(ICU_MAJOR).$(ICU_MINOR)
.ENDIF
TARFILE_ROOTDIR=icu

PATCH_FILE_NAME=${TARFILE_NAME}.patch

# ADDITIONAL_FILES=

.IF "$(GUI)"=="UNX"
.IF "$(COMNAME)"=="sunpro5"
.IF "$(BUILD_TOOLS)$/cc"=="$(shell +-which cc)"
CC:=$(COMPATH)$/bin$/cc
CXX:=$(COMPATH)$/bin$/CC
.ENDIF          # "$(BUILD_TOOLS)$/cc"=="$(shell +-which cc)"
.ENDIF          # "$(COMNAME)"=="sunpro5"

.IF "$(SYSBASE)"!=""
icu_CFLAGS+=-I$(SYSBASE)$/usr$/include
.IF "$(COMNAME)"=="sunpro5"
icu_CFLAGS+=$(C_RESTRICTIONFLAGS)
.ENDIF			# "$(COMNAME)"=="sunpro5"
icu_LDFLAGS+=-L$(SYSBASE)$/usr$/lib
.ENDIF			# "$(SYSBASE)"!=""

icu_CFLAGS+=-O $(ARCH_FLAGS)
icu_CXXFLAGS+=-O $(ARCH_FLAGS)

# until someone introduces SOLARIS 64-bit builds
.IF "$(OS)"=="SOLARIS"
DISABLE_64BIT=--enable-64bit-libs=no
.ENDIF			# "$(OS)"=="SOLARIS"

CONFIGURE_DIR=source

CONFIGURE_ACTION=sh -c 'CFLAGS="$(icu_CFLAGS)" CXXFLAGS="$(icu_CXXFLAGS)" LDFLAGS="$(icu_LDFLAGS)" ./configure --enable-layout --enable-static --enable-shared=yes $(DISABLE_64BIT)'

#CONFIGURE_FLAGS=--enable-layout --enable-static --enable-shared=yes --enable-64bit-libs=no
CONFIGURE_FLAGS=

# Use of
# CONFIGURE_ACTION=sh -c 'CFLAGS=-O CXXFLAGS=-O ./configure'
# CONFIGURE_FLAGS=--enable-layout --enable-static --enable-shared=yes --enable-64bit-libs=no
# doesn't work as it would result in
# sh -c 'CFLAGS=-O CXXFLAGS=-O ./configure' --enable-layout ...
# note the position of the single quotes.

BUILD_DIR=$(CONFIGURE_DIR)
BUILD_ACTION=$(GNUMAKE)
OUT2LIB= \
    $(BUILD_DIR)$/lib$/libicudata$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR).$(ICU_MICRO) \
    $(BUILD_DIR)$/lib$/libicudata$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR) \
    $(BUILD_DIR)$/lib$/libicudata$(DLLPOST) \
    $(BUILD_DIR)$/lib$/libicuuc$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR).$(ICU_MICRO) \
    $(BUILD_DIR)$/lib$/libicuuc$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR) \
    $(BUILD_DIR)$/lib$/libicuuc$(DLLPOST) \
    $(BUILD_DIR)$/lib$/libicui18n$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR).$(ICU_MICRO) \
    $(BUILD_DIR)$/lib$/libicui18n$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR) \
    $(BUILD_DIR)$/lib$/libicui18n$(DLLPOST) \
    $(BUILD_DIR)$/lib$/libicule$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR).$(ICU_MICRO) \
    $(BUILD_DIR)$/lib$/libicule$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR) \
    $(BUILD_DIR)$/lib$/libicule$(DLLPOST) \
    $(BUILD_DIR)$/lib$/libicutu$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR).$(ICU_MICRO) \
    $(BUILD_DIR)$/lib$/libicutu$(DLLPOST).$(ICU_MAJOR)$(ICU_MINOR) \
    $(BUILD_DIR)$/lib$/libicutu$(DLLPOST)

OUT2BIN= \
    $(BUILD_DIR)$/bin$/genccode \
    $(BUILD_DIR)$/bin$/genbrk \
    $(BUILD_DIR)$/bin$/gencmn

.ENDIF

.IF "$(GUI)"=="WNT"
CONFIGURE_DIR=source
.IF "$(USE_SHELL)"=="4nt"
BUILD_ACTION_SEP=^
.ELSE			# "$(USE_SHELL)"=="4nt"
BUILD_ACTION_SEP=;
.ENDIF			# "$(USE_SHELL)"=="4nt"
BUILD_DIR=source
.IF "full_debug" == ""
# Activating the debug mechanism produces incompatible libraries, you'd have
# at least to relink all modules that are directly using ICU. Note that library
# names get a 'd' appended and you'd have to edit the solenv/inc/libs.mk
# ICU*LIB macros as well. Normally you don't want all this.
#
# Instead, use the normal already existing Release build and edit the
# corresponding *.vcproj file of the section you're interested in. Make sure
# that
# - for the VCCLCompilerTool section the following line exists:
#   DebugInformationFormat="3"
# - and for the VCLinkerTool the line
#   GenerateDebugInformation="TRUE"
# Then delete the corresponding Release output directory, and delete the target
# flag files
# $(OUTPATH)/misc/build/so_built_so_icu
# $(OUTPATH)/misc/build/so_predeliver_so_icu
# and run dmake again, after which you may copy the resulting libraries to your
# OOo/SO installation.
ICU_BUILD_VERSION=Debug
ICU_BUILD_LIBPOST=d
.ELSE
ICU_BUILD_VERSION=Release
ICU_BUILD_LIBPOST=
.ENDIF

CONFIGURE_ACTION+= $(COPY) ..$/..$/..$/..$/..$/makefiles.zip . $(BUILD_ACTION_SEP) unzip makefiles.zip

.IF "$(CCNUMVER)"<="001400000000"
BUILD_ACTION=cd allinone && nmake /f all.mak CFG="all - Win32 Release" EXFLAGS="-EHsc" && cd ..$/..
.ELSE
BUILD_ACTION=cd allinone && nmake /f all.mak CFG="all - Win32 Release" EXFLAGS="-EHa -Zc:wchar_t-" && cd ..$/..
.ENDIF

OUT2LIB= \
    $(BUILD_DIR)$/..$/lib$/icudata.lib \
    $(BUILD_DIR)$/..$/lib$/icuin$(ICU_BUILD_LIBPOST).lib \
    $(BUILD_DIR)$/..$/lib$/icuuc$(ICU_BUILD_LIBPOST).lib \
    $(BUILD_DIR)$/..$/lib$/icule$(ICU_BUILD_LIBPOST).lib \
    $(BUILD_DIR)$/..$/lib$/icutu$(ICU_BUILD_LIBPOST).lib

OUT2BIN= \
    $(BUILD_DIR)$/..$/bin$/icudt$(ICU_MAJOR)$(ICU_MINOR).dll \
    $(BUILD_DIR)$/..$/bin$/icuin$(ICU_MAJOR)$(ICU_MINOR)$(ICU_BUILD_LIBPOST).dll \
    $(BUILD_DIR)$/..$/bin$/icuuc$(ICU_MAJOR)$(ICU_MINOR)$(ICU_BUILD_LIBPOST).dll \
    $(BUILD_DIR)$/..$/bin$/icule$(ICU_MAJOR)$(ICU_MINOR)$(ICU_BUILD_LIBPOST).dll \
    $(BUILD_DIR)$/..$/bin$/icutu$(ICU_MAJOR)$(ICU_MINOR)$(ICU_BUILD_LIBPOST).dll \
    $(BUILD_DIR)$/..$/bin$/genccode.exe \
    $(BUILD_DIR)$/..$/bin$/genbrk.exe \
    $(BUILD_DIR)$/..$/bin$/gencmn.exe

.ENDIF		# "$(GUI)"=="WNT"

# --- Targets ------------------------------------------------------

.INCLUDE : set_ext.mk
.INCLUDE :	target.mk
.INCLUDE :	tg_ext.mk

.IF "$(BINARY_PATCH_FILE_NAME)"!=""

$(PACKAGE_DIR)$/so_add_binary :  $(PACKAGE_DIR)$/$(ADD_FILES_FLAG_FILE)
    cd $(PACKAGE_DIR) && gunzip -c $(BACK_PATH)$(BINARY_PATCH_FILE_NAME) | tar $(TAR_EXCLUDE_SWITCH) -xvf -
    +$(TOUCH) $(PACKAGE_DIR)$/so_add_binary

$(PACKAGE_DIR)$/$(CONFIGURE_FLAG_FILE) : $(PACKAGE_DIR)$/so_add_binary

.ENDIF

# Since you never know what will be in a patch (for example, it may already
# patch at configure level) or in the case of a binary patch, we remove the
# entire package directory if a patch is newer.
# Changes in this makefile could also make a complete build necessary if
# configure is affected.
$(PACKAGE_DIR)$/$(UNTAR_FLAG_FILE) : makefile.mk

