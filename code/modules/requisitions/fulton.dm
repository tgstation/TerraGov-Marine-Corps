/obj/item/fulton_extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel. Anything not bolted down can be moved."
	icon = 'icons/obj/items/fulton.dmi'
	icon_state = "extraction_pack"
	item_state = "fulton"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	w_class = WEIGHT_CLASS_NORMAL
	tool_behaviour = TOOL_FULTON
	resistance_flags = RESIST_ALL
	///Reference to the balloon vis obj effect
	var/atom/movable/vis_obj/fulton_balloon/baloon
	var/obj/effect/fulton_extraction_holder/holder_obj
	/// How many times you can use the fulton before it goes poof
	var/uses = 3

/obj/item/fulton_extraction_pack/examine(mob/user)
	. = ..()
	. += "It has [uses] uses remaining."


/obj/item/fulton_extraction_pack/Initialize(mapload)
	. = ..()
	baloon = new()
	holder_obj = new()


/obj/item/fulton_extraction_pack/Destroy()
	QDEL_NULL(baloon)
	QDEL_NULL(holder_obj)
	return ..()


/obj/item/fulton_extraction_pack/proc/extract(atom/movable/spirited_away, mob/living/user)
	if(!do_checks(spirited_away, user))
		return
	do_extract(spirited_away, user)
	var/datum/export_report/export_report = spirited_away.supply_export(user.faction)
	if(export_report)
		SSpoints.export_history += export_report
	user.visible_message(span_notice("[user] finishes attaching [src] to [spirited_away] and activates it."),\
	span_notice("You attach the pack to [spirited_away] and activate it. This looks like it will yield [export_report.points ? export_report.points : "no"] point[export_report.points == 1 ? "" : "s"]."), null, 5)
	uses--
	if(uses < 1)
		user.temporarilyRemoveItemFromInventory(src) //Removes the item without qdeling it, qdeling it this early will break the rest of the procs
		moveToNullspace()

	qdel(spirited_away)


/obj/item/fulton_extraction_pack/proc/do_checks(atom/movable/spirited_away, mob/user)
	if(user.do_actions)
		return FALSE
	if(active)
		balloon_alert(user, "Fulton not ready")
		return FALSE
	user.visible_message(span_notice("[user] starts attaching [src] to [spirited_away]."),\
	span_notice("You start attaching the pack to [spirited_away]..."), null, 5)
	if(!do_after(user, 5 SECONDS, NONE, spirited_away))
		return FALSE
	if(!isturf(spirited_away.loc))
		balloon_alert(user, "Must extract on the ground")
		return FALSE
	if(spirited_away.anchored)
		balloon_alert(user, "Cannot extract anchored")
		return FALSE
	var/area/bathhouse = get_area(spirited_away)
	if(bathhouse.ceiling >= CEILING_OBSTRUCTED)
		balloon_alert(user, "Cannot extract indoors")
		return FALSE
	return TRUE


/obj/item/fulton_extraction_pack/proc/do_extract(atom/movable/spirited_away, mob/user)
	active = TRUE

	holder_obj.appearance = spirited_away.appearance
	holder_obj.forceMove(spirited_away.loc)
	if(spirited_away.anchored)
		spirited_away.anchored = FALSE
	if(isliving(spirited_away))
		ADD_TRAIT(spirited_away, TRAIT_IMMOBILE, type)
	spirited_away.moveToNullspace()
	baloon.icon_state = initial(baloon.icon_state)
	holder_obj.vis_contents += baloon

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(holder_obj), 'sound/items/fultext_deploy.ogg', 50, TRUE), 0.4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), get_turf(holder_obj), 'sound/items/fultext_launch.ogg', 50, TRUE), 7.4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(cleanup_extraction)), 8 SECONDS)

	flick("fulton_expand", baloon)
	baloon.icon_state = "fulton_balloon"
	animate(holder_obj, pixel_z = 0, time = 0.4 SECONDS)
	animate(pixel_z = 10, time = 2 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = SCREEN_PIXEL_SIZE, time = 1 SECONDS)


/obj/item/fulton_extraction_pack/proc/cleanup_extraction()
	holder_obj.moveToNullspace()
	holder_obj.pixel_z = initial(pixel_z)
	holder_obj.vis_contents -= baloon
	baloon.icon_state = initial(baloon.icon_state)
	if(uses < 1)
		qdel(src)
	active = FALSE


