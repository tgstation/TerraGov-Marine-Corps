///Wrapper for say
#define COMPANION_SAY(message) SSspeech_controller.queue_say_for_mob(parent, message, SPEECH_CONTROLLER_QUEUE_SAY_VERB)
///Wrapper for emote
#define COMPANION_EMOTE(message) SSspeech_controller.queue_say_for_mob(parent, message, SPEECH_CONTROLLER_QUEUE_EMOTE_VERB)

/**
 * Companion component
 *
 * This component defines behaviour for a mob to follow another mob and react to stuff it does.
 */
/datum/component/companion
	///The mob this mob is following
	var/mob/mob_master
	///List of actions performed upon hearing certain things from mob_master
	var/static/list/on_hear_behaviours = list(
		"help" = PROC_REF(help),
		"you will be called" = PROC_REF(update_name),
		"repeat after me" = PROC_REF(repeat_speech),
		"goodbye" = PROC_REF(goodbye)
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
	if(mob_master)
		unassign_mob_master()
	return ..()

/datum/component/companion/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_attackby))

/datum/component/companion/UnregisterFromParent()
	. = ..()
	if(mob_master)
		unassign_mob_master()
	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)

///The mob gives a note to the mob_master containing available commands
/datum/component/companion/proc/help()
	var/mob/mob_parent = parent
	if(!mob_parent.CanReach(mob_master))
		COMPANION_SAY("Come closer.")
		return

	var/obj/item/paper/brassnote/new_note = new
	new_note.info = commands_info
	if(mob_master.put_in_any_hand_if_possible(new_note))
		RegisterSignal(new_note, COMSIG_ITEM_DROPPED, PROC_REF(clear_note))
		COMPANION_EMOTE("passes note")
		return
	else
		qdel(new_note)
		COMPANION_SAY("Your hands are full.")

///Deletes the created commands note
/datum/component/companion/proc/clear_note(datum/source)
	SIGNAL_HANDLER
	COMPANION_EMOTE("...")
	qdel(source)

///Handles what the companion does when interacted with with an item
/datum/component/companion/proc/handle_attackby(datum/source, obj/item/I, mob/user, params)
	SIGNAL_HANDLER
	if(!istype(I, /obj/item/tool/research/xeno_analyzer))
		return

	if(!user || mob_master == user)
		return

	var/master_update_message = "I shall follow you [user]."
	if(mob_master)
		master_update_message = "Farewell [mob_master]. I will now follow [user]."
		unassign_mob_master()

	assign_mob_master(user, master_update_message)
	return COMPONENT_NO_AFTERATTACK

///Handles assigning a new master mob
/datum/component/companion/proc/assign_mob_master(atom/movable/new_mob_master, hello_message)
	mob_master = new_mob_master
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(handle_mob_master_speech))
	RegisterSignal(mob_master, COMSIG_QDELETING, PROC_REF(unassign_mob_master))
	var/mob/living/mob_parent = parent
	if(isanimal(parent))
		var/mob/living/simple_animal/animal_parent = parent
		animal_parent.toggle_ai(AI_OFF)
	if(hello_message)
		COMPANION_SAY(hello_message)
	mob_parent.AddComponent(/datum/component/ai_controller, /datum/ai_behavior, mob_master)
	///This needs to be after the AI component as that sets the intent to harm
	mob_parent.a_intent = INTENT_HELP

///Handles unassigning a master mob and cleaning up things related to that
/datum/component/companion/proc/unassign_mob_master(goodbye_message)
	UnregisterSignal(parent, COMSIG_MOVABLE_HEAR)
	UnregisterSignal(mob_master, COMSIG_QDELETING)
	if(goodbye_message)
		COMPANION_SAY(goodbye_message)
	mob_master = null
	var/mob/living/mob_parent = parent
	mob_parent.a_intent = INTENT_HARM
	if(isanimal(parent))
		var/mob/living/simple_animal/animal_parent = parent
		animal_parent.toggle_ai(AI_ON)
	mob_parent.remove_component(/datum/component/ai_controller)

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
			COMPANION_SAY(raw_message)
		return

	var/command = lowertext(copytext(raw_message, length(name) + 3, length(raw_message)))
	var/action = on_hear_behaviours[command]
	if(!action)
		COMPANION_EMOTE("nods")
		return

	addtimer(CALLBACK(src, action), 1 SECONDS, TIMER_UNIQUE)

///The slugcat listens for its new name
/datum/component/companion/proc/update_name(message)
	COMPANION_EMOTE("listens")
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(handle_update_name), override = TRUE)

///Does the name update action
/datum/component/companion/proc/handle_update_name(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return
	var/new_name = copytext(raw_message, 1, length(raw_message))
	addtimer(CALLBACK(SSspeech_controller, TYPE_PROC_REF(/datum/controller/subsystem/speech_controller, queue_say_for_mob), parent, "[new_name]", SPEECH_CONTROLLER_QUEUE_SAY_VERB), 1 SECONDS, TIMER_UNIQUE)
	var/mob/living/mob_parent = parent
	mob_parent.name = new_name
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(handle_mob_master_speech), override = TRUE)

///The slugcat repeats the person's words
/datum/component/companion/proc/repeat_speech(message)
	COMPANION_EMOTE("listens")
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(handle_repeat_speech), override = TRUE)

///Does the words repeating action
/datum/component/companion/proc/handle_repeat_speech(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	SIGNAL_HANDLER
	if(speaker != mob_master)
		return
	addtimer(CALLBACK(SSspeech_controller, TYPE_PROC_REF(/datum/controller/subsystem/speech_controller, queue_say_for_mob), parent, raw_message, SPEECH_CONTROLLER_QUEUE_SAY_VERB), 1 SECONDS, TIMER_UNIQUE)
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, PROC_REF(handle_mob_master_speech), override = TRUE)

///Removes the current master_mob through a command
/datum/component/companion/proc/goodbye()
	unassign_mob_master("Farewell [mob_master]...")

#undef COMPANION_SAY
#undef COMPANION_EMOTE
