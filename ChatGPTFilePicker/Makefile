TARGET := iphone:clang:12.4:12.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := ChatGPTFilePicker

ChatGPTFilePicker_FILES := Tweak.xm
ChatGPTFilePicker_CFLAGS := -fobjc-arc

ADDITIONAL_CFLAGS += -Wno-error=deprecated-module-dot-map
ADDITIONAL_OBJCFLAGS += -Wno-error=deprecated-module-dot-map

ChatGPTFilePicker_FRAMEWORKS := UIKit

INSTALL_TARGET_PROCESSES := MobileSafari

include $(THEOS_MAKE_PATH)/tweak.mk
