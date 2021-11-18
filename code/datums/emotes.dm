/datum/emote
	var/key = "" //What calls the emote
	var/key_third_person = "" //This will also call the emote
	var/message = "" //Message displayed when emote is used
	var/message_alien = "" //Message displayed if the user is a grown alien
	var/message_larva = "" //Message displayed if the user is an alien larva
	var/message_AI = "" //Message displayed if the user is an AI
	var/message_monkey = "" //Message displayed if the user is a monkey
	var/message_simple = "" //Message to display if the user is a simple_animal
	var/message_param = "" //Message to display if a param was given
	var/emote_type = EMOTE_VISIBLE //Whether the emote is visible or audible
	var/list/mob_type_allowed_typecache = /mob //Types that are allowed to use that emote
	var/list/mob_type_blacklist_typecache //Types that are NOT allowed to use that emote
	var/list/mob_type_ignore_stat_typecache
	var/stat_allowed = CONSCIOUS
	var/sound //Sound to play when emote is called
	var/flags_emote = NONE
	/// Cooldown between two uses of that emote. Every emote has its own coodldown
	var/cooldown = 2 SECONDS

	var/static/list/emote_list = list()


/datum/emote/New()
	if(key_third_person)
		emote_list[key_third_person] = src

	if(ispath(mob_type_allowed_typecache))
		switch(mob_type_allowed_typecache)
			if(/mob)
				mob_type_allowed_typecache = GLOB.typecache_mob
			if(/mob/living)
				mob_type_allowed_typecache = GLOB.typecache_living
			else
				mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)
	else
		mob_type_allowed_typecache = typecacheof(mob_type_allowed_typecache)

	mob_type_blacklist_typecache = typecacheof(mob_type_blacklist_typecache)
	mob_type_ignore_stat_typecache = typecacheof(mob_type_ignore_stat_typecache)


/datum/emote/proc/run_emote(mob/user, params, type_override, intentional = FALSE, prefix)
	. = TRUE
	if(!can_run_emote(user, TRUE, intentional))
		return FALSE
	var/msg = select_message_type(user)
	if(params && message_param)
		msg = select_param(user, params)

	msg = replace_pronoun(user, msg)

	if(!msg)
		return

	var/end = copytext_char(msg, length_char(message))
	if(!(end in list("!", ".", "?", ":", "\"", "-")))
		msg += "."

	if(intentional)
		user.log_message(msg, LOG_EMOTE)
	var/dchatmsg = "[prefix]<b>[user]</b> [msg]"

	var/tmp_sound = get_sound(user)
	if(tmp_sound && (!(flags_emote & EMOTE_FORCED_AUDIO) || !intentional))
		playsound(user, tmp_sound, 50, flags_emote & EMOTE_VARY)

	if(user.client)
		for(var/i in GLOB.dead_mob_list)
			var/mob/M = i
			if(isnewplayer(M) || !M.client)
				continue
			var/T = get_turf(user)
			if(!(M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) || (M in viewers(T, null)))
				continue
			M.show_message("[FOLLOW_LINK(M, user)] [dchatmsg]")

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg, audible_message_flags = EMOTE_MESSAGE, emote_prefix = prefix)
	else
		user.visible_message(msg, visible_message_flags = EMOTE_MESSAGE, emote_prefix = prefix)

/// For handling emote cooldown, return true to allow the emote to happen
/datum/emote/proc/check_cooldown(mob/user, intentional)
	if(!intentional)
		return TRUE
	if(TIMER_COOLDOWN_CHECK(user, "emote[key]"))
		return FALSE
	TIMER_COOLDOWN_START(user, "emote[key]", cooldown)
	return TRUE

/datum/emote/proc/get_sound(mob/living/user)
	return sound //by default just return this var.


/datum/emote/proc/replace_pronoun(mob/user, message)
	if(findtext_char(message, "their"))
		message = replacetext_char(message, "their", user.p_their())
	if(findtext_char(message, "them"))
		message = replacetext_char(message, "them", user.p_them())
	if(findtext_char(message, "%s"))
		message = replacetext_char(message, "%s", user.p_s())
	return message


/datum/emote/proc/select_message_type(mob/user)
	. = message
	if(!(flags_emote & EMOTE_MUZZLE_IGNORE) && user.is_muzzled() && emote_type == EMOTE_AUDIBLE)
		return "makes a [pick("strong ", "weak ", "")]noise."
	if(isxeno(user) && message_alien)
		. = message_alien
	else if(isxenolarva(user) && message_larva)
		. = message_larva
	else if(isAI(user) && message_AI)
		. = message_AI
	else if(ismonkey(user) && message_monkey)
		. = message_monkey
	else if(isanimal(user) && message_simple)
		. = message_simple


/datum/emote/proc/select_param(mob/user, params)
	return replacetext_char(message_param, "%t", params)


/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	. = TRUE

	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE

	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE

	if(intentional)
		if(flags_emote & EMOTE_FORCED_AUDIO)
			return FALSE

		if(sound || get_sound(user))
			if(HAS_TRAIT(user, TRAIT_MUTED))
				user.balloon_alert(user, "You are muted!")
				return FALSE
			if(TIMER_COOLDOWN_CHECK(user, COOLDOWN_EMOTE))
				user.balloon_alert(user, "You just did an audible emote")
				return FALSE
			else
				TIMER_COOLDOWN_START(user, COOLDOWN_EMOTE, 8 SECONDS)

		if(user.client)
			if(user.client.prefs.muted & MUTE_IC)
				to_chat(user, span_warning("You cannot send emotes (muted)."))
				return FALSE

			if(user.client.handle_spam_prevention(message, MUTE_IC))
				return FALSE

			if(is_banned_from(user.ckey, "Emote"))
				to_chat(user, span_warning("You cannot send emotes (banned)."))
				return FALSE

	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if(user.stat > stat_allowed)
			if(!intentional)
				return FALSE

			switch(user.stat)
				if(UNCONSCIOUS)
					to_chat(user, span_notice("You cannot [key] while unconscious."))
				if(DEAD)
					to_chat(user, span_notice("You cannot [key] while dead."))

			return FALSE

		if(flags_emote & EMOTE_RESTRAINT_CHECK)
			if(isliving(user))
				var/mob/living/L = user
				if(L.incapacitated())
					if(!intentional)
						return FALSE
					user.balloon_alert(user, "You cannot [key] while stunned")
					return FALSE

		if(flags_emote & EMOTE_ARMS_CHECK)
			///okay snapper
			var/mob/living/carbon/snapper = user
			var/datum/limb/left_hand = snapper.get_limb("l_hand")
			var/datum/limb/right_hand = snapper.get_limb("r_hand")
			if((!left_hand.is_usable()) && (!right_hand.is_usable()))
				to_chat(user, span_notice("You cannot [key] without a working hand."))
				return FALSE

		if((flags_emote & EMOTE_RESTRAINT_CHECK) && user.restrained())
			if(!intentional)
				return FALSE
			user.balloon_alert(user, "You cannot [key] while restrained")
			return FALSE
