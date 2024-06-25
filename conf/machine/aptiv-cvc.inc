#@TYPE: Machine inc.
#@NAME: aptiv-cvc

MACHINEOVERRIDES =. "aptiv-cvc:"

MACHINE_FEATURES:append = " hvp"
PREFERRED_VERSION_linux-yocto-rt ?= "6.6%"
PREFERRED_PROVIDER_virtual/kernel = "linux-yocto-rt"
NON_MULTILIB_RECIPES:append = " libfci libfci-cli"
