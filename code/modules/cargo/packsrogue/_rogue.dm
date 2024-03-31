/datum/supply_pack/rogue
	var/static_cost = FALSE
	var/randomprice_factor = 0.07

/datum/supply_pack/rogue/New()
	. = ..()
#ifdef TESTSERVER
	cost = 1
#else
	if(cost)
		if(cost == initial(cost) && !static_cost)
			var/na = max(round(cost * randomprice_factor, 1), 1)
			cost = max(rand(cost-na, cost+na), 1)
#endif