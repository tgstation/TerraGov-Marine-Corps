//A datum that stores information about this node, the actual effect nodes have these

//Different names for the weights being utilized and accounted for
#define ENEMY_PRESENCE 1
#define DANGER_SCALE 2

/datum/ai_node
	var/obj/effect/AINode/parentnode //The effect node this is attached to
	var/list/adjacent_nodes = list() // list of adjacent landmark nodes
	var/list/weights = list(ENEMY_PRESENCE = 0, DANGER_SCALE = 0) //List of weights for the overall things happening at this node

//If we wanted to see if it's not set to 0
/datum/ai_node/proc/weight_not_null(name)
	if(name in weights && !weights[name])
		return TRUE
	return FALSE

/datum/ai_node/proc/get_weight(name)
	return weights[name]

/datum/ai_node/proc/increment_weight(name, amount)
	weights[name] = max(0, weights[name] + amount)

/datum/ai_node/proc/set_weight(name, amount)
	weights[name] = amount
