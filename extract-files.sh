#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=mondrian
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
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
        vendor/etc/init/init.embmssl_server.rc)
            sed -i -n '/interface/!p' "${2}"
            ;;
        vendor/lib64/libsdmcore.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            ;;
        vendor/lib/libsdmcore.so)
            "${PATCHELF}" --replace-needed "libutils.so" "libutils-v33.so" "${2}"
            ;;
        vendor/lib64/hw/displayfeature.default.so)
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib/hw/displayfeature.default.so)
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/lib64/libdlbdsservice.so | vendor/lib64/soundfx/libhwdap.so | vendor/lib64/libstagefright_soft_ac4dec.so | vendor/lib64/libstagefright_soft_ddpdec.so | system/lib64/libdovi_omx.so | vendor/lib/mediadrm/libwvdrmengine.so | vendor/lib64/c2.dolby.avc.dec.so | vendor/lib64/c2.dolby.avc.sec.dec.so | vendor/lib64/c2.dolby.egl.so | vendor/lib64/c2.dolby.hevc.dec.so | vendor/lib64/c2.dolby.hevc.enc.so | vendor/lib64/c2.dolby.hevc.sec.dec.so | vendor/lib64/hw/audio.primary.taro.so | vendor/lib64/libdolbyvision.so | vendor/lib64/libmi-stc-HW-modulate.so | vendor/lib64/libmiBrightness.so | vendor/lib64/libqc2audio_hwaudiocodec.so | vendor/lib64/libstagefright_softomx.so | vendor/lib64/soundfx/libdlbvol.so | vendor/lib64/soundfx/libswspatializer.so | vendor/lib64/libcodec2_soft_ddpdec.so | vendor/lib64/libdlbpreg.so | vendor/lib64/libcodec2_soft_ac4dec.so)
            "${PATCHELF}" --replace-needed "libstagefright_foundation.so" "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/etc/camera/mondrian_enhance_motiontuning.xml|vendor/etc/camera/mondrian_motiontuning.xml)
            sed -i 's/xml=version/xml version/g' "${2}"
            ;;
        vendor/etc/camera/pureView_parameter.xml)
            sed -i 's/=\([0-9]\+\)>/="\1">/g' "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"