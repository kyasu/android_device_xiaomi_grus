/*
 * Copyright (C) 2021 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <compositionengine/FodExtension.h>
#include <drm/sde_drm.h>

uint32_t getFodZOrder(uint32_t z, bool touched) {
    if (touched) {
        z |= FOD_PRESSED_LAYER_ZORDER;
    }
    return z;
}

uint64_t getFodUsageBits(uint64_t usageBits, bool) {
    return usageBits;
}
