#*************************************************************************
#
#   $RCSfile: makefile.mk,v $
#
#   $Revision: 1.1.1.1 $
#
#   last change: $Author: er $ $Date: 2002-04-22 17:51:40 $
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

PRJNAME=so_icu
TARGET=so_icu

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------

TARFILE_NAME=icu-2.0
TARFILE_ROOTDIR=icu

PATCH_FILE_NAME=icu-2.0.patch

.IF "$(GUI)"=="UNX"
.IF "$(COMNAME)"=="sunpro5"
CC:=$(COMPATH)$/bin$/cc
CXX:=$(COMPATH)$/bin$/CC
.EXPORT : CC CXX
.ENDIF          # "$(COMNAME)"=="sunpro5"

CONFIGURE_DIR=source
CONFIGURE_ACTION=sh ./configure
CONFIGURE_FLAGS=--enable-layout --enable-static --enable-shared=yes --enable-64bit-libs=no

BUILD_DIR=$(CONFIGURE_DIR)
BUILD_ACTION=$(GNUMAKE)

.IF "$(CPU)"=="S" || "$(CPU)"=="P"
OUT2LIB= \
    $(BUILD_DIR)$/data$/libicudt20b.so
.ELSE
OUT2LIB= \
    $(BUILD_DIR)$/data$/libicudt20l.so
.ENDIF
OUT2LIB+= \
    $(BUILD_DIR)$/common$/libicuuc.a \
    $(BUILD_DIR)$/common$/libicuuc.so.20.0 \
    $(BUILD_DIR)$/common$/libicuuc.so.20 \
    $(BUILD_DIR)$/common$/libicuuc.so \
    $(BUILD_DIR)$/i18n$/libicui18n.a \
    $(BUILD_DIR)$/i18n$/libicui18n.so.20.0 \
    $(BUILD_DIR)$/i18n$/libicui18n.so.20 \
    $(BUILD_DIR)$/i18n$/libicui18n.so \
    $(BUILD_DIR)$/layout$/libicule.a \
    $(BUILD_DIR)$/layout$/libicule.so.20.0 \
    $(BUILD_DIR)$/layout$/libicule.so.20 \
    $(BUILD_DIR)$/layout$/libicule.so
.ENDIF

.IF "$(GUI)"=="WNT"
CONFIGURE_DIR=source
CONFIGURE_ACTION=$(BACK_PATH)..$/..$/convert.bat
BUILD_DIR=source
BUILD_ACTION=msdev allinone$/allinone.dsw /useenv /MAKE "all"

OUT2LIB= \
    $(BUILD_DIR)$/..$/lib$/icudata.lib \
    $(BUILD_DIR)$/..$/lib$/icuin.lib \
    $(BUILD_DIR)$/..$/lib$/icuuc.lib \
    $(BUILD_DIR)$/..$/lib$/icule.lib

OUT2BIN= \
    $(BUILD_DIR)$/..$/bin$/icudt20.dll \
    $(BUILD_DIR)$/..$/bin$/icuin20.dll \
    $(BUILD_DIR)$/..$/bin$/icuuc20.dll \
    $(BUILD_DIR)$/..$/bin$/icule20.dll
.ENDIF

# --- Targets ------------------------------------------------------

.INCLUDE : set_ext.mk
.INCLUDE :	target.mk
.INCLUDE :	tg_ext.mk

TG_DELIVER : build$/$(INPATH)$/so_predeliver
        $(DELIVER)

.IF "$(BUILD_SOSL)"!=""
ALLTAR : TG_DELIVER
.ENDIF

