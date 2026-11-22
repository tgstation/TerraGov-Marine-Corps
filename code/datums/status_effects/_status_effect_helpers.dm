/**
 * Applies a given status effect to this mob.
 *
 * Arguments:
 * * `new_effect`—TYPEPATH of a status effect to apply.
 * * Additional arguments can be passed.
 *
 * Returns the instance of the created effect, if successful.
 * Returns 'null' if unsuccessful.
 */
/mob/living/proc/apply_status_effect(datum/status_effect/new_effect, ...)
	RETURN_TYPE(/datum/status_effect)

	var/list/arguments = args.Copy()

	// If the status effect we're applying doesn't allow multiple effects, we need to handle it
	if(initial(new_effect.status_type) != STATUS_EFFECT_MULTIPLE)
		for(var/datum/status_effect/existing_effect as anything in status_effects)
			if(existing_effect.id != initial(new_effect.id))
				continue

			switch(existing_effect.status_type)
				// Multiple are allowed, continue as normal (not normally reachable)
				if(STATUS_EFFECT_MULTIPLE)
					break
				// Only one of this type is allowed, early return
				if(STATUS_EFFECT_UNIQUE)
					return
				// Replace the existing instance (deletes it)
				if(STATUS_EFFECT_REPLACE)
					qdel(existing_effect)
				// Refresh the existing type, then early return
				if(STATUS_EFFECT_REFRESH)
					existing_effect.refresh(arglist(arguments))
					return

	// For the new effect the 1st argument is this mob
	arguments[1] = src

	// Create the status effect with our mob + our arguments
	var/datum/status_effect/new_instance = new new_effect(arguments)
	if(!QDELETED(new_instance))
		return new_instance

/**
 * Removes all instances of a given status effect from this mob
 *
 * Arguments:
 * * `removed_effect`—TYPEPATH of a status effect to remove.
 * * Additional arguments can be passed.
 *
 * Returns `TRUE` if at least one was removed.
 */
/mob/living/proc/remove_status_effect(datum/status_effect/removed_effect, ...)
	var/list/arguments = args.Copy(2)

	. = FALSE
	for(var/datum/status_effect/existing_effect as anything in status_effects)
		if(existing_effect.id == initial(removed_effect.id) && existing_effect.before_remove(arglist(arguments)))
			qdel(existing_effect)
			. = TRUE

	return .

/**
 * Checks if this mob has a status effect that shares the passed effect's ID
 *
 * Arguments:
 * * `checked_effect`—TYPEPATH of a status effect to check for. Checks for its ID, not its typepath
 *
 * Returns an instance of a status effect, or `null` if none were found.
 */
/mob/living/proc/has_status_effect(datum/status_effect/checked_effect)
	RETURN_TYPE(/datum/status_effect)

	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			return present_effect

	return null

/// Removes all status effects, returns the number of status effects removed
/mob/living/proc/remove_all_status_effects()
	. = 0
	for(var/datum/status_effect/existing_effect as anything in status_effects)
		.++
		qdel(existing_effect)
