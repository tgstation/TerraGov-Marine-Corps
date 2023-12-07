//Xenomorph Evolution Code - Apophis775 - Last Edit: 11JUN16

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
// refactored by spookydonut because the above two were shitcoders and i'm sure in time my code too will be considered shit.
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc
// except use typepaths now so you dont have to have an entry for literally every evolve path

/mob/living/carbon/xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"

	GLOB.evo_panel.ui_interact(src)

/mob/living/carbon/xenomorph/verb/regress()
	set name = "Regress"
	set desc = "Regress into a lower form."
	set category = "Alien"

	var/tiers_to_pick_from
	switch(tier)
		if(XENO_TIER_ZERO, XENO_TIER_FOUR)
			if(isxenoshrike(src))
				tiers_to_pick_from = GLOB.xeno_types_tier_one
			else
				to_chat(src, span_warning("Your tier does not allow you to regress."))
				return
		if(XENO_TIER_ONE)
			tiers_to_pick_from = list(/mob/living/carbon/xenomorph/larva)
		if(XENO_TIER_TWO)
			tiers_to_pick_from = GLOB.xeno_types_tier_one
		if(XENO_TIER_THREE)
			tiers_to_pick_from = GLOB.xeno_types_tier_two
		else
			CRASH("side_evolve() called without a valid tier")

	var/list/castes_to_pick = list()
	for(var/type in tiers_to_pick_from)
		var/datum/xeno_caste/available_caste = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
		castes_to_pick += available_caste.caste_name
	var/castepick = tgui_input_list(src, "We are growing into a beautiful alien! It is time to choose a caste.", null, castes_to_pick)
	if(!castepick) //Changed my mind
		return

	var/castetype
	for(var/type in tiers_to_pick_from)
		var/datum/xeno_caste/available_caste = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
		if(castepick != available_caste.caste_name)
			continue
		castetype = type
		break

	do_evolve(castetype, castepick, TRUE)

///Handles the evolution or devolution of the xenomorph
/mob/living/carbon/xenomorph/proc/do_evolve(caste_type, forced_caste_name, regression = FALSE)
	if(!generic_evolution_checks())
		return

	if(caste_type == /mob/living/carbon/xenomorph/hivemind && tgui_alert(src, "You are about to evolve into a hivemind, which places its core on the tile you're on when evolving. This core cannot be moved and you cannot regress. Are you sure you would like to place your core here?", "Evolving to hivemind", list("Yes", "No"), FALSE) != "Yes")
		return

	var/new_mob_type
	var/castepick
	if(caste_type)
		new_mob_type = caste_type
		castepick = forced_caste_name
	else
		var/list/castes_to_pick = list()
		for(var/type in xeno_caste.evolves_to)
			var/datum/xeno_caste/Z = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
			castes_to_pick += Z.caste_name
		castepick = tgui_input_list(src, "We are growing into a beautiful alien! It is time to choose a caste.", null, castes_to_pick)
		if(!castepick) //Changed my mind
			return

		for(var/type in xeno_caste.evolves_to)
			var/datum/xeno_caste/XC = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
			if(castepick == XC.caste_name)
				new_mob_type = type
				break

	if(!new_mob_type)
		CRASH("[src] tried to evolve but failed to find a new_mob_type")

	if(!caste_evolution_checks(new_mob_type, castepick, regression))
		return

	to_chat(src, span_xenonotice("It looks like the hive can support our evolution to <span style='font-weight: bold'>[castepick]!</span>"))
	visible_message(span_xenonotice("\The [src] begins to twist and contort."), \
	span_xenonotice("We begin to twist and contort."))
	do_jitter_animation(1000)

	if(!regression && !do_after(src, 25, IGNORE_HELD_ITEM, null, BUSY_ICON_CLOCK))
		balloon_alert(src, span_warning("We must hold still while evolving."))
		return

	if(!generic_evolution_checks() || !caste_evolution_checks(new_mob_type, castepick, regression))
		return

	SStgui.close_user_uis(src) //Force close all UIs upon evolution.
	finish_evolve(new_mob_type)

