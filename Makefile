ASM = nasm
ASMFLAGS = -f elf64

LD = ld
LDFLAGS = -m elf_x86_64 -e _famine
FAMINE := Famine
FAMINE_DBG := Famine_dbg

all: $(FAMINE)

debug: ASMFLAGS += -DDEBUG -F dwarf -g
debug: debug_all

$(FAMINE): Famine.s
	$(ASM) $(ASMFLAGS) $^
	$(LD) $(LDFLAGS) -o $@ Famine.o 

debug_all: $(FAMINE_DBG)

$(FAMINE_DBG):
	$(ASM) $(ASMFLAGS) Famine.s
	gcc -DDEBUG -c xprintf.c
	$(LD) $(LDFLAGS) -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o $@ -lc Famine.o xprintf.o

clean:
	rm -f Famine.o
	rm -f xprintf.o

fclean: clean
	rm -f $(FAMINE)
	rm -f $(FAMINE_DBG)

re: fclean all