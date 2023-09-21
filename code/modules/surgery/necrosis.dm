

/datum/surgery_step/necro
	priority = 3
	var/necro_step

/datum/surgery_step/necro/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(target_zone == "mouth" || target_zone == "eyes")
		return SURGERY_CANNOT_USE

	if(affected.surgery_open_stage == 2 && (affected.limb_status & LIMB_NECROTIZED) && affected.necro_surgery_stage == necro_step)
		return SURGERY_CAN_USE

	return SURGERY_CANNOT_USE


/datum/surgery_step/necro/fix_dead_tissue //Debridement

	allowed_tools = list(
		/obj/item/tool/surgery/scalpel = 100,		\
		/obj/item/tool/kitchen/knife = 75,	\
		/obj/item/shard = 50, 		\
	)

	can_infect = 1
	blood_level = 1

	min_duration = NECRO_REMOVE_MIN_DURATION
	max_duration = NECRO_REMOVE_MAX_DURATION
	necro_step = 0

/datum/surgery_step/necro/fix_dead_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool].") , \
	span_notice("You start cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool]."))
	target.balloon_alert_to_viewers("Cutting...")
	target.custom_pain("The pain in [affected.display_name] is unbearable!", 1)
	..()

/datum/surgery_step/necro/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] has cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool]."), \
		span_notice("You cut away the necrosis in [target]'s [affected.display_name], but can't avoid some damage to the surrounding tissue."))
	target.balloon_alert_to_viewers("Success")
	affected.necro_surgery_stage = 1
	affected.createwound(CUT, 30)
	affected.germ_level = min(affected.germ_level, 600) //Ensure that necrosis won't immediately reform
	return ..()

/datum/surgery_step/necro/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	affected.createwound(CUT, 20)

/datum/surgery_step/necro/treat_necrosis

	allowed_tools = list(
		/obj/item/tool/surgery/surgical_membrane = 100,
	)

	can_infect = 0
	blood_level = 0

	min_duration = NECRO_TREAT_MIN_DURATION
	max_duration = NECRO_TREAT_MAX_DURATION
	necro_step = 1

/datum/surgery_step/necro/treat_necrosis/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts applying \the [tool] on the severed tissue in [target]'s [affected.display_name].") , \
	span_notice("You start applying \the [tool] on the severed tissue in [target]'s [affected.display_name]."))
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!", 1)
	target.balloon_alert_to_viewers("Applying...")
	..()

/datum/surgery_step/necro/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	target.update_body()

	user.visible_message(span_notice("[user] applies \the [tool] to the severed tissue in [target]'s [affected.display_name]."), \
	span_notice("You apply \the [tool] to the severed tissue in [target]'s [affected.display_name], mending it."))
	target.balloon_alert_to_viewers("Success")
	affected.necro_surgery_stage = 0
	affected.heal_limb_damage(affected.brute_dam / 2, updating_health = TRUE)
	affected.germ_level = max(0, affected.germ_level - 100) //Right at infection level 2 if it was previously above the cap
	affected.remove_limb_flags(LIMB_NECROTIZED)
	affected.bandage()
	return ..()

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, applying \the [tool] to the wrong place in [target]'s [affected.display_name]!") , \
	span_warning("Your hand slips, applying \the [tool] to the wrong place in [target]'s [affected.display_name]!"))
	target.balloon_alert_to_viewers("Slipped!")
