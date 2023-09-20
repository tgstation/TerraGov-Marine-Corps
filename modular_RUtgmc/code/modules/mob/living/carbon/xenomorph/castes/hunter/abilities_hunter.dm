/datum/action/xeno_action/mirage/swap()
	. = ..()
	owner.drop_all_held_items() // drop items (hugger/jelly)
