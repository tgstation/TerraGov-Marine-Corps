//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/fix_vein
	allowed_tools = list(
	/obj/item/tool/surgery/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = FIXVEIN_MIN_DURATION
	max_duration = FIXVEIN_MAX_DURATION

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(affected.surgery_open_stage >= 2)
		for(var/datum/wound/W in affected.wounds)
			if(W.internal)
				return 1

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts patching the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>" , \
	"<span class='notice'>You start patching the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has patched the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You have patched the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>")

	for(var/datum/wound/W in affected.wounds)
		if(W.internal)
			affected.wounds -= W
			affected.update_damages()
	if(ishuman(user) && prob(40))
		user:bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")
	affected.take_damage(5, 0)
	target.updatehealth()
