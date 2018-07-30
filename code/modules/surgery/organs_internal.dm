// Internal surgeries.
/datum/surgery_step/internal
	priority = 3
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	return affected.surgery_open_stage == (affected.encased ? 3 : 2)

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/internal/remove_embryo
	allowed_tools = list(
	/obj/item/tool/surgery/hemostat = 100,           \
	/obj/item/tool/wirecutters = 75,         \
	/obj/item/tool/kitchen/utensil/fork = 20
	)
	blood_level = 2

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_embryo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(target_zone != "chest")
		return 0
	if(..())
		var/obj/item/alien_embryo/A = locate() in target
		if(A)
			return 1

/datum/surgery_step/internal/remove_embryo/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts to pull something out from [target]'s ribcage with \the [tool].</span>", \
					"<span class='notice'>You start to pull something out from [target]'s ribcage with \the [tool].</span>")
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/internal/remove_embryo/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/obj/item/alien_embryo/A = locate() in target
	if(A)
		user.visible_message("<span class='warning'>[user] rips a wriggling parasite out of [target]'s ribcage!</span>",
							 "<span class='warning'>You rip a wriggling parasite out of [target]'s ribcage!</span>")
		var/mob/living/carbon/Xenomorph/Larva/L = locate() in target //the larva was fully grown, ready to burst.
		if(L)
			L.forceMove(target.loc)
			cdel(A)
		else
			A.forceMove(target.loc)
			target.status_flags &= ~XENO_HOST

	affected.createwound(CUT, rand(0,20), 1)
	target.updatehealth()
	affected.update_wounds()


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
	/obj/item/stack/medical/advanced/bruise_pack= 100, \
	/obj/item/stack/medical/bruise_pack = 20,          \
	/obj/item/stack/medical/bruise_pack/tajaran = 70,  \
	)

	min_duration = FIX_ORGAN_MIN_DURATION
	max_duration = FIX_ORGAN_MAX_DURATION

/datum/surgery_step/internal/fix_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		if(affected.body_part == HEAD)//brain and eye damage is fixed by a separate surgery
			return 0
		for(var/datum/internal_organ/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic != ORGAN_ROBOT)
				return 1


/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I && I.damage > 0 && I.robotic != ORGAN_ROBOT)
			user.visible_message("<span class='notice'>[user] starts treating damage to [target]'s [I.name] with [tool_name].</span>", \
			"<span class='notice'>You start treating damage to [target]'s [I.name] with [tool_name].</span>" )

	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/fix_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	var/tool_name = "\the [tool]"
	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "regenerative membrane"
	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "the bandaid"

	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I && I.damage > 0 && I.robotic != ORGAN_ROBOT)
			user.visible_message("<span class='notice'>[user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
			"<span class='notice'>You treat damage to [target]'s [I.name] with [tool_name].</span>" )
			I.damage = 0

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>")
	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack))
		dam_amt = 5
		target.adjustToxLoss(10)
		affected.createwound(CUT, 5)

	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I && I.damage > 0)
			I.take_damage(dam_amt,0)
	target.updatehealth()
	affected.update_wounds()



/datum/surgery_step/internal/fix_organ_robotic //For artificial organs
	allowed_tools = list(
	/obj/item/stack/nanopaste = 100,   \
	/obj/item/tool/surgery/bonegel = 30,     \
	/obj/item/tool/screwdriver = 70, \
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/fix_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		if(affected.body_part == HEAD)//brain and eye damage is fixed by a separate surgery
			return 0
		for(var/datum/internal_organ/I in affected.internal_organs)
			if(I.damage > 0 && I.robotic == ORGAN_ROBOT)
				return 1

/datum/surgery_step/internal/fix_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I && I.damage > 0 && I.robotic == ORGAN_ROBOT)
			user.visible_message("<span class='notice'>[user] starts mending the damage to [target]'s [I.name]'s mechanisms.</span>", \
			"<span class='notice'>You start mending the damage to [target]'s [I.name]'s mechanisms.</span>" )

	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/fix_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I && I.damage > 0 && I.robotic == ORGAN_ROBOT)
			user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool].</span>", \
			"<span class='notice'>You repair [target]'s [I.name] with [tool].</span>" )
			I.damage = 0

/datum/surgery_step/internal/fix_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!</span>")

	target.adjustToxLoss(5)
	affected.createwound(CUT, 5)

	for(var/datum/internal_organ/I in affected.internal_organs)
		if(I)
			I.take_damage(rand(3, 5), 0)
	target.updatehealth()
	affected.update_wounds()



