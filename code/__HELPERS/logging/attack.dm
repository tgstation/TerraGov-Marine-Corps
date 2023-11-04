/// Generic attack logging
/proc/log_attack(text, list/data)
	logger.Log(LOG_CATEGORY_ATTACK, text)

/// Generic attack logging for friendly fire
/proc/log_ffattack(text, list/data)
	logger.Log(LOG_CATEGORY_ATTACK_FF, text)

/**
 * Log a combat message in the attack log
 *
 * Arguments:
 * * atom/user - argument is the actor performing the action
 * * atom/target - argument is the target of the action
 * * what_done - is a verb describing the action (e.g. punched, throwed, kicked, etc.)
 * * atom/object - is a tool with which the action was made (usually an item)
 * * addition - is any additional text, which will be appended to the rest of the log line
 */
/proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	var/ssource = key_name(user)
	var/starget = key_name(target)

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	var/sobject = ""
	if(object)
		sobject = " with [object]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp]"

	var/message = "[what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color="red")

	if(user != target)
		var/reverse_message = "was [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_VICTIM, color="orange", log_globally=FALSE)

/// Logging for bombs detonating
/proc/log_bomber(atom/user, details, atom/bomb, additional_details, message_admins = FALSE)
	var/bomb_message = "[details][bomb ? " [bomb.name] at [AREACOORD(bomb)]": ""][additional_details ? " [additional_details]" : ""]."

	if(user)
		user.log_message(bomb_message, LOG_ATTACK) //let it go to individual logs as well as the game log
		bomb_message = "[key_name(user)] at [AREACOORD(user)] [bomb_message]."
	else
		log_game(bomb_message)

	if(message_admins)
		message_admins("[user ? "[ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(user)] " : ""][details][bomb ? " [bomb.name] at [ADMIN_VERBOSEJMP(bomb)]": ""][additional_details ? " [additional_details]" : ""].")
