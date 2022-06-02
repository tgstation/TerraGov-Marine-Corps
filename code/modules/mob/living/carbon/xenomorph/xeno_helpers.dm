
/mob/living/carbon/xenomorph/can_ventcrawl()
	if(mob_size == MOB_SIZE_BIG || !(xeno_caste.can_flags & CASTE_CAN_VENT_CRAWL))
		return FALSE
	else
		return TRUE

/mob/living/carbon/xenomorph/ventcrawl_carry()
	return TRUE

/mob/living/carbon/human/get_reagent_tags()
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
	if(!actions_by_path[/datum/action/xeno_action/rally_hive])
		var/datum/action/xeno_action/rally_hive/rally = new /datum/action/xeno_action/rally_hive
		rally.give_action(src)
	if(!actions_by_path[/datum/action/xeno_action/rally_minion])
		var/datum/action/xeno_action/rally_minion/rally = new /datum/action/xeno_action/rally_minion
		rally.give_action(src)
	if(!actions_by_path[/datum/action/xeno_action/set_agressivity])
		var/datum/action/xeno_action/set_agressivity/minions_behaviour = new /datum/action/xeno_action/set_agressivity
		minions_behaviour.give_action(src)



///Helper proc for removing the rally hive ability appropriately
/mob/living/carbon/xenomorph/proc/remove_rally_hive_ability()

	var/datum/action/xeno_action/rally_hive/rally = actions_by_path[/datum/action/xeno_action/rally_hive]

	if(rally)
		rally.remove_action(src)
	var/datum/action/xeno_action/rally_minion/rally_minion = actions_by_path[/datum/action/xeno_action/rally_minion]

	if(rally_minion)
		rally_minion.remove_action(src)
	var/datum/action/xeno_action/set_agressivity/minions_behaviour = actions_by_path[/datum/action/xeno_action/set_agressivity]
	if(minions_behaviour)
		minions_behaviour.remove_action(src)

