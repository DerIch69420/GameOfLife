# Makefile
all: life

life: main.o grid.o display.o
	ld -o life main.o grid.o display.o

%.o: %.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f *.o life