/datum/surgery_step/internal/detach_organ
	allowed_tools = list()/*
	/obj/item/tool/surgery/scalpel = 100,		\
	/obj/item/tool/kitchen/knife = 75,	\
	/obj/item/shard = 50, 		\
	)*/

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/detach_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!..())
		return 0

	if(checks_only) //Second call of can_use(), just before calling end_step().
		if(affected.surgery_organ)
			var/datum/internal_organ/I = target.internal_organs_by_name[affected.surgery_organ]
			if(I && !I.cut_away)
				return 1
	else
		var/list/attached_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/datum/internal_organ/I = target.internal_organs_by_name[organ]
			if(!I.cut_away && I.parent_limb == target_zone)
				attached_organs |= organ

		var/organ_to_detach = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
		if(!organ_to_detach)
			return 0
		if(affected.surgery_organ)
			return 0

		var/datum/internal_organ/I = target.internal_organs_by_name[organ_to_detach]
		if(!I || I.cut_away)
			return 0

		if(..())
			affected.surgery_organ = organ_to_detach
			return 1

/datum/surgery_step/internal/detach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts to separate [target]'s [affected.surgery_organ] with \the [tool].</span>", \
	"<span class='notice'>You start to separate [target]'s [affected.surgery_organ] with \the [tool].</span>" )
	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/detach_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has separated [target]'s [affected.surgery_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have separated [target]'s [affected.surgery_organ] with \the [tool].</span>")

	var/datum/internal_organ/I = target.internal_organs_by_name[affected.surgery_organ]
	I.cut_away = TRUE
	affected.surgery_organ = null

/datum/surgery_step/internal/detach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, rand(30, 50), 1)
	affected.update_wounds()
	affected.surgery_organ = null




/datum/surgery_step/internal/remove_organ
	allowed_tools = list()
	/*/obj/item/tool/surgery/hemostat = 100,           \
	/obj/item/tool/wirecutters = 75,         \
	/obj/item/tool/kitchen/utensil/fork = 20
	)*/

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!..())
		return 0

	if(checks_only) //Second call of can_use(), just before calling end_step().
		if(affected.surgery_organ)
			var/datum/internal_organ/I = target.internal_organs_by_name[affected.surgery_organ]
			if(I && I.cut_away)
				return 1
	else
		var/list/removable_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/datum/internal_organ/I = target.internal_organs_by_name[organ]
			if(I.cut_away && I.parent_limb == target_zone)
				removable_organs |= organ

		var/organ_to_remove = input(user, "Which organ do you want to remove?") as null|anything in removable_organs
		if(!organ_to_remove)
			return 0
		if(affected.surgery_organ) //already working on an organ
			return 0

		var/datum/internal_organ/I = target.internal_organs_by_name[organ_to_remove]
		if(!I || !I.cut_away)
			return 0

		if(..())
			affected.surgery_organ = organ_to_remove
			return 1

/datum/surgery_step/internal/remove_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts removing [target]'s [affected.surgery_organ] with \the [tool].</span>", \
	"<span class='notice'>You start removing [target]'s [affected.surgery_organ] with \the [tool].</span>")
	target.custom_pain("Someone's ripping out your [affected.surgery_organ]!", 1)
	..()

/datum/surgery_step/internal/remove_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has removed [target]'s [affected.surgery_organ] with \the [tool].</span>", \
	"<span class='notice'>You have removed [target]'s [affected.surgery_organ] with \the [tool].</span>")

	//Extract the organ!
	if(affected.surgery_organ)

		var/datum/internal_organ/I = target.internal_organs_by_name[affected.surgery_organ]

		var/obj/item/organ/O
		if(I && istype(I))
			O = I.remove(user)
			if(O && istype(O))

				//Stop the organ from continuing to reject.
				O.organ_data.rejecting = null

				//Transfer over some blood data, if the organ doesn't have data.
				var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in O.reagents.reagent_list
				if(!organ_blood || !organ_blood.data["blood_DNA"])
					target.take_blood(O, 5)

				//Kinda redundant, but I'm getting some buggy behavior.
				target.internal_organs_by_name[affected.surgery_organ] = null
				target.internal_organs_by_name -= affected.surgery_organ
				target.internal_organs -= O.organ_data
				affected.internal_organs -= O.organ_data
				O.removed(target,user)

		affected.surgery_organ = null

/datum/surgery_step/internal/remove_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 20)
	affected.update_wounds()
	affected.surgery_organ = null



