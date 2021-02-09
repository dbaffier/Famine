ASM = nasm
ASMFLAGS = -f elf64

LD = ld
LDFLAGS = -m elf_x86_64 -e _war
War := War

SRCS =  War.s

OBJS = $(SRCS:.s=.o)

all: $(War)

$(War): $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ 

%.o: %.s
	nasm -f elf64 -o $@ $<

clean:
	rm -f *.o

fclean: clean
	rm -f $(War)

re: fclean all