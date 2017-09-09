//Procedures in this file: Eye mending surgery
//////////////////////////////////////////////////////////////////
//						EYE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/eye
	priority = 2
	can_infect = 1

/datum/surgery_step/eye/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(!affected)
		return 0

	var/datum/organ/internal/eyes = target.internal_organs_by_name["eyes"]

	return target_zone == "eyes" && eyes

/datum/surgery_step/eye/cut_open
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/eye/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..()

/datum/surgery_step/eye/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	target.op_stage.is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts to separate the cornea on [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You start to separate the cornea on [target]'s eyes with \the [tool].</span>")
	..()

/datum/surgery_step/eye/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, stop
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] has separated the cornea on [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You have separated the cornea on [target]'s eyes with \the [tool].</span>",)
	target.op_stage.eyes = 1
	target.blinded += 1.5

/datum/surgery_step/eye/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/internal/eyes/eyes = target.internal_organs_by_name["eyes"]
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s eyes with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, slicing [target]'s eyes with \the [tool]!</span>" )
	affected.createwound(CUT, 10)
	eyes.take_damage(5, 0)
	target.updatehealth()
	affected.update_wounds()

/datum/surgery_step/eye/lift_eyes
	allowed_tools = list(
	/obj/item/weapon/retractor = 100,          \
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 30
	max_duration = 40

/datum/surgery_step/eye/lift_eyes/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 1

/datum/surgery_step/eye/lift_eyes/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	target.op_stage.is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts lifting the cornea from [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You start lifting the cornea from [target]'s eyes with \the [tool].</span>")
	..()

/datum/surgery_step/eye/lift_eyes/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, stop
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] has lifted the cornea from [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You have lifted the cornea from [target]'s eyes with \the [tool].</span>" )
	target.op_stage.eyes = 2

/datum/surgery_step/eye/lift_eyes/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/internal/eyes/eyes = target.internal_organs_by_name["eyes"]
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging [target]'s eyes with \the [tool]!</span>")
	target.apply_damage(10, BRUTE, affected)
	eyes.take_damage(5, 0)
	target.updatehealth()

/datum/surgery_step/eye/mend_eyes
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,         \
	/obj/item/stack/cable_coil = 75,         \
	/obj/item/device/assembly/mousetrap = 10 //I don't know. Don't ask me. But I'm leaving it because hilarity.
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/eye/mend_eyes/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.eyes == 2

/datum/surgery_step/eye/mend_eyes/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	target.op_stage.is_same_target = affected
	user.visible_message("<span class='notice'>[user] starts mending the nerves and lenses in [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You start mending the nerves and lenses in [target]'s eyes with the [tool].</span>")
	..()

/datum/surgery_step/eye/mend_eyes/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, stop
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	user.visible_message("<span class='notice'>[user] mends the nerves and lenses in [target]'s with \the [tool].</span>" ,	\
	"<span class='notice'>You mend the nerves and lenses in [target]'s with \the [tool].</span>")
	target.op_stage.eyes = 3

/datum/surgery_step/eye/mend_eyes/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/internal/eyes/eyes = target.internal_organs_by_name["eyes"]
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, stabbing \the [tool] into [target]'s eye!</span>", \
	"<span class='warning'>Your hand slips, stabbing \the [tool] into [target]'s eye!</span>")
	target.apply_damage(10, BRUTE, affected, sharp = 1)
	eyes.take_damage(5, 0)
	target.updatehealth()

/datum/surgery_step/eye/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/flame/lighter = 50,    \
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/eye/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..()

/datum/surgery_step/eye/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	target.op_stage.is_same_target = affected
	user.visible_message("<span class='notice'>[user] is beginning to cauterize the incision around [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You are beginning to cauterize the incision around [target]'s eyes with \the [tool].</span>")

/datum/surgery_step/eye/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(target.op_stage.is_same_target != affected) //We are not aiming at the same organ as when be begun, stop
		user << "<span class='warning'><b>You failed to start the surgery.</b> Aim at the same organ as the one that you started working on originally.</span>"
		return
	var/datum/organ/internal/eyes/eyes = target.internal_organs_by_name["eyes"]
	user.visible_message("<span class='notice'>[user] cauterizes the incision around [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision around [target]'s eyes with \the [tool].</span>")
	if(target.op_stage.eyes == 3)
		target.disabilities &= ~NEARSIGHTED
		target.sdisabilities &= ~BLIND
		eyes.damage = 0
	target.op_stage.eyes = 0

/datum/surgery_step/eye/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/internal/eyes/eyes = target.internal_organs_by_name["eyes"]
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, searing [target]'s eyes with \the [tool]!</span>")
	target.apply_damage(5, BURN, affected)
	eyes.take_damage(5, 0)
	target.updatehealth()
