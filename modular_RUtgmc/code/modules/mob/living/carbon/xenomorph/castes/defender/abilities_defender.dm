// ***************************************
// *********** Regenerate Skin
// ***************************************

/datum/action/xeno_action/regenerate_skin
	plasma_cost = 80

// ***************************************
// *********** Fortify
// ***************************************

/datum/action/xeno_action/fortify/set_fortify(on, silent)
	. = ..()
	if(on)
		owner.drop_all_held_items() // drop items (hugger/jelly)
