#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void generate_records(int i, FILE *strm)
{
    int t = 0;
    int x = rand() % 100;
    int y = rand() % 100;
    for (t = 0; t <= 200; ++t) {
        fprintf(strm, "%d %d %d %d\n", i, t, x, y);
        int vx = rand() % 11 - 5;
        int vy = rand() % 11 - 5;
        x += vx;
        y += vy;
    }
}

int main()
{
    srand(time(NULL));

    int n = 5;
    int i;
    for (i = 1; i <= n; ++i) {
        char file_name[32];
        sprintf(file_name, "d%d", i);
        FILE *strm = fopen(file_name, "w");
        if (strm == NULL)
            abort();
        generate_records(i, strm);
        fclose(strm);
    }
    return 0;
}
