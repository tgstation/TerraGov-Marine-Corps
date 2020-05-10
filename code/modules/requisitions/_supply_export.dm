/atom/movable/proc/supply_export()
	return 0


/obj/structure/closet/crate/supply_export()
	. = 3
	SSpoints.supply_points += .


/mob/living/carbon/xenomorph/supply_export()
	switch(tier)
		if(XENO_TIER_ZERO)
			. = 1
		if(XENO_TIER_ONE)
			. = 5
		if(XENO_TIER_TWO)
			. = 10
		if(XENO_TIER_THREE)
			. = 30
		if(XENO_TIER_FOUR)
			. = 50
	SSpoints.supply_points += .
