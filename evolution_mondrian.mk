#
# Copyright (C) 2022-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from mondrian device
$(call inherit-product, device/xiaomi/mondrian/device.mk)

# Inherit from common aosp configuration
TARGET_DISABLE_EPPE := true
$(call inherit-product, vendor/evolution/config/common_full_phone.mk)

PRODUCT_NAME := evolution_mondrian
PRODUCT_DEVICE := mondrian
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_SYSTEM_NAME := mondrian_global
PRODUCT_SYSTEM_DEVICE := mondrian

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="mondrian_global-user 12 SKQ1.230401.001 V816.0.3.0.UMNMIXM release-keys" \
    TARGET_DEVICE=$(PRODUCT_SYSTEM_DEVICE) \
    TARGET_PRODUCT=$(PRODUCT_SYSTEM_NAME)

BUILD_FINGERPRINT := POCO/mondrian_global/mondrian:12/SKQ1.230401.001/V816.0.3.0.UMNMIXM:user/release-keys

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

TARGET_BOOT_ANIMATION_RES := 1440
EXTRA_UDFPS_ANIMATIONS := true