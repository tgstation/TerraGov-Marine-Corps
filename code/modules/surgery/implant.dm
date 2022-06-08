//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1

/datum/surgery_step/cavity/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	return affected.surgery_open_stage == (affected.encased ? 3 : 2) && !(affected.limb_status & LIMB_BLEEDING)

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
		/obj/item/tool/surgery/surgicaldrill = 100,
		/obj/item/tool/pen = 75,
		/obj/item/stack/rods = 50,
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return !affected.cavity && !affected.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."), \
	span_notice("You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."))
	target.custom_pain("The pain in your chest is living hell!", 1)
	affected.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."), \
	span_notice("You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."))

/datum/surgery_step/cavity/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"))
	affected.createwound(CUT, 20)
	affected.update_wounds()



/datum/surgery_step/cavity/close_space
	allowed_tools = list(
		/obj/item/tool/surgery/cautery = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/tool/lighter = 50,
		/obj/item/tool/weldingtool = 25,
	)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return affected.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]."), \
	span_notice("You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]."))
	target.custom_pain("The pain in your chest is living hell!",1)
	affected.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool]."), \
	span_notice("You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool]."))

/datum/surgery_step/cavity/close_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"))
	affected.createwound(CUT, 20)
	affected.update_wounds()



/datum/surgery_step/cavity/place_item
	priority = 0 //Do NOT allow surgery items to go in here
	allowed_tools = list(/obj/item = 100)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	if(..())
		return !affected.hidden && affected.cavity && tool.w_class <= get_max_wclass(affected)

/datum/surgery_step/cavity/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity."), \
	span_notice("You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.") )
	target.custom_pain("The pain in your chest is living hell!",1)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity."), \
	span_notice("You put \the [tool] inside [target]'s [get_cavity(affected)] cavity."))
	if(tool.w_class > get_max_wclass(affected)/2 && prob(50))
		to_chat(user, span_warning("You tear some blood vessels trying to fit such a big object in this cavity."))
		new /datum/wound/internal_bleeding(10, affected)
		affected.owner.custom_pain("You feel something rip in your [affected.display_name]!", 1)
	user.transferItemToLoc(tool, target)
	affected.hidden = tool
	affected.cavity = 0

/datum/surgery_step/cavity/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"))
	affected.createwound(CUT, 20)
	affected.update_wounds()



//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY				//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/implant_removal
	priority = 1
	allowed_tools = list(
		/obj/item/tool/surgery/hemostat = 100,
		/obj/item/tool/wirecutters = 75,
		/obj/item/tool/kitchen/utensil/fork = 20,
	)

	min_duration = HEMOSTAT_REMOVE_MIN_DURATION
	max_duration = HEMOSTAT_REMOVE_MAX_DURATION

/datum/surgery_step/implant_removal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected, checks_only)
	return affected.surgery_open_stage >= 2

/datum/surgery_step/implant_removal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_notice("[user] starts poking around inside the incision on [target]'s [affected.display_name] with \the [tool]."), \
	span_notice("You start poking around inside the incision on [target]'s [affected.display_name] with \the [tool]."))
	target.custom_pain("The pain in your chest is living hell!", 1)
	target.balloon_alert_to_viewers("Checking...")
	..()

/datum/surgery_step/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	if(affected.implants.len)

		var/obj/item/implantfound = affected.implants[1]
		user.visible_message(span_notice("[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool]."), \
		span_notice("You take [implantfound] out of incision on [target]'s [affected.display_name]s with \the [tool]."))
		target.balloon_alert_to_viewers("Implant found")
		implantfound.unembed_ourself()

	else if(affected.hidden)
		user.visible_message(span_notice("[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool]."), \
		span_notice(" You take something out of incision on [target]'s [affected.display_name]s with \the [tool]."))
		target.balloon_alert_to_viewers("Shrapnel found")
		affected.hidden.loc = get_turf(target)
		affected.hidden.update_icon()
		affected.hidden = null

	else
		user.visible_message(span_notice("[user] could not find anything inside [target]'s [affected.display_name], and pulls \the [tool] out."), \
		span_notice("You could not find anything inside [target]'s [affected.display_name]."))
		target.balloon_alert_to_viewers("Nothing found")

/datum/surgery_step/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/limb/affected)
	user.visible_message(span_warning("[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!"))
	target.balloon_alert_to_viewers("Slipped!")
	affected.createwound(CUT, 20)
	if(affected.implants.len)
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if(prob(fail_prob))
			var/obj/item/I = affected.implants[1]
			if(istype(I,/obj/item/implant))
				var/obj/item/implant/imp = I
				user.visible_message(span_warning("Something beeps inside [target]'s [affected.display_name]!"))
				playsound(imp.loc, 'sound/items/countdown.ogg', 25, 1)
				addtimer(CALLBACK(imp, /obj/item/implant.proc/activate), 25)
	target.updatehealth()
	affected.update_wounds()
