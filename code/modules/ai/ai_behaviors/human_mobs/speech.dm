/**
 * Says a custom audible message from a string you provide.
 *
 * More flexible than [/datum/ai_behavior/human/proc/list_speak].
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
	if(mob_parent.incapacitated())
		return
	if(!force && !COOLDOWN_FINISHED(src, global_chat_cooldown))
		return
	if(!force && LAZYACCESS(specific_chat_cooldowns, unique_cooldown_key) > world.time)
		return FALSE

	// maybe radio arg in the future for some things
	INVOKE_ASYNC(mob_parent, TYPE_PROC_REF(/atom/movable, say), message)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)

	if(unique_cooldown_key)
		LAZYSET(specific_chat_cooldowns, unique_cooldown_key, world.time + unique_cooldown_time)

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
/datum/ai_behavior/human/proc/list_speak(
	list/chat_lines,
	cooldown = COOLDOWN_AI_SPEECH,
	unique_cooldown_key,
	unique_cooldown_time,
	force = FALSE,
)
	if(!islist(chat_lines))
		CRASH("[type]/list_speak called without a list.")
	if(mob_parent.incapacitated())
		return
	if(!force && !COOLDOWN_FINISHED(src, global_chat_cooldown))
		return
	if(!force && LAZYACCESS(specific_chat_cooldowns, unique_cooldown_key) > world.time)
		return FALSE

	var/line = pick(chat_lines[mob_parent.faction] || chat_lines[FACTION_NEUTRAL])
	if(!line)
		CRASH("[type]/list_speak was not able to find a chat line. For bare minimum functionality, all speech lists should have lines for FACTION_NEUTRAL.")

	// maybe radio arg in the future for some things
	INVOKE_ASYNC(mob_parent, TYPE_PROC_REF(/atom/movable, say), line)
	COOLDOWN_START(src, global_chat_cooldown, cooldown)

	if(unique_cooldown_key)
		LAZYSET(specific_chat_cooldowns, unique_cooldown_key, world.time + unique_cooldown_time)
