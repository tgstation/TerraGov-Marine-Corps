//This is for telling the ai mind the reason for a action state being completed or interupted; helps determine the next action state
#define REASON_FINISHED_NODE_MOVE "finished moving to node" //We finished moving to a node
#define REASON_TARGET_KILLED "recently killed a target" //We finished killing something
#define REASON_TARGET_SPOTTED "spotted a target, attacking with favorable conditions"  //We spotted a target and determined it's a good idea to attack
#define REASON_REFRESH_TARGET "picking a new target while having a target" //Repick targets every so often so we don't get stuck on a single thing forever
