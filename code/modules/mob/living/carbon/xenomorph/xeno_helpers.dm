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

/mob/living/carbon/xenomorph/get_crit_threshold()
	. = ..()
	if(!endure)
		return
	var/datum/action/ability/xeno_action/endure/endure_ability = actions_by_path[/datum/action/ability/xeno_action/endure]
	return endure_ability.endure_threshold + endure_ability.endure_threshold_bonus

/mob/living/carbon/xenomorph/get_death_threshold()
	if(!endure)
		return xeno_caste.crit_health
	var/datum/action/ability/xeno_action/endure/endure_ability = actions_by_path[/datum/action/ability/xeno_action/endure]
	return endure_ability.endure_threshold + endure_ability.endure_threshold_bonus

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


///Helper proc for giving ruler abilities
/mob/living/carbon/xenomorph/proc/give_ruler_abilities()
	if(!actions_by_path[/datum/action/ability/xeno_action/set_xeno_lead])
		var/datum/action/ability/xeno_action/set_xeno_lead/lead = new /datum/action/ability/xeno_action/set_xeno_lead
		lead.give_action(src)
	if(!actions_by_path[/datum/action/ability/xeno_action/blessing_menu])
		var/datum/action/ability/xeno_action/blessing_menu/bless = new /datum/action/ability/xeno_action/blessing_menu
		bless.give_action(src)
	if(!actions_by_path[/datum/action/ability/xeno_action/hive_message])
		var/datum/action/ability/xeno_action/hive_message/message = new /datum/action/ability/xeno_action/hive_message
		message.give_action(src)
	if(!actions_by_path[/datum/action/ability/xeno_action/rally_hive])
		var/datum/action/ability/xeno_action/rally_hive/hive = new /datum/action/ability/xeno_action/rally_hive
		hive.give_action(src)
	if(!actions_by_path[/datum/action/ability/xeno_action/rally_minion])
		var/datum/action/ability/xeno_action/rally_minion/minion = new /datum/action/ability/xeno_action/rally_minion
		minion.give_action(src)


///Helper proc for removing ruler abilities
/mob/living/carbon/xenomorph/proc/remove_ruler_abilities()
	var/datum/action/ability/xeno_action/lead = actions_by_path[/datum/action/ability/xeno_action/set_xeno_lead]
	if(lead)
		lead.remove_action(src)
	var/datum/action/ability/xeno_action/blessing_menu/bless = actions_by_path[/datum/action/ability/xeno_action/blessing_menu]
	if(bless)
		bless.remove_action(src)
	var/datum/action/ability/xeno_action/hive_message/message = actions_by_path[/datum/action/ability/xeno_action/hive_message]
	if(message)
		message.remove_action(src)
	var/datum/action/ability/xeno_action/rally_hive/hive = actions_by_path[/datum/action/ability/xeno_action/rally_hive]
	if(hive)
		hive.remove_action(src)
	var/datum/action/ability/xeno_action/rally_minion/minion = actions_by_path[/datum/action/ability/xeno_action/rally_minion]
	if(minion)
		minion.remove_action(src)


/**
 * This handles checking for a xenomorph's potential IFF signals carried by components
 * Currently, IFF tags attach a component listening for this.
 */
/mob/living/carbon/xenomorph/proc/xeno_iff_check()
	var/list/inplace_iff = list(NONE)
	SEND_SIGNAL(src, COMSIG_XENO_IFF_CHECK, inplace_iff) //Inplace list magic to allow for multiple potential listeners to all do their things on the same variable.
	return inplace_iff[1]
