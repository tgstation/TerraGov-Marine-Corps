//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type, message, intentional = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findtext_char(act, " ")
	if(custom_param)
		param = copytext_char(act, custom_param + length_char(act[custom_param]))
		act = copytext_char(act, 1, custom_param)

	var/datum/emote/E
	E = E.emote_list[act]
	if(!E)
		to_chat(src, span_notice("Unusable emote '[act]'. Say *help for a list."))
		return
	if(!E.check_cooldown(src, intentional))
		to_chat(src, span_notice("You used that emote too recently."))
		return
	E.run_emote(src, param, m_type, intentional)


/datum/emote/help
	key = "help"


/datum/emote/help/run_emote(mob/user, params)
	var/list/keys = list()
	var/list/message = list("Available emotes, you can use them with say \"*emote\": ")

	var/datum/emote/E
	var/list/emote_list = E.emote_list
	for(var/e in emote_list)
		if(e in keys)
			continue
		E = emote_list[e]
		if(E.can_run_emote(user, status_check = FALSE, intentional = FALSE))
			keys += E.key

	keys = sortList(keys)

	for(var/emote in keys)
		if(LAZYLEN(message) > 1)
			message += ", [emote]"
		else
			message += "[emote]"

	message += "."

	message = jointext(message, "")

	to_chat(user, message)


/datum/emote/custom
	key = "me"
	key_third_person = "custom"
	message = null
	flags_emote = NO_KEYBIND //This shouldn't have a keybind


/datum/emote/custom/run_emote(mob/user, params, type_override, intentional = FALSE, prefix)
	message = params
	return ..()


/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	flags_emote = EMOTE_RESTRAINT_CHECK
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)


/datum/emote/spin/run_emote(mob/user)
	. = ..()
	if(!.)
		return

	user.spin(20, 1)
