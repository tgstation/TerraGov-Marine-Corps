// Internal surgeries.
/datum/surgery_step/internal
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(affected.surgery_open_stage == (affected.encased ? 3 : 2))
		return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/internal/remove_embryo
	priority = 3
	allowed_tools = list(
		/obj/item/tool/surgery/hemostat = 100,
		/obj/item/tool/wirecutters = 75,
		/obj/item/tool/kitchen/utensil/fork = 20,
	)
	blood_level = 2

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_embryo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(affected.body_part != CHEST)
		return SURGERY_CANNOT_USE
	if(..())
		if(locate(/obj/item/alien_embryo) in target)
			return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

/datum/surgery_step/internal/remove_embryo/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts to pull something out from [target]'s ribcage with \the [tool]."), \
					span_notice("You start to pull something out from [target]'s ribcage with \the [tool]."))
	target.balloon_alert_to_viewers("Pulling...")
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/internal/remove_embryo/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/obj/item/alien_embryo/A = locate() in target
	if(A)
		user.visible_message(span_warning("[user] rips a wriggling parasite out of [target]'s ribcage!"),
							span_warning("You rip a wriggling parasite out of [target]'s ribcage!"))
		target.balloon_alert_to_viewers("Success")
		var/mob/living/carbon/xenomorph/larva/L = locate() in target //the larva was fully grown, ready to burst.
		if(L)
			L.forceMove(target.loc)
			qdel(A)
		else
			A.forceMove(target.loc)
			target.status_flags &= ~XENO_HOST

	affected.createwound(CUT, rand(0,20), 1)
	target.updatehealth()
	affected.update_wounds()
	return ..()


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/internal/fix_organ
	priority = 1
	allowed_tools = list(
		/obj/item/tool/surgery/surgical_membrane = 100,
	)

	min_duration = FIX_ORGAN_MIN_DURATION
	max_duration = FIX_ORGAN_MAX_DURATION

/datum/surgery_step/internal/fix_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		if(affected.body_part == HEAD)//brain and eye damage is fixed by a separate surgery
			return SURGERY_CANNOT_USE
		for(var/datum/internal_organ/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic != ORGAN_ROBOT)
				return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE


/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I?.damage > 0 && I.robotic != ORGAN_ROBOT)
			user.visible_message(span_notice("[user] starts treating damage to [target]'s [I.name] with the surgical membrane."), \
			span_notice("You start treating damage to [target]'s [I.name] with the surgical membrane.") )
			target.balloon_alert_to_viewers("Fixing...")

	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/fix_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I?.damage > 0 && I.robotic != ORGAN_ROBOT)

			user.visible_message(span_notice("[user] treats damage to [target]'s [I.name] with surgical membrane."), \
			span_notice("You treat damage to [target]'s [I.name] with surgical membrane.") )
			I.heal_organ_damage(I.damage)
			target.balloon_alert_to_viewers("Success")
	return ..()

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, getting messy and tearing the inside of [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, getting messy and tearing the inside of [target]'s [affected.display_name] with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	var/dam_amt = 2

	if(istype(tool, /obj/item/tool/surgery/surgical_membrane))
		target.adjustToxLoss(5)

	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I?.damage > 0)
			I.take_damage(dam_amt,0)
	target.updatehealth()
	affected.update_wounds()



/datum/surgery_step/internal/fix_organ_robotic //For artificial organs
	allowed_tools = list(
		/obj/item/stack/nanopaste = 100,
		/obj/item/tool/surgery/bonegel = 30,
		/obj/item/tool/screwdriver = 70,
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/fix_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		if(affected.body_part == HEAD)//brain and eye damage is fixed by a separate surgery
			return SURGERY_CANNOT_USE
		for(var/datum/internal_organ/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic == ORGAN_ROBOT)
				return SURGERY_CAN_USE
	return SURGERY_CANNOT_USE

/datum/surgery_step/internal/fix_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I?.damage > 0 && I.robotic == ORGAN_ROBOT)
			user.visible_message(span_notice("[user] starts mending the damage to [target]'s [I.name]'s mechanisms."), \
			span_notice("You start mending the damage to [target]'s [I.name]'s mechanisms.") )

	target.balloon_alert_to_viewers("Mending...")
	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/fix_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I?.damage > 0 && I.robotic == ORGAN_ROBOT)
			user.visible_message(span_notice("[user] repairs [target]'s [I.name] with [tool]."), \
			span_notice("You repair [target]'s [I.name] with [tool].") )
			I.damage = 0
	target.balloon_alert_to_viewers("Success")
	return ..()

/datum/surgery_step/internal/fix_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")

	target.adjustToxLoss(5)
	affected.createwound(CUT, 5)

	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I)
			I.take_damage(rand(3, 5), 0)
	target.updatehealth()
	affected.update_wounds()
