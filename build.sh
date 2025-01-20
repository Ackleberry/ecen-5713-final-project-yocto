#!/bin/bash

set -e

git submodule init
git submodule sync
git submodule update

source poky/oe-init-build-env

# Modify poky/build/conf/local.conf
conflines=(
    "MACHINE = \"stm32mp13-disco\""
    "ACCEPT_EULA_stm32mp1 = \"1\""
    "PACKAGE_CLASSES = \"package_deb\""
    "DL_DIR = \"../\""
)

#DL_DIR ?= "${TOPDIR}/downloads"
for CONFLINE in "${conflines[@]}"; do
    grep "${CONFLINE}" conf/local.conf > /dev/null
    local_conf_info=$?

    if [ $local_conf_info -ne 0 ]; then
        echo "Appending ${CONFLINE} to the local.conf file"
        echo "${CONFLINE}" >> conf/local.conf
    else
        echo "${CONFLINE} already exists in the local.conf file"
    fi
done

# Add external layers
layers=(
    "../meta-openembedded/meta-oe"
    "../meta-openembedded/meta-python"
    "../meta-st-stm32mp" 
)

for layer in "${layers[@]}"; do
    bitbake-layers show-layers | grep "$layer" > /dev/null
    layer_info=$?

    if [ $layer_info -ne 0 ]; then
        echo "Adding layer '$layer'..."
        bitbake-layers add-layer "$layer"
    else
        echo "Layer '$layer' already exists."
    fi
done

bitbake core-image-full-cmdline