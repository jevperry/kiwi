# /.../
# Copyright (c) 2006 SUSE LINUX Products GmbH. All rights reserved.
# Author: Marcus Schaefer <sax@suse.de>, 2006
#
# Makefile for OpenSuSE - KIWI Image System
# ---
buildroot = /

export

#============================================
# Prefixs...
#--------------------------------------------
kiwi_prefix = ${buildroot}/usr/share/kiwi
tftp_prefix = ${buildroot}/var/lib/tftpboot

#============================================
# Variables... 
#--------------------------------------------
KIWIBINVZ   = ${buildroot}/usr/sbin
KIWIMODVZ   = ${kiwi_prefix}/modules
TOOLSVZ     = ${kiwi_prefix}/tools
KIWIIMAGE   = ${kiwi_prefix}/image
TFTPKIWI    = ${tftp_prefix}/KIWI
TFTPBOOT    = ${tftp_prefix}/boot
TFTPBOOTCONF= ${tftp_prefix}/boot/pxelinux.cfg
TFTPUPLOAD  = ${tftp_prefix}/upload
TFTPIMAGE   = ${tftp_prefix}/image

all:
	#============================================
	# building kiwi tools...
	#--------------------------------------------
	${MAKE} -C ./tools -f Makefile all

install:
	#============================================
	# Install base directories
	#--------------------------------------------
	install -d -m 755 ${KIWIBINVZ} ${KIWIMODVZ} ${TOOLSVZ} ${KIWIIMAGE}
	install -d -m 755 ${TFTPKIWI} ${TFTPBOOT} ${TFTPBOOTCONF} ${TFTPIMAGE}
	install -d -m 777 ${TFTPUPLOAD}

	#============================================
	# Install kiwi tools
	#--------------------------------------------
	install -m 755 ./tools/restart ${TOOLSVZ}
	install -m 755 ./tools/timed   ${TOOLSVZ}

	#============================================
	# Install KIWI base and modules
	#--------------------------------------------
	install -m 755 ./kiwi.pl       ${KIWIBINVZ}/kiwi
	install -m 644 ./modules/*     ${KIWIMODVZ}

	#============================================
	# Install TFTP netboot structure and loader
	#--------------------------------------------
	install -m 755 pxeboot/pxelinux.0        ${TFTPBOOT}
	install -m 755 pxeboot/pxelinux.0.config ${TFTPBOOTCONF}/default

	#============================================
	# Install image descriptions
	#--------------------------------------------
	cp -a system/* ${KIWIIMAGE}
