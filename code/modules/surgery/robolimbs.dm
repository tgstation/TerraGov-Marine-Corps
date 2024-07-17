//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb
	can_infect = 0
	var/limb_step

/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		return SURGERY_CANNOT_USE
	if(!(affected.limb_status & LIMB_DESTROYED))
		return SURGERY_CANNOT_USE
	if(affected.parent && (affected.parent.limb_status & LIMB_DESTROYED))//parent limb is destroyed
		return SURGERY_CANNOT_USE
	if(affected.limb_replacement_stage != limb_step)
		return SURGERY_CANNOT_USE
	if(affected.body_part == HEAD) //head has its own steps
		return SURGERY_CANNOT_USE
	return SURGERY_CAN_USE

/datum/surgery_step/limb/cut
	allowed_tools = list(
		/obj/item/tool/surgery/scalpel = 100,
		/obj/item/tool/kitchen/knife = 75,
		/obj/item/shard = 50,
	)

	min_duration = ROBOLIMB_CUT_MIN_DURATION
	max_duration = ROBOLIMB_CUT_MAX_DURATION
	limb_step = 0

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool]."), \
	span_notice("You start cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool]."))
	target.balloon_alert_to_viewers("Cutting...")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] cuts away flesh where [target]'s [affected.display_name] used to be with \the [tool]."),	\
	span_notice("You cut away flesh where [target]'s [affected.display_name] used to be with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.limb_replacement_stage = 1
	return ..()

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, cutting [target]'s [affected.display_name] open!"), \
		span_warning("Your hand slips, cutting [target]'s [affected.display_name] open!"))
		target.balloon_alert_to_viewers("Slipped!")
		affected.createwound(CUT, 10)
		affected.update_wounds()



/datum/surgery_step/limb/mend
	allowed_tools = list(
		/obj/item/tool/surgery/retractor = 100,
		/obj/item/tool/crowbar = 75,
		/obj/item/tool/kitchen/utensil/fork = 50,
	)

	min_duration = ROBOLIMB_MEND_MIN_DURATION
	max_duration = ROBOLIMB_MEND_MAX_DURATION
	limb_step = 1

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] is beginning to reposition flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool]."), \
	span_notice("You start repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool]."))
	target.balloon_alert_to_viewers("Repositioning...")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool]."),	\
	span_notice("You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.limb_replacement_stage = 2
	return ..()

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!"), \
		span_warning("Your hand slips, tearing flesh on [target]'s [affected.display_name]!"))
		target.balloon_alert_to_viewers("Slipped!")
		target.apply_damage(10, BRUTE, affected, 0, TRUE, updating_health = TRUE)


/datum/surgery_step/limb/prepare
	allowed_tools = list(
		/obj/item/tool/surgery/cautery = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/tool/lighter = 50,
		/obj/item/tool/weldingtool = 25,
	)

	min_duration = ROBOLIMB_PREPARE_MIN_DURATION
	max_duration = ROBOLIMB_PREPARE_MAX_DURATION
	limb_step = 2

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts adjusting the area around [target]'s [affected.display_name] with \the [tool]."), \
	span_notice("You start adjusting the area around [target]'s [affected.display_name] with \the [tool]."))
	target.balloon_alert_to_viewers("Adjusting...")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has finished adjusting the area around [target]'s [affected.display_name] with \the [tool]."),	\
	span_notice("You have finished adjusting the area around [target]'s [affected.display_name] with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.add_limb_flags(LIMB_AMPUTATED)
	affected.setAmputatedTree()
	affected.limb_replacement_stage = 0
	return ..()

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, searing [target]'s [affected.display_name]!"), \
		span_warning("Your hand slips, searing [target]'s [affected.display_name]!"))
		target.balloon_alert_to_viewers("Slipped!")
		target.apply_damage(10, BURN, affected, updating_health = TRUE)


/datum/surgery_step/limb/attach
	allowed_tools = list(/obj/item/robot_parts = 100)

	min_duration = ROBOLIMB_ATTACH_MIN_DURATION
	max_duration = ROBOLIMB_ATTACH_MAX_DURATION
	limb_step = 0

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(..())
		var/obj/item/robot_parts/p = tool
		if(p.part)
			if(!(affected.name in p.part))
				return SURGERY_CANNOT_USE
		if(affected.limb_status & LIMB_AMPUTATED)
			return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts attaching \the [tool] where [target]'s [affected.display_name] used to be."), \
	span_notice("You start attaching \the [tool] where [target]'s [affected.display_name] used to be."))
	target.balloon_alert_to_viewers("Attaching...")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has attached \the [tool] where [target]'s [affected.display_name] used to be."),	\
	span_notice("You have attached \the [tool] where [target]'s [affected.display_name] used to be."))
	target.balloon_alert_to_viewers("Success")

	//Update our dear victim to have a limb again
	if(istype(tool, /obj/item/robot_parts/biotic))
		affected.biotize()
	else
		affected.robotize()

	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	//Deal with the limb item properly
	user.temporarilyRemoveItemFromInventory(tool)
	qdel(tool)
	return ..()

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!"), \
	span_warning("Your hand slips, damaging connectors on [target]'s [affected.display_name]!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.apply_damage(10, BRUTE, affected, 0, TRUE, updating_health = TRUE)
