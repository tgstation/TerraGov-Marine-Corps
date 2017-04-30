//Procedures in this file: Robotic limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/limb
	can_infect = 0

/datum/surgery_step/limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return 0
	if(!(affected.status & ORGAN_DESTROYED))
		return 0
	if(affected.parent)
		if (affected.parent.status & ORGAN_DESTROYED)
			return 0
	return affected.name != "head"

/datum/surgery_step/limb/cut
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/limb/cut/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return !(affected.status & ORGAN_CUT_AWAY)

/datum/surgery_step/limb/cut/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>", \
	"<span class='notice'>You start cutting away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>")
	..()

/datum/surgery_step/limb/cut/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] cuts away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>",	\
	"<span class='notice'>You cut away flesh where [target]'s [affected.display_name] used to be with \the [tool].</span>")
	affected.status |= ORGAN_CUT_AWAY

/datum/surgery_step/limb/cut/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s [affected.display_name] open!</span>", \
		"<span class='warning'>Your hand slips, cutting [target]'s [affected.display_name] open!</span>")
		affected.createwound(CUT, 10)
		affected.update_wounds()

/datum/surgery_step/limb/mend
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,          \
	/obj/item/weapon/crowbar = 75,             \
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/limb/mend/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.status & ORGAN_CUT_AWAY && affected.open < 3 && !(affected.status & ORGAN_ATTACHABLE)

/datum/surgery_step/limb/mend/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	is_same_target = affected
	user.visible_message("<span class='notice'>[user] is beginning to reposition flesh and nerve endings where where [target]'s [affected.display_name] used to be with [tool].</span>", \
	"<span class='notice'>You start repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>")
	..()

/datum/surgery_step/limb/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].</span>")
	affected.open = 3

/datum/surgery_step/limb/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!</span>", \
		"<span class='warning'>Your hand slips, tearing flesh on [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BRUTE, affected, sharp = 1)
		target.updatehealth()

/datum/surgery_step/limb/prepare
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/flame/lighter = 50,    \
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/limb/prepare/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 3

/datum/surgery_step/limb/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>")
	..()

/datum/surgery_step/limb/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>",	\
	"<span class='notice'>You have finished adjusting the area around [target]'s [affected.display_name] with \the [tool].</span>")
	affected.status |= ORGAN_ATTACHABLE
	affected.amputated = 1
	affected.setAmputatedTree()
	affected.open = 0

/datum/surgery_step/limb/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s [affected.display_name]!</span>", \
		"<span class='warning'>Your hand slips, searing [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BURN, affected)
		target.updatehealth()

/datum/surgery_step/limb/attach
	allowed_tools = list(/obj/item/robot_parts = 100)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		var/obj/item/robot_parts/p = tool
		if(p.part)
			if(!(target_zone in p.part))
				return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.status & ORGAN_ATTACHABLE

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts attaching \the [tool] where [target]'s [affected.display_name] used to be.</span>", \
	"<span class='notice'>You start attaching \the [tool] where [target]'s [affected.display_name] used to be.</span>")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/L = tool
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(is_same_target != affected) //We are not aiming at the same organ as when be begun, cut him up
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [affected.display_name] used to be.</span>",	\
	"<span class='notice'>You have attached \the [tool] where [target]'s [affected.display_name] used to be.</span>")

	//Update our dear victim to have a limb again

	affected.germ_level = 0
	affected.robotize()
	if(L.sabotaged)
		affected.sabotaged = 1
	else
		affected.sabotaged = 0
	target.update_body(0)
	target.updatehealth()
	target.UpdateDamageIcon()

	//Deal with the limb item properly

	user.temp_drop_inv_item(tool)
	del(tool)

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!</span>", \
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s [affected.display_name]!</span>")
	target.apply_damage(10, BRUTE, affected, sharp = 1)
	target.updatehealth()
