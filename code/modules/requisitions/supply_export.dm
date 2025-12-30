///Function that sells whatever object this is to the faction_selling; returns a /datum/export_report if successful
/atom/movable/proc/supply_export(faction_selling, mob/user)
	var/list/points = get_export_value()
	if(!points)
		return FALSE

	SSpoints.add_supply_points(faction_selling, points[1])
	SSpoints.add_dropship_points(faction_selling, points[2])
	return list(new /datum/export_report(points[1], name, faction_selling, points[2]))

/mob/living/carbon/human/supply_export(faction_selling, mob/user)
	if(!can_sell_human_body(src, faction_selling))
		return list(new /datum/export_report(0, name, faction_selling, 0))
	return ..()

/mob/living/carbon/xenomorph/supply_export(faction_selling, mob/user)
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(faction_selling in hive.allied_factions)
		return list(new /datum/export_report(0, "[name] (Allied hive!)", faction_selling, 0))
	. = ..()
	if(!.)
		return FALSE

	var/list/points = get_export_value()
	GLOB.round_statistics.points_from_xenos += points[1]

/obj/structure/closet/supply_export(faction_selling, mob/user)
	. = ..()
	for(var/atom/movable/AM in contents)
		. += AM.supply_export(faction_selling)
		qdel(AM)

/obj/item/stack/req_jelly/supply_export(faction_selling, mob/user)
	var/datum/hive_status/hive = GLOB.hive_datums[hivenumber]
	if(faction_selling in hive.allied_factions)
		return list(new /datum/export_report(0, "[name] (Allied hive!)", faction_selling, 0))
	. = ..()
	var/datum/export_report/export_report = .[1]
	GLOB.round_statistics.points_from_ambrosia += export_report.points
	var/datum/game_mode/infestation/extended_plus/secret_of_life/gaymode = SSticker.mode
	if(gaymode && user)
		var/datum/individual_stats/the_stats = gaymode.stat_list[user.faction].get_player_stats(user)
		the_stats?.give_funds(round(export_report.points*0.4))

/**
 * Getter proc for the point value of this object
 *
 * Returns:
 * * A list where the first value is the number of req points and the second number is the number of cas points.
 */
/atom/movable/proc/get_export_value()
	. = list(0,0)

/mob/living/carbon/human/get_export_value()
	switch(job.job_category)
		if(JOB_CAT_ENGINEERING, JOB_CAT_MEDICAL, JOB_CAT_REQUISITIONS, JOB_CAT_ENGINEERINGSOM, JOB_CAT_MEDICALSOM, JOB_CAT_REQUISITIONSSOM)
			. = list(200, 20)
		if(JOB_CAT_MARINE, JOB_CAT_MARINESOM)
			. = list(300, 30)
		if(JOB_CAT_SILICON)
			. = list(800, 80)
		if(JOB_CAT_COMMAND, JOB_CAT_COMMANDSOM)
			. = list(1000, 100)
	return

/mob/living/carbon/xenomorph/get_export_value()
	switch(tier)
		if(XENO_TIER_MINION)
			. = list(60, 20)
		if(XENO_TIER_ZERO)
			. = list(200, 20)
		if(XENO_TIER_ONE)
			. = list(300, 40)
		if(XENO_TIER_TWO)
			. = list(600, 60)
		if(XENO_TIER_THREE)
			. = list(1000, 100)
		if(XENO_TIER_FOUR)
			. = list(2000, 200)
	return

//I hate it but it's how it was so I'm not touching it further than this
/mob/living/carbon/xenomorph/shrike/get_export_value()
	return list(1200, 120)

/obj/item/reagent_containers/food/snacks/req_pizza/get_export_value()
	return list(10, 0)

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

/obj/item/stack/req_jelly/get_export_value()
	return list(100 * amount, 25 * amount)
