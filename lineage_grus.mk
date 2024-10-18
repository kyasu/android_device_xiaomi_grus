#
# Copyright (C) 2018-2019,2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

$(call inherit-product, device/xiaomi/grus/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := lineage_grus
PRODUCT_DEVICE := grus
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := Mi 9 SE
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="grus-user 11 RKQ1.200826.002 V12.5.1.0.RFBMIXM release-keys" \
    BuildFingerprint=Xiaomi/grus/grus:11/RKQ1.200826.002/V12.5.1.0.RFBMIXM:user/release-keys \
    DeviceName=grus \
    DeviceProduct=grus \
    SystemName=grus
