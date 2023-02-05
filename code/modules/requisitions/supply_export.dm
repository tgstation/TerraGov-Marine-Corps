///Should return a /datum/export_report if overriden
/atom/movable/proc/supply_export(faction_selling)
	return 0

/obj/item/reagent_containers/food/snacks/req_pizza/supply_export(faction_selling)
	SSpoints.supply_points[faction_selling] += 10
	return new /datum/export_report(10, name, faction_selling)

/mob/living/carbon/xenomorph/supply_export(faction_selling)
	switch(tier)
		if(XENO_TIER_MINION)
			. = 50
		if(XENO_TIER_ZERO)
			. = 150
		if(XENO_TIER_ONE)
			. = 300
		if(XENO_TIER_TWO)
			. = 400
		if(XENO_TIER_THREE)
			. = 500
		if(XENO_TIER_FOUR)
			. = 1000
	SSpoints.supply_points[faction_selling] += .
	return new /datum/export_report(., name, faction_selling)

/mob/living/carbon/xenomorph/shrike/supply_export(faction_selling)
	SSpoints.supply_points[faction_selling] += 500
	return new /datum/export_report(500, name, faction_selling)


/mob/living/carbon/human/supply_export(faction_selling)
	if(!can_sell_human_body(src, faction_selling))
		return new /datum/export_report(0, name, faction_selling)
	switch(job.job_category)
		if(JOB_CAT_ENGINEERING, JOB_CAT_MEDICAL, JOB_CAT_REQUISITIONS)
			. = 200
		if(JOB_CAT_MARINE)
			. = 300
		if(JOB_CAT_SILICON)
			. = 800
		if(JOB_CAT_COMMAND)
			. = 1000
	SSpoints.supply_points[faction_selling] += .
	return new /datum/export_report(., name, faction_selling)

/// Return TRUE if the relation between the two factions are bad enough that a bounty is on the human_to_sell head
/proc/can_sell_human_body(mob/living/carbon/human/human_to_sell, seller_faction)
	var/to_sell_alignement = GLOB.faction_to_alignement[human_to_sell.faction]
	switch(to_sell_alignement)
		if(ALIGNEMENT_NEUTRAL) //No one hates neutral
			return FALSE
		if(ALIGNEMENT_HOSTILE) // Can always sell an hostile unless you are of the same faction
			if(seller_faction == human_to_sell.faction)
				return FALSE
			return TRUE
		if(ALIGNEMENT_FRIENDLY)
			if(GLOB.faction_to_alignement[seller_faction] == ALIGNEMENT_FRIENDLY)
				return FALSE
			return TRUE
