

/datum/surgery_step/necro
	priority = 1
	var/necro_step

/datum/surgery_step/necro/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(target_zone == "mouth" || target_zone == "eyes")
		return 0

	return affected.surgery_open_stage == 2 && (affected.status & LIMB_NECROTIZED) && affected.necro_surgery_stage == necro_step


/datum/surgery_step/necro/fix_dead_tissue //Debridement

	allowed_tools = list(
		/obj/item/tool/surgery/scalpel/manager = 0,			\
		/obj/item/tool/surgery/scalpel = 100,		\
		/obj/item/tool/kitchen/knife = 75,	\
		/obj/item/shard = 50, 		\
	)

	can_infect = 1
	blood_level = 1

	min_duration = NECRO_REMOVE_MIN_DURATION
	max_duration = NECRO_REMOVE_MAX_DURATION
	necro_step = 0

/datum/surgery_step/necro/fix_dead_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool].</span>" , \
	"<span class='notice'>You start cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("The pain in [affected.display_name] is unbearable!", 1)
	..()

/datum/surgery_step/necro/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You have cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.necro_surgery_stage = 1

/datum/surgery_step/necro/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20, 1)
	affected.update_wounds()

/datum/surgery_step/necro/treat_necrosis

	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100, \
	/obj/item/stack/medical/bruise_pack = 20,          \
	)

	can_infect = 0
	blood_level = 0

	min_duration = NECRO_TREAT_MIN_DURATION
	max_duration = NECRO_TREAT_MAX_DURATION
	necro_step = 1

/datum/surgery_step/necro/treat_necrosis/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts applying \the [tool] on the affected tissue in [target]'s [affected.display_name].</span>" , \
	"<span class='notice'>You start applying \the [tool] on the affected tissue in [target]'s [affected.display_name].</span>")
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!", 1)
	..()

/datum/surgery_step/necro/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	affected.status &= ~LIMB_NECROTIZED
	target.update_body()

	user.visible_message("<span class='notice'>[user] applies \the [tool] on the affected tissue in [target]'s [affected.display_name].</span>", \
	"<span class='notice'>You apply \the [tool] on the affected tissue in [target]'s [affected.display_name].</span>")
	affected.necro_surgery_stage = 0

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, applying \the [tool] to the wrong place in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, applying \the [tool] to the wrong place in [target]'s [affected.display_name]!</span>")
