//This is for telling the ai behavior what is making it swap over to a new action to execute because of some new circumstances
#define REASON_FINISHED_NODE_MOVE "finished moving to node" //We finished moving to a node
#define REASON_TARGET_KILLED "recently killed a target" //We finished killing something
#define REASON_TARGET_SPOTTED "spotted a target, attacking with favorable conditions"  //We spotted a target and determined it's a good idea to attack
#define REASON_REFRESH_TARGET "picking a new target while having a target" //Repick targets every so often so we don't get stuck on a single thing forever

//DEFINES for AI behavior to utilize to show off what it's currently doing
#define MOVING_TO_NODE "moving to a node" //Move to a node
#define MOVING_TO_ATOM "moving to an atom" //We want to move to this thing and probably hit it; can be just about anything like a mob or machinery
