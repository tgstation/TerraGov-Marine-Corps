/datum/ai_behavior/xeno/husk
	identifier = IDENTIFIER_HUSK
	base_action = ESCORTING_ATOM
	sidestep_prob = 10
	minimum_health = 0

/datum/ai_behavior/xeno/husk/attack_target(datum/soure, atom/attacked)
	if(world.time < mob_parent.next_move)
		return
	if(!attacked)
		attacked = atom_to_walk_to
	if(get_dist(attacked, mob_parent) > 1)
		return
	mob_parent.face_atom(attacked)
	var/obj/item/item_in_hand = mob_parent.r_hand
	if(!item_in_hand)
		item_in_hand = mob_parent.l_hand
	if(!item_in_hand)
		return
	INVOKE_ASYNC(item_in_hand, /obj/item.proc/melee_attack_chain, mob_parent, attacked)

/datum/ai_behavior/xeno/husk/try_to_heal()
	return //Husks don't need to do anything to heal

/datum/ai_behavior/xeno/husk/patrolling
	base_action = MOVING_TO_NODE
