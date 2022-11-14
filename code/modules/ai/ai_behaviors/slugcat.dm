#define HELD_ITEM "held_item" //an item the mob is currently holding
#define FETCH_TARGET "fetch_target" //the item the mob is trying to pick up
#define ACTION_TERMINATE_TIMER "action_terminate_timer" //a timer that terminates the current action if it doesn't complete on time

#define RETURNING_ITEM

/// Slugcat AI configuration
/datum/ai_behavior/slugcat
	///The action that the AI is trying to accomplish. This is used to determine whether to cancel an ongoing action in case it might conflict with a different one
	var/current_activity
	///The mob the slugcat is following
	var/mob/mob_master
	///List of actions performed upon hearing certain things from mob_master
	var/list/on_hear_behaviours = list(
		"repeat after me" = .proc/repeat_speech,
		"fetch" = .proc/fetch,
		"maybe the xenos are not so bad" = .proc/for_the_empire
	)
	///An associative list, where temporary variables required for some actions can be inserted
	var/blackboard = list()

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

/datum/ai_behavior/slugcat/proc/fetch()
	if(held_item)
		say("I currently hold [held_item]")
		return
	RegisterSignal(mob_master, COMSIG_POINT_TO_ATOM, .proc/handle_fetch)

/datum/ai_behavior/slugcat/proc/fetch_cleanup()
	if(current_action != ESCORTING_ATOM)
		change_action(ESCORTING_ATOM, mob_master)
	if(blackboard[HELD_ITEM])


/datum/ai_behavior/slugcat/proc/handle_fetch(datum/source, atom/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/async_fetch, target)

/datum/ai_behavior/slugcat/proc/async_fetch(atom/target)
	UnregisterSignal(mob_master, COMSIG_POINT_TO_ATOM)
	if(!can_interact_with_item(target))
		say("Cannot fetch [target]")
		return

	say("Fetching [target]")
	change_action(MOVING_TO_ATOM, target)
	blackboard[FETCH_TARGET] = target
	RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/pickup_item)
	blackboard[ACTION_TERMINATE_TIMER] = addtimer(CALLBACK(src, .proc/apply_psychic_link, target), GORGER_PSYCHIC_LINK_CHANNEL, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/ai_behavior/slugcat/proc/pickup_item(datum/source, atom/movable/target)
	if(!can_pickup_item(target))
		return
	target.forceMove(mob_parent)
	held_item = target
	RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/give_item, override = TRUE)
	change_action(ESCORTING_ATOM, mob_master)

/datum/ai_behavior/slugcat/proc/give_item(datum/source)
	if(!held_item)
		return
	if(mob_master.put_in_any_hand_if_possible(held_item))
		emote("gives [held_item]")
		return

	held_item.forceMove(get_turf(mob_parent))
	emote("drops [held_item]")
	held_item = null
	UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)

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

/datum/ai_behavior/slugcat/proc/can_interact_with_item(atom/movable/target)
	if(!target)
		return FALSE
	if(!isturf(target?.loc))
		return FALSE
	return isitem(target)

/datum/ai_behavior/slugcat/proc/can_pickup_item(atom/movable/target)
	if(!can_interact_with_item(target))
		return FALSE
	if(target.anchored)
		return FALSE
	return mob_parent.CanReach(target)
