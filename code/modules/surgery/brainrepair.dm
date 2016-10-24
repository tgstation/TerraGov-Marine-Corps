//////////////////////////////////////////////////////////////////
//				BRAIN DAMAGE FIXING								//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/brain/bone_chips
	priority = 3
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100, 		   \
	/obj/item/weapon/wirecutters = 75, 		   \
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/brain/bone_chips/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/datum/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
	return (sponge && sponge.damage > 0 && sponge.damage <= 20) && affected.open == 3 && target_zone == "head"

/datum/surgery_step/brain/bone_chips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts taking bone chips out of [target]'s brain with \the [tool].</span>", \
	"<span class='notice'>You start taking bone chips out of [target]'s brain with \the [tool].</span>")
	..()

/datum/surgery_step/brain/bone_chips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] takes out all the bone chips in [target]'s brain with \the [tool].</span>",	\
	"<span class='notice'>You take out all the bone chips in [target]'s brain with \the [tool].</span>")
	var/datum/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
	if(sponge)
		sponge.damage = 0

/datum/surgery_step/brain/bone_chips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, jabbing \the [tool] in [target]'s brain!</span>", \
	"<span class='warning'>Your hand slips, jabbing \the [tool] in [target]'s brain!</span>")
	target.apply_damage(30, BRUTE, "head", 1, sharp = 1)
	target.updatehealth()

/datum/surgery_step/brain/hematoma
	priority = 3
	allowed_tools = list(
	/obj/item/weapon/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/brain/hematoma/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/datum/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
	return (sponge && sponge.damage > 20) && affected.open == 3 && target_zone == "head"

/datum/surgery_step/brain/hematoma/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts mending hematoma in [target]'s brain with \the [tool].</span>", \
	"<span class='notice'>You start mending hematoma in [target]'s brain with \the [tool].</span>")
	..()

/datum/surgery_step/brain/hematoma/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] mends hematoma in [target]'s brain with \the [tool].</span>",	\
	"<span class='notice'>You mend hematoma in [target]'s brain with \the [tool].</span>")
	var/datum/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
	if(sponge)
		sponge.damage = 20

/datum/surgery_step/brain/hematoma/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, bruising [target]'s brain with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, bruising [target]'s brain with \the [tool]!</span>")
	target.apply_damage(20, BRUTE, "head", 1, sharp = 1)
	target.updatehealth()
