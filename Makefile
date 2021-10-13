ARCHS = arm64
TARGET := iphone:clang:latest:11.0
INSTALL_TARGET_PROCESSES = Discord
THEOS_DEVICE_IP = 127.0.0.1
THEOS_DEVICE_PORT = 2222
LEAN_AND_MEAN = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DiscordSecureToken

DiscordSecureToken_FILES = Tweak.x 
DiscordSecureToken_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
