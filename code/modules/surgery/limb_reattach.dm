scalpel -> retract -> place limb -> hemo -> fix-o-vein  -> bone gel -> bone setter ->  ATK -> cautery

/datum/surgery_step/limb_reattach
	priority = 1
	can_infect = 0
	var/reattach_step

/datum/surgery_step/limb_reattach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		return FALSE
	if(!(affected.limb_status & LIMB_DESTROYED))
		return FALSE
	if(!affected.parent || CHECK_BITFIELD(affected.parent.limb_status, LIMB_AMPUTATED|LIMB_ROBOT))
		return FALSE
	if(affected.limb_replacement_stage != 2)
		return FALSE
	if(affected.natural_replacement_state != reattach_step)
		return FALSE
	if(affected.body_part == HEAD) //head has its own steps
		return FALSE
	return TRUE

/datum/surgery_step/limb_reattach/attach
	allowed_tools = list(/obj/item/limb = 100)

	min_duration = ROBOLIMB_ATTACH_MIN_DURATION
	max_duration = ROBOLIMB_ATTACH_MAX_DURATION
	reattach_step = 0

/datum/surgery_step/limb/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(!..())
		return FALSE
	var/obj/item/limb/p = tool
	if(!istype(affected, p.attached_type))
		return FALSE

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts attaching \the [tool] where [target]'s [affected.display_name] used to be.</span>", \
	"<span class='notice'>You start attaching \the [tool] where [target]'s [affected.display_name] used to be.</span>")

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [affected.display_name] used to be.</span>",	\
	"<span class='notice'>You have attached \the [tool] where [target]'s [affected.display_name] used to be.</span>")

	//Deal with the limb item properly
	user.temporarilyRemoveItemFromInventory(tool)
	qdel(tool)

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging nerves on [target]'s [affected.display_name]!</span>", \
	"<span class='warning'>Your hand slips, damaging nerves on [target]'s [affected.display_name]!</span>")
	target.apply_damage(10, BRUTE, affected, sharp = 1)
	target.updatehealth()
