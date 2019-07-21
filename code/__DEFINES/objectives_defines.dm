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
#define OBJ_PREREQS_CANT_FAIL (1<<0)
#define OBJ_DO_NOT_TREE (1<<1)
#define OBJ_REQUIRES_POWER (1<<2)
#define OBJ_REQUIRES_COMMS (1<<3)
#define OBJ_DEAD_END (1<<4)
#define OBJ_PROCESS_ON_DEMAND (1<<5)
#define OBJ_CRITICAL (1<<6) // does failing this constitute a loss?
#define OBJ_CAN_BE_UNCOMPLETED (1<<7)
#define OBJ_FAILABLE (1<<8)

// Display flags
#define OBJ_DISPLAY_AT_END (1<<0) // show it on the round end screen
#define OBJ_DISPLAY_WHEN_INACTIVE (1<<1)
#define OBJ_DISPLAY_WHEN_COMPLETE (1<<2)
#define OBJ_DISPLAY_HIDDEN (1<<3)
