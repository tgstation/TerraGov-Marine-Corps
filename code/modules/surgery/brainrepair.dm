//////////////////////////////////////////////////////////////////
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain
	var/dmg_min = 0
	var/dmg_max

/datum/surgery_step/brain/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	var/datum/internal_organ/brain/sponge = target.internal_organs_by_name["brain"]
	if(!sponge || sponge.damage <= dmg_min || affected.surgery_open_stage != 3 || target_zone != "head")
		return SURGERY_CANNOT_USE
	if(dmg_max && sponge.damage > dmg_max)
		return SURGERY_CANNOT_USE
	return SURGERY_CAN_USE



/datum/surgery_step/brain/bone_chips
	priority = 3
	allowed_tools = list(
		/obj/item/tool/surgery/hemostat = 100,
		/obj/item/tool/wirecutters = 75,
		/obj/item/tool/kitchen/utensil/fork = 20,
	)

	min_duration = BONECHIPS_REMOVAL_MIN_DURATION
	max_duration = BONECHIPS_REMOVAL_MAX_DURATION
	dmg_max = BONECHIPS_MAX_DAMAGE //need to use the FixOVein past this point

/datum/surgery_step/brain/bone_chips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts taking bone chips out of [target]'s brain with \the [tool]."), \
	span_notice("You start taking bone chips out of [target]'s brain with \the [tool]."))
	target.balloon_alert_to_viewers("Clearing bone...")
	..()

/datum/surgery_step/brain/bone_chips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] takes out all the bone chips in [target]'s brain with \the [tool]."),	\
	span_notice("You take out all the bone chips in [target]'s brain with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	var/datum/internal_organ/brain/sponge = target.internal_organs_by_name["brain"]
	if(sponge)
		sponge.damage = 0
	return ..()

/datum/surgery_step/brain/bone_chips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, jabbing \the [tool] in [target]'s brain!"), \
	span_warning("Your hand slips, jabbing \the [tool] in [target]'s brain!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.apply_damage(30, BRUTE, "head", 0, TRUE, updating_health = TRUE)


/datum/surgery_step/brain/hematoma
	priority = 3
	allowed_tools = list(
		/obj/item/tool/surgery/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
	)

	min_duration = HEMOTOMA_MIN_DURATION
	max_duration = HEMOTOMA_MAX_DURATION
	dmg_min = BONECHIPS_MAX_DAMAGE //below that, you use the hemostat


/datum/surgery_step/brain/hematoma/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts mending hematoma in [target]'s brain with \the [tool]."), \
	span_notice("You start mending hematoma in [target]'s brain with \the [tool]."))
	target.balloon_alert_to_viewers("Mending...")
	..()

/datum/surgery_step/brain/hematoma/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] mends hematoma in [target]'s brain with \the [tool]."),	\
	span_notice("You mend hematoma in [target]'s brain with \the [tool]."))
	target.balloon_alert_to_viewers("Success")
	var/datum/internal_organ/brain/sponge = target.internal_organs_by_name["brain"]
	if(sponge)
		sponge.damage = BONECHIPS_MAX_DAMAGE
	return ..()

/datum/surgery_step/brain/hematoma/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, bruising [target]'s brain with \the [tool]!"), \
	span_warning("Your hand slips, bruising [target]'s brain with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	target.apply_damage(20, BRUTE, "head", 0, TRUE, updating_health = TRUE)
