//A datum that stores information about this node, the actual effect nodes have these created and referenced

/datum/ai_node
	var/obj/effect/ai_node/parentnode //The effect node this is attached to
	var/list/adjacent_nodes = list() // list of adjacent landmark nodes
	var/list/weights = list(ENEMY_PRESENCE = 0, DANGER_SCALE = 0) //List of weights for the overall things happening at this node

/datum/ai_node/proc/increment_weight(name, amount)
	weights[name] = max(0, weights[name] + amount)

/datum/ai_node/proc/set_weight(name, amount)
	weights[name] = amount
