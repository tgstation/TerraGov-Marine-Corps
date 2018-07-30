//Procedures in this file: Eye mending surgery
//////////////////////////////////////////////////////////////////
//						EYE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/eye
	priority = 2
	can_infect = 1
	var/eye_step

/datum/surgery_step/eye/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!affected || (affected.status & DESTROYED))
		return 0

	if(target_zone != "eyes")
		return 0

	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	if(!E)
		return 0
	if(E.eye_surgery_stage == eye_step)
		return 1

/datum/surgery_step/eye/cut_open
	allowed_tools = list(
	/obj/item/tool/surgery/scalpel = 100,		\
	/obj/item/tool/kitchen/knife = 75,	\
	/obj/item/shard = 50, 		\
	)

	min_duration = EYE_CUT_MIN_DURATION
	max_duration = EYE_CUT_MAX_DURATION
	eye_step = 0

/datum/surgery_step/eye/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts to separate the cornea on [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You start to separate the cornea on [target]'s eyes with \the [tool].</span>")
	..()

/datum/surgery_step/eye/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has separated the cornea on [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You have separated the cornea on [target]'s eyes with \the [tool].</span>",)
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	E.eye_surgery_stage = 1
	target.disabilities |= NEARSIGHTED // code\#define\mobs.dm

/datum/surgery_step/eye/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing [target]'s eyes with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, slicing [target]'s eyes with \the [tool]!</span>" )
	affected.createwound(CUT, 10)
	E.take_damage(5, 0)
	target.updatehealth()
	affected.update_wounds()


/datum/surgery_step/eye/lift_eyes
	allowed_tools = list(
	/obj/item/tool/surgery/retractor = 100,          \
	/obj/item/tool/kitchen/utensil/fork = 50
	)

	min_duration = EYE_LIFT_MIN_DURATION
	max_duration = EYE_LIFT_MAX_DURATION
	eye_step = 1

/datum/surgery_step/eye/lift_eyes/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts lifting the cornea from [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You start lifting the cornea from [target]'s eyes with \the [tool].</span>")
	..()

/datum/surgery_step/eye/lift_eyes/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has lifted the cornea from [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You have lifted the cornea from [target]'s eyes with \the [tool].</span>" )
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	E.eye_surgery_stage = 2

/datum/surgery_step/eye/lift_eyes/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/datum/internal_organ/eyes/eyes = target.internal_organs_by_name["eyes"]
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging [target]'s eyes with \the [tool]!</span>")
	target.apply_damage(10, BRUTE, affected)
	eyes.take_damage(5, 0)
	target.updatehealth()

/datum/surgery_step/eye/mend_eyes
	allowed_tools = list(
	/obj/item/tool/surgery/hemostat = 100,         \
	/obj/item/stack/cable_coil = 75,         \
	/obj/item/device/assembly/mousetrap = 10 //I don't know. Don't ask me. But I'm leaving it because hilarity.
	)

	min_duration = EYE_MEND_MIN_DURATION
	max_duration = EYE_MEND_MAX_DURATION
	eye_step = 2

/datum/surgery_step/eye/mend_eyes/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts mending the nerves and lenses in [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You start mending the nerves and lenses in [target]'s eyes with the [tool].</span>")
	..()

/datum/surgery_step/eye/mend_eyes/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] mends the nerves and lenses in [target]'s with \the [tool].</span>" ,	\
	"<span class='notice'>You mend the nerves and lenses in [target]'s with \the [tool].</span>")
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	E.eye_surgery_stage = 3

/datum/surgery_step/eye/mend_eyes/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	user.visible_message("<span class='warning'>[user]'s hand slips, stabbing \the [tool] into [target]'s eye!</span>", \
	"<span class='warning'>Your hand slips, stabbing \the [tool] into [target]'s eye!</span>")
	target.apply_damage(10, BRUTE, affected, sharp = 1)
	E.take_damage(5, 0)
	target.updatehealth()


/datum/surgery_step/eye/cauterize
	allowed_tools = list(
	/obj/item/tool/surgery/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/tool/lighter = 50,    \
	/obj/item/tool/weldingtool = 25
	)
	
	min_duration = EYE_CAUTERISE_MIN_DURATION
	max_duration = EYE_CAUTERISE_MAX_DURATION
	eye_step = 3

/datum/surgery_step/eye/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] is beginning to cauterize the incision around [target]'s eyes with \the [tool].</span>" , \
	"<span class='notice'>You are beginning to cauterize the incision around [target]'s eyes with \the [tool].</span>")

/datum/surgery_step/eye/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] cauterizes the incision around [target]'s eyes with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision around [target]'s eyes with \the [tool].</span>")
	target.disabilities &= ~NEARSIGHTED
	target.sdisabilities &= ~BLIND
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	E.damage = 0
	E.eye_surgery_stage = 0


/datum/surgery_step/eye/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/datum/internal_organ/eyes/E = target.internal_organs_by_name["eyes"]
	user.visible_message("<span class='warning'>[user]'s hand slips, searing [target]'s eyes with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, searing [target]'s eyes with \the [tool]!</span>")
	target.apply_damage(5, BURN, affected)
	E.take_damage(5, 0)
	target.updatehealth()
