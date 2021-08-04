/atom/movable/proc/supply_export(faction_selling)
	for(var/atom/movable/thing_inside in contents)
		thing_inside.supply_export(faction_selling)


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
	SSpoints.export_history += new /datum/export_report(., name, faction_selling)

/mob/living/carbon/xenomorph/shrike/supply_export(faction_selling)
	SSpoints.supply_points[faction_selling] += 50
	SSpoints.export_history += new /datum/export_report(50, name, faction_selling)


/mob/living/carbon/human/supply_export(faction_selling)
	if(faction == faction_selling)
		burial_export(faction_selling)
		return
	else switch(job.job_category)
		if(JOB_CAT_ENGINEERING || JOB_CAT_MEDICAL || JOB_CAT_REQUISITIONS)
			. = 20
		if(JOB_CAT_MARINE)
			. = 30
		if(JOB_CAT_SILICON)
			. = 80
		if(JOB_CAT_COMMAND)
			. = 100
	SSpoints.supply_points[faction_selling] += .
	SSpoints.export_history += new /datum/export_report(., name, faction_selling)

/**Calculates return value of properly prepared corpses, returns a number
 *
 * Checks for:
 **Five minute defib timer
 **Any brute or burn damage, including internal bleeding
 **Any limbs requiring repair, bearing an open surgical incision, or carrying high germs
 **Eye damage or disfigurement
 **Shrapnel
 **Full dress uniform: torso, hat, gloves, boots
 **Suicide
 **Dogtag in memorial, if they've got one
 */
/mob/living/carbon/human/proc/burial_export(faction_selling)
	var/report_name = name
	var/list/problems = list()
	var/payout = 0

	switch(job.job_category)
		if(JOB_CAT_ENGINEERING || JOB_CAT_MEDICAL || JOB_CAT_REQUISITIONS)
			payout = 5	//Shipside crew shouldn't be dying in any situation where you can still use requisitions.
		if(JOB_CAT_MARINE)
			payout = 20
		if(JOB_CAT_SILICON)
			payout = 50	//Silicons can get recycled so they're worth extra
		if(JOB_CAT_COMMAND)
			payout = 30

	if(!HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
		problems += "lingering vitals"
		payout = 0

	var/damaged_limbs = 0
	var/surgery_limbs = 0
	var/infected_limbs = 0
	var/tissue_damage = 0
	for(var/datum/limb/test_limb AS in limbs)
		if(test_limb.limb_status & (LIMB_BLEEDING|LIMB_BROKEN|LIMB_DESTROYED|LIMB_NECROTIZED|LIMB_AMPUTATED|LIMB_MUTATED))
			damaged_limbs++
		if(test_limb.surgery_open_stage)
			surgery_limbs++
		if(test_limb.germ_level > INFECTION_LEVEL_ONE)
			infected_limbs++
		tissue_damage += test_limb.brute_dam + test_limb.burn_dam
	if(damaged_limbs)
		payout -= 3 * damaged_limbs
		problems += "damaged limbs"
	if(surgery_limbs)
		payout -= 5 * surgery_limbs
		problems += "ongoing surgery"
	if(infected_limbs)
		payout -= 3 * infected_limbs
		problems += "infection"
	if(tissue_damage > 10)
		payout -= round(tissue_damage/10)
		problems += "tissue damage"


	if(internal_organs_by_name["eyes"]?.damage)
		payout -= 3
		problems |= "ocular damage"
	if(get_limb("head")?.disfigured)
		payout -= 10
		problems += "disfigurement"
	if(LAZYLEN(embedded_objects))
		payout -= 5
		problems += "embedded shrapnel"

	var/bad_fashion
	//Full dress uniform. Other things being present is fine, but replacing the uniform will naturally remove almost all of it.
	if(!istype(w_uniform, /obj/item/clothing/under/whites))
		payout -= 5
		bad_fashion = TRUE
	if(!istype(head, /obj/item/clothing/head/white_dress))
		payout -= 5
		bad_fashion = TRUE
	if(!istype(gloves, /obj/item/clothing/gloves/white))
		payout -= 5
		bad_fashion = TRUE
	if(!istype(shoes, /obj/item/clothing/shoes/white))
		payout -= 5
		bad_fashion = TRUE
	if(bad_fashion)
		problems += "improper dress"

	if(istype(wear_id, /obj/item/card/id/dogtag))
		var/obj/item/card/id/dogtag/our_tag = wear_id
		if((!our_tag.dogtag_taken) || (!GLOB.fallen_list.Find(our_tag.registered_name)))
			payout = 0
			problems += "marine not memorialized"

	if(suiciding)
		payout = 0
		problems += "non-combat death"

	if(problems.len)
		report_name += " \[DISCREPANCIES: "
		for(var/messup in problems)
			report_name += messup + ", "
		report_name = copytext(report_name, 1, -2) + "\]"
		payout = max(payout, 0)

	SSpoints.supply_points[faction_selling] += payout
	SSpoints.export_history += new /datum/export_report(payout, report_name, faction_selling)


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
