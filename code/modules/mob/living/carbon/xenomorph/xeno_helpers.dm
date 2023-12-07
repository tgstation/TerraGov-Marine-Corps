/mob/living/carbon/xenomorph/can_be_pulled(user, force)
	return ..(user, move_resist) // xenos can always be pulled regardless of move force

/mob/living/carbon/xenomorph/get_reagent_tags()
	. = ..()
	return .|IS_XENO

/mob/living/carbon/xenomorph/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	return FALSE

//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/xenomorph/restrained(ignore_checks)
	SHOULD_CALL_PARENT(FALSE)
	return FALSE

/mob/living/carbon/xenomorph/get_death_threshold()
	return xeno_caste.crit_health

///Helper proc for giving the rally abilities
/mob/living/carbon/xenomorph/proc/give_rally_abilities()
	if(!actions_by_path[/datum/action/ability/xeno_action/rally_hive])
		var/datum/action/ability/xeno_action/rally_hive/rally = new /datum/action/ability/xeno_action/rally_hive
		rally.give_action(src)
	if(!actions_by_path[/datum/action/ability/xeno_action/rally_minion])
		var/datum/action/ability/xeno_action/rally_minion/rally = new /datum/action/ability/xeno_action/rally_minion
		rally.give_action(src)


///Helper proc for removing the rally hive ability appropriately
/mob/living/carbon/xenomorph/proc/remove_rally_hive_ability()

	var/datum/action/ability/xeno_action/rally_hive/rally = actions_by_path[/datum/action/ability/xeno_action/rally_hive]

	if(rally)
		rally.remove_action(src)
	var/datum/action/ability/xeno_action/rally_minion/rally_minion = actions_by_path[/datum/action/ability/xeno_action/rally_minion]

	if(rally_minion)
		rally_minion.remove_action(src)

/mob/living/carbon/xenomorph/get_liquid_slowdown()
	return XENO_WATER_SLOWDOWN

/**
 * This handles checking for a xenomorph's potential IFF signals carried by components
 * Currently, IFF tags attach a component listening for this.
 */
/mob/living/carbon/xenomorph/proc/xeno_iff_check()
	var/list/inplace_iff = list(NONE)
	SEND_SIGNAL(src, COMSIG_XENO_IFF_CHECK, inplace_iff) //Inplace list magic to allow for multiple potential listeners to all do their things on the same variable.
	return inplace_iff[1]
