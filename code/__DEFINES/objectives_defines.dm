// Objective priorities
#define OBJECTIVE_NO_VALUE 0
#define OBJECTIVE_LOW_VALUE 10
#define OBJECTIVE_MEDIUM_VALUE 20
#define OBJECTIVE_HIGH_VALUE 30
#define OBJECTIVE_EXTREME_VALUE 50
#define OBJECTIVE_ABSOLUTE_VALUE 100
//=================================================

// Required prereqs
#define PREREQUISITES_NONE 0
#define PREREQUISITES_ONE 1
#define PREREQUISITES_MAJORITY 2
#define PREREQUISITES_ALL 3

// Functionality flags
#define OBJ_PREREQS_CANT_FAIL 1
#define OBJ_DO_NOT_TREE 2
#define OBJ_REQUIRES_POWER 4
#define OBJ_REQUIRES_COMMS 8
#define OBJ_DEAD_END 16
#define OBJ_PROCESS_ON_DEMAND 32
#define OBJ_CRITICAL 64 // does failing this constitute a loss?
#define OBJ_CAN_BE_UNCOMPLETED 128
#define OBJ_FAILABLE 256

// Display flags
#define OBJ_DISPLAY_AT_END 1 // show it on the round end screen
#define OBJ_DISPLAY_WHEN_INACTIVE 2
#define OBJ_DISPLAY_WHEN_COMPLETE 4
#define OBJ_DISPLAY_HIDDEN 8