///Actually changes the xenomorph to another caste
/mob/living/carbon/xenomorph/proc/finish_evolve(new_mob_type)
	var/mob/living/carbon/xenomorph/new_xeno = new new_mob_type(get_turf(src))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		stack_trace("[src] tried to evolve but their new_xeno wasn't a xeno at all.")
		if(new_xeno)
			qdel(new_xeno)
		return
	new_xeno.upgrade_stored = upgrade_stored
	while(new_xeno.upgrade_stored >= new_xeno.xeno_caste?.upgrade_threshold && new_xeno.upgrade_possible())
		new_xeno.upgrade_xeno(new_xeno.upgrade_next(), TRUE)

	SEND_SIGNAL(src, COMSIG_XENOMORPH_EVOLVED, new_xeno)

	for(var/obj/item/W in contents) //Drop stuff
		dropItemToGround(W)

	if(mind)
		mind.transfer_to(new_xeno)
	else
		new_xeno.key = key

	//Pass on the unique nicknumber, then regenerate the new mob's name on Login()
	new_xeno.nicknumber = nicknumber
	new_xeno.hivenumber = hivenumber
	new_xeno.transfer_to_hive(hivenumber)
	transfer_observers_to(new_xeno)

	if(new_xeno.health - getBruteLoss(src) - getFireLoss(src) > 0) //Cmon, don't kill the new one! Shouldnt be possible though
		new_xeno.bruteloss = bruteloss //Transfers the damage over.
		new_xeno.fireloss = fireloss //Transfers the damage over.
		new_xeno.updatehealth()

	if(xeno_mobhud)
		var/datum/atom_hud/H = GLOB.huds[DATA_HUD_XENO_STATUS]
		H.add_hud_to(new_xeno) //keep our mobhud choice
		new_xeno.xeno_mobhud = TRUE

	if(lighting_alpha != new_xeno.lighting_alpha)
		new_xeno.toggle_nightvision(lighting_alpha)

	new_xeno.update_spits() //Update spits to new/better ones

	new_xeno.visible_message(span_xenodanger("A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [src]."), \
	span_xenodanger("We emerge in a greater form from the husk of our old body. For the hive!"))

	SEND_SIGNAL(hive, COMSIG_XENOMORPH_POSTEVOLVING, new_xeno)
	// Update the turf just in case they moved, somehow.
	var/turf/T = get_turf(src)
	deadchat_broadcast(" has evolved into a <b>[new_xeno.xeno_caste.caste_name]</b> at <b>[get_area_name(T)]</b>.", "<b>[src]</b>", follow_target = new_xeno, turf_target = T)

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")

	if(queen_chosen_lead && (new_xeno.xeno_caste.can_flags & CASTE_CAN_BE_LEADER)) // xeno leader is removed by Destroy()
		hive.add_leader(new_xeno)
		new_xeno.hud_set_queen_overwatch()
		if(hive.living_xeno_queen)
			new_xeno.handle_xeno_leader_pheromones(hive.living_xeno_queen)

		new_xeno.update_leader_icon(TRUE)

	if(upgrade == XENO_UPGRADE_PRIMO)
		switch(tier)
			if(XENO_TIER_TWO)
				SSmonitor.stats.primo_T2--
			if(XENO_TIER_THREE)
				SSmonitor.stats.primo_T3--
			if(XENO_TIER_FOUR)
				SSmonitor.stats.primo_T4--

	new_xeno.upgrade_stored = max(upgrade_stored, new_xeno.upgrade_stored)
	while(new_xeno.upgrade_possible() && new_xeno.upgrade_stored >= new_xeno.xeno_caste.upgrade_threshold)
		new_xeno.upgrade_xeno(new_xeno.upgrade_next(), TRUE)
	var/atom/movable/screen/zone_sel/selector = new_xeno.hud_used?.zone_sel
	selector?.set_selected_zone(zone_selected, new_xeno)
	qdel(src)
	INVOKE_ASYNC(new_xeno, TYPE_PROC_REF(/atom, do_jitter_animation), 1000)

	new_xeno.overlay_fullscreen_timer(2 SECONDS, 20, "roundstart2", /atom/movable/screen/fullscreen/spawning_in)

