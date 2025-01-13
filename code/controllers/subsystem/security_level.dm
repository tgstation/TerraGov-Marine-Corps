/**
 * ## Security Level Subsystem
 * ### `SSsecurity_level`
 *
 * Subsystem that handles setting the security level of the marine ship.
 *
 * See [/datum/security_level] for additional usage.
 *
 * This replaces hardcoded security levels with a new system that makes new security levels extremely
 * easy to implement, and existing ones extremely easy to modify.
 */
SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SECURITY_LEVEL
	/// Currently set security level
	var/datum/security_level/current_security_level
	/// The most recent security level number. Relevant if you want to avoid repeat actions
	/// in situations like going from Green to Blue and vice versa (see: mainship lights)
	var/most_recent_level = SEC_LEVEL_GREEN
	/// A list of initialised security level datums.
	var/list/available_levels = list()

/datum/controller/subsystem/security_level/Initialize()
	for(var/iterating_security_level_type in subtypesof(/datum/security_level))
		var/datum/security_level/new_security_level = new iterating_security_level_type
		available_levels[new_security_level.name] = new_security_level
	current_security_level = available_levels[number_level_to_text(SEC_LEVEL_GREEN)]
	return SS_INIT_SUCCESS

/datum/controller/subsystem/security_level/stat_entry()
	return ..("Current Level: [uppertext(current_security_level.name)] Previous Level: [uppertext(number_level_to_text(most_recent_level))]")

/**
 * Sets a new security level as our current level. This is how anything should be changing the security level.
 *
 * Produces a signal: [COMSIG_SECURITY_LEVEL_CHANGED]
 *
 * Can use this for world objects that react to the security level being updated. (red lights, etc)
 *
 * Arguments:
 * * new_level - The new security level that will become our current level
 * * announce - Play the announcement, set to FALSE if you're doing your own custom announcement to prevent duplicates
 * * allow_illegal_switching_from - Set to TRUE if you want to allow switching from a sec level that prevents it
 */
/datum/controller/subsystem/security_level/proc/set_level(new_level, announce = TRUE, allow_illegal_switching_from = FALSE)
	new_level = istext(new_level) ? new_level : number_level_to_text(new_level)
	if(new_level == current_security_level.name) // If we are already at the desired level, do nothing
		return

	if(!allow_illegal_switching_from && (current_security_level.sec_level_flags & SEC_LEVEL_CANNOT_SWITCH))
		return

	var/datum/security_level/selected_level = available_levels[new_level]

	if(!selected_level)
		CRASH("set_level was called with an invalid security level([new_level])")

	if(announce)
		level_announce(selected_level, current_security_level.number_level)

	SSsecurity_level.most_recent_level = current_security_level.number_level

	SSsecurity_level.current_security_level = selected_level
	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, selected_level.number_level, SSsecurity_level.most_recent_level)
	SSblackbox.record_feedback(FEEDBACK_TALLY, "security_level_changes", 1, selected_level.name)

/**
 * Returns the current security level as a number
 */
/datum/controller/subsystem/security_level/proc/get_current_level_as_number()
	return ((!initialized || !current_security_level) ? SEC_LEVEL_GREEN : current_security_level.number_level) //Send the default security level in case the subsystem hasn't finished initializing yet

/**
 * Returns the current security level as text
 */
/datum/controller/subsystem/security_level/proc/get_current_level_as_text()
	return ((!initialized || !current_security_level) ? "green" : current_security_level.name)

/**
 * Converts a text security level to a number
 *
 * Arguments:
 * * level - The text security level to convert
 */
/datum/controller/subsystem/security_level/proc/text_level_to_number(text_level)
	var/datum/security_level/selected_level = available_levels[text_level]
	return selected_level?.number_level

/**
 * Converts a number security level to a text
 *
 * Arguments:
 * * level - The number security level to convert
 */
/datum/controller/subsystem/security_level/proc/number_level_to_text(number_level)
	for(var/iterating_level_text in available_levels)
		var/datum/security_level/iterating_security_level = available_levels[iterating_level_text]
		if(iterating_security_level.number_level == number_level)
			return iterating_security_level.name
