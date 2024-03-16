/*
 * Copyright (C) 2024 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "vendor.lineage.touch@1.0-service.xiaomi_sm8475"

#include "HighTouchPollingRate.h"
#include <android-base/file.h>
#include <android-base/logging.h>
#include <sys/ioctl.h>
#include "xiaomi_touch.h"

namespace vendor {
namespace lineage {
namespace touch {
namespace V1_0 {
namespace implementation {

#define TOUCH_DEV_PATH "/dev/xiaomi-touch"
#define TOUCH_ID 0
#define TOUCH_MAGIC 'T'
#define TOUCH_IOC_SET_CUR_VALUE _IO(TOUCH_MAGIC, SET_CUR_VALUE)
#define TOUCH_IOC_GET_CUR_VALUE _IO(TOUCH_MAGIC, GET_CUR_VALUE)

static int upThreshold = 0;
static int tolerance = 0;
static int edgeFilter = 0;

bool setTouchModeValue(int mode, int value) {
    int fd = open(TOUCH_DEV_PATH, O_RDWR);
    if (fd < 0) {
        return false;
    }

    int arg[3] = {TOUCH_ID, mode, value};
    ioctl(fd, TOUCH_IOC_SET_CUR_VALUE, &arg);
    close(fd);
    return true;
}

bool getTouchModeValue(int mode, int* value) {
    int fd = open(TOUCH_DEV_PATH, O_RDWR);
    if (fd < 0) {
        return false;
    }

    int arg[3] = {TOUCH_ID, mode, 0};
    ioctl(fd, TOUCH_IOC_GET_CUR_VALUE, &arg);
    close(fd);

    if (value) {
        *value = arg[0];
    }
    return true;
}

Return<bool> HighTouchPollingRate::isEnabled() {
    int gameMode = 0;
    getTouchModeValue(Touch_Game_Mode, &gameMode);
    return gameMode == 1;
}

Return<bool> HighTouchPollingRate::setEnabled(bool enabled) {
    if (enabled) {
        getTouchModeValue(Touch_UP_THRESHOLD, &upThreshold);
        getTouchModeValue(Touch_Tolerance, &tolerance);
        getTouchModeValue(Touch_Edge_Filter, &edgeFilter);

        setTouchModeValue(Touch_Game_Mode, 1);
        setTouchModeValue(Touch_Active_MODE, 1);
        setTouchModeValue(Touch_UP_THRESHOLD, 99);
        setTouchModeValue(Touch_Tolerance, 5);
        setTouchModeValue(Touch_Edge_Filter, 0);
    }
    else {
        setTouchModeValue(Touch_Game_Mode, 0);
        setTouchModeValue(Touch_Active_MODE, 0);
        setTouchModeValue(Touch_UP_THRESHOLD, upThreshold);
        setTouchModeValue(Touch_Tolerance, tolerance);
        setTouchModeValue(Touch_Edge_Filter, edgeFilter);
    }
    return true;
}

}  // namespace implementation
}  // namespace V1_0
}  // namespace touch
}  // namespace lineage
}  // namespace vendor