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

/mob/living/carbon/xenomorph/proc/do_evolve(caste_type, forced_caste_name, regression = FALSE)
	if(is_ventcrawling)
		to_chat(src, span_warning("This place is too constraining to evolve."))
		return

	if(!isturf(loc))
		to_chat(src, span_warning("We can't evolve here."))
		return

	if(xeno_caste.hardcore)
		to_chat(src, span_warning("Nuh-uh."))
		return

	if(is_banned_from(ckey, ROLE_XENOMORPH))
		log_admin_private("[key_name(src)] has tried to evolve as a xenomorph while being banned from the role.")
		message_admins("[ADMIN_TPMONTY(src)] has tried to evolve as a xenomorph while being banned. They shouldn't be playing the role.")
		to_chat(src, span_warning("You are jobbanned from aliens and cannot evolve. How did you even become an alien?"))
		return

	if(incapacitated(TRUE))
		to_chat(src, span_warning("We can't evolve in our current state."))
		return

	if(handcuffed)
		to_chat(src, span_warning("The restraints are too restricting to allow us to evolve."))
		return

	if(isnull(xeno_caste.evolves_to))
		to_chat(src, span_warning("We are already the apex of form and function. Let's go forth and spread the hive!"))
		return

	if(health < maxHealth)
		to_chat(src, span_warning("We must be at full health to evolve."))
		return

	if(plasma_stored < (xeno_caste.plasma_max * xeno_caste.plasma_regen_limit))
		to_chat(src, span_warning("We must be at full plasma to evolve."))
		return

	if (agility || fortify || crest_defense || status_flags & INCORPOREAL)
		to_chat(src, span_warning("We cannot evolve while in this stance."))
		return

	if(eaten_mob)
		to_chat(src, span_warning("We cannot evolve with a belly full."))
		return

	var/new_caste_type
	var/castepick
	if(caste_type)
		new_caste_type = caste_type
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
				new_caste_type = type
				break

	if(!new_caste_type)
		CRASH("[src] tried to evolve but failed to find a new_caste_type")

	if(!isturf(loc)) //cdel'd or inside something
		return

	if(incapacitated(TRUE))
		to_chat(src, span_warning("We can't evolve in our current state."))
		return

	if(handcuffed)
		to_chat(src, span_warning("The restraints are too restricting to allow us to evolve."))
		return

	if(xeno_caste.hardcore)
		to_chat(src, span_warning("Nuh-uhh."))
		return

	if(!regression && !(new_caste_type in xeno_caste.evolves_to))
		to_chat(src, span_warning("We can't evolve to that caste from our current one."))
		return

	// used below
	var/no_room_tier_two = length(hive.xenos_by_tier[XENO_TIER_TWO]) >= hive.tier2_xeno_limit
	var/no_room_tier_three = length(hive.xenos_by_tier[XENO_TIER_THREE]) >= hive.tier3_xeno_limit

	if(new_caste_type == /mob/living/carbon/xenomorph/queen) //Special case for dealing with queenae
		if(is_banned_from(ckey, ROLE_XENO_QUEEN))
			to_chat(src, span_warning("You are jobbanned from the Queen role."))
			return

		var/datum/job/xenojob = SSjob.GetJobType(/datum/job/xenomorph/queen)
		if(xenojob.required_playtime_remaining(client))
			to_chat(src, span_warning("[get_exp_format(xenojob.required_playtime_remaining(client))] as [xenojob.get_exp_req_type()] required to play the queen role."))
			return

		if(hive.living_xeno_queen)
			to_chat(src, span_warning("There already is a living Queen."))
			return

		if(hive.can_hive_have_a_queen())
			to_chat(src, span_warning("The hivemind is too weak to sustain a Queen. Gather more xenos. [hive.xenos_per_queen] are required."))
			return FALSE

		if(hivenumber == XENO_HIVE_NORMAL && SSticker.mode && hive.xeno_queen_timer)
			to_chat(src, "<span class='warning'>We must wait about [timeleft(hive.xeno_queen_timer) * 0.1] seconds for the hive to recover from the previous Queen's death.<span>")
			return

		if(isxenoresearcharea(get_area(src)))
			to_chat(src, span_warning("Something in this place is isolating us from Queen Mother's psychic presence. We should leave before it's too late!"))
			return

		switch(hivenumber) // because it causes issues otherwise
			if(XENO_HIVE_CORRUPTED)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Corrupted
			if(XENO_HIVE_ALPHA)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Alpha
			if(XENO_HIVE_BETA)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Beta
			if(XENO_HIVE_ZETA)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Zeta
			if(XENO_HIVE_ADMEME)
				new_caste_type = /mob/living/carbon/xenomorph/queen/admeme

	else if(new_caste_type == /mob/living/carbon/xenomorph/shrike) //Special case for dealing with shrikes
		if(is_banned_from(ckey, ROLE_XENO_QUEEN))
			to_chat(src, span_warning("You are jobbanned from Queen-like roles."))
			return

		if(length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/shrike]))
			to_chat(src, span_warning("There already is a living Shrike. The hive cannot contain more than one psychic energy repository."))
			return

		if(isxenoresearcharea(get_area(src)))
			to_chat(src, span_warning("Something in this place is interfering with our link to Queen Mother. We are unable to evolve to a psychic caste here!"))
			return

	else if(new_caste_type == /mob/living/carbon/xenomorph/hivemind) //Special case for dealing with hiveminds - this may be subject to heavy change, such as multiple hiveminds potentially being an option
		if(length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/hivemind]))
			to_chat(src, span_warning("There cannot be two manifestations of the hivemind's will at once."))
			return

		if(isxenoresearcharea(get_area(src)))
			to_chat(src, span_warning("Something in this place is interfering with our link to the Hivemind. We are unable to evolve to be its manifestation!"))
			return

		var/turf/T = get_turf(src)

		if(!T.check_alien_construction(src))
			return


	else
		var/potential_queens = length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/larva]) + length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/drone])

		if(regression)
			//Nothing, go on as normal.
		else if(tier == XENO_TIER_ONE && no_room_tier_two)
			to_chat(src, span_warning("The hive cannot support another Tier 2, wait for either more aliens to be born or someone to die."))
			return
		else if(tier == XENO_TIER_TWO && no_room_tier_three)
			to_chat(src, span_warning("The hive cannot support another Tier 3, wait for either more aliens to be born or someone to die."))
			return
		else if(SSticker.mode?.flags_round_type & MODE_XENO_RULER && !hive.living_xeno_ruler && potential_queens == 1)
			if(isxenolarva(src) && new_caste_type != /mob/living/carbon/xenomorph/drone)
				to_chat(src, span_xenonotice("The hive currently has no sister able to become a ruler! The survival of the hive requires from us to be a Drone!"))
				return
			else if(isxenodrone(src) && new_caste_type != /mob/living/carbon/xenomorph/shrike)
				to_chat(src, span_xenonotice("The hive currently has no sister able to become a ruler! The survival of the hive requires from us to be a Shrike!"))
				return
		else if(xeno_caste.evolution_threshold && evolution_stored < xeno_caste.evolution_threshold)
			to_chat(src, span_warning("We must wait before evolving. Currently at: [evolution_stored] / [xeno_caste.evolution_threshold]."))
			return
		else
			to_chat(src, span_xenonotice("It looks like the hive can support our evolution to <span style='font-weight: bold'>[castepick]!</span>"))

	if(isnull(new_caste_type))
		CRASH("[src] tried to evolve but their castepick was null")

	visible_message(span_xenonotice("\The [src] begins to twist and contort."), \
	span_xenonotice("We begin to twist and contort."))
	do_jitter_animation(1000)

	if(!regression && !do_after(src, 25, FALSE, null, BUSY_ICON_CLOCK))
		to_chat(src, span_warning("We quiver, but nothing happens. We must hold still while evolving."))
		return

	if(new_caste_type == /mob/living/carbon/xenomorph/queen)
		if(hive.living_xeno_queen) //Do another check after the tick.
			to_chat(src, span_warning("There already is a Queen."))
			return
	else if(new_caste_type == /mob/living/carbon/xenomorph/shrike)
		if(length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/shrike]))
			to_chat(src, span_warning("There already is a Shrike."))
			return
	else if(new_caste_type == /mob/living/carbon/xenomorph/hivemind) //Special case for dealing with hiveminds - this may be subject to heavy change, such as multiple hiveminds potentially being an option
		if(length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/hivemind]))
			to_chat(src, span_warning("There cannot be two manifestations of the hivemind's will at once."))
			return
	else if(!regression) // these shouldnt be checked if trying to become a queen.
		if(tier == XENO_TIER_ONE && no_room_tier_two)
			to_chat(src, span_warning("Another sister evolved meanwhile. The hive cannot support another Tier 2."))
			return
		else if(tier == XENO_TIER_TWO && no_room_tier_three)
			to_chat(src, span_warning("Another sister evolved meanwhile. The hive cannot support another Tier 3."))
			return

	if(!isturf(loc)) //cdel'd or moved into something
		return

	SStgui.close_user_uis(src) //Force close all UIs upon evolution.

	//From there, the new xeno exists, hopefully
	var/mob/living/carbon/xenomorph/new_xeno = new new_caste_type(get_turf(src))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		stack_trace("[src] tried to evolve but their new_xeno wasn't a xeno at all.")
		if(new_xeno)
			qdel(new_xeno)
		return
	if(tier != XENO_TIER_ONE || !regression )
		new_xeno.upgrade_xeno(upgrade, TRUE)
	if(!regression && upgrade != XENO_UPGRADE_INVALID)
		new_xeno.upgrade_xeno(new_xeno.upgrade_prev(), TRUE)

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

	var/turf/T = get_turf(new_xeno)
	deadchat_broadcast(" has evolved into a <b>[new_xeno.xeno_caste.caste_name]</b> at <b>[get_area_name(T)]</b>.", "<b>[src]</b>", follow_target = new_xeno, turf_target = T)

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")

	if(queen_chosen_lead && (new_xeno.xeno_caste.can_flags & CASTE_CAN_BE_LEADER)) // xeno leader is removed by Destroy()
		hive.add_leader(new_xeno)
		new_xeno.hud_set_queen_overwatch()
		if(hive.living_xeno_queen)
			new_xeno.handle_xeno_leader_pheromones(hive.living_xeno_queen)

		new_xeno.update_leader_icon(TRUE)

	if(upgrade == XENO_UPGRADE_THREE || upgrade == XENO_UPGRADE_FOUR)
		switch(tier)
			if(XENO_TIER_TWO)
				SSmonitor.stats.ancient_T2--
			if(XENO_TIER_THREE)
				SSmonitor.stats.ancient_T3--

	new_xeno.upgrade_stored = max(upgrade_stored, new_xeno.upgrade_stored)
	while(new_xeno.upgrade_possible() && new_xeno.upgrade_stored >= new_xeno.xeno_caste.upgrade_threshold)
		new_xeno.upgrade_xeno(new_xeno.upgrade_next(), TRUE)
	var/obj/screen/zone_sel/selector = new_xeno.hud_used?.zone_sel
	selector?.set_selected_zone(zone_selected, new_xeno)
	qdel(src)
	INVOKE_ASYNC(new_xeno, /mob/living.proc/do_jitter_animation, 1000)

//Wraith can't regress/evo in phase shift
/mob/living/carbon/xenomorph/wraith/do_evolve(caste_type, forced_caste_name, regression = FALSE)
	if(status_flags & INCORPOREAL)
		return
	return ..()

///Handles special conditions that influence a caste's evolution point gain, such as larva gaining a bonus if on weed.
/mob/living/carbon/xenomorph/proc/spec_evolution_boost()
	return 0
