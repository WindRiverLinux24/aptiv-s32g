make_aptiv_s32g_wic() {
    set -e
    cd ${IMGDEPLOYDIR}
    for plat in ${UBOOT_CONFIG}; do
        atf_s32="${DEPLOY_DIR_IMAGE}/atf-$plat.s32"
        dd if=$atf_s32 of=${IMAGE_NAME}.rootfs.wic conv=notrunc seek=512 skip=512 oflag=seek_bytes iflag=skip_bytes
    done
}

do_image_wic_complete() {
    make_aptiv_s32g_wic

    for plat in ${UBOOT_CONFIG}; do

        ivt="${DEPLOY_DIR_IMAGE}/ivt-${plat}.bin"
        dcd="${DEPLOY_DIR_IMAGE}/dcd-${plat}.bin"
        hse="${DEPLOY_DIR_IMAGE}/hse.bin"
        m7="${DEPLOY_DIR_IMAGE}/m7.bin"

        if [ ! -f "${IMAGE_NAME}.rootfs.wic" ]; then
            bberror "WIC file not found: ${IMAGE_NAME}.rootfs.wic"
        fi

        if ${@bb.utils.contains("MACHINE_FEATURES", "ivt_image", "true", "false", d)}; then
            # add IVT at 0x000000
            dd if="${ivt}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc bs=256 count=1
            # add IVT at 0x001000
            dd if="${ivt}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc bs=256 count=1 seek=16
        fi

        if ${@bb.utils.contains("MACHINE_FEATURES", "dcd_image", "true", "false", d)}; then
            # add DCD at 0x00200000
            dd if="${dcd}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc obs=512 seek=4096
        fi
        if ${@bb.utils.contains("MACHINE_FEATURES", "hse_image", "true", "false", d)}; then
            # add HSE at 0x00400000
            dd if="${hse}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc obs=512 seek=8192
        fi
        if ${@bb.utils.contains("MACHINE_FEATURES", "m7_image", "true", "false", d)}; then
            # add M7 at 0x00500000
            dd if="${m7}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc obs=512 seek=10240
        fi
    done
}

do_image_wic[postfuncs] += "${@bb.utils.contains('MACHINE_FEATURES', 'omit_atf', '', 'do_image_wic_complete', d)}"
