@echo off
zmac IBC_DMP011_REV_L.asm
objcopy --input-target=ihex --output-target=binary zout\IBC_DMP011_REV_L.hex zout\IBC_DMP011_REV_L.bin
truncate --size=8K zout\IBC_DMP011_REV_L.bin
diff IBC_DMP011_REV_L.bin zout\IBC_DMP011_REV_L.bin
