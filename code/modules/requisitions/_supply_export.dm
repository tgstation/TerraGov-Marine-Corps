/atom/movable/proc/supply_export()
	return 0


/obj/structure/closet/crate/supply_export()
	. = 3
	SSpoints.supply_points += .

/obj/structure/ore_box/phoron/supply_export()
	. = 20
	SSpoints.supply_points += .

/obj/item/compactorebox/phoron/supply_export()
	. = 20
	SSpoints.supply_points += .

/obj/item/compactorebox/platinum/supply_export()
	. = 40
	SSpoints.supply_points += .

/obj/structure/ore_box/platinum/supply_export()
	. = 40
	SSpoints.supply_points += .

/mob/living/carbon/xenomorph/supply_export()
	switch(tier)
		if(XENO_TIER_ZERO)
			. = 15
		if(XENO_TIER_ONE)
			. = 30
		if(XENO_TIER_TWO)
			. = 40
		if(XENO_TIER_THREE)
			. = 50
		if(XENO_TIER_FOUR)
			. = 100
	SSpoints.supply_points += .
