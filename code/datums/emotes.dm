#define EMOTE_VISIBLE 1
#define EMOTE_AUDIBLE 2

#define EMOTE_VARY 				(1<<0) //vary the pitch
#define EMOTE_FORCED_AUDIO 		(1<<1) //can only code call this event instead of the player.
#define EMOTE_MUZZLE_IGNORE 	(1<<2) //Will only work if the emote is EMOTE_AUDIBLE
#define EMOTE_RESTRAINT_CHECK 	(1<<3) //Checks if the mob is restrained before performing the emote

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

	user.log_message(msg, LOG_EMOTE)
	msg = "[prefix]<b>[user]</b> [msg]"

	var/tmp_sound = get_sound(user)
	if(tmp_sound && (!(flags_emote & EMOTE_FORCED_AUDIO) || !intentional))
		playsound(user, tmp_sound, 50, flags_emote & EMOTE_VARY)

	for(var/i in GLOB.dead_mob_list)
		var/mob/M = i
		if(isnewplayer(M) || !M.client)
			continue
		var/T = get_turf(user)
		if(!(M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) || (M in viewers(T, null)))
			continue
		M.show_message("[FOLLOW_LINK(M, user)] [msg]")

	if(emote_type == EMOTE_AUDIBLE)
		user.audible_message(msg)
	else
		user.visible_message(msg)


/datum/emote/proc/get_sound(mob/living/user)
	return sound //by default just return this var.


/datum/emote/proc/replace_pronoun(mob/user, message)
	if(findtext(message, "their"))
		message = replacetext(message, "their", user.p_their())
	if(findtext(message, "them"))
		message = replacetext(message, "them", user.p_them())
	if(findtext(message, "%s"))
		message = replacetext(message, "%s", user.p_s())
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
	return replacetext(message_param, "%t", params)


/datum/emote/proc/can_run_emote(mob/user, status_check = TRUE, intentional = FALSE)
	. = TRUE

	if(!is_type_in_typecache(user, mob_type_allowed_typecache))
		return FALSE

	if(is_type_in_typecache(user, mob_type_blacklist_typecache))
		return FALSE

	if(intentional && (sound || get_sound(user)))
		if(user.audio_emote_time >= world.time)
			to_chat(user, "<span class='notice'>You just did an audible emote. Wait a while.</span>")
			return FALSE
		else
			user.audio_emote_time = world.time + 8 SECONDS

	if(intentional && user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot send emotes (muted).</span>")
			return FALSE

		if(user.client.handle_spam_prevention(message, MUTE_IC))
			return FALSE

		if(is_banned_from(user.ckey, "Emote"))
			to_chat(src, "<span class='warning'>You cannot send emotes (banned).</span>")
			return FALSE

	if(status_check && !is_type_in_typecache(user, mob_type_ignore_stat_typecache))
		if(user.stat > stat_allowed)
			if(!intentional)
				return FALSE

			switch(user.stat)
				if(UNCONSCIOUS)
					to_chat(user, "<span class='notice'>You cannot [key] while unconscious.</span>")
				if(DEAD)
					to_chat(user, "<span class='notice'>You cannot [key] while dead.</span>")

			return FALSE

		if(flags_emote & EMOTE_RESTRAINT_CHECK)
			if(isliving(user))
				var/mob/living/L = user
				if(L.incapacitated())
					if(!intentional)
						return FALSE
					to_chat(user, "<span class='notice'>You cannot [key] while stunned.</span>")
					return FALSE

		if((flags_emote & EMOTE_RESTRAINT_CHECK) && user.restrained())
			if(!intentional)
				return FALSE
			to_chat(user, "<span class='notice'>You cannot [key] while restrained.</span>")
			return FALSE