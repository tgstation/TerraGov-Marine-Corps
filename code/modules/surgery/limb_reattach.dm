//scalpel -> retract -> place limb -> hemo -> fix-o-vein  -> bone gel -> bone setter ->  ATK -> cautery

/datum/surgery_step/limb_reattach
	priority = 1
	can_infect = 0
	var/reattach_step = 0

/datum/surgery_step/limb_reattach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		to_chat(world, "cant use9")
		return FALSE
	if(!(affected.limb_status & LIMB_DESTROYED))
		to_chat(world, "cant use8")
		return FALSE
	if(!affected.parent || CHECK_BITFIELD(affected.parent.limb_status, LIMB_AMPUTATED|LIMB_ROBOT))
		to_chat(world, "cant use7")
		return FALSE
	if(affected.limb_replacement_stage < 2)
		to_chat(world, "cant use6")
		return FALSE
	if(affected.natural_replacement_state != reattach_step)
		to_chat(world, "cant use5")
		return FALSE
	if(affected.body_part == HEAD) //head has its own steps
		to_chat(world, "cant use4")
		return FALSE
	to_chat(world, "can use1")
	return TRUE

/datum/surgery_step/limb_reattach/attach
	allowed_tools = list(/obj/item/limb = 100)

	min_duration = ROBOLIMB_ATTACH_MIN_DURATION
	max_duration = ROBOLIMB_ATTACH_MAX_DURATION
	reattach_step = 0

/datum/surgery_step/limb_reattach/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/limb/p = tool
	if(!istype(affected, p.attached_type))
		to_chat(world, "cant use2")
		return FALSE
	if(p.owner != target)
		to_chat(world, "cant use3")
		return FALSE

/datum/surgery_step/limb_reattach/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts attaching \the [tool] where [target]'s [affected.display_name] used to be.</span>", \
	"<span class='notice'>You start attaching \the [tool] where [target]'s [affected.display_name] used to be.</span>")

/datum/surgery_step/limb_reattach/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has attached \the [tool] where [target]'s [affected.display_name] used to be.</span>",	\
	"<span class='notice'>You have attached \the [tool] where [target]'s [affected.display_name] used to be.</span>")

	var/obj/item/limb/L = tool
	if(L.wounds)
		affected.wounds = L.wounds.Copy()
	affected.brute_dam = L.brute
	affected.burn_dam = L.burn

	//todo: amputation time handling

	//Deal with the limb item properly
	user.dropItemToGround(L)
	qdel(L)
	affected.natural_replacement_state = 1
	affected.limb_replacement_stage = 3

/datum/surgery_step/limb_reattach/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging nerves on [target]'s [affected.display_name]!</span>", \
	"<span class='warning'>Your hand slips, damaging nerves on [target]'s [affected.display_name]!</span>")
	target.apply_damage(10, BRUTE, affected, sharp = 1)
	target.updatehealth()

/datum/surgery_step/limb_reattach/pull
	allowed_tools = list(
	/obj/item/tool/surgery/hemostat = 100,         \
	/obj/item/stack/cable_coil = 75,         \
	/obj/item/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60
	reattach_step = 1

/datum/surgery_step/limb_reattach/pull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts reattaching the nerves in [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start reattaching the nerves in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("The pain in your [affected.display_name] is maddening!", 1)
	..()

/datum/surgery_step/limb_reattach/pull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] reattaching the nerves in [target]'s [affected.display_name] with \the [tool].</span>",	\
	"<span class='notice'>You reattaching the nerves in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.natural_replacement_state = 2

/datum/surgery_step/limb_reattach/pull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",)
	affected.createwound(CUT, 10)
	affected.update_wounds()

/datum/surgery_step/limb_reattach/fix_vein
	allowed_tools = list(
	/obj/item/tool/surgery/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1
	reattach_step = 2
	min_duration = FIXVEIN_MIN_DURATION
	max_duration = FIXVEIN_MAX_DURATION

/datum/surgery_step/limb_reattach/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts patching the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>" , \
	"<span class='notice'>You start patching the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
	..()

/datum/surgery_step/limb_reattach/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has patched the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You have patched the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.natural_replacement_state = 3
	

/datum/surgery_step/limb_reattach/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")
	affected.take_damage_limb(5, 0)
	target.updatehealth()



/datum/surgery_step/limb_reattach/glue_bone
	allowed_tools = list(
	/obj/item/tool/surgery/bonegel = 100,	  \
	/obj/item/tool/screwdriver = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = BONEGEL_REPAIR_MIN_DURATION
	max_duration = BONEGEL_REPAIR_MAX_DURATION
	reattach_step = 3

/datum/surgery_step/limb_reattach/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>" , \
		"<span class='notice'>You start applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!", 1)
	..()

/datum/surgery_step/limb_reattach/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] applies some [tool] to [target]'s bone in [affected.display_name].</span>", \
	"<span class='notice'>You apply some [tool] to [target]'s bone in [affected.display_name] with \the [tool].</span>")
	affected.natural_replacement_state = 4

/datum/surgery_step/limb_reattach/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")


/datum/surgery_step/limb_reattach/set_bone
	allowed_tools = list(
	/obj/item/tool/surgery/bonesetter = 100, \
	/obj/item/tool/wrench = 75	   \
	)

	min_duration = BONESETTER_MIN_DURATION
	max_duration = BONESETTER_MAX_DURATION
	reattach_step = 4


/datum/surgery_step/limb_reattach/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.body_part == HEAD)
		user.visible_message("<span class='notice'>[user] is beginning to piece together [target]'s skull with \the [tool].</span>"  , \
		"<span class='notice'>You are beginning to piece together [target]'s skull with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] is beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>" , \
		"<span class='notice'>You are beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>")
		target.custom_pain("The pain in your [affected.display_name] is going to make you pass out!", 1)
	..()

/datum/surgery_step/limb_reattach/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [affected.display_name] in place with \the [tool].</span>", \
	"<span class='notice'>You set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>")
	affected.natural_replacement_state = 5

/datum/surgery_step/bone/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 5)
	affected.update_wounds()
