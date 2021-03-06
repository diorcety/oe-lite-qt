#!/bin/bash
# Script used to setup the enviroment for Qmake
# Preconditions:
#  The following environemt settings are needed prior to invoking the script:
#  * CROSS_COMPILE must be set, e.g.  CROSS_COMPILE=arm-cortexa9neont-linux-gnueabi-
#  * Host executeable must be in the path (<sdk_folder>/bin)
#
# Note: The script can be run on Windows too with MSYS installed
# The script generates a qt.conf file which will be placed in <sdk_folder>

CURRENT_OS=$(uname)

echo "Script detected it is running on:"
if [[ $CURRENT_OS == Linux* ]] ; then
    echo "Linux"
else
    echo "Windows"
fi

echo "CROSS_COMPILE is '$CROSS_COMPILE'"
if [ -z $CROSS_COMPILE ]; then
    echo "Error: 'CROSS_COMPILE' must be set!"  >&2
    exit 1
fi

# Determine the tools dir
GCC_TO_USE=$(which ${CROSS_COMPILE}gcc)
if [ -z $GCC_TO_USE ]; then
    echo "Error: Cannot find the cross compiler directory!"  >&2
    exit 1
fi

export TOOL=$(dirname $(which ${CROSS_COMPILE}gcc))"/../"
if [ ! -d $TOOL ]; then
    echo "Error: Tool dir '$TOOL' does not exist!"  >&2
    exit 1
fi

# Strip off the last character
MACHINE_ARCH=${CROSS_COMPILE:0:$((${#CROSS_COMPILE}-1))}
echo "Machine arch is: $MACHINE_ARCH"

SYS_REL_TOOL=${MACHINE_ARCH}/sysroot
export SYS=${TOOL}/${SYS_REL_TOOL}

if [ ! -d $SYS ]; then
    echo "Error: Sysroot dir '$SYS' does not exist!"  >&2
    exit 1
fi

export AR=${CROSS_COMPILE}ar
export CC=${CROSS_COMPILE}gcc
export CXX=${CROSS_COMPILE}g++
export STRIP=${CROSS_COMPILE}strip

export PKG_CONFIG_LIBDIR=${SYS}/usr/lib/pkgconfig
export PKG_CONFIG_PATH=${SYS}/usr/lib/pkgconfig
export PKG_CONFIG_SYSROOT_DIR=${SYS}

export OE_QMAKE_UIC="${TOOL}bin/uic"
export OE_QMAKE_MOC="${TOOL}bin/moc"
export OE_QMAKE_RCC="${TOOL}bin/rcc"

export OE_QMAKE_LINK="${CXX}"
export OE_QMAKE_CC="${CC}"
export OE_QMAKE_CXX="${CXX}"
export OE_QMAKE_AR="${AR}"
export OE_QMAKE_STRIP="${STRIP}"

QT_CONF_FILE=${TOOL}/qt.conf
touch ${QT_CONF_FILE} || exit 1

echo "[Paths]" > ${QT_CONF_FILE}
# Give prefix relative to the tools dir
echo "Prefix = ../" >> ${QT_CONF_FILE}
echo "Headers = ${SYS_REL_TOOL}/usr/include/qt5" >> ${QT_CONF_FILE}
echo "Libraries = ${SYS_REL_TOOL}/usr/lib" >> ${QT_CONF_FILE}
echo "ArchData = ${SYS_REL_TOOL}/usr/lib" >> ${QT_CONF_FILE}
echo "Data = ${SYS_REL_TOOL}/usr/share" >> ${QT_CONF_FILE}
echo "Plugins = ${SYS_REL_TOOL}/usr/lib/qt5/plugins" >> ${QT_CONF_FILE}
echo "HostBinaries = bin" >> ${QT_CONF_FILE}
echo "HostData = ${SYS_REL_TOOL}/usr/share/qt5" >> ${QT_CONF_FILE}
if [[ $CURRENT_OS == Linux* ]] ; then
    echo "HostSpec = ${SYS_REL_TOOL}/usr/share/qt5/mkspecs/linux-oe-g++" >> ${QT_CONF_FILE}
else
    echo "HostSpec = ${SYS_REL_TOOL}/usr/share/qt5/mkspecs/win32-g++" >> ${QT_CONF_FILE}
fi
echo "TargetSpec = ${SYS_REL_TOOL}/usr/share/qt5/mkspecs/linux-oe-g++" >> ${QT_CONF_FILE}

# Set the paths to the config file
export QT_CONF_PATH="${QT_CONF_FILE}"
# And Specs for target
export QMAKESPEC="linux-oe-g++"
