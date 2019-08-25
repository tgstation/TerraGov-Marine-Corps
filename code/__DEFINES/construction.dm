//girder construction states
//^ wrench
#define GIRDER_BROKEN			0
//^ screwdriver
//v metal
#define GIRDER_BROKEN_PATCHED	1
//^ damage
//v welder
#define GIRDER_NORMAL			2 //wrench will anchor, crowbar will unanchor, screwdriver will disassemble if unanchored
// ^ screwdriver
// v metal / plastel
#define GIRDER_BUILDING1_LOOSE	3
// ^ crowbar
// v welder
#define GIRDER_BUILDING1		4
// ^ screwdriver
// v metal / plastel
#define GIRDER_BUILDING2_LOOSE	5
// ^ crowbar
// v welder
#define GIRDER_BUILDING2		6
// ^ screwdriver
// v metal / plastel
#define GIRDER_BUILDING3_LOOSE	7
// v welder
#define GIRDER_WALL_BUILT		8

#define GIRDER_REINF_METAL	/obj/item/stack/sheet/metal
#define GIRDER_REINF_PLASTEEL	/obj/item/stack/sheet/plasteel

#define STACK_RECIPE_INFINITE_PER_TILE 0
#define STACK_RECIPE_ONE_PER_TILE 1
#define STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE 2
