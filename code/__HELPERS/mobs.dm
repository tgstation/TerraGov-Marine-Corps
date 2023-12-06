/proc/random_ethnicity()
	return pick(GLOB.ethnicities_list)

/proc/random_hair_style(gender, species = "Human")
	var/list/valid_hairstyles = list()
	for(var/hairstyle in GLOB.hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if(!(species in S.species_allowed))
			continue
		valid_hairstyles[hairstyle] = GLOB.hair_styles_list[hairstyle]

	if(!length(valid_hairstyles))
		return "Crewcut"

	return pick(valid_hairstyles)


/proc/random_facial_hair_style(gender, species = "Human")
	var/list/valid_facialhairstyles = list()
	for(var/facialhairstyle in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if(!(species in S.species_allowed))
			continue

		valid_facialhairstyles[facialhairstyle] = GLOB.facial_hair_styles_list[facialhairstyle]

	if(!length(valid_facialhairstyles))
		return "Shaved"

	return pick(valid_facialhairstyles)

///returns a random tts voice based on gender. Assumes theres 30 voices, not actually how many there are but yolo. todo should return based on gender but we need voice tags for that
/proc/random_tts_voice()
	var/list/voices
	if(SStts.tts_enabled)
		voices = SStts.available_speakers
	else if(fexists("data/cached_tts_voices.json"))
		var/list/text_data = rustg_file_read("data/cached_tts_voices.json")
		voices = json_decode(text_data)
	if(!length(voices))
		return null
	return pick(voices)

/proc/get_playable_species()
	return GLOB.roundstart_species

//some additional checks as a callback for for do_afters that want to break on losing health or on the mob taking action
/mob/proc/break_do_after_checks(list/checked_health, check_clicks, selected_zone_check)
	if(check_clicks && next_move > world.time)
		return FALSE
	if(selected_zone_check && zone_selected != selected_zone_check)
		return FALSE
	return TRUE


//pass a list in the format list("health" = mob's health var) to check health during this
/mob/living/break_do_after_checks(list/checked_health, check_clicks, selected_zone_check)
	if(islist(checked_health))
		if(health < checked_health["health"])
			return FALSE
		checked_health["health"] = health
	return ..()

///A delayed action with adjustable checks
/proc/do_after(mob/user, delay, timed_action_flags = NONE, atom/target, user_display, target_display, prog_bar = PROGRESS_GENERIC, datum/callback/extra_checks)
	if(!user)
		return FALSE
	if(!isnum(delay))
		CRASH("do_after was passed a non-number delay: [delay || "null"].")

	var/atom/target_loc
	if(target)
		target_loc = target.loc

	var/atom/user_loc = user.loc

	var/holding = user.get_active_held_item()
	delay *= user.do_after_coefficent()

	var/atom/progtarget = target
	if(!target || target_loc == user)
		progtarget = user
	var/datum/progressbar/progbar = prog_bar ? new prog_bar(user, delay, progtarget, user_display, target_display) : null

	LAZYINCREMENT(user.do_actions, target)
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		progbar?.update(world.time - starttime)

		if(QDELETED(user) || (target && (QDELETED(target))))
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_INCAPACITATED) && user.incapacitated(TRUE))
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_HELD_ITEM) && user.get_active_held_item() != holding)
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_USER_LOC_CHANGE) && (user.loc != user_loc))
			. = FALSE
			break
		if(!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE) && target && (QDELETED(target_loc) || target_loc != target.loc))
			. = FALSE
			break
		if(extra_checks && !extra_checks.Invoke())
			. = FALSE
			break

	if(progbar)
		qdel(progbar)
	LAZYDECREMENT(user.do_actions, target)


/mob/proc/do_after_coefficent() // This gets added to the delay on a do_after, default 1
	. = 1


/proc/random_unique_name(gender, attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		. = GLOB.namepool[/datum/namepool].get_random_name(gender)

		if(!findname(.))
			break


/proc/get_mob_by_ckey(key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M


/proc/living_player_count()
	. = 0
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(M.stat != DEAD)
			.++


/// Displays a message in deadchat, sent by source. Source is not linkified, message is, to avoid stuff like character names to be linkified.
/// Automatically gives the class deadsay to the whole message (message + source)
/proc/deadchat_broadcast(message, source = null, mob/follow_target = null, turf/turf_target = null, speaker_key = null, message_type = DEADCHAT_REGULAR)
	message = span_deadsay("[source][span_linkify("[message]")]")
	for(var/mob/M in GLOB.player_list)
		var/chat_toggles = TOGGLES_CHAT_DEFAULT
		var/deadchat_toggles = TOGGLES_DEADCHAT_DEFAULT
		if(M.client.prefs)
			var/datum/preferences/prefs = M.client.prefs
			chat_toggles = prefs.toggles_chat
			deadchat_toggles = prefs.toggles_deadchat


		var/override = FALSE
		if(check_other_rights(M.client, R_ADMIN, FALSE) && (chat_toggles & CHAT_DEAD))
			override = TRUE
		if(SSticker.current_state == GAME_STATE_FINISHED)
			override = TRUE
		if(isnewplayer(M) && !override)
			continue
		if(M.stat != DEAD && !override)
			continue

		switch(message_type)
			if(DEADCHAT_DEATHRATTLE)
				if(CHECK_BITFIELD(deadchat_toggles, DISABLE_DEATHRATTLE))
					continue
			if(DEADCHAT_ARRIVALRATTLE)
				if(CHECK_BITFIELD(deadchat_toggles, DISABLE_ARRIVALRATTLE))
					continue
			if(DEADCHAT_REGULAR)
				if(!CHECK_BITFIELD(chat_toggles, CHAT_DEAD))
					continue

		if(isobserver(M))
			var/rendered_message = message

			if(follow_target)
				var/F
				if(turf_target)
					F = FOLLOW_OR_TURF_LINK(M, follow_target, turf_target)
				else
					F = FOLLOW_LINK(M, follow_target)
				rendered_message = "[F] [message]"
			else if(turf_target)
				var/turf_link = TURF_LINK(M, turf_target)
				rendered_message = "[turf_link] [message]"

			to_chat(M, rendered_message, avoid_highlighting = speaker_key == M.key)
		else
			to_chat(M, message, avoid_highlighting = speaker_key == M.key)
