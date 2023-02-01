#define NO_SMOOTHING 0
#define CARDINAL_SMOOTHING 1
#define DIAGONAL_SMOOTHING 2

//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define NORTH_JUNCTION		NORTH //(1<<0)
#define SOUTH_JUNCTION		SOUTH //(1<<1)
#define EAST_JUNCTION		EAST  //(1<<2)
#define WEST_JUNCTION		WEST  //(1<<3)
#define NORTHEAST_JUNCTION	(1<<4)
#define SOUTHEAST_JUNCTION	(1<<5)
#define SOUTHWEST_JUNCTION	(1<<6)
#define NORTHWEST_JUNCTION	(1<<7)

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
