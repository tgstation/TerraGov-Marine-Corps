/datum/action/xeno_action/activable/forward_charge/unprecise
		cooldown_timer = 30 SECONDS

/datum/action/xeno_action/activable/forward_charge/unprecise/use_ability(atom/A)
	return ..(get_turf(A))
