///The AI component has finished moving towards a node, change the state because of that certain thing happening
#define GO_TO_RANDOM_NODE "finished_moving_to_node"

///Find a target to attack
#define PICK_OTHER_TARGET "pick_other_target"

///Go back to our escorted atom
#define GO_TO_ESCORTED_ATOM "escorted_atom_is_too_far"

///AI component state where it's moving towards a node
#define MOVING_TO_NODE "moving_to_a_node" //Move to a node

///AI component state where we're moving towards *something*, probably something we want to hit
#define MOVING_TO_ATOM "moving_to_an_atom"

///AI component state where we're escorting something and looking for a target nearby
#define ESCORTING_ATOM "escorting_atom"

///A define for a node variable which is the last world.time that a AI chose to visit it
#define NODE_LAST_CHOSE_TO_VISIT "node_last_chose_to_visit"

/**
 * Identifier tags
 * Ultilized for having AI look at weights based on if they're a "marine human" or a "xenomorph" or something else
 * This is mainly used for deciding what weights are to be looked at when determing a node waypoint of going towards
 */
#define IDENTIFIER_XENO "identifies_xeno"
#define IDENTIFIER_ILLUSION "identifies_illusion"
