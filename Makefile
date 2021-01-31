ASM = nasm
ASMFLAGS = -f elf64

LD = ld
LDFLAGS = -m elf_x86_64 -e _famine
FAMINE := Famine

SRCS =  Famine.s

OBJS = $(SRCS:.s=.o)

all: $(FAMINE)

$(FAMINE): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ 

%.o: %.s
	nasm -f elf64 -o $@ $<

clean:
	rm -f *.o

fclean: clean
	rm -f $(FAMINE)

re: fclean all