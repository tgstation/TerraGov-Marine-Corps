/// List of all non-abstract AI speech datums
GLOBAL_LIST_INIT(ai_speech, init_ai_speech_datums())

/// Initializes all non-abstract AI speech datums
/proc/init_ai_speech_datums()
	. = list()
	for(var/datum/ai_speech/ai_speech AS in subtypesof(/datum/ai_speech))
		if(ai_speech::abstract_type == ai_speech)
			continue
		if(.[ai_speech::key])
			stack_trace("Multiple AI speech datums with the same key detected ([ai_speech::key]), these must be unique!")
			continue
		.[ai_speech.key] = new ai_speech

/**
 * This represents a group of lines that NPCs can speak!
 *
 * Bare minimum usage boils down to:
 * * A datum's `chat_lines` must at least be an assoc list of `FACTION_NEUTRAL` -> (lines list)
 *   * For faction specific lines you can also add keys for other factions
 * * Use [/datum/ai_behavior/proc/key_speak] with a datum's key
 */
/datum/ai_speech
	/// Won't initialize if our type is this
	var/abstract_type = /datum/ai_speech
	/// Identifier for this AI speech, must be unique
	var/key = "change_me"
	/**
	 * An associative list of faction strings -> lists of lines.
	 *
	 * [/datum/ai_speech/proc/speak] will use `FACTION_NEUTRAL` if there are no faction specific lines
	 * for a speaker's faction. *Every datum should have `FACTION_NEUTRAL` lines.*
	 *
	 * You can also set faction specific lines by adding another list with a different faction as its key.
	 */
	var/list/chat_lines = list()

/**
 * Gets an applicable chat line based on the speaker's faction.
 *
 * Defaults to `FACTION_NEUTRAL` if there are no faction specific lines.
 */
/datum/ai_speech/proc/pick_line(mob/living/carbon/human/speaker, datum/ai_behavior/human/ai_behavior)
	if(ismonkey(speaker)) // monkeys could probably use their own faction (lol) but here's this for now
		return pick(GLOB.ai_monkey_lines)
	var/faction = speaker.faction
	if(!chat_lines[faction])
		faction = FACTION_NEUTRAL
	. = pick(chat_lines[faction])
	if(!.)
		CRASH("[type] does not have any chat lines to use! For bare minimum functionality, there should be lines for FACTION_NEUTRAL.")

/// Checks that we're actually able to speak for [/datum/ai_speech/proc/speak]
/datum/ai_speech/proc/can_speak(mob/living/carbon/human/speaker, datum/ai_behavior/human/ai_behavior)
	SHOULD_CALL_PARENT(TRUE)
	if(LAZYACCESS(ai_behavior.specific_chat_cooldowns, key) > world.time)
		return FALSE
	. = TRUE

/// Where the work actually happens (saying and possibly other effects).
/// This should call parent if anyone adds an override for it in the future.
/datum/ai_speech/proc/speak(mob/living/carbon/human/speaker, datum/ai_behavior/human/ai_behavior)
	SHOULD_CALL_PARENT(TRUE)
	if(!can_speak(speaker, ai_behavior))
		return
	INVOKE_ASYNC(speaker, TYPE_PROC_REF(/atom/movable, say), pick_line(speaker, ai_behavior))

/// Says a custom audible message
/datum/ai_behavior/human/proc/custom_speak(message, cooldown = COOLDOWN_AI_SPEECH)
	if(mob_parent.incapacitated())
		return
	if(!COOLDOWN_FINISHED(src, global_chat_cooldown))
		return
	//maybe radio arg in the future for some things
	mob_parent.say(message)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)

/// Says an audible message based on an AI speech datum's key
/datum/ai_behavior/human/proc/key_speak(key, cooldown = COOLDOWN_AI_SPEECH, unique_cooldown = null)
	if(mob_parent.incapacitated())
		return
	if(!COOLDOWN_FINISHED(src, global_chat_cooldown))
		return
	var/datum/ai_speech/ai_speech = GLOB.ai_speech[key]
	if(!key)
		CRASH("[type]/key_speak called with an invalid key!")
	ai_speech.speak(mob_parent, src)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)
	if(unique_cooldown)
		LAZYSET(specific_chat_cooldowns, key, world.time + unique_cooldown)

/datum/ai_behavior/human
	/// Chat lines when moving to a new target
	var/list/new_move_chat = list("Moving.", "On the way.", "Moving out.", "On the move.", "Changing position.", "Watch your spacing!", "Let's move.", "Move out!", "Go go go!!", "moving.", "Mobilising.", "Hoofing it.")
	/// Chat lines when following a new target
	var/list/new_follow_chat = list("Following.", "Following you.", "I got your back!", "Take the lead.", "Let's move!", "Let's go!", "Group up!.", "In formation.", "Where to?",)
	/// Chat lines when engaging a new target
	var/list/new_target_chat = list("Get some!!", "Engaging!", "You're mine!", "Bring it on!", "Hostiles!", "Take them out!", "Kill 'em!", "Lets rock!", "Go go go!!", "Waste 'em!", "Intercepting.", "Weapons free!", "Fuck you!!", "Moving in!")
	/// Chat lines for retreating on low health
	var/list/retreating_chat = list("Falling back!", "Cover me, I'm hit!", "I'm hit!", "Cover me!", "Disengaging!", "Help me!", "Need a little help here!", "Tactical withdrawal.", "Repositioning.", "Taking fire!", "Taking heavy fire!", "Run for it!")
	/// General acknowledgement of receiving an order
	var/list/receive_order_chat = list("Understood.", "Moving.", "Moving out", "Got it.", "Right away.", "Roger", "You got it.", "On the move.", "Acknowledged.", "Affirmative.", "Who put you in charge?", "Ok.", "I got it sorted.", "On the double.",)
	/// Cooldown on chat lines, to reduce spam
	COOLDOWN_DECLARE(global_chat_cooldown)
	/// Cooldown for specific chat lines, if applicable
	var/list/specific_chat_cooldowns
