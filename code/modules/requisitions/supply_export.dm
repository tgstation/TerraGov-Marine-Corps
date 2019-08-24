/atom/movable/proc/supply_export()
	return FALSE


/obj/structure/closet/crate/supply_export()
	SSpoints.supply_points += POINTS_PER_CRATE
	return TRUE


/mob/living/carbon/xenomorph/supply_export()
	switch(tier)
		if(XENO_TIER_ZERO)
			SSpoints.supply_points++
		if(XENO_TIER_ONE)
			SSpoints.supply_points += 5
		if(XENO_TIER_TWO)
			SSpoints.supply_points += 10
		if(XENO_TIER_THREE)
			SSpoints.supply_points += 30
		if(XENO_TIER_FOUR)
			SSpoints.supply_points += 50
	return TRUE
