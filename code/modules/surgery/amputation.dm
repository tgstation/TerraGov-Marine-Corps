


/datum/surgery_step/cut_limb
	can_infect = 1
	allowed_tools = list(
		/obj/item/tool/surgery/circular_saw = 100,
		/obj/item/tool/hatchet = 75,
		/obj/item/weapon/claymore = 75,
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/cut_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		return SURGERY_CANNOT_USE
	if(affected.limb_status & LIMB_DESTROYED) //already missing
		return SURGERY_CANNOT_USE
	if(affected.surgery_open_stage) //avoids conflict with sawing skull open
		return SURGERY_CANNOT_USE
	if(target_zone == "chest" || target_zone == "groin" || target_zone == "head") //can't amputate the chest
		return SURGERY_CANNOT_USE
	return SURGERY_CAN_USE

/datum/surgery_step/cut_limb/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] is beginning to cut off [target]'s [affected.display_name] with \the [tool].") , \
	span_notice("You are beginning to cut off [target]'s [affected.display_name] with \the [tool]."))
	target.balloon_alert_to_viewers("Sawing...")
	target.custom_pain("Your [affected.display_name] is being ripped apart!", 1)
	..()

/datum/surgery_step/cut_limb/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] cuts off [target]'s [affected.display_name] with \the [tool]."), \
	span_notice("You cut off [target]'s [affected.display_name] with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.droplimb(1)
	target.updatehealth()
	return ..()

/datum/surgery_step/generic/cut_limb/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	affected.createwound(CUT, 30)
	affected.fracture()
	affected.update_wounds()
