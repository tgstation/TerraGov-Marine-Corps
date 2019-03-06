//gets the turf the atom is located in (or itself, if it is a turf).
//returns null if the atom is not in a turf.
#define get_turf(A) get_step(A, 0)

#define CARDINAL_DIRS 		list(1,2,4,8)
#define CARDINAL_ALL_DIRS 	list(1,2,4,5,6,8,9,10)
#define cheap_hypotenuse(Ax,Ay,Bx,By) (sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2)) //A squared + B squared = C squared

#define LEFT 1
#define RIGHT 2