#define NO_SMOOTHING 0
#define CARDINAL_SMOOTHING 1
#define DIAGONAL_SMOOTHING 2

//smoothing_groups
#define SMOOTH_GENERAL_STRUCTURES (1<<0) //Walls, doors, windows, girders, you name it.
#define SMOOTH_XENO_STRUCTURES (1<<1) //Resin structures.
#define SMOOTH_FLORA (1<<3) //Vegetation walls
#define SMOOTH_MINERAL_STRUCTURES (1<<4) //Caves


//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define N_NORTH		NORTH //(1<<0)
#define N_SOUTH		SOUTH //(1<<1)
#define N_EAST		EAST  //(1<<2)
#define N_WEST		WEST  //(1<<3)
#define N_NORTHEAST	(1<<4)
#define N_SOUTHEAST	(1<<5)
#define N_SOUTHWEST	(1<<6)
#define N_NORTHWEST	(1<<7)

//Corner types
#define CONVEX 0
#define CONCAVE 1
#define HORIZONTAL 2
#define VERTICAL 3
#define FLAT 4
