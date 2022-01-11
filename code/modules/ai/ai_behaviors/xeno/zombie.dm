/datum/ai_behavior/xeno/zombie
	identifier = IDENTIFIER_ZOMBIE
	base_action = ESCORTING_ATOM
	pathfinding_datum_type = /datum/pathfinding_datum/zombie

/datum/ai_behavior/xeno/zombie/process()
	. = ..()
	var/mob/living/living_parent = mob_parent
	if(living_parent.resting)
		living_parent.get_up()

/datum/ai_behavior/xeno/zombie/attack_target(datum/soure, atom/attacked)
	if(world.time < mob_parent.next_move)
		return
	if(!attacked)
		attacked = pathfinding_datum.atom_to_walk_to
	if(get_dist(attacked, mob_parent) > 1)
		return
	mob_parent.face_atom(attacked)
	var/obj/item/item_in_hand = mob_parent.r_hand
	if(!item_in_hand)
		item_in_hand = mob_parent.l_hand
	if(!item_in_hand)
		return
	INVOKE_ASYNC(item_in_hand, /obj/item.proc/melee_attack_chain, mob_parent, attacked)

/datum/ai_behavior/xeno/zombie/try_to_heal()
	return //Zombies don't need to do anything to heal

/datum/ai_behavior/xeno/zombie/patrolling
	base_action = MOVING_TO_NODE

/datum/ai_behavior/xeno/zombie/idle
	base_action = IDLE