/datum/surgery_step/internal/replace_organ
	allowed_tools = list(/obj/item/organ = 100)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/replace_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)

	var/obj/item/organ/O = tool

	var/organ_compatible
	var/organ_missing

	if(!istype(O))
		return 0

	if(!target.species)
		user << "<span class='warning'>You have no idea what species this person is. Report this on the bug tracker.</span>"
		return SPECIAL_SURGERY_INVALID

	var/o_is = (O.gender == PLURAL) ? "are"   : "is"
	var/o_a =  (O.gender == PLURAL) ? ""      : "a "
	var/o_do = (O.gender == PLURAL) ? "don't" : "doesn't"

	if(target.species.has_organ[O.organ_tag])

		if(!O.health)
			user << "<span class='warning'>\The [O.organ_tag] [o_is] in no state to be anted.</span>"
			return SPECIAL_SURGERY_INVALID

		if(!target.internal_organs_by_name[O.organ_tag])
			organ_missing = 1
		else
			user << "<span class='warning'>\The [target] already has [o_a][O.organ_tag].</span>"
			return SPECIAL_SURGERY_INVALID

		if(O.organ_data && affected.name == O.organ_data.parent_limb)
			organ_compatible = 1
		else
			user << "<span class='warning'>\The [O.organ_tag] [o_do] normally go in \the [affected.display_name].</span>"
			return SPECIAL_SURGERY_INVALID
	else
		user << "<span class='warning'>You're pretty sure [target.species.name_plural] don't normally have [o_a][O.organ_tag].</span>"
		return SPECIAL_SURGERY_INVALID

	return ..() && organ_missing && organ_compatible

/datum/surgery_step/internal/replace_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts transplanting \the [tool] into [target]'s [affected.display_name].</span>", \
	"<span class='notice'>You start transplanting \the [tool] into [target]'s [affected.display_name].</span>")
	target.custom_pain("Someone's rooting around in your [affected.display_name]!", 1)
	..()

/datum/surgery_step/internal/replace_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has transplanted \the [tool] into [target]'s [affected.display_name].</span>", \
	"<span class='notice'>You have transplanted \the [tool] into [target]'s [affected.display_name].</span>")
	user.temp_drop_inv_item(tool)
	var/obj/item/organ/O = tool

	if(istype(O))

		var/datum/reagent/blood/transplant_blood = locate(/datum/reagent/blood) in O.reagents.reagent_list
		if(!transplant_blood)
			O.organ_data.transplant_data = list()
			O.organ_data.transplant_data["species"]    = target.species.name
			O.organ_data.transplant_data["blood_type"] = target.dna.b_type
			O.organ_data.transplant_data["blood_DNA"]  = target.dna.unique_enzymes
		else
			O.organ_data.transplant_data = list()
			O.organ_data.transplant_data["species"]    = transplant_blood.data["species"]
			O.organ_data.transplant_data["blood_type"] = transplant_blood.data["blood_type"]
			O.organ_data.transplant_data["blood_DNA"]  = transplant_blood.data["blood_DNA"]

		O.organ_data.organ_holder = null
		O.organ_data.owner = target
		target.internal_organs |= O.organ_data
		affected.internal_organs |= O.organ_data
		target.internal_organs_by_name[O.organ_tag] = O.organ_data
		O.organ_data.cut_away = TRUE
		O.replaced(target)

	cdel(O)

/datum/surgery_step/internal/replace_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging \the [tool]!</span>")
	var/obj/item/organ/I = tool
	if(istype(I))
		I.organ_data.take_damage(rand(3, 5), 0)
	target.updatehealth()




/datum/surgery_step/internal/attach_organ
	allowed_tools = list(
	/obj/item/tool/surgery/FixOVein = 100, \
	/obj/item/stack/cable_coil = 75
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/attach_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(!..())
		return 0

	if(checks_only) //Second call of can_use(), just before calling end_step().
		if(affected.surgery_organ)
			var/datum/internal_organ/I = target.internal_organs_by_name[affected.surgery_organ]
			if(I && I.cut_away)
				return 1
	else
		var/list/removable_organs = list()
		for(var/organ in target.internal_organs_by_name)
			var/datum/internal_organ/I = target.internal_organs_by_name[organ]
			if(I.cut_away && I.parent_limb == target_zone)
				removable_organs |= organ

		var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
		if(!organ_to_replace)
			return 0

		if(affected.surgery_organ)
			return 0

		var/datum/internal_organ/I = target.internal_organs_by_name[organ_to_replace]
		if(!I || !I.cut_away)
			return 0

		if(..())
			affected.surgery_organ = organ_to_replace
			return 1

/datum/surgery_step/internal/attach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] begins reattaching [target]'s [affected.surgery_organ] with \the [tool].</span>", \
	"<span class='notice'>You start reattaching [target]'s [affected.surgery_organ] with \the [tool].</span>")
	target.custom_pain("Someone's digging needles into your [affected.surgery_organ]!", 1)
	..()

/datum/surgery_step/internal/attach_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [affected.surgery_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have reattached [target]'s [affected.surgery_organ] with \the [tool].</span>")

	var/datum/internal_organ/I = target.internal_organs_by_name[affected.surgery_organ]
	I.cut_away = FALSE
	affected.surgery_organ = null

/datum/surgery_step/internal/attach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 20)
	affected.update_wounds()
	affected.surgery_organ = null