///Check if the xeno is currently able to evolve
/mob/living/carbon/xenomorph/proc/generic_evolution_checks()
	if(do_actions)
		balloon_alert(src, "We're busy!")
		return FALSE

	if(is_ventcrawling)
		balloon_alert(src, "This place is too constraining to evolve")
		return FALSE

	if(!isturf(loc))
		balloon_alert(src, "We can't evolve here")
		return FALSE

	if(is_banned_from(ckey, ROLE_XENOMORPH))
		log_admin_private("[key_name(src)] has tried to evolve as a xenomorph while being banned from the role.")
		message_admins("[ADMIN_TPMONTY(src)] has tried to evolve as a xenomorph while being banned. They shouldn't be playing the role.")
		balloon_alert(src, "You are jobbanned from aliens and cannot evolve. How did you even become an alien?")
		return FALSE

	if(incapacitated(TRUE))
		balloon_alert(src, "We can't evolve in our current state")
		return FALSE

	if(handcuffed)
		balloon_alert(src, "The restraints are too restricting to allow us to evolve")
		return FALSE

	if(isnull(xeno_caste.evolves_to) || !(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED) || HAS_TRAIT(src, TRAIT_VALHALLA_XENO))
		balloon_alert(src, "We are already the apex of form and function. Let's go forth and spread the hive!")
		return FALSE

	if(health < maxHealth)
		balloon_alert(src, "We must be at full health to evolve")
		return FALSE

	if(plasma_stored < (xeno_caste.plasma_max * xeno_caste.plasma_regen_limit))
		balloon_alert(src, "We must be at full plasma to evolve")
		return FALSE

	if (agility || fortify || crest_defense || status_flags & INCORPOREAL)
		balloon_alert(src, "We cannot evolve while in this stance")
		return FALSE

	if(eaten_mob)
		balloon_alert(src, "We cannot evolve with a belly full")
		return FALSE

	if(HAS_TRAIT_FROM(src, TRAIT_IMMOBILE, BOILER_ROOTED_TRAIT))
		balloon_alert(src, "We cannot evolve while rooted to the ground")
		return FALSE

	return TRUE

