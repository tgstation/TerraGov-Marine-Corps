/// Companion module
/datum/component/companion
	///The mob this mob is following
	var/mob/mob_master
	///List of actions performed upon hearing certain things from mob_master
	var/static/list/on_hear_behaviours = list(
		"help" = .proc/help,
		"you will be called" = .proc/update_name,
		"repeat after me" = .proc/repeat_speech,
		"goodbye" = .proc/goodbye
	)
	var/static/commands_info

/datum/component/companion/Initialize()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(!commands_info)
		var/info = "Available commands:<br>"
		for(var/key in on_hear_behaviours)
			info += "[key]<br>"
		commands_info = info

/datum/component/companion/Destroy(force, silent)
	unassign_mob_master()
	return ..()

/datum/component/companion/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MASTER_MOB_CHANGE, .proc/handle_master_change)

/datum/component/companion/UnregisterFromParent()
	. = ..()
	unassign_mob_master()
	UnregisterSignal(parent, COMSIG_MASTER_MOB_CHANGE)

///The mob gives a note to the mob_master containing available commands
/datum/component/companion/proc/help()
	var/mob/mob_parent = parent
	if(!mob_parent.CanReach(mob_master))
		say("Come closer.")
		return

	var/obj/item/paper/brassnote/new_note = new
	new_note.info = commands_info
	if(mob_master.put_in_any_hand_if_possible(new_note))
		RegisterSignal(new_note, COMSIG_ITEM_DROPPED, .proc/clear_note)
		emote("passes note")
		return
	else
		qdel(new_note)
		say("Your hands are full.")

///Deletes the created commands note
/datum/component/companion/proc/clear_note(datum/source)
	SIGNAL_HANDLER
	emote("...")
	qdel(source)

///Handles changing the AI's mob_master
/datum/component/companion/proc/handle_master_change(datum/source, atom/movable/new_mob_master)
	SIGNAL_HANDLER
	if(mob_master == new_mob_master)
		return

	if(!new_mob_master)
		unassign_mob_master("Farewell [mob_master]...")
		return

	var/master_update_message = "I shall follow you [new_mob_master]"
	if(mob_master)
		unassign_mob_master()
		master_update_message = "Farewell [mob_master]. I will now follow [new_mob_master]"

	assign_mob_master(new_mob_master, master_update_message)

///Handles assigning a new master mob
/datum/component/companion/proc/assign_mob_master(atom/movable/new_mob_master, hello_message)
	mob_master = new_mob_master
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, .proc/handle_mob_master_speech)
	var/mob/living/mob_parent = parent
	if(isanimal(parent))
		var/mob/living/simple_animal/animal_parent = parent
		animal_parent.toggle_ai(AI_OFF)
	if(hello_message)
		say(hello_message)
	mob_parent.AddComponent(/datum/component/ai_controller, /datum/ai_behavior, mob_master)
	///This needs to be after the AI component as that sets the intent to harm
	mob_parent.a_intent = INTENT_HELP

///Handles unassigning a master mob and cleaning up things related to that
/datum/component/companion/proc/unassign_mob_master(goodbye_message)
	UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)
	if(goodbye_message)
		say(goodbye_message)
	mob_master = null
	var/mob/living/mob_parent = parent
	mob_parent.a_intent = INTENT_HARM
	if(isanimal(parent))
		var/mob/living/simple_animal/animal_parent = parent
		animal_parent.toggle_ai(AI_ON)
	var/datum/component/ai_component = mob_parent.GetComponent(/datum/component/ai_controller)
	ai_component.RemoveComponent()

///Handles what the slug does on hearing its owner
/datum/component/companion/proc/handle_mob_master_speech(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return

	var/mob/living/mob_parent = parent
	var/name = mob_parent.name
	var/calling_name = copytext(raw_message, 1, length(name) + 1)
	if(name != calling_name)
		if(prob(10))
			say(raw_message)
		return

	var/command = lowertext(copytext(raw_message, length(name) + 3, length(raw_message)))
	var/action = on_hear_behaviours[command]
	if(!action)
		emote("nods")
		return

	addtimer(CALLBACK(src, action), 1 SECONDS, TIMER_UNIQUE)

///The slugcat listens for its new name
/datum/component/companion/proc/update_name(message)
	emote("listens")
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, .proc/handle_update_name, override = TRUE)

///Does the name update action
/datum/component/companion/proc/handle_update_name(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return
	var/new_name = copytext(raw_message, 1, length(raw_message))
	addtimer(CALLBACK(src, .proc/say, "[new_name]", SPEECH_CONTROLLER_QUEUE_SAY_VERB), 1 SECONDS, TIMER_UNIQUE)
	var/mob/living/mob_parent = parent
	mob_parent.name = new_name
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, .proc/handle_mob_master_speech, override = TRUE)

///The slugcat repeats the person's words
/datum/component/companion/proc/repeat_speech(message)
	emote("listens")
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, .proc/handle_repeat_speech, override = TRUE)

///Does the words repeating action
/datum/component/companion/proc/handle_repeat_speech(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return
	addtimer(CALLBACK(src, .proc/say, raw_message, SPEECH_CONTROLLER_QUEUE_SAY_VERB), 1 SECONDS, TIMER_UNIQUE)
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, .proc/handle_mob_master_speech, override = TRUE)

///Removes the current master_mob through a command
/datum/component/companion/proc/goodbye()
	unassign_mob_master("Farewell [mob_master]...")

///Wrapper for say
/datum/component/companion/proc/say(message)
	SSspeech_controller.queue_say_for_mob(parent, message, SPEECH_CONTROLLER_QUEUE_SAY_VERB)

///Wrapper for emote
/datum/component/companion/proc/emote(message)
	SSspeech_controller.queue_say_for_mob(parent, message, SPEECH_CONTROLLER_QUEUE_EMOTE_VERB)
