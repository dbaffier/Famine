ASM = nasm
ASMFLAGS = -f elf64

LD = ld
LDFLAGS = -m elf_x86_64 -e _war
Death := Death

SRCS =  Death.s

OBJS = $(SRCS:.s=.o)

all: $(Death)

$(Death): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ 

%.o: %.s
	nasm -f elf64 -o $@ $<

clean:
	rm -f *.o

fclean: clean
	rm -f $(Death)

re: fclean all
