/datum/action/ability/activable/xeno/charge/forward_charge/unprecise
	cooldown_duration = 30 SECONDS

/datum/action/ability/activable/xeno/charge/forward_charge/unprecise/use_ability(atom/A)
	return ..(get_turf(A))
