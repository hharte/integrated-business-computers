@echo off
zmac IBC_DMP047_REV_A_TMS2764.asm
objcopy --input-target=ihex --output-target=binary zout\IBC_DMP047_REV_A_TMS2764.hex zout\IBC_DMP047_REV_A_TMS2764.bin
truncate --size=8K zout\IBC_DMP047_REV_A_TMS2764.bin
diff IBC_DMP047_REV_A_TMS2764.bin zout\IBC_DMP047_REV_A_TMS2764.bin
