#!/bin/bash
# shellcheck disable=2059

set -eE -o pipefail

# IVT Image Structure
# -------------------
#
# Address   | Size      | Name
# Offset    | in bytes  |
# ----------|-----------|---------------------------------------
# 0x00      |   4       | IVT header (0xd1010060, big endian)
# 0x04      |   4       | Reserved
# 0x08      |   4       | Self-Test DCD pointer
# 0x0c      |   4       | Self-Test DCD backup pointer
# 0x10      |   4       | DCD pointer
# 0x14      |   4       | DCD backup pointer
# 0x18      |   4       | HSE FW flash start pointer
# 0x1c      |   4       | HSE FW flash start backup pointer
# 0x20      |   4       | Application flash start pointer
# 0x24      |   4       | Application flash start backup pointer
# 0x28      |   4       | Boot configuration word
# 0x2c      |   4       | Life-cycle configuration word
# 0x30      |   4       | Reserved
# 0x34      |  32       | Reserved
# 0x54      | 156       | Reserved
# 0xf0      |  16       | GMAC
# ----------|-----------|--------------------------------------
#           | 256       |

trap "exit 2" ERR

# brief:
#   prepare a format string for writing binary data with printf
#
# params:
#   1: num - the number to include in the string
#   2: base - numerical base of 'num', 'hex' (default) or 'dec'
#   3: endian - endianness of 'num'
fmt_str() {
    num=""
    base="${2:-hex}"
    endian="${3:-le}"

    if [[ "${base}" == "hex" ]]; then
        num="${1}"
    else
        num="$(printf "%.0d%.8x" 0000000 "${1}")"
    fi

    if [[ "${endian}" == "be" ]]; then
        echo -n "\\x${num:0:2}\\x${num:2:2}\\x${num:4:2}\\x${num:6:2}"
    else
        echo -n "\\x${num:6:2}\\x${num:4:2}\\x${num:2:2}\\x${num:0:2}"
    fi
}

declare ivt=""
declare app_ptr=""
declare dcd_ptr=""
declare hse_ptr=""
declare hse_sysimg_ptr=""
declare boot_cfg=""
declare autosar_ptr=""

while getopts "a:b:d:h:s:o:m:x" opt; do
    case "${opt}" in
        a)
            # Application pointer
            app_ptr="${OPTARG}"
            ;;
        b)
            # Boot configuration word
            boot_cfg="${OPTARG}"
            ;;
        d)
            # DCD pointer
            dcd_ptr="${OPTARG}"
            ;;
        h)
            # HSE pointer
            hse_ptr="${OPTARG}"
            ;;
        s)
            # HSE SYS-IMG pointer
            hse_sysimg_ptr="${OPTARG}"
            ;;
        o)
            # Output file name
            ivt="${OPTARG}"
            ;;
        m)
            # m7 autosar pointer
            autosar_ptr="${OPTARG}"
            ;;
        x)
            # Debug output
            set -x
            ;;
        *)
            # All other options are treated as failure
            exit 1
            ;;
    esac
done

if [[ -z "${ivt}" ]]; then
    exit 1
fi

# prepare empty IVT image
dd if=/dev/zero of="${ivt}" bs=256 count=1

# IVT header
printf "$(fmt_str 'd1010060' 'hex' 'be')" | dd of="${ivt}" conv=notrunc
# DCD pointer
if [[ -n "${dcd_ptr}" ]]; then
    printf "$(fmt_str "${dcd_ptr}")" | dd of="${ivt}" conv=notrunc seek=16 bs=1
fi
# HSE firmware flash pointer
if [[ -n "${hse_ptr}" ]]; then
    printf "$(fmt_str "${hse_ptr}")" | dd of="${ivt}" conv=notrunc seek=24 bs=1
fi
# HSE Sys-Img flash pointer
if [[ -n "${hse_sysimg_ptr}" ]]; then
    printf "$(fmt_str "${hse_sysimg_ptr}")" | dd of="${ivt}" conv=notrunc seek=52 bs=1
fi
# Application flash start pointer
if [[ -n "${app_ptr}" ]]; then
    printf "$(fmt_str "${app_ptr}")" | dd of="${ivt}" conv=notrunc seek=32 bs=1
fi
# Boot configuration word
if [[ -n "${boot_cfg}" ]]; then
    printf "$(fmt_str "${boot_cfg}")" | dd of="${ivt}" conv=notrunc seek=40 bs=1
fi
# m7 autosar flash start pointer
if [[ -n "${autosar_ptr}" ]]; then
    printf "$(fmt_str "${autosar_ptr}")" | dd of="${ivt}" conv=notrunc seek=224 bs=1
fi
