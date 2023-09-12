// ***************************************
// *********** Snatch
// ***************************************

/datum/action/xeno_action/activable/snatch
	cooldown_timer = 35 SECONDS

/datum/action/xeno_action/activable/snatch/drop_item()
	if(!stolen_item)
		return

	stolen_item.drag_windup = 0 SECONDS
	owner.start_pulling(stolen_item, suppress_message = FALSE)
	stolen_item.drag_windup = 1.5 SECONDS

	return ..()
