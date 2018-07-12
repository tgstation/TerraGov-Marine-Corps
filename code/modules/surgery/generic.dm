//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic
	can_infect = 1
	var/open_step

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(target_zone == "eyes" || target_zone == "mouth") //There are specific steps for eye surgery and face surgery
		return 0
	if(!affected)
		return 0
	if(affected.status & LIMB_DESTROYED)
		return 0
	if(!isnull(open_step) && affected.surgery_open_stage != open_step)
		return 0
	if(target_zone == "head" && target.species && (target.species.flags & IS_SYNTHETIC))
		return 1
	if(affected.status & LIMB_ROBOT)
		return 0
	if(isYautja(target) && !isYautja(user))
		return 0
	return 1


/datum/surgery_step/generic/incision_manager
	priority = 0.1 //Attempt before generic scalpel step
	allowed_tools = list(
	/obj/item/tool/surgery/scalpel/manager = 100
	)

	min_duration = INCISION_MANAGER_MIN_DURATION
	max_duration = INCISION_MANAGER_MAX_DURATION
	open_step = 0

/datum/surgery_step/generic/incision_manager/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts to construct a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start to construct a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("You feel a horrible, searing pain in your [affected.display_name] as it is pushed apart!",1)
	..()

/datum/surgery_step/generic/incision_manager/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has constructed a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have constructed a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>",)
	affected.surgery_open_stage = 1

	if(istype(target) && !(target.species.flags & NO_BLOOD))
		affected.status |= LIMB_BLEEDING

	affected.createwound(CUT, 1)
	affected.clamp() //Hemostat function, clamp bleeders
	affected.surgery_open_stage = 2 //Can immediately proceed to other surgery steps
	target.updatehealth()

/datum/surgery_step/generic/incision_manager/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	affected.createwound(BURN, 15)
	affected.update_wounds()



/datum/surgery_step/generic/cut_with_laser
	priority = 0.1 //Attempt before generic scalpel step
	allowed_tools = list(
	/obj/item/tool/surgery/scalpel/laser3 = 95, \
	/obj/item/tool/surgery/scalpel/laser2 = 85, \
	/obj/item/tool/surgery/scalpel/laser1 = 75, \
	/obj/item/weapon/energy/sword = 5
	)

	min_duration = 60
	max_duration = 80
	open_step = 0

/datum/surgery_step/generic/cut_with_laser/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts the bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start the bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("You feel a horrible, searing pain in your [affected.display_name]!", 1)
	..()

/datum/surgery_step/generic/cut_with_laser/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has made a bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have made a bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>")
	//Could be cleaner
	affected.surgery_open_stage = 1

	if(istype(target) && !(target.species.flags & NO_BLOOD))
		affected.status |= LIMB_BLEEDING

	affected.createwound(CUT, 1)
	affected.clamp() //Hemostat function, clamp bleeders
	//spread_germs_to_organ(affected, user) //I don't see the reason for infection with a clean laser incision, when scalpel or ICS is fine
	affected.update_wounds()

/datum/surgery_step/generic/cut_with_laser/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips as the blade sputters, searing a long gash in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips as the blade sputters, searing a long gash in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 7.5)
	affected.createwound(BURN, 12.5)
	affected.update_wounds()



/datum/surgery_step/generic/cut_open
	allowed_tools = list(
	/obj/item/tool/surgery/scalpel = 100,         \
	/obj/item/tool/kitchen/knife = 75,     \
	/obj/item/shard = 50,            \
	/obj/item/weapon/combat_knife = 25,     \
	/obj/item/weapon/throwing_knife = 15,   \
	/obj/item/weapon/claymore/mercsword = 1
	)

	min_duration = 60
	max_duration = 80
	open_step = 0

/datum/surgery_step/generic/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.display_name]!", 1)
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [affected.display_name] with \the [tool].</span>",)
	affected.surgery_open_stage = 1

	if(istype(target) && !(target.species.flags & NO_BLOOD))
		affected.status |= LIMB_BLEEDING

	affected.createwound(CUT, 1)
	target.updatehealth()

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [affected.display_name] in the wrong place with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [affected.display_name] in the wrong place with \the [tool]!</span>")
	affected.createwound(CUT, 10)
	affected.update_wounds()



/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
	/obj/item/tool/surgery/hemostat = 100,         \
	/obj/item/stack/cable_coil = 75,         \
	/obj/item/device/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60

/datum/surgery_step/generic/clamp_bleeders/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return affected.surgery_open_stage && (affected.status & LIMB_BLEEDING)

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start clamping bleeders in [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("The pain in your [affected.display_name] is maddening!", 1)
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [affected.display_name] with \the [tool].</span>",	\
	"<span class='notice'>You clamp bleeders in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.clamp()
	spread_germs_to_organ(affected, user)

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",)
	affected.createwound(CUT, 10)
	affected.update_wounds()



/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
	/obj/item/tool/surgery/retractor = 100,          \
	/obj/item/tool/crowbar = 75,             \
	/obj/item/tool/kitchen/utensil/fork = 50
	)

	min_duration = 30
	max_duration = 40
	open_step = 1

/datum/surgery_step/generic/retract_skin/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(target_zone == "groin")
		user.visible_message("<span class='notice'>[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool].</span>", \
		"<span class='notice'>You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] starts to pry open the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You start to pry open the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("It feels like the skin on your [affected.display_name] is on fire!", 1)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(target_zone == "chest")
		user.visible_message("<span class='notice'>[user] keeps the ribcage open on [target]'s torso with \the [tool].</span>", \
		"<span class='notice'>You keep the ribcage open on [target]'s torso with \the [tool].</span>")
	else if(target_zone == "groin")
		user.visible_message("<span class='notice'>[user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>", \
		"<span class='notice'>You keep the incision open on [target]'s lower abdomen with \the [tool].</span>")
	else
		user.visible_message("<span class='notice'>[user] keeps the incision open on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You keep the incision open on [target]'s [affected.display_name] with \the [tool].</span>")
	affected.surgery_open_stage = 2

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(target_zone == "chest")
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>", \
		"<span class='warning'>Your hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>")
	if(target_zone == "groin")
		user.visible_message("<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!</span>", \
		"<span class='warning'>Your hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!</span>")
	else
		user.visible_message("<span class='warning'>[user]'s hand slips, tearing the edges of the incision on [target]'s [affected.display_name] with \the [tool]!</span>", \
		"<span class='warning'>Your hand slips, tearing the edges of the incision on [target]'s [affected.display_name] with \the [tool]!</span>")
	target.apply_damage(12, BRUTE, affected, sharp = 1)
	affected.update_wounds()


/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/tool/surgery/cautery = 100,         \
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/tool/lighter = 50,    \
	/obj/item/tool/weldingtool = 25
	)

	min_duration = CAUTERY_MIN_DURATION
	max_duration = CAUTERY_MAX_DURATION

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return affected.surgery_open_stage == 1 || affected.surgery_open_stage == 2

/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] is beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].</span>" , \
	"<span class='notice'>You are beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("Your [affected.display_name] is being burned!", 1)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	affected.surgery_open_stage = 0
	affected.germ_level = 0
	affected.status &= ~LIMB_BLEEDING

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>")
	target.apply_damage(3, BURN, affected)
	target.updatehealth()
