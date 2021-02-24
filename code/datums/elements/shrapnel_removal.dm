/datum/element/shrapnel_removal
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/do_after_time

/datum/element/shrapnel_removal/Attach(datum/target, duration)
	. = ..()
	if(!isitem(target) || (duration < 1))
		return ELEMENT_INCOMPATIBLE
	do_after_time = duration
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_attack)

/datum/element/shrapnel_removal/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_ATTACK)

/datum/element/shrapnel_removal/proc/on_attack(datum/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/attempt_remove, source, M, user)
	return COMPONENT_ITEM_NO_ATTACK

/datum/element/shrapnel_removal/proc/attempt_remove(obj/item/removaltool, mob/living/M, mob/living/user)
	if(!ishuman(M))
		to_chat(user, "<span class='warning'>You only know how to remove shrapnel from humans!</span>")
		return
	var/mob/living/carbon/human/target = M
	var/datum/limb/targetlimb = target.get_limb(user.zone_selected)
	if(!length(targetlimb.implants))
		to_chat(user, "<span class='warning'>There is nothing in this limb!</span>")
		return
	var/skill = user.skills.getRating("medical")
	if(skill < SKILL_MEDICAL_PRACTICED)
		user.visible_message("<span class='notice'>[user] fumbles around with the [removaltool].</span>",
		"<span class='notice'>You fumble around figuring out how to use [removaltool].</span>")
		if(!do_after(user, do_after_time * (SKILL_MEDICAL_PRACTICED - skill), TRUE, target, BUSY_ICON_UNSKILLED))
			return
	user.visible_message("<span class='notice'>[user] starts searching for shrapnel in [target] with the [removaltool].</span>", "<span class='notice'>You start searching for shrapnel in [target] with the [removaltool].</span>")
	if(!do_after(user, do_after_time, TRUE, target, BUSY_ICON_MEDICAL))
		return
	for(var/obj/item/I AS in targetlimb.implants)
		if(is_type_in_list(I, GLOB.known_implants))
			continue
		I.unembed_ourself(FALSE)
		if(skill < SKILL_MEDICAL_PRACTICED)
			user.visible_message("<span class='notice'>[user] violently rips out [I] from [target]!</span>", "<span class='notice'>You violently rip out [I] from [target]!</span>")
			target.apply_damage(30 * (SKILL_MEDICAL_PRACTICED - skill), def_zone = user.zone_selected)
		else
			user.visible_message("<span class='notice'>[user] pulls out [I] from [target]!</span>", "<span class='notice'>You pull out [I] from [target]!</span>")
			target.apply_damage(15, def_zone = user.zone_selected)
		break
