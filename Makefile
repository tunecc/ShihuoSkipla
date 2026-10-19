export THEOS := /opt/theos

TARGET := iphone:clang:latest:12.4
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES := ShihuoIPhone

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := ShihuoSkipla
ShihuoSkipla_FILES := Tweak.xm
ShihuoSkipla_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
ShihuoSkipla_FRAMEWORKS := Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
