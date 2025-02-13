# Project Overview

https://github.com/cu-ecen-aeld/final-project-Ackleberry/wiki/Project-Overview

# Building

`./build.sh`
`./build.sh prolific-image`
`./build.sh core-image-weston`

# Flashing

`./flash_sd_card.sh /dev/mmcblk0`
`./flash_sd_card.sh /dev/mmcblk0 prolific-image`
`./flash_sd_card.sh /dev/mmcblk0 core-image-weston`

# Useful Commands:

## Show Images

    ls meta*/recipes*/images/*.bb
    bitbake-layers show-recipes | grep image