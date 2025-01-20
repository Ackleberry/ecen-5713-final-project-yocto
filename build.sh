#!/bin/bash

git submodule init
git submodule sync
git submodule update

rm -f ./build/conf/local.conf
rm -f ./build/conf/bblayers.conf

source poky/oe-init-build-env

# Modify poky/build/conf/local.conf
conflines=(
    "MACHINE = \"stm32mp13-disco\""
    "ACCEPT_EULA_stm32mp1 = \"1\""
    "PACKAGE_CLASSES = \"package_deb\""
    "CORE_IMAGE_EXTRA_INSTALL:append = \" prolific-pl7413\""
    # "DL_DIR = \"${TOPDIR}/downloads\"" # permission issues
#    "IMAGE_INSTALL:append = \" packagegroup-core-buildessential\""
#    "IMAGE_INSTALL:append = \" nano\""
)

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
    "../meta-prolific"
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

set -e
bitbake core-image-full-cmdline