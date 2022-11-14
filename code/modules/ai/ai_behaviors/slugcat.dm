/// Slugcat AI configuration
/datum/ai_behavior/slugcat
	///The mob the slugcat is following
	var/mob/mob_master
	///List of actions performed upon hearing certain things from mob_master
	var/list/on_hear_behaviours = list(
		"repeat after me" = .proc/repeat_speech,
		"maybe the xenos are not so bad" = .proc/for_the_empire
	)

/datum/ai_behavior/slugcat/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	..()
	RegisterSignal(mob_parent, COMSIG_MASTER_MOB_CHANGE, .proc/handle_master_change)

/datum/ai_behavior/slugcat/Destroy(force, ...)
	. = ..()
	mob_master = null

/// Handles changing the AI's mob_master
/datum/ai_behavior/slugcat/proc/handle_master_change(datum/source, atom/movable/new_mob_master)
	SIGNAL_HANDLER
	if(!new_mob_master || mob_master == new_mob_master)
		return
	var/master_update_message = "I shall follow you [new_mob_master]"
	if(mob_master)
		unassign_mob_master()
		master_update_message = "Farewell [mob_master]. I now answer to [new_mob_master]"

	assign_mob_master(new_mob_master, master_update_message)

/// Handles assigning a new master mob
/datum/ai_behavior/slugcat/proc/assign_mob_master(atom/movable/new_mob_master, hello_message)
	mob_master = new_mob_master
	RegisterSignal(mob_parent, COMSIG_MOVABLE_HEAR, .proc/handle_mob_master_speech)
	mob_parent.a_intent = INTENT_HELP
	change_action(ESCORTING_ATOM, mob_master)
	if(hello_message)
		say(hello_message)

/// Handles unassigning a master mob and cleaning up things related to that
/datum/ai_behavior/slugcat/proc/unassign_mob_master(goodbye_message)
	UnregisterSignal(mob_parent, COMSIG_MOVABLE_HEAR)

	if(goodbye_message)
		say("Farewell [mob_master]...")
	mob_master = null
	mob_parent.a_intent = INTENT_HARM

/// Handles what the slug does on hearing its owner
/datum/ai_behavior/slugcat/proc/handle_mob_master_speech(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return

	var/name = mob_parent.name
	var/calling_name = copytext(raw_message, 1, length(name) + 1)
	if(name != calling_name)
		if(prob(0.1))
			say(raw_message)
		return

	var/command = lowertext(copytext(raw_message, length(name) + 3, length(raw_message)))
	var/action = on_hear_behaviours[command]
	if(!action)
		say("Unknown action...")
		return

	addtimer(CALLBACK(src, action), 1 SECONDS, TIMER_UNIQUE)

/// The slugcat repeats the person's words
/datum/ai_behavior/slugcat/proc/repeat_speech(message)
	say("...")
	RegisterSignal(mob_parent, COMSIG_MOVABLE_HEAR, .proc/handle_repeat_speech, override = TRUE)

/// Does the words repeating action
/datum/ai_behavior/slugcat/proc/handle_repeat_speech(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return
	addtimer(CALLBACK(src, .proc/say, raw_message, SPEECH_CONTROLLER_QUEUE_SAY_VERB), 1 SECONDS, TIMER_UNIQUE)
	RegisterSignal(mob_parent, COMSIG_MOVABLE_HEAR, .proc/handle_mob_master_speech, override = TRUE)

/datum/ai_behavior/slugcat/proc/for_the_empire()
	SIGNAL_HANDLER
	var/delay = 0.7
	for(var/number in 1 to 3)
		addtimer(CALLBACK(src, .proc/say, "HERECY!!!"), delay * number SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/explosion, get_turf(mob_parent), 2, 2, 6, 5, 5), (delay * 3 + 0.5) SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/ai_behavior/slugcat/proc/say(message)
	SSspeech_controller.queue_say_for_mob(mob_parent, message, SPEECH_CONTROLLER_QUEUE_SAY_VERB)

/datum/ai_behavior/slugcat/proc/emote(message)
	SSspeech_controller.queue_say_for_mob(mob_parent, message, SPEECH_CONTROLLER_QUEUE_EMOTE_VERB)
