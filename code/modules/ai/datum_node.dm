//A datum that stores information about this node, the actual effect nodes have these

//Different names for the weights being utilized and accounted for

/datum/ai_node
	var/obj/effect/AINode/parentnode //The effect node this is attached to
	var/list/adjacent_nodes = list() // list of adjacent landmark nodes
	var/list/weights = list(ENEMY_PRESENCE = 0, DANGER_SCALE = 0) //List of weights for the overall things happening at this node
	var/list/construction_markers = list(XENOMORPH = list(), MARINE = list(), NO_FACTION = list()) //ALL markers
	var/list/unassigned_markers = list(XENOMORPH = list(), MARINE = list(), NO_FACTION = list()) //All markers with no builder assigned

/datum/ai_node/proc/get_all_marker_faction(faction_type)
	return(construction_markers[faction_type])

/datum/ai_node/proc/get_unassigned_marker_faction(faction_type)
	return(unassigned_markers[faction_type])

/datum/ai_node/proc/remove_from_construction(datum/construction_marker/marker_to_remove)
	construction_markers[marker_to_remove.faction].Remove(marker_to_remove)
	unassigned_markers[marker_to_remove.faction].Remove(marker_to_remove)
	qdel(marker_to_remove)
	if(!length(construction_markers[marker_to_remove.faction]) && (src in GLOB.nodes_with_construction))
		GLOB.nodes_with_construction.Remove(src)

/datum/ai_node/proc/add_construction(datum/construction_marker/marker_to_add)
	if(!construction_markers[marker_to_add.faction])
		GLOB.nodes_with_construction.Add(src)
	construction_markers[marker_to_add.faction].Add(marker_to_add)
	unassigned_markers[marker_to_add.faction].Add(marker_to_add)

/datum/ai_node/proc/move_to_unassigned(datum/construction_marker/marker_to_move)
	unassigned_markers[marker_to_move.faction].Add(marker_to_move)
	construction_markers[marker_to_move.faction].Remove(marker_to_move)

/datum/ai_node/proc/remove_from_unassigned(datum/construction_marker/marker_to_move)
	construction_markers[marker_to_move.faction].Add(marker_to_move)
	unassigned_markers[marker_to_move.faction].Remove(marker_to_move)

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
