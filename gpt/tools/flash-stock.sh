#!/bin/bash

# I wrote this for my own debugging purposes only.
# Be careful what you do, as you might brick your device by running it.

set -e -u -o pipefail

export TOPDIR=$(cd $(dirname ${BASH_SOURCE[0]} ) && pwd)
img_path=${TOPDIR}/../../YT-X703L_S000973_180524_ROW_firmware

if grep "^product: *MSM8952$" <(fastboot getvar product) > /dev/null; then
	echo "This fastboot ROM does not match the connected device."
	exit 1
fi

flash_partition() {
	local label="$1"
	local img="$2"

	echo "* ${label}..."
	fastboot flash ${label} ${img_path}/${img}
}

flash_critical() {
	echo "Applying the critical firmware images..."
	flash_partition 'dsp'          "adspso.bin"
	flash_partition 'cmnlib64'     "cmnlib64.mbn"
	flash_partition 'cmnlib64bak'  "cmnlib64.mbn"
	flash_partition 'cmnlib'       "cmnlib.mbn"
	flash_partition 'cmnlibbak'    "cmnlib.mbn"
	flash_partition 'devcfg'       "devcfg.mbn"
	flash_partition 'devcfgbak'    "devcfg.mbn"
	flash_partition 'aboot'        "emmc_appsboot.mbn"
	flash_partition 'abootbak'     "emmc_appsboot.mbn"
	flash_partition 'keymaster'    "keymaster.mbn"
	flash_partition 'keymasterbak' "keymaster.mbn"
	flash_partition 'mdtp'         "mdtp.img"
	flash_partition 'modem'        "NON-HLOS.bin"
	flash_partition 'rpm'          "rpm.mbn"
	flash_partition 'rpmbak'       "rpm.mbn"
	flash_partition 'sbl1'         "sbl1.mbn"
	flash_partition 'sbl1bak'      "sbl1.mbn"
	flash_partition 'splash'       "splash.img"
	flash_partition 'tz'           "tz.mbn"
	flash_partition 'tzbak'        "tz.mbn"
	echo "Critical firmware partitions flashed successfully."
}

fastboot flashing unlock_critical
echo "Flashing GPT partition table..."
fastboot flash partition gpt_treble.bin
echo "GPT partition table flashed successfully."
echo "WARNING!! The eMMC is now fully wiped by the bootloader."
echo "Flashing critical partitions again so that the tablet will not become a brick upon next reboot."
flash_critical
echo "Rebooting to fastboot is now safe."
