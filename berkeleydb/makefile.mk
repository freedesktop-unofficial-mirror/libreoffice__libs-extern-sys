#*************************************************************************
#
#   $RCSfile: makefile.mk,v $
#
#   $Revision: 1.8 $
#
#   last change: $Author: mh $ $Date: 2002-11-20 10:35:32 $
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

PRJNAME=so_berkeleydb
TARGET=so_berkeleydb

# --- Settings -----------------------------------------------------

.INCLUDE :	settings.mk

# --- Files --------------------------------------------------------

TARFILE_NAME=db-3.2.9

# not needed for win32. comment out when causing problems...
PATCH_FILE_NAME=db-3.2.9.patch

.IF "$(GUI)"=="UNX"
CONFIGURE_DIR=out
#relative to CONFIGURE_DIR
CONFIGURE_ACTION=..$/dist$/configure
CONFIGURE_FLAGS=--enable-cxx --enable-java --enable-dynamic --enable-shared

BUILD_DIR=$(CONFIGURE_DIR)
BUILD_ACTION=make

OUT2LIB=$(BUILD_DIR)$/.libs$/libdb*.so

OUT2BIN=java$/classes$/db.jar
    
.ENDIF			# "$(GUI)"=="UNX"

.IF "$(GUI)"=="WNT"
# make use of stlport headerfiles
EXT_USE_STLPORT=TRUE

BUILD_DIR=build_win32
BUILD_ACTION=msdev Berkeley_DB.dsw /useenv /MAKE "db_buildall - RELEASE" /MAKE "db_java - RELEASE"

OUT2BIN=java$/classes$/db.jar \
    $(BUILD_DIR)$/Release$/libdb_java32.dll \
    $(BUILD_DIR)$/Release$/libdb32.dll

OUT2LIB= \
    $(BUILD_DIR)$/Release$/libdb_java32.lib \
    $(BUILD_DIR)$/Release$/libdb32.lib
    
.ENDIF			# "$(GUI)"=="WNT"

OUT2INC= \
    $(BUILD_DIR)$/db.h \
    include$/db_185.h \
    include$/db_cxx.h

OUT2CLASS=java$/classes$/db.jar

# --- Targets ------------------------------------------------------

.INCLUDE : set_ext.mk
.INCLUDE :	target.mk
.INCLUDE :	tg_ext.mk

TG_DELIVER : $(INPATH)$/misc$/build$/so_predeliver
        $(DELIVER)

.IF "$(BUILD_PREDELIVER)"!=""
ALLTAR : TG_DELIVER
.ENDIF			# "$(BUILD_PREDELIVER)"!=""

