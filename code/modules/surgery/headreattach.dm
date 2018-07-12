//This is an uguu head restoration surgery TOTALLY not yoinked from chinsky's limb reattacher

/datum/surgery_step/head
	priority = 1
	can_infect = 0
	allowed_species = list("Synthetic", "Early Synthetic")
	var/reattach_step

/datum/surgery_step/head/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected)
		return 0
	if(!(affected.status & LIMB_DESTROYED))
		return 0
	if(affected.body_part != HEAD)
		return 0
	if(affected.limb_replacement_stage == reattach_step)
		return 1

/datum/surgery_step/head/peel
	allowed_tools = list(
	/obj/item/tool/surgery/retractor = 100,           \
	/obj/item/tool/crowbar = 75,              \
	/obj/item/tool/kitchen/utensil/fork = 50, \
	)

	min_duration = 30
	max_duration = 40
	reattach_step = 0


/datum/surgery_step/head/peel/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts peeling back tattered flesh where [target]'s head used to be with \the [tool].</span>", \
	"<span class='notice'>You start peeling back tattered flesh where [target]'s head used to be with \the [tool].</span>")
	..()

/datum/surgery_step/head/peel/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] peels back tattered flesh where [target]'s head used to be with \the [tool].</span>",	\
	"<span class='notice'>You peel back tattered flesh where [target]'s head used to be with \the [tool].</span>")
	affected.limb_replacement_stage = 1

/datum/surgery_step/head/peel/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, ripping [target]'s [affected.display_name] open!</span>", \
		"<span class='warning'>Your hand slips,  ripping [target]'s [affected.display_name] open!</span>")
		affected.createwound(CUT, 10)
		affected.update_wounds()


/datum/surgery_step/head/shape
	allowed_tools = list(
	/obj/item/tool/surgery/FixOVein = 100,         \
	/obj/item/stack/cable_coil = 75,         \
	/obj/item/device/assembly/mousetrap = 10
	)

	min_duration = 60
	max_duration = 80
	reattach_step = 1

/datum/surgery_step/head/shape/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] is beginning to reshape [target]'s esophagal and vocal region with \the [tool].</span>", \
	"<span class='notice'>You start to reshape [target]'s head esophagal and vocal region with \the [tool].</span>")
	..()

/datum/surgery_step/head/shape/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and tissue to something anatomically recognizable where [target]'s head used to be with \the [tool].</span>")
	affected.limb_replacement_stage = 2

/datum/surgery_step/head/shape/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, further rending flesh on [target]'s neck!</span>", \
		"<span class='warning'>Your hand slips, further rending flesh on [target]'s neck!</span>")
		target.apply_damage(10, BRUTE, affected)
		target.updatehealth()



/datum/surgery_step/head/suture
	allowed_tools = list(
	/obj/item/tool/surgery/hemostat = 100, \
	/obj/item/stack/cable_coil = 60, \
	/obj/item/tool/surgery/FixOVein = 80
	)

	min_duration = 60
	max_duration = 80
	reattach_step = 2

/datum/surgery_step/head/suture/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] is stapling and suturing flesh into place in [target]'s esophagal and vocal region with \the [tool].</span>", \
	"<span class='notice'>You start to staple and suture flesh into place in [target]'s esophagal and vocal region with \the [tool].</span>")
	..()

/datum/surgery_step/head/suture/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has finished stapling [target]'s neck into place with \the [tool].</span>",	\
	"<span class='notice'>You have finished stapling [target]'s neck into place with \the [tool].</span>")
	affected.limb_replacement_stage = 3

/datum/surgery_step/head/suture/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, ripping apart flesh on [target]'s neck!</span>", \
		"<span class='warning'>Your hand slips, ripping apart flesh on [target]'s neck!</span>")
		target.apply_damage(10, BRUTE, affected)
		target.updatehealth()



/datum/surgery_step/head/prepare
	allowed_tools = list(
	/obj/item/tool/surgery/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/tool/lighter = 50,    \
	/obj/item/tool/weldingtool = 25
	)

	min_duration = 60
	max_duration = 80
	reattach_step = 3

/datum/surgery_step/head/prepare/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts adjusting area around [target]'s neck with \the [tool].</span>", \
	"<span class='notice'>You start adjusting area around [target]'s neck with \the [tool].</span>")
	..()

/datum/surgery_step/head/prepare/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has finished adjusting the area around [target]'s neck with \the [tool].</span>",	\
	"<span class='notice'>You have finished adjusting the area around [target]'s neck with \the [tool].</span>")
	affected.limb_replacement_stage = 0
	affected.status |= LIMB_AMPUTATED
	affected.setAmputatedTree()

/datum/surgery_step/head/prepare/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.parent)
		affected = affected.parent
		user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s neck!</span>", \
		"<span class='warning'>Your hand slips, searing [target]'s [affected.display_name]!</span>")
		target.apply_damage(10, BURN, affected)
		target.updatehealth()



/datum/surgery_step/head/attach
	allowed_tools = list(/obj/item/limb/head/synth = 100)
	can_infect = 0
	min_duration = 60
	max_duration = 80
	reattach_step = 0

/datum/surgery_step/head/attach/can_use(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		if(affected.status & LIMB_AMPUTATED)
			return 1

/datum/surgery_step/head/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts attaching [tool] to [target]'s reshaped neck.</span>", \
	"<span class='notice'>You start attaching [tool] to [target]'s reshaped neck.</span>")
	..()

/datum/surgery_step/head/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has attached [target]'s head to the body.</span>",	\
	"<span class='notice'>You have attached [target]'s head to the body.</span>")

	//Update our dear victim to have a head again

	var/obj/item/limb/head/synth/B = tool

	affected.robotize()
	target.updatehealth()
	target.update_body()
	target.UpdateDamageIcon()

	//Prepare mind datum
	if(B.brainmob.mind)
		B.brainmob.mind.transfer_to(target)

	//Deal with the head item properly
	user.temp_drop_inv_item(B)
	cdel(B)

/datum/surgery_step/head/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s neck!</span>", \
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s neck!</span>")
	target.apply_damage(10, BRUTE, affected, sharp = 1)
	target.updatehealth()
