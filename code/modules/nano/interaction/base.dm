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
	if(incapacitated())
		return STATUS_CLOSE
	return ..()