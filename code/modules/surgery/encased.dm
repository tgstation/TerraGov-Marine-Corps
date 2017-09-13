//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	priority = 1
	can_infect = 1
	blood_level = 1

/datum/surgery_step/open_encased/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return 0

	var/datum/limb/affected = target.get_limb(target_zone)
	return affected.encased && affected.open >= 2


/datum/surgery_step/open_encased/saw
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/open_encased/saw/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	return ..() && affected.open == 2

/datum/surgery_step/open_encased/saw/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	target.op_stage.is_same_target = affected

	user.visible_message("<span class='notice'>[user] begins to cut through [target]'s [affected.encased] with \the [tool].</span>", \
	"<span class='notice'>You begin to cut through [target]'s [affected.encased] with \the [tool].</span>")
	target.custom_pain("Something hurts horribly in your [affected.display_name]!", 1)
	..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] has cut [target]'s [affected.encased] open with \the [tool].</span>",		\
	"<span class='notice'>You have cut [target]'s [affected.encased] open with \the [tool].</span>")
	affected.open = 2.5

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cracking [target]'s [affected.encased] with \the [tool]!</span>" )

	affected.createwound(CUT, 20)
	affected.fracture()
	affected.update_wounds()

/datum/surgery_step/open_encased/retract
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, \
	/obj/item/weapon/crowbar = 75
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/open_encased/retract/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	return ..() && affected.open == 2.5

/datum/surgery_step/open_encased/retract/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	target.op_stage.is_same_target = affected

	user.visible_message("<span class='notice'>[user] starts to force open the [affected.encased] in [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start to force open the [affected.encased] in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("Something hurts horribly in your [affected.display_name]!", 1)
	..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return

	user.visible_message("<span class='notice'>[user] forces open [target]'s [affected.encased] with \the [tool].</span>", \
	"<span class='notice'>You force open [target]'s [affected.encased] with \the [tool].</span>")
	affected.open = 3

	//Whoops!
	if(prob(10))
		affected.fracture()

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s [affected.encased]!</span>", \
	"<span class='warning'>Your hand slips, cracking [target]'s  [affected.encased]!</span>")

	affected.createwound(BRUISE, 20)
	affected.fracture()
	affected.update_wounds()

/datum/surgery_step/open_encased/close
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, \
	/obj/item/weapon/crowbar = 75
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/open_encased/close/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	return ..() && affected.open == 3

/datum/surgery_step/open_encased/close/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	target.op_stage.is_same_target = affected

	user.visible_message("<span class='notice'>[user] starts bending [target]'s [affected.encased] back into place with \the [tool].</span>", \
	"<span class='notice'>You start bending [target]'s [affected.encased] back into place with \the [tool].</span>")
	target.custom_pain("Something hurts horribly in your [affected.display_name]!", 1)
	..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return

	user.visible_message("<span class='notice'>[user] bends [target]'s [affected.encased] back into place with \the [tool].</span>", \
	"<span class='notice'>You bend [target]'s [affected.encased] back into place with \the [tool].</span>")
	affected.open = 2.5

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, bending [target]'s [affected.encased] the wrong way!</span>", \
	"<span class='warning'>Your hand slips, bending [target]'s [affected.encased] the wrong way!</span>")

	affected.createwound(BRUISE, 20)
	affected.fracture()
	affected.update_wounds()

/datum/surgery_step/open_encased/mend
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/open_encased/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	return ..() && affected.open == 2.5

/datum/surgery_step/open_encased/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	target.op_stage.is_same_target = affected

	user.visible_message("<span class='notice'>[user] starts applying \the [tool] to [target]'s [affected.encased].</span>", \
	"<span class='notice'>You start applying \the [tool] to [target]'s [affected.encased].</span>")
	target.custom_pain("Something hurts horribly in your [affected.display_name]!",1)
	..()

/datum/surgery_step/open_encased/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/limb/affected = target.get_limb(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return

	user.visible_message("<span class='notice'>[user] applied \the [tool] to [target]'s [affected.encased].</span>", \
	"<span class='notice'>You applied \the [tool] to [target]'s [affected.encased].</span>")
	affected.open = 2