///Check if the xeno can currently evolve into a specific caste
/mob/living/carbon/xenomorph/proc/caste_evolution_checks(new_mob_type, castepick, regression = FALSE)
	if(!regression && !(new_mob_type in xeno_caste.evolves_to))
		balloon_alert(src, "We can't evolve to that caste from our current one")
		return FALSE

	var/no_room_tier_two = length(hive.xenos_by_tier[XENO_TIER_TWO]) >= hive.tier2_xeno_limit
	var/no_room_tier_three = length(hive.xenos_by_tier[XENO_TIER_THREE]) >= hive.tier3_xeno_limit
	var/datum/xeno_caste/new_caste_type = GLOB.xeno_caste_datums[new_mob_type][XENO_UPGRADE_BASETYPE]
	// Initial can access uninitialized vars, which is why it's used here.
	var/new_caste_flags = new_caste_type.caste_flags
	if(CHECK_BITFIELD(new_caste_flags, CASTE_LEADER_TYPE))
		if(is_banned_from(ckey, ROLE_XENO_QUEEN))
			balloon_alert(src, "You are jobbanned from xenomorph leader roles")
			return FALSE
		var/datum/job/xenojob = SSjob.GetJobType(/datum/job/xenomorph/queen)
		if(xenojob.required_playtime_remaining(client))
			to_chat(src, span_warning("[get_exp_format(xenojob.required_playtime_remaining(client))] as [xenojob.get_exp_req_type()] required to play queen like roles."))
			return FALSE

	var/min_xenos = new_caste_type.evolve_min_xenos
	if(min_xenos && (hive.total_xenos_for_evolving() < min_xenos))
		balloon_alert(src, "[min_xenos] xenos needed to become a [initial(new_caste_type.display_name)]")
		return FALSE
	if(CHECK_BITFIELD(new_caste_flags, CASTE_CANNOT_EVOLVE_IN_CAPTIVITY) && isxenoresearcharea(get_area(src)))
		to_chat(src, "Something in this place is isolating us from Queen Mother's psychic presence. We should leave before it's too late!")
		return FALSE
	// Check if there is a death timer for this caste
	if(new_caste_type.death_evolution_delay)
		var/death_timer = hive.caste_death_timers[new_caste_type.caste_type_path]
		if(death_timer)
			to_chat(src, span_warning("The hivemind is still recovering from the last [initial(new_caste_type.display_name)]'s death. We must wait [DisplayTimeText(timeleft(death_timer))] before we can evolve."))
			return FALSE
	var/maximum_active_caste = new_caste_type.maximum_active_caste
	if(maximum_active_caste != INFINITY && maximum_active_caste <= length(hive.xenos_by_typepath[new_mob_type]))
		to_chat(src, span_warning("There is already a [initial(new_caste_type.display_name)] in the hive. We must wait for it to die."))
		return FALSE
	var/turf/T = get_turf(src)
	if(CHECK_BITFIELD(new_caste_flags, CASTE_REQUIRES_FREE_TILE) && T.check_alien_construction(src))
		balloon_alert(src, "We need a empty tile to evolve")
		return FALSE

	if(istype(new_mob_type, /mob/living/carbon/xenomorph/queen))
		switch(hivenumber) // because it causes issues otherwise
			if(XENO_HIVE_CORRUPTED)
				new_mob_type = /mob/living/carbon/xenomorph/queen/Corrupted
			if(XENO_HIVE_ALPHA)
				new_mob_type = /mob/living/carbon/xenomorph/queen/Alpha
			if(XENO_HIVE_BETA)
				new_mob_type = /mob/living/carbon/xenomorph/queen/Beta
			if(XENO_HIVE_ZETA)
				new_mob_type = /mob/living/carbon/xenomorph/queen/Zeta
			if(XENO_HIVE_ADMEME)
				new_mob_type = /mob/living/carbon/xenomorph/queen/admeme
			if(XENO_HIVE_FALLEN)
				new_mob_type = /mob/living/carbon/xenomorph/queen/Corrupted/fallen

	if(!regression)
		if(new_caste_type.tier == XENO_TIER_TWO && no_room_tier_two)
			balloon_alert(src, "The hive cannot support another Tier 2, wait for either more aliens to be born or someone to die")
			return FALSE
		if(new_caste_type.tier == XENO_TIER_THREE && no_room_tier_three)
			balloon_alert(src, "The hive cannot support another Tier 3, wait for either more aliens to be born or someone to die")
			return FALSE
		var/potential_queens = length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/larva]) + length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/drone])
		if(SSticker.mode?.flags_round_type & MODE_XENO_RULER && !hive.living_xeno_ruler && potential_queens == 1)
			if(isxenolarva(src) && new_mob_type != /mob/living/carbon/xenomorph/drone)
				to_chat(src, span_xenonotice("The hive currently has no sister able to become a ruler! The survival of the hive requires from us to be a Drone!"))
				return FALSE
			else if(isxenodrone(src) && new_mob_type != /mob/living/carbon/xenomorph/shrike)
				to_chat(src, span_xenonotice("The hive currently has no sister able to become a ruler! The survival of the hive requires from us to be a Shrike!"))
				return FALSE
		if(!CHECK_BITFIELD(new_caste_flags, CASTE_INSTANT_EVOLUTION) && xeno_caste.evolution_threshold && evolution_stored < xeno_caste.evolution_threshold)
			to_chat(src, span_warning("We must wait before evolving. Currently at: [evolution_stored] / [xeno_caste.evolution_threshold]."))
			return FALSE

	if(isnull(new_mob_type))
		CRASH("[src] tried to evolve but their castepick was null")

	return TRUE

///Handles special conditions that influence a caste's evolution point gain, such as larva gaining a bonus if on weed.
/mob/living/carbon/xenomorph/proc/spec_evolution_boost()
	return 0
