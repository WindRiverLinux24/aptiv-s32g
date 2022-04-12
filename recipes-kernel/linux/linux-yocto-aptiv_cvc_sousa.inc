#
# Copyright (C) 2020 Wind River Systems, Inc.
#

COMPATIBLE_MACHINE:aptiv_cvc_sousa = "aptiv_cvc_sousa"
TARGET_SUPPORTED_KTYPES:aptiv_cvc_sousa = "preempt-rt"

KERNEL_VERSION_SANITY_SKIP = "1"
SRCREV_machine:aptiv_cvc_sousa ?= "${AUTOREV}"
SRCREV_meta:aptiv_cvc_sousa ?= "${AUTOREV}"

FILESEXTRAPATHS:prepend:aptiv_cvc_sousa := "${THISDIR}/files:"
