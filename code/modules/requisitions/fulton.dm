/obj/item/fulton_extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	icon = 'icons/obj/items/fulton.dmi'
	icon_state = "extraction_pack"
	w_class = WEIGHT_CLASS_NORMAL
	tool_behaviour = TOOL_FULTON
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	var/atom/movable/vis_obj/fulton_baloon/baloon = new()
	var/obj/effect/fulton_extraction_holder/holder_obj = new()
	var/active = FALSE


/obj/item/fulton_extraction_pack/Destroy()
	QDEL_NULL(baloon)
	QDEL_NULL(holder_obj)
	return ..()


/obj/item/fulton_extraction_pack/proc/extract(atom/movable/spirited_away, mob/user)
	if(user.action_busy)
		return
	if(active)
		to_chat(user, "<span class='warning'>The fulton device is not yet ready to extract again. Wait a moment.</span>")
		return
	user.visible_message("<span class='notice'>[user] starts attaching [src] to [spirited_away].</span>",\
	"<span class='notice'>You start attaching the pack to [spirited_away]...</span>", null, 5)
	if(!do_after(user, 5 SECONDS, TRUE, spirited_away))
		return
	if(!isturf(spirited_away.loc))
		to_chat(user, "<span class='warning'>The fulton device cannot extract [spirited_away]. Place it on the ground.</span>")
		return
	if(spirited_away.anchored)
		to_chat(user, "<span class='warning'>[spirited_away] is anchored, it cannot be extracted!</span>")
		return
	var/area/bathhouse = get_area(spirited_away)
	if(bathhouse.ceiling >= CEILING_METAL)
		to_chat(user, "<span class='warning'>You cannot extract [spirited_away] while indoors!</span>")
		return

	active = TRUE
	user.visible_message("<span class='notice'>[user] finishes attaching [src] to [spirited_away] and activates it.</span>",\
	"<span class='notice'>You attach the pack to [spirited_away] and activate it.</span>", null, 5)

	holder_obj.appearance = spirited_away.appearance
	holder_obj.forceMove(spirited_away.loc)
	spirited_away.moveToNullspace()
	baloon.icon_state = initial(baloon.icon_state)
	holder_obj.vis_contents += baloon

	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(holder_obj), 'sound/items/fultext_deploy.ogg', 50, TRUE), 0.4 SECONDS)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(holder_obj), 'sound/items/fultext_launch.ogg', 50, TRUE), 8.4 SECONDS)
	addtimer(CALLBACK(src, .proc/cleanup_extraction), 9 SECONDS)

	flick("fulton_expand", baloon)
	baloon.icon_state = "fulton_balloon"
	animate(holder_obj, pixel_z = 0, time = 0.4 SECONDS)
	animate(pixel_z = 10, time = 2 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 15, time = 1 SECONDS)
	animate(pixel_z = 10, time = 1 SECONDS)
	animate(pixel_z = 320, time = 2 SECONDS)

	. = spirited_away.supply_export()
	user.visible_message("<span class='notice'>[user] finishes attaching [src] to [spirited_away] and activates it.</span>",\
	"<span class='notice'>You attach the pack to [spirited_away] and activate it. This looks like it will yield [. ? . : "no"] point[. == 1 ? "" : "s"].</span>", null, 5)
	qdel(spirited_away)


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
