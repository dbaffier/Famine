ASM = nasm
ASMFLAGS = -f elf64 -F dwarf -g

LD = ld
LDFLAGS = -m elf_x86_64 -e _infect
FAMINE := Famine

all: $(FAMINE)

$(FAMINE): Famine.s
	$(ASM) $(ASMFLAGS) $^
	$(LD) $(LDFLAGS) -o $@ Famine.o

clean:
	rm -f Famine.o

fclean: clean
	rm -f $(FAMINE)

re: fclean all