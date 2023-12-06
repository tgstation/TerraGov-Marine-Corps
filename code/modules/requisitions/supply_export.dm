///Function that sells whatever object this is to the faction_selling; returns a /datum/export_report if successful
/atom/movable/proc/supply_export(faction_selling)
	var/points = get_export_value()
	if(!points)
		return FALSE

	SSpoints.supply_points[faction_selling] += points
	SSpoints.dropship_points += points * 0.1
	return new /datum/export_report(points, name, faction_selling)

/mob/living/carbon/human/supply_export(faction_selling)
	if(!can_sell_human_body(src, faction_selling))
		return new /datum/export_report(0, name, faction_selling)
	return ..()

///Getter to obtain the req point value of whatever this is
/atom/movable/proc/get_export_value()
	return 0

/mob/living/carbon/human/get_export_value()
	switch(job.job_category)
		if(JOB_CAT_ENGINEERING, JOB_CAT_MEDICAL, JOB_CAT_REQUISITIONS)
			. = 200
		if(JOB_CAT_MARINE)
			. = 300
		if(JOB_CAT_SILICON)
			. = 800
		if(JOB_CAT_COMMAND)
			. = 1000
	return

/mob/living/carbon/xenomorph/get_export_value()
	switch(tier)
		if(XENO_TIER_MINION)
			. = 50
		if(XENO_TIER_ZERO)
			. = 70
		if(XENO_TIER_ONE)
			. = 150
		if(XENO_TIER_TWO)
			. = 300
		if(XENO_TIER_THREE)
			. = 500
		if(XENO_TIER_FOUR)
			. = 1000
	return

//I hate it but it's how it was so I'm not touching it further than this
/mob/living/carbon/xenomorph/shrike/get_export_value()
	return 500

/obj/item/reagent_containers/food/snacks/req_pizza/get_export_value()
	return 10

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
