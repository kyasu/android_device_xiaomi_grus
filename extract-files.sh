#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=grus
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system_ext/etc/permissions/qti_libpermissions.xml)
            [ "$2" = "" ] && return 0
            grep -q "name=\"android.hidl.manager-V1.0-java" "${2}" && sed -i "s/name=\"android.hidl.manager-V1.0-java/name=\"android.hidl.manager@1.0-java/g" "${2}"
            ;;
        vendor/lib*/sensors.ssc.so)
            [ "$2" = "" ] && return 0
            grep -q vendor.qti.hardware.display.mapper@2.0.so "${2}" && ${PATCHELF} --remove-needed vendor.qti.hardware.display.mapper@2.0.so "${2}"
            grep -q vendor.qti.hardware.display.mapper@3.0.so "${2}" && ${PATCHELF} --remove-needed vendor.qti.hardware.display.mapper@3.0.so "${2}"
            ;;
        system_ext/lib64/lib-imsvideocodec.so)
            [ "$2" = "" ] && return 0
            grep -q "libgui_shim.so" "${2}" || ${PATCHELF} --add-needed "libgui_shim.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac
    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
