ASM = nasm
ASMFLAGS = -f elf64

LD = ld
LDFLAGS = -m elf_x86_64 -e _famine
FAMINE := Famine

all: $(FAMINE)

debug: ASMFLAGS += -DDEBUG -F dwarf -g
debug: all

$(FAMINE): Famine.s
	$(ASM) $(ASMFLAGS) $^
	$(LD) $(LDFLAGS) -o $@ Famine.o

clean:
	rm -f Famine.o

fclean: clean
	rm -f $(FAMINE)

re: fclean all