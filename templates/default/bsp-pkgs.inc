IMAGE_INSTALL += "linuxptp linuxptp-configs"
IMAGE_INSTALL += "can-utils"
IMAGE_INSTALL += "i2c-tools"
IMAGE_INSTALL += "u-boot-s32"
IMAGE_INSTALL += "atf-s32g"
IMAGE_INSTALL += "vsomeip"
IMAGE_INSTALL += "watchdog"
IMAGE_INSTALL += "pfe"

APTIV_CVC_SOUSA_WIC_INC:aptiv_cvc_sousa = "${@bb.utils.contains('S32G_FEATURES', 'm7_boot', 'make_aptiv_m7_boot_wic.inc', 'make_aptiv_cvc_sousa_wic.inc', d)}"
require conf/${APTIV_CVC_SOUSA_WIC_INC}
