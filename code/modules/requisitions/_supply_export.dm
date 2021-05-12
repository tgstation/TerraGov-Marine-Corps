/atom/movable/proc/supply_export(faction_selling)
	return 0


/mob/living/carbon/xenomorph/supply_export(faction_selling)
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
	SSpoints.supply_points[faction_selling] += .
	return new /datum/export_report(., name, faction_selling)


/mob/living/carbon/human/supply_export(faction_selling)
	switch(job.job_category)
		if(JOB_CAT_ENGINEERING || JOB_CAT_MEDICAL || JOB_CAT_REQUISITIONS)
			. = 20
		if(JOB_CAT_MARINE)
			. = 30
		if(JOB_CAT_SILICON)
			. = 80
		if(JOB_CAT_COMMAND)
			. = 100
	SSpoints.supply_points[faction_selling] += .
	return new /datum/export_report(., name, faction_selling)

/// Return TRUE if the relation between the two factions are bad enough that a bounty is on the human_to_sell head
/proc/can_sell_human_body(mob/living/carbon/human/human_to_sell, seller_faction)
	switch(human_to_sell.faction)
		if(FACTION_NEUTRAL) //No one hates neutral
			return FALSE
		if(FACTION_TERRAGOV || FACTION_NANOTRASEN || FACTION_FREELANCERS)
			if(seller_faction == FACTION_TERRAGOV || seller_faction == FACTION_NANOTRASEN || seller_faction == FACTION_FREELANCERS)
				return FALSE
			return TRUE
		else
			if(seller_faction == FACTION_TERRAGOV || seller_faction == FACTION_NANOTRASEN || seller_faction == FACTION_FREELANCERS)
				return TRUE
			return FALSE
