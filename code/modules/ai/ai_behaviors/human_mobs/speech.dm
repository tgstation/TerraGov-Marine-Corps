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
/datum/ai_behavior/human/proc/self_text_replacement(text)
	AI_STANDARD_TEXT_REPLACEMENT("SELF", text, mob_parent)
	return text

/// Like `self_text_replacement` but a provided mob's first name/last name/title/etc
/datum/ai_behavior/human/proc/them_text_replacement(text, mob/living/them)
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

	message = self_text_replacement(message)
	if(isliving(talking_with))
		message = them_text_replacement(message, talking_with)

	// maybe radio arg in the future for some things
	INVOKE_ASYNC(mob_parent, TYPE_PROC_REF(/atom/movable, say), message)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)

	if(unique_cooldown_key)
		LAZYSET(specific_chat_cooldowns, unique_cooldown_key, world.time + unique_cooldown_time)

/**
 * Internal proc that gets a suitable line from the provided `chat_lines` list.
 *
 * Provided lists should always have *at least* lines for `FACTION_NEUTRAL`,
 * but you can also add faction specific lines by including factions other
 * than neutral.
 *
 * This is passed to `faction_list_speak` but you can also call this yourself,
 * modify its returned text, and pass it to `custom_speak` for specific needs.
 *
 * Arguments:
 * * `chat_lines`—Associative list of (faction strings -> (lines)) to pick from
 */
/datum/ai_behavior/human/proc/pick_faction_line(list/chat_lines)
	if(!islist(chat_lines))
		CRASH("[type]/pick_faction_line should be called with a list.")
	. = pick(chat_lines[mob_parent.faction] || chat_lines[FACTION_NEUTRAL])
	if(!.)
		CRASH("[type]/faction_list_speak was not able to find a chat line. For bare minimum functionality, all speech lists should have lines for FACTION_NEUTRAL.")

/**
 * Says an audible message, picking from an associative list that should
 * be structured as (faction strings -> (lines to say for that faction)).
 *
 * Provided lists should always have *at least* lines for `FACTION_NEUTRAL`,
 * but you can also add faction specific lines by including factions other
 * than neutral.
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
	var/line = pick_faction_line(chat_lines)
	if(!line)
		return

	custom_speak(line, cooldown, unique_cooldown_key, unique_cooldown_time, force, talking_with)
