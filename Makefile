# If your default python is 3, you may want to change this to python27.
PYTHON = python


all: game.gbc ; @:

clean:
	@rm -f $(obj)
	@rm -f game.{gbc,sym,map}


obj := src/main.o


# Build objects from source.
%.o: %.asm
	@rgbasm -i src/ -o $@ $<


# Link objects to create a playable image.
# This also spits out game.sym, which lets you use labels in bgb.
game.gbc: $(obj)
	@rgblink -n $*.sym -m $*.map -o $@ $^
	@rgbfix  -v $@


# Images can be converted from png to 1bpp and 2bpp.
%.2bpp: %.png ; $(PYTHON) gfx.py 2bpp $<
%.1bpp: %.png ; $(PYTHON) gfx.py 1bpp $<
