//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	return affected.surgery_open_stage == (affected.encased ? 3 : 2) && !(affected.status & LIMB_BLEEDING)

/datum/surgery_step/cavity/proc/get_max_wclass(datum/limb/affected)
	switch (affected.name)
		if("head")
			return 1
		if("chest")
			return 3
		if("groin")
			return 2
	return 0

/datum/surgery_step/cavity/proc/get_cavity(datum/limb/affected)
	switch (affected.name)
		if("head")
			return "cranial"
		if("chest")
			return "thoracic"
		if("groin")
			return "abdominal"
	return ""

/datum/surgery_step/cavity/make_space
	allowed_tools = list(
	/obj/item/tool/surgery/surgicaldrill = 100, \
	/obj/item/tool/pen = 75,            \
	/obj/item/stack/rods = 50
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return !affected.cavity && !affected.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>", \
	"<span class='notice'>You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>")
	target.custom_pain("The pain in your chest is living hell!", 1)
	affected.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>", \
	"<span class='notice'>You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>")

/datum/surgery_step/cavity/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	affected.update_wounds()



/datum/surgery_step/cavity/close_space
	allowed_tools = list(
	/obj/item/tool/surgery/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/tool/lighter = 50,    \
	/obj/item/tool/weldingtool = 25
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return affected.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].</span>", \
	"<span class='notice'>You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].</span>")
	target.custom_pain("The pain in your chest is living hell!",1)
	affected.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>")

/datum/surgery_step/cavity/close_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	affected.update_wounds()



/datum/surgery_step/cavity/place_item
	priority = 0 //Do NOT allow surgery items to go in here
	allowed_tools = list(/obj/item = 100)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return !istype(user,/mob/living/silicon/robot) && !affected.hidden && affected.cavity && tool.w_class <= get_max_wclass(affected)

/datum/surgery_step/cavity/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>", \
	"<span class='notice'>You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>" )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>", \
	"<span class='notice'>You put \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>")
	if(tool.w_class > get_max_wclass(affected)/2 && prob(50))
		user << "<span class='warning'>You tear some blood vessels trying to fit such a big object in this cavity.</span>"
		var/datum/wound/internal_bleeding/I = new (10)
		affected.wounds += I
		affected.owner.custom_pain("You feel something rip in your [affected.display_name]!", 1)
	user.drop_inv_item_to_loc(tool, target)
	affected.hidden = tool
	affected.cavity = 0

/datum/surgery_step/cavity/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	affected.update_wounds()



//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY				//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/cavity/implant_removal
	priority = 1
	allowed_tools = list(
	/obj/item/tool/surgery/hemostat = 100,           \
	/obj/item/tool/wirecutters = 75,         \
	/obj/item/tool/kitchen/utensil/fork = 20
	)

	min_duration = HEMOSTAT_REMOVE_MIN_DURATION
	max_duration = HEMOSTAT_REMOVE_MAX_DURATION

/datum/surgery_step/cavity/implant_removal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	var/datum/internal_organ/brain/sponge = target.internal_organs_by_name["brain"]
	//potential conflict with brain repair surgery
	return ..() && (target_zone != "head" || (!sponge || !sponge.damage || sponge.damage>20))

/datum/surgery_step/cavity/implant_removal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='notice'>[user] starts poking around inside the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You start poking around inside the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	target.custom_pain("The pain in your chest is living hell!", 1)
	..()

/datum/surgery_step/cavity/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.implants.len)

		var/obj/item/obj = affected.implants[1]
		user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You take [obj] out of incision on [target]'s [affected.display_name]s with \the [tool].</span>")
		affected.implants -= obj

		obj.loc = get_turf(target)
		if(istype(obj,/obj/item/implant))
			var/obj/item/implant/imp = obj
			imp.imp_in = null
			imp.implanted = 0

		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			H.sec_hud_set_implants()

	else if(affected.hidden)
		user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"\blue You take something out of incision on [target]'s [affected.display_name]s with \the [tool].</span>")
		affected.hidden.loc = get_turf(target)
		if(!affected.hidden.blood_DNA)
			affected.hidden.blood_DNA = list()
		affected.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
		affected.hidden.update_icon()
		affected.hidden = null

	else
		user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [affected.display_name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [affected.display_name].</span>")

/datum/surgery_step/cavity/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	if(affected.implants.len)
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if(prob(fail_prob))
			var/obj/item/I = affected.implants[1]
			if(istype(I,/obj/item/implant))
				var/obj/item/implant/imp = I
				user.visible_message("<span class='warning'>Something beeps inside [target]'s [affected.display_name]!</span>")
				playsound(imp.loc, 'sound/items/countdown.ogg', 25, 1)
				spawn(25)
					imp.activate()
	target.updatehealth()
	affected.update_wounds()
