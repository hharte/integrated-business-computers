# On MacOS, brew install binutils truncate
#
# Compile zmac from source: http://48k.ca/zmac.html
#
if zmac IBC_DMP047_REV_A_TMS2764.asm
then
    objcopy --input-target=ihex --output-target=binary zout/IBC_DMP047_REV_A_TMS2764.hex zout/IBC_DMP047_REV_A_TMS2764.bin
    truncate -s 8192 zout/IBC_DMP047_REV_A_TMS2764.bin
    if cmp -s IBC_DMP047_REV_A_TMS2764.bin zout/IBC_DMP047_REV_A_TMS2764.bin
    then
        echo "Ok."
    else
        echo "ROM is not identical to the original."
    fi
else
    echo "Assembly failed."
fi
