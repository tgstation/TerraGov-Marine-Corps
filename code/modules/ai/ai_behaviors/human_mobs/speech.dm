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

/**
 * Says a custom audible message from the provided `message`.
 *
 * Arguments:
 * * `message`—What to speak
 * * `cooldown`—How long the global cooldown should last, to reduce spam from very quick speech
 * * `unique_cooldown_key`—For specific cooldowns that apply to specific lines
 * * `unique_cooldown_time`—The time for specific cooldowns
 * * `force`—This will bypass cooldowns if TRUE
 */
/datum/ai_behavior/human/proc/custom_speak(
	message,
	cooldown = COOLDOWN_AI_SPEECH,
	unique_cooldown_key,
	unique_cooldown_time,
	force = FALSE,
)
	if(!force && !can_speak(unique_cooldown_key, unique_cooldown_time))
		return

	// maybe radio arg in the future for some things
	INVOKE_ASYNC(mob_parent, TYPE_PROC_REF(/atom/movable, say), message)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)

	if(unique_cooldown_key)
		LAZYSET(specific_chat_cooldowns, unique_cooldown_key, world.time + unique_cooldown_time)

/// Internal proc that actually gets a suitable line from a faction list
/datum/ai_behavior/human/proc/handle_faction_lines_list(list/chat_lines)
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
 */
/datum/ai_behavior/human/proc/faction_list_speak(
	list/chat_lines,
	cooldown = COOLDOWN_AI_SPEECH,
	unique_cooldown_key,
	unique_cooldown_time,
	force = FALSE,
)
	if(!islist(chat_lines))
		CRASH("[type]/faction_list_speak called without a list.")

	var/line = handle_faction_lines_list(chat_lines)
	if(!line)
		CRASH("[type]/faction_list_speak was not able to find a chat line. For bare minimum functionality, all speech lists should have lines for FACTION_NEUTRAL.")

	custom_speak(line, cooldown, unique_cooldown_key, unique_cooldown_time, force)
