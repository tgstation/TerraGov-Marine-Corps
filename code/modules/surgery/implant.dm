//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY				//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/implant_removal
	priority = 1
	allowed_tools = list(
		/obj/item/tool/surgery/hemostat = 100,
		/obj/item/tool/wirecutters = 75,
		/obj/item/tool/kitchen/utensil/fork = 20,
	)

	min_duration = HEMOSTAT_REMOVE_MIN_DURATION
	max_duration = HEMOSTAT_REMOVE_MAX_DURATION

/datum/surgery_step/implant_removal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(affected.surgery_open_stage >= 2)
		return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

/datum/surgery_step/implant_removal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts poking around inside the incision on [target]'s [affected.display_name] with \the [tool]."), \
	span_notice("You start poking around inside the incision on [target]'s [affected.display_name] with \the [tool]."))
	target.custom_pain("The pain in your chest is living hell!", 1)
	target.balloon_alert_to_viewers("Checking...")
	..()

/datum/surgery_step/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(length(affected.implants))

		var/obj/item/implantfound = affected.implants[1]
		user.visible_message(span_notice("[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool]."), \
		span_notice("You take [implantfound] out of incision on [target]'s [affected.display_name]s with \the [tool]."))
		target.balloon_alert_to_viewers("Implant found")
		implantfound.unembed_ourself()

	else if(affected.hidden)
		user.visible_message(span_notice("[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool]."), \
		span_notice(" You take something out of incision on [target]'s [affected.display_name]s with \the [tool]."))
		target.balloon_alert_to_viewers("Shrapnel found")
		affected.hidden.loc = get_turf(target)
		affected.hidden.update_icon()
		affected.hidden = null

	else
		user.visible_message(span_notice("[user] could not find anything inside [target]'s [affected.display_name], and pulls \the [tool] out."), \
		span_notice("You could not find anything inside [target]'s [affected.display_name]."))
		target.balloon_alert_to_viewers("Nothing found")
	return ..()

/datum/surgery_step/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	affected.createwound(CUT, 20)
	if(length(affected.implants))
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if(prob(fail_prob))
			var/obj/item/I = affected.implants[1]
			if(istype(I,/obj/item/implant))
				var/obj/item/implant/imp = I
				user.visible_message(span_warning("Something beeps inside [target]'s [affected.display_name]!"))
				playsound(imp.loc, 'sound/items/countdown.ogg', 25, 1)
				addtimer(CALLBACK(imp, TYPE_PROC_REF(/obj/item/implant, activate)), 25)
	target.updatehealth()
	affected.update_wounds()
