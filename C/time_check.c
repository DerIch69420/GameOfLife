#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define WIDTH  80
#define HEIGHT 25
#define ALIVE  "\u2588" // white block
#define DEAD   " "

int grid[HEIGHT][WIDTH];
int next[HEIGHT][WIDTH];

// initialize grid with random values
void init_grid() {
    for (int y = 0; y < HEIGHT; y++)
        for (int x = 0; x < WIDTH; x++)
            grid[y][x] = rand() % 2;
}

// print grid to terminal
void print_grid() {
    printf("\033[2J\033[H");
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++)
            printf("%s", grid[y][x] ? ALIVE : DEAD);
        putchar('\n');
    }
}

// count live neighbors
int count_neighbors(int y, int x) {
    int count = 0;
    for (int dy = -1; dy <= 1; dy++)
        for (int dx = -1; dx <= 1; dx++) {
            if (dy == 0 && dx == 0) continue;
            int ny = (y + dy + HEIGHT) % HEIGHT;
            int nx = (x + dx + WIDTH) % WIDTH;
            count += grid[ny][nx];
        }
    return count;
}

// rules
void update_grid() {
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            int n = count_neighbors(y, x);
            if (grid[y][x]) {
                next[y][x] = (n == 2 || n == 3);
            } else {
                next[y][x] = (n == 3);
            }
        }
    }

    // copy next to grid
    for (int y = 0; y < HEIGHT; y++)
        for (int x = 0; x < WIDTH; x++)
            grid[y][x] = next[y][x];
}

int main() {
    init_grid();

    for (int i =0; i < 100; i++) {
        print_grid();
        update_grid();
    }

    return 0;
}

