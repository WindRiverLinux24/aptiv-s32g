#@TYPE: Machine inc.
#@NAME: aptiv-cvc

MACHINEOVERRIDES =. "aptiv-cvc:"

PREFERRED_VERSION_linux-yocto-rt ?= "5.15%"
PREFERRED_PROVIDER_virtual/kernel = "linux-yocto-rt"
NON_MULTILIB_RECIPES:append = " libfci libfci-cli"
