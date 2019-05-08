/datum/proc/nano_host()
	return src


/datum/proc/nano_container()
	return src


/datum/proc/CanUseTopic(mob/user, datum/topic_state/state = GLOB.default_state)
	var/datum/src_object = nano_host()
	return state.can_use_topic(src_object, user)


/datum/topic_state/proc/href_list(mob/user)
	return list()


/datum/topic_state/proc/can_use_topic(src_object, mob/user)
	return STATUS_CLOSE


/mob/proc/shared_nano_interaction()
	if(stat || !client)
		return STATUS_CLOSE						// no updates, close the interface
	else if(incapacitated())
		return STATUS_UPDATE					// update only (orange visibility)
	return STATUS_INTERACTIVE


/mob/living/silicon/ai/shared_nano_interaction()
	if(check_unable(1, 0))
		return STATUS_CLOSE
	return ..()


/* Will be used in the future
/mob/living/silicon/robot/shared_nano_interaction()
	. = STATUS_INTERACTIVE
	if(!cell || cell.charge <= 0)
		return STATUS_CLOSE
	if(lockcharge)
		. = STATUS_DISABLED
	return min(., ..())
*/