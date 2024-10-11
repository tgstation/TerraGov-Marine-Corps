//gets the turf the atom is located in (or itself, if it is a turf).
//returns null if the atom is not in a turf.
#define get_turf(A) get_step(A, 0)

//Same as above except gets the area instead
#define get_area(A) (isarea(A) ? A : get_step(A, 0)?.loc)

#define CARDINAL_DIRS list(1,2,4,8)
#define CARDINAL_ALL_DIRS list(1,2,4,5,6,8,9,10)
#define get_dist_euclidean_square(A, B) (A && B ? A.z == B.z ? (A.x - B.x)**2 + (A.y - B.y)**2 : INFINITY : INFINITY)
#define get_dist_euclidean(A, B) (sqrt(get_dist_euclidean_square(A, B)))

/// rand() but for floats, returns a random floating point number between low and high
#define randfloat(low, high) ((low) + rand() * ((high) - (low)))

#define LEFT 1
#define RIGHT 2
