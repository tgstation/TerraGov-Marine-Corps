//The code execution of the emote datum is located at code/datums/emotes.dm
/mob/proc/emote(act, m_type = null, message = null, intentional = FALSE, forced = FALSE, targetted = FALSE)
	var/oldact = act
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
//	if(custom_param)
//		param = copytext(act, custom_param + 1, length(act) + 1)
//		act = copytext(act, 1, custom_param)

	if(intentional || !forced)
		if(world.time < next_emote)
			return

	var/list/key_emotes = GLOB.emote_list[act]

	if(!length(key_emotes) || custom_param)
		if(intentional)
			if(client)
				if(get_playerquality(client.ckey) <= -10)
					to_chat(src, "<span class='warning'>Unrecognized emote.</span>")
					return
			var/list/custom_emote = GLOB.emote_list["me"]
			for(var/datum/emote/P in custom_emote)
				P.run_emote(src, oldact, m_type, intentional, targetted)
				next_emote = world.time + P.mute_time
		return
	for(var/datum/emote/P in key_emotes)
		if(P.run_emote(src, param, m_type, intentional, targetted))
			next_emote = world.time + P.mute_time
			return

/atom/movable/proc/send_speech_emote(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language = null, message_mode)
	var/rendered = compose_message(src, message_language, message, , spans, message_mode)
	for(var/_AM in get_hearers_in_view(range, source))
		var/atom/movable/AM = _AM
		AM.Hear(rendered, src, message_language, message, , spans, message_mode)
//	if(intentional)
//		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
/*
/datum/emote/flip
	key = "flip"
	key_third_person = "flips"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/living/carbon/human/flip/can_run_emote(mob/user, status_check = TRUE , intentional)
	return FALSE

/datum/emote/flip/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(.)
		user.SpinAnimation(7,1)

/datum/emote/spin
	key = "spin"
	key_third_person = "spins"
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living, /mob/dead/observer)
	mob_type_ignore_stat_typecache = list(/mob/dead/observer)

/datum/emote/living/carbon/human/spin/can_run_emote(mob/user, status_check = TRUE , intentional)
	return FALSE


/datum/emote/spin/run_emote(mob/user, params ,  type_override, intentional)
	. = ..()
	if(.)
		user.spin(20, 1)

		if(iscyborg(user) && user.has_buckled_mobs())
			var/mob/living/silicon/robot/R = user
			var/datum/component/riding/riding_datum = R.GetComponent(/datum/component/riding)
			if(riding_datum)
				for(var/mob/M in R.buckled_mobs)
					riding_datum.force_dismount(M)
			else
				R.unbuckle_all_mobs()
*/
