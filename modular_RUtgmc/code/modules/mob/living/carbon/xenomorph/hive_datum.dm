/datum/hive_status
	///List of facehuggers
	var/list/mob/living/carbon/xenomorph/facehugger/facehuggers = list()

	///List of castes unavailable for evolution
	var/list/hive_forbiden_castes = list()
	var/forbid_count = 0

// ***************************************
// *********** Init
// ***************************************
/datum/hive_status/New()
	. = ..()

	for(var/caste_type_path AS in GLOB.xeno_caste_datums)
		var/datum/xeno_caste/caste = GLOB.xeno_caste_datums[caste_type_path][XENO_UPGRADE_BASETYPE]
		if(initial(caste.tier) == XENO_TIER_MINION)
			continue
		hive_forbiden_castes += list(list(
			"is_forbid" = FALSE,
			"type_path" = caste.caste_type_path,
			"caste_name" = initial(caste.caste_name),
		))

// ***************************************
// *********** UI for Hive Status
// ***************************************
/datum/hive_status/ui_data(mob/user)
	. = ..()
	.["hive_forbiden_castes"] = hive_forbiden_castes

// ***************************************
// *********** Facehuggers proc
// ***************************************
/datum/hive_status/proc/can_spawn_as_hugger(mob/dead/observer/user)

	if(!user.client?.prefs || is_banned_from(user.ckey, ROLE_XENOMORPH))
		return FALSE

	if(GLOB.key_to_time_of_death[user.key] + TIME_BEFORE_TAKING_BODY > world.time && !user.started_as_observer)
		to_chat(user, span_warning("You died too recently to be able to take a new facehugger."))
		return FALSE

	if(tgui_alert(user, "Are you sure you want to be a Facehugger?", "Become a part of the Horde", list("Yes", "No")) != "Yes")
		return FALSE

	if(length(facehuggers) >= MAX_FACEHUGGERS)
		to_chat(user, span_warning("The Hive cannot support more facehuggers! Limit: <b>[length_char(facehuggers)]/[MAX_FACEHUGGERS]</b>."))
		return FALSE

	return TRUE

//Managing the number of facehuggers in the hive
/mob/living/carbon/xenomorph/facehugger/add_to_hive(datum/hive_status/HS, force)
	. = ..()

	HS.facehuggers += src

/mob/living/carbon/xenomorph/facehugger/remove_from_hive()
	var/datum/hive_status/hive_removed_from = hive

	. = ..()

	hive_removed_from.facehuggers -= src

// ***************************************
// *********** Forbid
// ***************************************

/datum/hive_status/proc/toggle_forbit(mob/living/carbon/xenomorph/forbider, idx)
	if(!forbit_checks(forbider, idx))
		return
	var/is_forbiden = hive_forbiden_castes[idx]["is_forbid"]
	var/caste_name = hive_forbiden_castes[idx]["caste_name"]
	if(is_forbiden)
		xeno_message("[usr] undeclared the [caste_name] a forbidden caste!", "xenoannounce")
		log_game("[key_name(usr)] has unforbid [caste_name].")
		message_admins("[ADMIN_TPMONTY(usr)] has unforbid [caste_name].")
		forbid_count--
	else
		if(forbid_count >= MAX_FORBIDEN_CASTES)
			forbider.balloon_alert(forbider, "You can't forbid more castes!")
			return
		xeno_message("[usr] declared the [caste_name] a forbidden caste!", "xenoannounce")
		log_game("[key_name(usr)] has forbid [caste_name].")
		message_admins("[ADMIN_TPMONTY(usr)] has forbid [caste_name].")
		forbid_count++
	hive_forbiden_castes[idx]["is_forbid"] = !is_forbiden

/datum/hive_status/proc/forbit_checks(mob/living/carbon/xenomorph/forbider, idx)
	if(hive_forbiden_castes[idx]["type_path"] in GLOB.forbid_excepts)
		forbider.balloon_alert(forbider, "You can't forbid this caste!")
		return FALSE
	return TRUE

