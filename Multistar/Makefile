AS=./zmac.exe
ASFLAGS=

ODIR=zout

_OBJ = IBC_DMP011_REV_L.hex
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))

_HDC_OBJ = IBC_DMP014_REV_U.hex
HDC_OBJ = $(patsubst %,$(ODIR)/%,$(_HDC_OBJ))

$(ODIR)/%.hex: %.asm
	$(AS) $< $(ASFLAGS)

all: IBC_DMP011_REV_L.bin IBC_DMP014_REV_U.bin

IBC_DMP011_REV_L.bin: $(OBJ)
	objcopy -I ihex -O binary $^ $@
	truncate -s 8192 $@

IBC_DMP014_REV_U.bin: $(HDC_OBJ)
	objcopy -I ihex -O binary $^ $@
	truncate -s 8192 $@


.PHONY: clean

clean:
	rm -f $(ODIR)/*
