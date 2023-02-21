#@TYPE: Machine inc.
#@NAME: aptiv-cvc

MACHINEOVERRIDES =. "aptiv-cvc:"

PREFERRED_VERSION_linux-yocto-rt ?= "5.15%"
PREFERRED_PROVIDER_virtual/kernel = "linux-yocto-rt"
NON_MULTILIB_RECIPES:append = " libfci libfci-cli"

IMAGE_BOOT_FILES:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', '${HSE_SEC_PUB_KEY}', '', d)}"
IMAGE_BOOT_FILES:append = " ${@bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_secboot', '${HSE_SEC_PUB_KEY_PEM}', '', d)}"
