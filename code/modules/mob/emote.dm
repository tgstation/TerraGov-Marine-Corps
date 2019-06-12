//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type, message, intentional = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findtext(act, " ")
	if(custom_param)
		param = copytext(act, custom_param + 1, length(act) + 1)
		act = copytext(act, 1, custom_param)

	var/datum/emote/E
	E = E.emote_list[act]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
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