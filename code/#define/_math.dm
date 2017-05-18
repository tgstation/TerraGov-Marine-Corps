//gets the turf the atom is located in (or itself, if it is a turf).
//returns null if the atom is not in a turf.
#define get_turf(A) get_step(A, 0)

#define PI 3.1415
#define CARDINAL_DIRS 		list(1,2,4,8)
#define CARDINAL_ALL_DIRS 	list(1,2,4,5,6,8,9,10)

//some colors
#define COLOR_RED 		"#FF0000"
#define COLOR_GREEN 	"#00FF00"
#define COLOR_BLUE 		"#0000FF"
#define COLOR_CYAN 		"#00FFFF"
#define COLOR_PINK 		"#FF00FF"
#define COLOR_YELLOW 	"#FFFF00"
#define COLOR_ORANGE 	"#FF9900"
#define COLOR_WHITE 	"#FFFFFF"

#define LEFT 1
#define RIGHT 2