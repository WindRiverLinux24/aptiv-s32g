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
        m7="${DEPLOY_DIR_IMAGE}/m7-autosar.bin"

        if [ ! -f "${IMAGE_NAME}.rootfs.wic" ]; then
            bberror "WIC file not found: ${IMAGE_NAME}.rootfs.wic"
        fi

        # add IVT at 0x000000
        dd if="${ivt}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc bs=256 count=1
        # add IVT at 0x001000
        dd if="${ivt}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc bs=256 count=1 seek=16

        # add DCD at 0x00120000
        dd if="${dcd}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc obs=512 seek=2304

        # add HSE at 0x00200000
        dd if="${hse}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc obs=512 seek=4096

        # add M7 at 0x00300000
        dd if="${m7}" of="${IMAGE_NAME}.rootfs.wic" conv=notrunc obs=512 seek=6144
    done
}

do_image_wic[postfuncs] = "do_image_wic_complete"