/obj/effect/fulton_extraction_holder
	name = "fulton extraction holder"
	desc = "You shouldn't see this."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


//Overrides.
/mob/living/carbon/xenomorph/fulton_act(mob/living/user, obj/item/I)
	if(!SSpoints)
		balloon_alert(user, "Failed to link with destination")
		return TRUE

	if(stat != DEAD)
		balloon_alert(user, "Target still alive")
		to_chat(user, span_warning("The extraction device buzzes, complaining. This one seems to be alive still."))
		return TRUE

	var/obj/item/fulton_extraction_pack/ext_pack = I
	ext_pack.extract(src, user)
	return TRUE

/mob/living/carbon/human/fulton_act(mob/living/user, obj/item/I)
	if(!can_sell_human_body(src, user.faction))
		balloon_alert(user, "High command not interested")
		return TRUE
	if(stat != DEAD)
		balloon_alert(user, "Target still alive")
		to_chat(user, span_warning("The extraction device buzzes, complaining. This one seems to be alive still."))
		return TRUE
	var/obj/item/fulton_extraction_pack/ext_pack = I
	ext_pack.extract(src, user)
	return TRUE


/obj/structure/table/fulton_act(mob/living/user, obj/item/I)
	if(!flipped)
		return FALSE //Place it in.
	balloon_alert(user, "Cannot extract")
	return TRUE


/obj/structure/closet/fulton_act(mob/living/user, obj/item/I)
	if(opened)
		return FALSE //Place it in.
	balloon_alert(user, "Cannot extract")
	return TRUE


/obj/structure/closet/crate/fulton_act(mob/living/user, obj/item/I)
	if(opened)
		return FALSE //Place it in.

	if(!SSpoints)
		balloon_alert(user, "Failed to link with destination")
		return TRUE

	if(length(contents))
		balloon_alert(user, "[src] not empty")
		to_chat(user, span_warning("Maximum weight surpassed. Empty [src] in order to extract it."))
		return TRUE

	var/obj/item/fulton_extraction_pack/ext_pack = I
	ext_pack.extract(src, user)
	return TRUE


/obj/item/fulton_extraction_pack/adminbus //For adminbusing and doing quests.
	tool_behaviour = null //We work on a different system here.
	var/obj/structure/fulton_extraction_point/linked_extraction_point
	var/list/allowed_target_tags = list() //List of valid tags for objects to extract.
	var/must_be_used_outdoors = TRUE
	var/do_after_time = 5 SECONDS
	var/require_living_to_be_dead = TRUE
	var/care_about_anchored = TRUE


/obj/item/fulton_extraction_pack/adminbus/Destroy()
	linked_extraction_point = null
	return ..()


/obj/item/fulton_extraction_pack/adminbus/preattack(mob/user, atom/target)
	if(!isturf(target.loc) || !ismovableatom(target))
		return FALSE
	if(active)
		balloon_alert(user, "Fulton not ready")
		return FALSE
	. = TRUE
	if(istype(target, /obj/structure/fulton_extraction_point))
		if(linked_extraction_point && linked_extraction_point == target)
			linked_extraction_point = null
			balloon_alert(user, "Extraction point unlinked")
		else
			linked_extraction_point = target
			balloon_alert(user, "Extraction point linked")
		return
	if(length(allowed_target_tags) && !(target.tag in allowed_target_tags))
		return
	if(must_be_used_outdoors)
		var/area/target_area = get_area(target)
		if(target_area.ceiling >= CEILING_OBSTRUCTED)
			balloon_alert(user, "Cannot extract indoors")
			return
	var/atom/movable/movable_target = target
	if(care_about_anchored && movable_target.anchored)
		balloon_alert(user, "Cannot extract anchored")
		return FALSE
	if(do_after_time && (user.do_actions || !do_after(user, do_after_time, TRUE, target)))
		return
	if(require_living_to_be_dead && isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return

	do_extract(target, user)

	if(linked_extraction_point)
		movable_target.forceMove(get_turf(linked_extraction_point))
		if(isliving(movable_target))
			REMOVE_TRAIT(movable_target, TRAIT_IMMOBILE, type)
	else
		qdel(target)


/obj/structure/fulton_extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Activate a pack in your hand to link it to a beacon."
	icon = 'icons/obj/items/fulton.dmi'
	icon_state = "extraction_point"
	anchored = TRUE
	density = FALSE
