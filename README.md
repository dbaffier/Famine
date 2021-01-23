## Famine

# Virus

- Infect all binaries `ET_EXEC & x86_64` on `/tmp/test/` and `/tmp/test2/` folders by injecting himself without altering the initial behavior of them.

# Features

- Anti debugging with PTRACE
- Anti debugging with elapsed time between 2 block of code
- Doesn't infect if a specific `test` process is running
- False disassembly
- Code obfuscation


# Method
- Reverse text infection
    * Patch the insertion code (parasite) to jump to the entry point
      (original)
    * Locate the text segment
    * For each phdr who's segment is after the insertion (text segment)
            * increase p_offset to reflect the new position after insertion
    * For each shdr who's section resides after the insertion
            * Increase sh_offset to account for the new code
    * Physically insert the new code into the file

original:

	[text]
	[data]

parasite:

	[parasite] (new start of text)
	[text]
	[data]


What's next ?

- Reduce his size and optimized use of registers
- Obfuscation of every "plain text" strings
- Encryption
- Polymorphism
- Methamorphism