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

///AI component state where we're moving towards *something*, probably something we want to hit
#define MOVING_TO_ATOM "moving_to_an_atom"

///A define for a node variable which is the last world.time that a AI visited it
#define NODE_LAST_VISITED "node_last_visited"

/**
 * Identifier tags
 * Ultilized for having AI look at weights based on if they're a "marine human" or a "xenomorph" or something else
 * This is mainly used for deciding what weights are to be looked at when determing a node waypoint of going towards
 */
#define IDENTIFIER_XENO "identifies_xeno"
