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

export TARGET_ENABLE_CHECKELF=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

function vendor_imports() {
    cat <<EOF >>"$1"
                "hardware/google/interfaces",
                "hardware/google/pixel",
                "hardware/lineage/interfaces/power-libperfmgr",
                "hardware/qcom-caf/common/libqti-perfd-client",
                "hardware/qcom-caf/sdm845",
                "hardware/qcom-caf/wlan",
                "hardware/xiaomi",
                "vendor/qcom/opensource/commonsys/display",
                "vendor/qcom/opensource/commonsys-intf/display",
                "vendor/qcom/opensource/dataservices",
                "vendor/qcom/opensource/data-ipa-cfg-mgr-legacy-um",
                "vendor/qcom/opensource/display",
                "vendor/qcom/opensource/usb/etc",
EOF
}

function lib_to_package_fixup_vendor_variants() {
    if [ "$2" != "vendor" ]; then
        return 1
    fi

    case "$1" in
        com.qualcomm.qti.dpm.api@1.0 | \
            com.qualcomm.qti.imscmservice@1.0 | \
            com.qualcomm.qti.imscmservice@2.0 | \
            com.qualcomm.qti.imscmservice@2.1 | \
            com.qualcomm.qti.imscmservice@2.2 | \
            com.qualcomm.qti.uceservice@2.0 | \
            com.qualcomm.qti.uceservice@2.1 | \
            com.qualcomm.qti.uceservice@2.2 | \
            vendor.qti.hardware.alarm@1.0 | \
            vendor.qti.hardware.radio.am@1.0 | \
            vendor.qti.hardware.radio.ims@1.0 | \
            vendor.qti.hardware.radio.ims@1.1 | \
            vendor.qti.hardware.radio.ims@1.2 | \
            vendor.qti.hardware.radio.ims@1.3 | \
            vendor.qti.hardware.radio.ims@1.4 | \
            vendor.qti.hardware.radio.ims@1.5 | \
            vendor.qti.hardware.radio.ims@1.6 | \
            vendor.qti.ims.callinfo@1.0 | \
            vendor.qti.ims.callcapability@1.0 | \
            vendor.qti.ims.factory@1.0 | \
            vendor.qti.ims.rcsconfig@1.0 | \
            vendor.qti.ims.rcsconfig@1.1 | \
            vendor.qti.ims.rcsconfig@2.0 | \
            vendor.qti.ims.rcsconfig@2.1 | \
            vendor.qti.imsrtpservice@3.0 | \
            libmmosal)
            echo "$1_vendor"
            ;;
        libOmxCore | \
            libgrallocutils | \
            libril | \
            libwpa_client)
            # Android.mk only packages
            ;;
        *)
            return 1
            ;;
    esac
}

function lib_to_package_fixup() {
    lib_to_package_fixup_clang_rt_ubsan_standalone "$1" ||
        lib_to_package_fixup_proto_3_9_1 "$1" ||
        lib_to_package_fixup_vendor_variants "$@"
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}"

# Warning headers and guards
write_headers

write_makefiles "${MY_DIR}/proprietary-files.txt"
if [ -f "${MY_DIR}/proprietary-files-carriersettings.txt" ]; then
write_makefiles "${MY_DIR}/proprietary-files-carriersettings.txt"

write_rro_package "CarrierConfigOverlay" "com.android.carrierconfig" product
write_single_product_packages "CarrierConfigOverlay"
fi

if [ -f "${MY_DIR}/proprietary-firmware.txt" ]; then
append_firmware_calls_to_makefiles "${MY_DIR}/proprietary-firmware.txt"
fi

# Finish
write_footers
