IMAGE_INSTALL += "linuxptp linuxptp-configs"
IMAGE_INSTALL += "can-utils"
IMAGE_INSTALL += "i2c-tools"
IMAGE_INSTALL += "u-boot-s32"
IMAGE_INSTALL += "atf-s32g"
IMAGE_INSTALL += "vsomeip"
IMAGE_INSTALL += "watchdog"
IMAGE_INSTALL += "libfci libfci-cli"
IMAGE_INSTALL += "libp11"

def get_wic_inc(d):
    if bb.utils.contains('MACHINE_FEATURES', 'm7_boot', True, False, d):
        return 'make_aptiv_m7_boot_wic.inc'
    elif bb.utils.contains('MACHINE_FEATURES', 'm7_autosar_boot', True, False, d):
        return 'make_aptiv_m7_autosar_wic.inc'
    else:
        return 'make_aptiv_cvc_wic.inc'

require conf/${@get_wic_inc(d)}
