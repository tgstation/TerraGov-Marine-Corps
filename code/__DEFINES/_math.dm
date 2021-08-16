//gets the turf the atom is located in (or itself, if it is a turf).
//returns null if the atom is not in a turf.
#define get_turf(A) get_step(A, 0)

//Same as above except gets the area instead
#define get_area(A) (isarea(A) ? A : get_step(A, 0)?.loc)

#define CARDINAL_DIRS list(1,2,4,8)
#define CARDINAL_ALL_DIRS list(1,2,4,5,6,8,9,10)
#define cheap_hypotenuse(Ax,Ay,Bx,By) (sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2)) //A squared + B squared = C squared
#define get_dist_euclide_square(A, B) (A && B ? A.z == B.z ? (A.x - B.x)**2 + (A.y - B.y)**2 : INFINITY : INFINITY)
#define get_dist_euclide(A, B) (sqrt(get_dist_euclide_square(A, B)))

#define LEFT 1
#define RIGHT 2