/datum/hive_status/proc/unforbid_all_castes(var/is_admin = FALSE)
	if(is_admin)
		xeno_message("Queen Mother unforbid all castes!", "xenoannounce")
	for(var/forbid_data in hive_forbiden_castes)
		forbid_data["is_forbid"] = FALSE
	forbid_count = 0

// ***************************************
// *********** Xeno upgrades
// ***************************************
/datum/hive_status/proc/attempt_punishment(mob/living/carbon/xenomorph/devolver, mob/living/carbon/xenomorph/target)
	var/confirm = tgui_input_list(devolver, "Choose a punishment for the [target] ", null, list("Deevolve", "Banish/De-Banish", "Abort",))

	switch(confirm)
		if("Deevolve")
			attempt_deevolve(usr, target)
			return
		if("Banish/De-Banish")
			attempt_banish(usr, target)
			return
		if("Abort")
			attempt_abort(usr, target)
			return
	return

/datum/hive_status/attempt_deevolve(mob/living/carbon/xenomorph/devolver, mob/living/carbon/xenomorph/target)
	if(!target.xeno_caste.deevolves_to)
		to_chat(devolver, span_xenonotice("Cannot deevolve [target]."))
		return

	var/datum/xeno_caste/new_caste = get_deevolve_caste(devolver, target)

	if(!new_caste) //better than nothing
		new_caste = GLOB.xeno_caste_datums[target.xeno_caste.deevolves_to][XENO_UPGRADE_NORMAL]

	for(var/forbid_info in hive_forbiden_castes)
		if(forbid_info["type_path"] == new_caste.caste_type_path && forbid_info["is_forbid"])
			to_chat(devolver, span_xenonotice("We can't deevolve to forbided caste"))
			return FALSE

	var/reason = stripped_input(devolver, "Provide a reason for deevolving this xenomorph, [target]")
	if(isnull(reason))
		to_chat(devolver, span_xenonotice("De-evolution reason required."))
		return

	if(!devolver.check_concious_state())
		return

	if(target.is_ventcrawling)
		to_chat(devolver, span_xenonotice("Cannot deevolve, [target] is ventcrawling."))
		return

	if(!isturf(target.loc))
		to_chat(devolver, span_xenonotice("Cannot deevolve [target] here."))
		return

	if((target.health < target.maxHealth) || (target.plasma_stored < (target.xeno_caste.plasma_max * target.xeno_caste.plasma_regen_limit)))
		to_chat(devolver, span_xenonotice("Cannot deevolve, [target] is too weak."))
		return

	target.balloon_alert(target, "Forced deevolution")
	to_chat(target, span_xenowarning("[devolver] deevolved us for the following reason: [reason]."))

	target.do_evolve(new_caste.caste_type_path, new_caste.caste_name, TRUE)

	log_game("[key_name(devolver)] has deevolved [key_name(target)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(devolver)] has deevolved [ADMIN_TPMONTY(target)]. Reason: [reason]")

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_xenos_created")
	qdel(target)

/datum/hive_status/proc/get_deevolve_caste(mob/living/carbon/xenomorph/devolver, mob/living/carbon/xenomorph/target)
	//copypaste from evolution.dm
	var/tiers_to_pick_from
	switch(target.tier)
		if(XENO_TIER_ZERO, XENO_TIER_FOUR)
			if(isxenoshrike(target))
				tiers_to_pick_from = GLOB.xeno_types_tier_one
			else
				to_chat(devolver, span_warning("Xeno tier does not allow you to regress."))
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
	var/castepick = tgui_input_list(devolver, "Choose the caste you want to deevolve into.", null, castes_to_pick)
	if(!castepick) //Changed my mind
		return

	var/datum/xeno_caste/castedatum
	for(var/type in tiers_to_pick_from)
		var/datum/xeno_caste/available_caste = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
		if(castepick != available_caste.caste_name)
			continue
		castedatum = available_caste
		break

	return castedatum

