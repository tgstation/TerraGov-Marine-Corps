///The AI component has finished moving towards a node, change the state because of that certain thing happening
#define REASON_FINISHED_NODE_MOVE "finished_moving_to_node"

///Signal that's sent whenever the AI component kills off it's current target, this triggers a state change which could then go into a "patrol" or decide to attack another nearby target
#define REASON_TARGET_KILLED "recently_killed_a_target"

///AI component spotted a valid target and wants to attack it
#define REASON_TARGET_SPOTTED "spotted_a_target_attacking_with_favorable conditions"

///Repick targets every so often so we don't get stuck on a single thing forever
#define REASON_REFRESH_TARGET "picking_a_new_target_while_having_a_target"

///AI component state where it's moving towards a node
#define MOVING_TO_NODE "moving_to_a_node" //Move to a node

///AI component state where we're escorting something and looking for a target nearby
#define ESCORTING_ATOM "escorting_atom"

///AI component state where we're moving towards *something*, probably something we want to hit
#define MOVING_TO_ATOM "moving_to_an_atom"

///Ai component state where the ai tries to flee to heal
#define MOVING_TO_SAFETY "moving_to_safety"

///Ai component state where the ai just does nothing
#define IDLE "idle"

///Ai component state where the ai is following a tile path
#define FOLLOWING_PATH "following path"

///A define for a node variable which is the last world.time that a AI visited it
#define NODE_LAST_VISITED "node_last_visited"

/**
 * Identifier tags
 * Ultilized for having AI look at weights based on if they're a "marine human" or a "xenomorph" or something else
 * This is mainly used for deciding what weights are to be looked at when determing a node waypoint of going towards
 */
#define IDENTIFIER_XENO "identifies_xeno"
#define IDENTIFIER_ZOMBIE "identifies_zombie"


//Flags for the get_nearest_target
#define TARGET_HUMAN_TURRETS (1<<0)
#define TARGET_XENO_TURRETS (1<<1)
#define TARGET_HUMAN (1<<2)
#define TARGET_XENO (1<<3)
#define TARGET_UNMANNED_VEHICLE (1<<4)

#define MAX_NODE_RANGE 15
#define PATHFINDER_MAX_TRIES 200

GLOBAL_LIST_EMPTY(all_nodes)

///A GLOB of all /datum/component/ai_controller that currently exist
GLOBAL_LIST_EMPTY(ai_instances_active)

//To be implemented in later updates
GLOBAL_LIST_EMPTY(nodes_with_enemies)
GLOBAL_LIST_EMPTY(nodes_with_construction)
#define can_cross_lava_turf(turf_to_check) (!islava(turf_to_check) || locate(/turf/open/lavaland/catwalk) in turf_to_check)
