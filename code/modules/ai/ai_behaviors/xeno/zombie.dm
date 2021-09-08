/datum/ai_behavior/xeno/zombie
	identifier = IDENTIFIER_ZOMBIE
	base_action = ESCORTING_ATOM

/datum/ai_behavior/xeno/zombie/New(loc, mob/parent_to_assign, atom/escorted_atom)
	if(!escorted_atom)
		escorted_atom = get_turf(parent_to_assign)
	..()
