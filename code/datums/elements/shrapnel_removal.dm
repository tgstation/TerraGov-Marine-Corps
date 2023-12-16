/datum/element/shrapnel_removal
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///Channel time per shrap removal
	var/do_after_time
	///Fumble time for unskilled users
	var/fumble_duration

/datum/element/shrapnel_removal/Attach(datum/target, duration, fumble_time)
	. = ..()
	if(!isitem(target) || (duration < 1))
		return ELEMENT_INCOMPATIBLE
	do_after_time = duration
	fumble_duration = fumble_time ? fumble_time : do_after_time
	RegisterSignal(target, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))

/datum/element/shrapnel_removal/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/shrapnel_removal/proc/on_attack(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_remove), source, M, user)
	return COMPONENT_ITEM_NO_ATTACK

/datum/element/shrapnel_removal/proc/attempt_remove(obj/item/removaltool, mob/living/M, mob/living/user)
	if(!ishuman(M))
		M.balloon_alert(user, "You only know how to remove shrapnel from humans!")
		return
	var/mob/living/carbon/human/target = M
	var/datum/limb/targetlimb = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(target, user) : target.get_limb(user.zone_selected)
	if(!targetlimb) //radial_medical can return null
		return
	if(!has_shrapnel(targetlimb))
		M.balloon_alert(user, "There is nothing in limb!")
		return
	var/skill = user.skills.getRating(SKILL_MEDICAL)
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message(span_notice("[user] fumbles around with the [removaltool]."),
		span_notice("You fumble around figuring out how to use [removaltool]."))
		if(!do_after(user, fumble_duration * (SKILL_MEDICAL_PRACTICED - skill), NONE, target, BUSY_ICON_UNSKILLED))
			return
	user.visible_message(span_notice("[user] starts searching for shrapnel in [target] with the [removaltool]."), span_notice("You start searching for shrapnel in [target] with the [removaltool]."))
	if(!do_after(user, do_after_time, NONE, target, BUSY_ICON_MEDICAL))
		to_chat(user, span_notice("You stop searching for shrapnel in [target]"))
		return
	remove_shrapnel(user, target, targetlimb, skill)
	//iterates over the rest of the patient's limbs, attempting to remove shrapnel
	for(targetlimb AS in target.limbs)
		while(has_shrapnel(targetlimb))
			if(!do_after(user, do_after_time, NONE, target, BUSY_ICON_MEDICAL))
				to_chat(user, span_notice("You stop searching for shrapnel in [target]"))
				return
			remove_shrapnel(user, target, targetlimb, skill)
	to_chat(user, span_notice("You remove the last of the shrapnel from [target]"))

///returns TRUE if the argument limb has any shrapnel in it
/datum/element/shrapnel_removal/proc/has_shrapnel(datum/limb/targetlimb)
	for (var/obj/item/I in targetlimb.implants)
		if(!is_type_in_list(I, GLOB.known_implants))
			return TRUE
	return FALSE

/datum/element/shrapnel_removal/proc/remove_shrapnel(mob/living/user, mob/living/target, datum/limb/targetlimb, skill)
	for(var/obj/item/I AS in targetlimb.implants)
		if(is_type_in_list(I, GLOB.known_implants))
			continue
		I.unembed_ourself(FALSE)
		if(skill < SKILL_MEDICAL_PRACTICED)
			user.visible_message(span_notice("[user] violently rips out [I] from [target]!"), span_notice("You violently rip out [I] from [target]!"))
			targetlimb.take_damage_limb(30 * (SKILL_MEDICAL_PRACTICED - skill), 0, FALSE, FALSE)
		else
			user.visible_message(span_notice("[user] pulls out [I] from [target]!"), span_notice("You pull out [I] from [target]!"))
			targetlimb.take_damage_limb(15, 0, FALSE, FALSE)
		break
