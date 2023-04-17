//girder construction states
//^ wrench
#define GIRDER_BROKEN 0
//^ wirecutters
//v metal
#define GIRDER_BROKEN_PATCHED 1
//^ damage
//v welder
#define GIRDER_NORMAL 2 //wrench will anchor, crowbar will unanchor, screwdriver will disassemble if unanchored
// ^ crowbar
// v 2 metal / 15 plastel
#define GIRDER_BUILDING1_LOOSE 3
// ^ screwdriver
// v screwdriver
#define GIRDER_BUILDING1_SECURED 4
// ^ wirecutters
// v welder
#define GIRDER_BUILDING1_WELDED 5
// ^ crowbar
// v 2 metal / 15 plasteel
#define GIRDER_BUILDING2_LOOSE 6
// ^ screwdriver
// v screwdriver
#define GIRDER_BUILDING2_SECURED 7
// v welder
#define GIRDER_WALL_BUILT 8

#define GIRDER_REINF_METAL /obj/item/stack/sheet/metal
#define GIRDER_REINF_PLASTEEL /obj/item/stack/sheet/plasteel

#define STACK_RECIPE_INFINITE_PER_TILE 0
#define STACK_RECIPE_ONE_PER_TILE 1
#define STACK_RECIPE_ONE_DIRECTIONAL_PER_TILE 2

#define MAXCOIL 30

//The amount of materials you get from a sheet of mineral like iron/diamond/glass etc
#define MINERAL_MATERIAL_AMOUNT 2000

