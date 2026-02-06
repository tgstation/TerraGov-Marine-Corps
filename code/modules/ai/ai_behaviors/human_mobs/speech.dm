/**
 * Internal proc for checking that we can/should actually speak.
 *
 * Arguments:
 * * `unique_cooldown_key`—For specific cooldowns that apply to specific lines on top of the global cooldown
 */
/datum/ai_behavior/human/proc/can_speak(unique_cooldown_key)
	if(mob_parent.incapacitated())
		return FALSE
	if(!COOLDOWN_FINISHED(src, global_chat_cooldown))
		return FALSE
	if(unique_cooldown_key)
		if(LAZYACCESS(specific_chat_cooldowns, unique_cooldown_key) > world.time)
			return FALSE
		LAZYREMOVE(specific_chat_cooldowns, unique_cooldown_key)
	. = TRUE

/// Handles simple text replacement of the parent's first name/last name/title/etc for constants
/// and simple text replacement for another mob if one is provided
/datum/ai_behavior/human/proc/speech_text_replacement(text, mob/living/them)
	AI_STANDARD_TEXT_REPLACEMENT("SELF", text, mob_parent)
	if(isliving(them))
		AI_STANDARD_TEXT_REPLACEMENT("AFFECTED", text, them)
	return text

/**
 * Says a custom audible message from the provided `message`.
 *
 * Arguments:
 * * `message`—What to speak
 * * `cooldown`—How long the global cooldown should last, to reduce spam from very quick speech
 * * `unique_cooldown_key`—For specific cooldowns that apply to specific lines
 * * `unique_cooldown_time`—The time for specific cooldowns
 * * `force`—This will bypass cooldowns if TRUE
 * * `talking_with`—A mob we may be addressing, this allows text replacement related to them to work aswell
 */
/datum/ai_behavior/human/proc/custom_speak(
	message,
	cooldown = COOLDOWN_AI_SPEECH,
	unique_cooldown_key,
	unique_cooldown_time,
	force = FALSE,
	mob/living/talking_with,
)
	if(!force && !can_speak(unique_cooldown_key))
		return
	if(!istext(message))
		CRASH("[type]/custom_speak should be called with text as its message.")

	message = speech_text_replacement(message, talking_with)

	// maybe radio arg in the future for some things
	INVOKE_ASYNC(mob_parent, TYPE_PROC_REF(/atom/movable, say), message)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)

	if(unique_cooldown_key)
		LAZYSET(specific_chat_cooldowns, unique_cooldown_key, world.time + unique_cooldown_time)

/**
 * Says an audible message, picking from an associative list that should
 * be structured as (faction strings -> (lines to say for that faction)).
 *
 * This proc will look for chat lines under this mob's faction, but if none
 * exist, it will fall back to `FACTION_NEUTRAL`. Provided lists should have
 * lines for `FACTION_NEUTRAL` at the very least.
 *
 * Arguments:
 * * `chat_lines`—Associative list of (faction strings -> (lines)) to pick from
 * * `cooldown`—How long the global cooldown should last, to reduce spam from very quick speech
 * * `unique_cooldown_key`—For specific cooldowns that apply to specific lines
 * * `unique_cooldown_time`—The time for specific cooldowns
 * * `force`—This will bypass cooldowns if TRUE
 * * `talking_with`—A mob we may be addressing, this allows text replacement related to them to work aswell
 */
/datum/ai_behavior/human/proc/faction_list_speak(
	list/chat_lines,
	cooldown = COOLDOWN_AI_SPEECH,
	unique_cooldown_key,
	unique_cooldown_time,
	force = FALSE,
	mob/living/talking_with,
)
	var/line = pick(chat_lines[mob_parent.faction] || chat_lines[FACTION_NEUTRAL])
	if(!line)
		CRASH("[type]/faction_list_speak was not able to find a chat line. For bare minimum functionality, all speech lists should have lines for FACTION_NEUTRAL.")

	custom_speak(line, cooldown, unique_cooldown_key, unique_cooldown_time, force, talking_with)
