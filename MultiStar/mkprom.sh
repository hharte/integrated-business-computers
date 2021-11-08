# On MacOS, brew install binutils truncate
#
# Compile zmac from source: http://48k.ca/zmac.html
#
if zmac IBC_DMP011_REV_L.asm
then
    objcopy --input-target=ihex --output-target=binary zout/IBC_DMP011_REV_L.hex zout/IBC_DMP011_REV_L.bin
    truncate -s 8192 zout/IBC_DMP011_REV_L.bin
    if cmp -s IBC_DMP011_REV_L.bin zout/IBC_DMP011_REV_L.bin
    then
        echo "Ok."
    else
        echo "ROM is not identical to the original."
    fi
else
    echo "Assembly failed."
fi
