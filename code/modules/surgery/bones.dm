//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/bone
	var/bone_step

/datum/surgery_step/bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	return affected.surgery_open_stage >= 2 && !(affected.limb_status & LIMB_DESTROYED) && affected.bone_repair_stage == bone_step && !(affected.limb_status & LIMB_REPAIRED)


/datum/surgery_step/bone/glue_bone
	allowed_tools = list(
		/obj/item/tool/surgery/bonegel = 100,
		/obj/item/tool/screwdriver = 75,
	)
	can_infect = 1
	blood_level = 1

	min_duration = BONEGEL_REPAIR_MIN_DURATION
	max_duration = BONEGEL_REPAIR_MAX_DURATION
	bone_step = 0

/datum/surgery_step/bone/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>" , \
		"<span class='notice'>You start applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!", 1)
	..()

/datum/surgery_step/bone/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] applies some [tool] to [target]'s bone in [affected.display_name].</span>", \
	"<span class='notice'>You apply some [tool] to [target]'s bone in [affected.display_name] with \the [tool].</span>")
	affected.bone_repair_stage = 1

/datum/surgery_step/bone/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")


/datum/surgery_step/bone/set_bone
	allowed_tools = list(
		/obj/item/tool/surgery/bonesetter = 100,
		/obj/item/tool/wrench = 75,
	)

	min_duration = BONESETTER_MIN_DURATION
	max_duration = BONESETTER_MAX_DURATION
	bone_step = 1


/datum/surgery_step/bone/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.body_part == HEAD)
		user.visible_message("<span class='notice'>[user] is beginning to piece together [target]'s skull with \the [tool].</span>"  , \
		"<span class='notice'>You are beginning to piece together [target]'s skull with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] is beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>" , \
		"<span class='notice'>You are beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>")
		target.custom_pain("The pain in your [affected.display_name] is going to make you pass out!", 1)
	..()

/datum/surgery_step/bone/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.body_part == HEAD)
		user.visible_message("<span class='notice'>[user] sets [target]'s skull with \the [tool].</span>" , \
		"<span class='notice'>You set [target]'s skull with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [affected.display_name] in place with \the [tool].</span>", \
		"<span class='notice'>You set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>")
	affected.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
	affected.add_limb_flags(LIMB_REPAIRED)
	affected.bone_repair_stage = 0

/datum/surgery_step/bone/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.body_part == HEAD)
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
		var/datum/limb/head/h = affected
		h.createwound(BRUISE, 10)
		h.disfigured = 1
		h.owner.name = h.owner.get_visible_name()
		h.update_wounds()
	else
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
		affected.createwound(BRUISE, 5)
		affected.update_wounds()
