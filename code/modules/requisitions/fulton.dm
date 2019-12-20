/obj/item/fulton_extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	icon = 'icons/obj/items/fulton.dmi'
	icon_state = "extraction_pack"
	w_class = WEIGHT_CLASS_NORMAL
	tool_behaviour = TOOL_FULTON
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/atom/movable/vis_obj/fulton_baloon/baloon
	var/obj/effect/fulton_extraction_holder/holder_obj


/obj/item/fulton_extraction_pack/Initialize()
	. = ..()
	baloon = new()
	holder_obj = new()


/obj/item/fulton_extraction_pack/Destroy()
	QDEL_NULL(baloon)
	QDEL_NULL(holder_obj)
	return ..()


/obj/item/fulton_extraction_pack/proc/extract(atom/movable/spirited_away, mob/user)
	if(!do_checks(spirited_away, user))
		return
	do_extract(spirited_away, user)

	. = spirited_away.supply_export()
	user.visible_message("<span class='notice'>[user] finishes attaching [src] to [spirited_away] and activates it.</span>",\
	"<span class='notice'>You attach the pack to [spirited_away] and activate it. This looks like it will yield [. ? . : "no"] point[. == 1 ? "" : "s"].</span>", null, 5)

	qdel(spirited_away)


/obj/item/fulton_extraction_pack/proc/do_checks(atom/movable/spirited_away, mob/user)
	if(user.action_busy)
		return FALSE
	if(active)
		to_chat(user, "<span class='warning'>The fulton device is not yet ready to extract again. Wait a moment.</span>")
		return FALSE
	user.visible_message("<span class='notice'>[user] starts attaching [src] to [spirited_away].</span>",\
	"<span class='notice'>You start attaching the pack to [spirited_away]...</span>", null, 5)
	if(!do_after(user, 5 SECONDS, TRUE, spirited_away))
		return FALSE
	if(!isturf(spirited_away.loc))
		to_chat(user, "<span class='warning'>The fulton device cannot extract [spirited_away]. Place it on the ground.</span>")
		return FALSE
	if(spirited_away.anchored)
		to_chat(user, "<span class='warning'>[spirited_away] is anchored, it cannot be extracted!</span>")
		return FALSE
	var/area/bathhouse = get_area(spirited_away)
	if(bathhouse.ceiling >= CEILING_METAL)
		to_chat(user, "<span class='warning'>You cannot extract [spirited_away] while indoors!</span>")
		return FALSE
	return TRUE


/obj/item/fulton_extraction_pack/proc/do_extract(atom/movable/spirited_away, mob/user)
	active = TRUE

	holder_obj.appearance = spirited_away.appearance
	holder_obj.forceMove(spirited_away.loc)
	if(spirited_away.anchored)
		spirited_away.anchored = FALSE
	if(isliving(spirited_away))
		var/mob/living/kidnapped = spirited_away
		kidnapped.set_frozen(TRUE)
		kidnapped.update_canmove()
	spirited_away.moveToNullspace()
	baloon.icon_state = initial(baloon.icon_state)
	holder_obj.vis_contents += baloon

	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(holder_obj), 'sound/items/fultext_deploy.ogg', 50, TRUE), 0.4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(holder_obj), 'sound/items/fultext_launch.ogg', 50, TRUE), 7.4 SECONDS)
	addtimer(CALLBACK(src, .proc/cleanup_extraction), 8 SECONDS)

	flick("fulton_expand", baloon)
	baloon.icon_state = "fulton_balloon"
	animate(holder_obj, pixel_z = 0, time = 0.4 SECONDS)
	animate(pixel_z = 10, time = 2 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 480, time = 1 SECONDS)


/obj/item/fulton_extraction_pack/proc/cleanup_extraction()
	holder_obj.moveToNullspace()
	holder_obj.pixel_z = initial(pixel_z)
	holder_obj.vis_contents -= baloon
	baloon.icon_state = initial(baloon.icon_state)
	active = FALSE


/obj/effect/fulton_extraction_holder
	name = "fulton extraction holder"
	desc = "You shouldn't see this."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


//Overrides.
/mob/living/carbon/xenomorph/fulton_act(mob/living/user, obj/item/I)
	if(!SSpoints)
		to_chat(user, "<span class='notice'>Failure to form link with destination target.</span>")
		return TRUE

	if(stat != DEAD)
		to_chat(user, "<span class='warning'>The extraction device buzzes, complaining. This one seems to be alive still.</span>")
		return TRUE

	var/obj/item/fulton_extraction_pack/ext_pack = I
	ext_pack.extract(src, user)
	return TRUE


/obj/structure/table/fulton_act(mob/living/user, obj/item/I)
	if(!flipped)
		return FALSE //Place it in.
	to_chat(user, "<span class='warning'>Cannot extract [src].</span>")
	return TRUE


/obj/structure/closet/fulton_act(mob/living/user, obj/item/I)
	if(opened)
		return FALSE //Place it in.
	to_chat(user, "<span class='warning'>Cannot extract [src].</span>")
	return TRUE


/obj/structure/closet/crate/fulton_act(mob/living/user, obj/item/I)
	if(opened)
		return FALSE //Place it in.

	if(!SSpoints)
		to_chat(user, "<span class='warning'>Failure to form link with destination target.</span>")
		return TRUE

	if(length(contents))
		to_chat(user, "<span class='warning'>Maximum weight surpassed. Empty [src] in order to extract it.</span>")
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
		to_chat(user, "<span class='warning'>The fulton device is not yet ready to extract again. Wait a moment.</span>")
		return FALSE
	. = TRUE
	if(istype(target, /obj/structure/fulton_extraction_point))
		if(linked_extraction_point && linked_extraction_point == target)
			linked_extraction_point = null
			to_chat(user, "<span class='notice'>Extraction point unlinked.</span>")
		else
			linked_extraction_point = target
			to_chat(user, "<span class='notice'>Extraction point linked.</span>")
		return
	if(length(allowed_target_tags) && !(target.tag in allowed_target_tags))
		return
	if(must_be_used_outdoors)
		var/area/target_area = get_area(target)
		if(target_area.ceiling >= CEILING_METAL)
			to_chat(user, "<span class='warning'>You cannot extract [target] while indoors!</span>")
			return
	var/atom/movable/movable_target = target
	if(care_about_anchored && movable_target.anchored)
		to_chat(user, "<span class='warning'>[target] is anchored, it cannot be extracted!</span>")
		return FALSE
	if(do_after_time && (user.action_busy || !do_after(user, do_after_time, TRUE, target)))
		return
	if(require_living_to_be_dead && isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return

	do_extract(target, user)

	if(linked_extraction_point)
		movable_target.forceMove(get_turf(linked_extraction_point))
		if(isliving(movable_target))
			var/mob/living/living_target = target
			living_target.set_frozen(TRUE)
	else
		qdel(target)


/obj/structure/fulton_extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Activate a pack in your hand to link it to a beacon."
	icon = 'icons/obj/items/fulton.dmi'
	icon_state = "extraction_point"
	anchored = TRUE
	density = FALSE
