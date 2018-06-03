


/datum/surgery_step/cut_limb
	can_infect = 1
	allowed_tools = list(
	/obj/item/tool/surgery/circular_saw = 100, \
	/obj/item/tool/hatchet = 75,       \
	/obj/item/weapon/claymore = 75
	)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/cut_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		return 0
	if(affected.status & LIMB_DESTROYED) //already missing
		return 0
	if(affected.surgery_open_stage) //avoids conflict with sawing skull open
		return 0
	if(target_zone == "chest" || target_zone == "groin" || target_zone == "head") //can't amputate the chest
		return 0
	return 1

/datum/surgery_step/cut_limb/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] is beginning to cut off [target]'s [affected.display_name] with \the [tool].</span>" , \
	"<span class='notice'>You are beginning to cut off [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("Your [affected.display_name] is being ripped apart!", 1)
	..()

/datum/surgery_step/cut_limb/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] cuts off [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You cut off [target]'s [affected.display_name] with \the [tool].</span>")
	affected.droplimb(1)
	target.updatehealth()

/datum/surgery_step/generic/cut_limb/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 30)
	affected.fracture()
	affected.update_wounds()