/datum/hive_status/proc/attempt_banish(mob/living/carbon/xenomorph/user, mob/living/carbon/xenomorph/target)
	if(!target_status_check(user, target))
		return

	var/confirm = tgui_alert(user, "Are you sure you want to banish/de-banish [target]?", null, list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/reason = stripped_input(user, "Provide a reason for banish this xenomorph, [target]")
	if(!reason)
		to_chat(user, span_xenonotice("Banish reason required."))
		return

	if(!user.check_concious_state())
		return

	if(!target_status_check(user, target))
		return


	if(!HAS_TRAIT(target, TRAIT_BANISHED))
		ADD_TRAIT(target, TRAIT_BANISHED, TRAIT_BANISHED)
		target.hud_set_banished()

		xeno_message("BANISHMENT", "xenobanishtitleannonce", 5, target.hivenumber, sound= sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS))
		xeno_message("By [user]'s will, [target] has been banished from the hive!\n[reason]", "xenobanishannonce", 5, target.hivenumber)
		to_chat(target, span_xenohighdanger("The [user] has banished you from the hive! Other xenomorphs may now attack you freely, but your link to the hivemind remains, preventing you from harming other sisters."))
		log_game("[key_name(user)] has banish [key_name(target)]. Reason: [reason]")
		message_admins("[ADMIN_TPMONTY(user)] has banish/(<a href='?_src_=holder;[HrefToken(TRUE)];adminunbanish=1;target=[REF(target)]'>unbanish</a>) [ADMIN_TPMONTY(target)]. Reason: [reason].")
		return

	REMOVE_TRAIT(target, TRAIT_BANISHED, TRAIT_BANISHED)
	target.hud_set_banished()

	xeno_message("By [user]'s will, [target] has been readmitted into the Hive!\n[reason]", "xenoannounce", 5, user.hivenumber, sound= sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS))
	log_game("[key_name(user)] has returned [key_name(target)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(user)] has returned [ADMIN_TPMONTY(target)]. Reason: [reason]")
	return

/datum/hive_status/proc/attempt_abort(mob/living/carbon/xenomorph/user, mob/living/carbon/xenomorph/target)
	if(!target_status_check(user, target))
		return

	var/confirm = tgui_alert(user, "Are you sure you want to abort [target]?", null, list("Yes", "No"))
	if(confirm != "Yes")
		return

	var/reason = stripped_input(user, "Provide a reason for abort this xenomorph, [target]")
	if(isnull(reason))
		to_chat(user, span_xenonotice("Abort reason required."))
		return

	if(!user.check_concious_state())
		return

	if(!target_status_check(user, target))
		return

	target.ghostize(FALSE)
	xeno_message("[user] abort  [target] into the void", "xenoannounce", 5, user.hivenumber)
	log_game("[key_name(user)] has abort [key_name(target)]. Reason: [reason]")
	message_admins("[ADMIN_TPMONTY(user)] has abort [ADMIN_TPMONTY(target)]. Reason: [reason]")

/datum/hive_status/proc/target_status_check(mob/living/carbon/xenomorph/user, mob/living/carbon/xenomorph/target)
	if(target.is_ventcrawling)
		to_chat(user, span_xenonotice("Cannot punish, [target] is ventcrawling."))
		return FALSE

	if(!isturf(target.loc))
		to_chat(user, span_xenonotice("Cannot punish [target] here."))
		return FALSE

	if(target.tier == XENO_TIER_FOUR || isxenohivemind(target))
		to_chat(user, span_xenonotice("Tier does not allow to punish."))
		return FALSE

	return TRUE

// ***************************************
// *********** Queen
// ***************************************

/datum/hive_status/on_queen_death()
	. = ..()
	unforbid_all_castes()

///Signal handler to tell the hive to check for siloless in MINIMUM_TIME_SILO_LESS_COLLAPSE
/datum/hive_status/normal/proc/set_siloless_collapse_timer()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_SHUTTERS_EARLY))
	hive_flags |= HIVE_CAN_COLLAPSE_FROM_SILO
	addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, update_silo_death_timer), src), MINIMUM_TIME_SILO_LESS_COLLAPSE)

/datum/hive_status/normal/on_shuttle_hijack(obj/docking_port/mobile/marine_dropship/hijacked_ship)
	SSticker.mode.update_silo_death_timer(src)
	return ..()
