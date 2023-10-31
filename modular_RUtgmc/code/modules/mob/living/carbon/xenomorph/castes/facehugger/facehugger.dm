/mob/living/carbon/xenomorph/facehugger
	caste_base_type = /mob/living/carbon/xenomorph/facehugger
	name = "Facehugger"
	desc = "This one looks much more active than its fellows"
	icon = 'modular_RUtgmc/icons/Xeno/castes/facehugger.dmi'
	icon_state = "Facehugger Walking"

	health = 50
	maxHealth = 50
	plasma_stored = 100

	pixel_x = -8
	pixel_y = -3
	old_x = -8
	old_y = -3

	// default_honor_value = 0

	tier = XENO_TIER_MINION
	upgrade = XENO_UPGRADE_BASETYPE
	mob_size = MOB_SIZE_SMALL
	pull_speed = -2
	allow_pass_flags = PASS_MOB|PASS_XENO
	pass_flags = PASS_LOW_STRUCTURE|PASS_MOB|PASS_XENO
	density = FALSE

	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	bubble_icon = "alien"

// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/facehugger/handle_living_health_updates()
	. = ..()
	var/turf/T = loc
	if(!istype(T))
		return
	//We lose health if we go off the weed
	if(!loc_weeds_type && !(lying_angle || resting))
		adjustBruteLoss(2, TRUE)
		return

//Handles change in density (so people can walk through us)
/mob/living/carbon/xenomorph/facehugger/set_lying_angle(new_lying)
	. = ..()
	if(isnull(.))
		return
	if(density != initial(density))
		density = FALSE

/mob/living/carbon/xenomorph/facehugger/update_progression()
	return

/mob/living/carbon/xenomorph/facehugger/on_death()
	///We QDEL them as cleanup and preventing them from being sold
	QDEL_IN(src, 1 MINUTES)
	GLOB.hive_datums[hivenumber].facehuggers -= src
	return ..()

/mob/living/carbon/xenomorph/facehugger/start_pulling(atom/movable/AM, force = move_force, suppress_message = FALSE)
	return FALSE

/mob/living/carbon/xenomorph/facehugger/pull_response(mob/puller)
	return TRUE

/mob/living/carbon/xenomorph/facehugger/death_cry()
	return

/mob/living/carbon/xenomorph/facehugger/get_liquid_slowdown()
	return FACEHUGGER_WATER_SLOWDOWN

///Trying to attach facehagger to face. Returns true on success and false otherwise
/mob/living/carbon/xenomorph/facehugger/proc/try_attach(mob/living/carbon/human/host)
	var/obj/item/clothing/mask/facehugger/larval/mask = new /obj/item/clothing/mask/facehugger/larval(host, src.hivenumber, src)
	if(host.can_be_facehugged(mask, provoked = TRUE))
		if(mask.Attach(host, FALSE)) //Attach hugger-mask
			src.forceMove(host) //Moving sentient hugger inside host
			if(client && isnormalhive(hive))
				client.facehugger_exp_update(1)
			return TRUE
		else
			qdel(mask)
			return FALSE
	else
		qdel(mask)
		return FALSE

/mob/living/carbon/xenomorph/facehugger/generate_name()
	var/playtime_mins = client?.get_exp(EXP_TYPE_FACEHUGGER_STAT)
	var/rank_name
	switch(playtime_mins)
		if(0 to 14)
			rank_name = "Young"
		if(15 to 49)
			rank_name = "Fledgling"
		if(50 to 149)
			rank_name = "Veteran"
		if(150 to 499)
			rank_name = "Baneful"
		if(500 to INFINITY)
			rank_name = "Royal"
		else
			rank_name = "Young"
	var/prefix = (hive.prefix || xeno_caste.upgrade_name) ? "[hive.prefix][xeno_caste.upgrade_name] " : ""
	name = prefix + "[rank_name ? "[rank_name] " : ""][xeno_caste.display_name] ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/facehugger/playtime_as_number()
	var/playtime_mins = client?.get_exp(EXP_TYPE_FACEHUGGER_STAT)
	switch(playtime_mins)
		if(0 to 14)
			return 0
		if(15 to 49)
			return 1
		if(50 to 149)
			return 2
		if(150 to 499)
			return 3
		if(500 to INFINITY)
			return 4
		else
			return 0



