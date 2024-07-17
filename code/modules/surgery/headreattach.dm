//This is an uguu head restoration surgery TOTALLY not yoinked from chinsky's limb reattacher

/datum/surgery_step/head
	priority = 1
	can_infect = 0
	allowed_species = list("Synthetic", "Early Synthetic", "Combat Robot")
	var/reattach_step

/datum/surgery_step/head/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		return SURGERY_CANNOT_USE
	if(!(affected.limb_status & LIMB_DESTROYED))
		return SURGERY_CANNOT_USE
	if(affected.body_part != HEAD)
		return SURGERY_CANNOT_USE
	if(affected.limb_replacement_stage == reattach_step)
		return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

/datum/surgery_step/head/peel
	allowed_tools = list(
		/obj/item/tool/surgery/retractor = 100,
		/obj/item/tool/crowbar = 75,
		/obj/item/tool/kitchen/utensil/fork = 50,
	)

	min_duration = 30
	max_duration = 40
	reattach_step = 0


/datum/surgery_step/head/peel/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts peeling back tattered flesh where [target]'s head used to be with \the [tool]."), \
	span_notice("You start peeling back tattered flesh where [target]'s head used to be with \the [tool]."))
	target.balloon_alert_to_viewers("Peeling...")
	..()

/datum/surgery_step/head/peel/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] peels back tattered flesh where [target]'s head used to be with \the [tool]."),	\
	span_notice("You peel back tattered flesh where [target]'s head used to be with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.limb_replacement_stage = 1
	return ..()

/datum/surgery_step/head/peel/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, ripping [target]'s [affected.display_name] open!"), \
		span_warning("Your hand slips,  ripping [target]'s [affected.display_name] open!"))
		target.balloon_alert_to_viewers("Slipped!")
		affected.createwound(CUT, 10)
		affected.update_wounds()


/datum/surgery_step/head/shape
	allowed_tools = list(
		/obj/item/tool/surgery/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/assembly/mousetrap = 10,
	)

	min_duration = 60
	max_duration = 80
	reattach_step = 1

/datum/surgery_step/head/shape/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] is beginning to reshape [target]'s esophagal and vocal region with \the [tool]."), \
	span_notice("You start to reshape [target]'s head esophagal and vocal region with \the [tool]."))
	target.balloon_alert_to_viewers("Reshaping...")
	..()

/datum/surgery_step/head/shape/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool]."),	\
	span_notice("You have finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.limb_replacement_stage = 2
	return ..()

/datum/surgery_step/head/shape/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, further rending flesh on [target]'s neck!"), \
		span_warning("Your hand slips, further rending flesh on [target]'s neck!"))
		target.balloon_alert_to_viewers("Slipped!")
		target.apply_damage(10, BRUTE, affected, updating_health = TRUE)


/datum/surgery_step/head/suture
	allowed_tools = list(
		/obj/item/tool/surgery/hemostat = 100,
		/obj/item/stack/cable_coil = 60,
		/obj/item/tool/surgery/FixOVein = 80,
	)

	min_duration = 60
	max_duration = 80
	reattach_step = 2

/datum/surgery_step/head/suture/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] is stapling and suturing flesh into place in [target]'s esophagal and vocal region with \the [tool]."), \
	span_notice("You start to staple and suture flesh into place in [target]'s esophagal and vocal region with \the [tool]."))
	target.balloon_alert_to_viewers("Suturing...")
	..()

/datum/surgery_step/head/suture/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has finished stapling [target]'s neck into place with \the [tool]."),	\
	span_notice("You have finished stapling [target]'s neck into place with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.limb_replacement_stage = 3
	return ..()

/datum/surgery_step/head/suture/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, ripping apart flesh on [target]'s neck!"), \
		span_warning("Your hand slips, ripping apart flesh on [target]'s neck!"))
		target.balloon_alert_to_viewers("Slipped!")
		target.apply_damage(10, BRUTE, affected, updating_health = TRUE)


/datum/surgery_step/head/prepare
	allowed_tools = list(
		/obj/item/tool/surgery/cautery = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/tool/lighter = 50,
		/obj/item/tool/weldingtool = 25,
	)

	min_duration = 60
	max_duration = 80
	reattach_step = 3

/datum/surgery_step/head/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts adjusting area around [target]'s neck with \the [tool]."), \
	span_notice("You start adjusting area around [target]'s neck with \the [tool]."))
	target.balloon_alert_to_viewers("Adjusting...")
	..()

/datum/surgery_step/head/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has finished adjusting the area around [target]'s neck with \the [tool]."),	\
	span_notice("You have finished adjusting the area around [target]'s neck with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	affected.limb_replacement_stage = 0
	affected.add_limb_flags(LIMB_AMPUTATED)
	affected.setAmputatedTree()
	return ..()

/datum/surgery_step/head/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, searing [target]'s neck!"), \
		span_warning("Your hand slips, searing [target]'s [affected.display_name]!"))
		target.balloon_alert_to_viewers("Slipped!")
		target.apply_damage(10, BURN, affected, updating_health = TRUE)


/datum/surgery_step/head/attach
	allowed_tools = list(/obj/item/limb/head/synth = 100, /obj/item/limb/head/robotic = 100)
	can_infect = 0
	min_duration = 60
	max_duration = 80
	reattach_step = 0

/datum/surgery_step/head/attach/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		if(affected.limb_status & LIMB_AMPUTATED)
			return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

/datum/surgery_step/head/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts attaching [tool] to [target]'s reshaped neck."), \
	span_notice("You start attaching [tool] to [target]'s reshaped neck."))
	target.balloon_alert_to_viewers("Attaching...")
	..()

/datum/surgery_step/head/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has attached [target]'s head to the body."),	\
	span_notice("You have attached [target]'s head to the body."))
	target.balloon_alert_to_viewers("Success")

	//Update our dear victim to have a head again

	var/obj/item/limb/head/B = tool

	affected.robotize()
	target.updatehealth()
	target.update_body()
	target.UpdateDamageIcon()
	target.update_hair()

	//Prepare mind datum
	if(B.brainmob?.mind)
		B.brainmob.mind.transfer_to(target)

	//Deal with the head item properly
	user.temporarilyRemoveItemFromInventory(B)
	qdel(B)
	return ..()

/datum/surgery_step/head/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, damaging connectors on [target]'s neck!"), \
	span_warning("Your hand slips, damaging connectors on [target]'s neck!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.apply_damage(10, BRUTE, affected, 0, TRUE, updating_health = TRUE)
