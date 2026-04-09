# -*- mode: makefile-gmake; -*-

main.hex: main.asm
	avra $<

fuse:
	avrdude -c avrftdi -p m16 -P /dev/serial/by-id/usb-FTDI_USB__-__Serial_Converter_FT9RN7V1-if01-port0  -U lfuse:w:0xE1:m -U hfuse:w:0xD9:m

flash: main.hex
	avrdude -c avrftdi -p m16 -P /dev/serial/by-id/usb-FTDI_USB__-__Serial_Converter_FT9RN7V1-if01-port0  -U flash:w:main.hex:a

.PHONY: fuse flash
