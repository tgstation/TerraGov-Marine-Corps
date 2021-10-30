//Construction Categories
#define PIPE_STRAIGHT 0 //2 directions: N/S, E/W
#define PIPE_BENDABLE 1 //6 directions: N/S, E/W, N/E, N/W, S/E, S/W
#define PIPE_TRINARY 2 //4 directions: N/E/S, E/S/W, S/W/N, W/N/E
#define PIPE_TRIN_M 3 //8 directions: N->S+E, S->N+E, N->S+W, S->N+W, E->W+S, W->E+S, E->W+N, W->E+N
#define PIPE_UNARY 4 //4 directions: N, S, E, W
#define PIPE_ONEDIR 5 //1 direction: N/S/E/W
#define PIPE_UNARY_FLIPPABLE 6 //8 directions: N/S/E/W/N-flipped/S-flipped/E-flipped/W-flipped
