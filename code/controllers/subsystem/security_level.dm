/**
 * ## Security Level Subsystem
 *
 * Subsystem that controls the security level of the marine ship.
 *
 * See [/datum/security_level] for usage (implementing new levels, modifying existing, etc).
 */
SUBSYSTEM_DEF(security_level)
	name = "Security Level"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SECURITY_LEVEL
	/// Currently set security level
	var/datum/security_level/current_security_level
	/// Associative list of security level names -> datums
	var/list/available_levels = list()

/datum/controller/subsystem/security_level/Initialize()
	for(var/iterating_security_level_type in subtypesof(/datum/security_level))
		var/datum/security_level/new_security_level = new iterating_security_level_type
		available_levels[new_security_level.name] = new_security_level
	current_security_level = available_levels[number_level_to_text(SEC_LEVEL_GREEN)]
	return SS_INIT_SUCCESS

/datum/controller/subsystem/security_level/stat_entry()
	return ..("Current Level: [uppertext(get_current_level_as_text())]")

/**
 * Sets a new security level as our current level. This is how anything should be changing the security level.
 *
 * Returns `TRUE` if there's a change in the level, `FALSE` otherwise.
 *
 * Produces a signal: [COMSIG_SECURITY_LEVEL_CHANGED].
 * Can use it for world objects that react to the security level being updated. (red lights, etc)
 *
 * Arguments:
 * * new_level - The new security level that will become our current level
 * * announce - Play the announcement, set to FALSE if you're doing your own custom announcement to prevent duplicates
 */
/datum/controller/subsystem/security_level/proc/set_level(new_level, announce = TRUE)
	new_level = istext(new_level) ? new_level : number_level_to_text(new_level)
	if(new_level == current_security_level.name) // If we are already at the desired level, don't bother
		return FALSE

	var/datum/security_level/selected_level = available_levels[new_level]

	if(!selected_level)
		CRASH("set_level was called with an invalid security level([new_level])")

	if(announce)
		level_announce(selected_level, current_security_level.number_level)

	var/datum/security_level/previous_level = current_security_level // for signals
	current_security_level = selected_level
	SEND_SIGNAL(src, COMSIG_SECURITY_LEVEL_CHANGED, selected_level, previous_level)
	SSblackbox.record_feedback(FEEDBACK_TALLY, "security_level_changes", 1, selected_level.name, previous_level)
	return TRUE

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
