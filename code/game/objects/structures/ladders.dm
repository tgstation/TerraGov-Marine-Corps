/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "ladder11"
	var/id = null
	var/height = 0							//The 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//The ladder below this one
	var/obj/structure/ladder/up = null		//The ladder above this one
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = LADDER_LAYER
	var/is_watching = 0
	var/obj/machinery/camera/cam

/obj/structure/ladder/Initialize(mapload)
	. = ..()
	cam = new /obj/machinery/camera(src)
	cam.network = list("LADDER")
	cam.c_tag = name

	GLOB.ladder_list += src

	return INITIALIZE_HINT_LATELOAD


/obj/structure/ladder/LateInitialize()
	. = ..()
	for(var/obj/structure/ladder/L AS in GLOB.ladder_list)
		if(L.id == id)
			if(L.height == (height - 1))
				down = L
				continue
			if(L.height == (height + 1))
				up = L
				continue

		if(up && down)	//If both our connections are filled
			break
	update_icon()

/obj/structure/ladder/Destroy()
	if(down)
		down.up = null
		down = null
	if(up)
		up.down = null
		up = null
	if(cam)
		qdel(cam)
		cam = null
	GLOB.ladder_list -= src
	return ..()

/obj/structure/ladder/update_icon_state()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	return attack_hand(X)

/obj/structure/ladder/attack_larva(mob/living/carbon/xenomorph/larva/X)
	return attack_hand(X)

/obj/structure/ladder/attack_hivemind(mob/living/carbon/xenomorph/hivemind/M)
	return attack_hand(M)

/obj/structure/ladder/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated() || !Adjacent(user) || user.lying_angle || user.buckled || user.anchored)
		return
	var/ladder_dir_name
	var/obj/structure/ladder/ladder_dest
	if(up && down)
		ladder_dir_name = tgui_alert(user, "Go up or down the ladder?", "Ladder", list("Up", "Down", "Cancel"))
		switch(ladder_dir_name)
			if("Up")
				ladder_dir_name = "up"
				ladder_dest = up
			if("Down")
				ladder_dir_name = "down"
				ladder_dest = down
			else
				return
	else if(up)
		ladder_dir_name = "up"
		ladder_dest = up
	else if(down)
		ladder_dir_name = "down"
		ladder_dest = down
	else return //just in case

	step(user, get_dir(user, src))
	user.visible_message(span_notice("[user] starts climbing [ladder_dir_name] [src]."),
	span_notice("You start climbing [ladder_dir_name] [src]."))
	if(!do_after(user, 20, IGNORE_HELD_ITEM, src, BUSY_ICON_GENERIC) || user.lying_angle || user.anchored)
		return
	user.trainteleport(ladder_dest.loc)
	visible_message(span_notice("[user] climbs [ladder_dir_name] [src].")) //Hack to give a visible message to the people here without duplicating user message
	user.visible_message(span_notice("[user] climbs [ladder_dir_name] [src]."),
	span_notice("You climb [ladder_dir_name] [src]."))


/obj/structure/ladder/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(up && down)
		switch(tgui_alert(user, "Go up or down the ladder?", "Ladder", list("Up", "Down", "Cancel")))
			if("Up")
				user.forceMove(get_turf(up))
			if("Down")
				user.forceMove(get_turf(down))
			else
				return

	else if(up)
		user.forceMove(get_turf(up))

	else if(down)
		user.forceMove(get_turf(down))


/obj/structure/ladder/check_eye(mob/user)
	//Are we capable of looking?
	if(user.incapacitated() || get_dist(user, src) > 1 || is_blind(user) || user.lying_angle || !user.client)
		user.unset_interaction()

	//Are ladder cameras ok?
	else if (is_watching == 1)
		if (!down || !down.cam || !down.cam.can_use()) //Camera doesn't work or is gone
			user.unset_interaction()
	else if (is_watching == 2)
		if (!up || !up.cam || !up.cam.can_use()) //Camera doesn't work or is gone
			user.unset_interaction()



/obj/structure/ladder/on_set_interaction(mob/user)
	if (is_watching == 1)
		if (down || down.cam || down.cam.can_use()) //Camera works
			user.reset_perspective(down.cam)
			return
	else if (is_watching == 2)
		if (up || up.cam || up.cam.can_use())
			user.reset_perspective(up.cam)
			return

	user.unset_interaction() //No usable cam, we stop interacting right away



/obj/structure/ladder/on_unset_interaction(mob/user)
	..()
	is_watching = 0
	user.reset_perspective(null)

//Peeking up/down
/obj/structure/ladder/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr))))
		if(isxenolarva(usr) || isobserver(usr) || usr.incapacitated() || is_blind(usr) || usr.lying_angle)
			to_chat(usr, "You can't do that in your current state.")
			return
		if(is_watching)
			to_chat(usr, "Someone's already looking through [src].")
			return
		if(up && down)
			switch(tgui_alert(usr, "Look up or down the ladder?", "Ladder", list("Up", "Down", "Cancel")))
				if("Up")
					usr.visible_message(span_notice("[usr] looks up [src]!"),
					span_notice("You look up [src]!"))
					is_watching = 2
					usr.set_interaction(src)

				if("Down")
					usr.visible_message(span_notice("[usr] looks down [src]!"),
					span_notice("You look down [src]!"))
					is_watching = 1
					usr.set_interaction(src)

				if("Cancel")
					return

		else if(up)
			usr.visible_message(span_notice("[usr] looks up [src]!"),
			span_notice("You look up [src]!"))
			is_watching = 2
			usr.set_interaction(src)


		else if(down)
			usr.visible_message(span_notice("[usr] looks down [src]!"),
			span_notice("You look down [src]!"))
			is_watching = 1
			usr.set_interaction(src)


//Throwing Shiet
/obj/structure/ladder/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/G = I
		var/ladder_dir_name
		var/obj/structure/ladder/ladder_dest

		if(up && down)
			ladder_dir_name = tgui_alert(user, "Throw up or down?", "Ladder", list("Up", "Down", "Cancel"), 0)
			switch(ladder_dir_name)
				if("Up")
					ladder_dest = up
					ladder_dir_name = "up"
				if("Down")
					ladder_dest = down
					ladder_dir_name = "down"
				else
					return
		else if(up)
			ladder_dir_name = "up"
			ladder_dest = up

		else if(down)
			ladder_dir_name = "down"
			ladder_dest = down
		else
			return

		user.visible_message(span_warning("[user] takes position to throw [G] [ladder_dir_name] [src]."),
		span_warning("You take position to throw [G] [ladder_dir_name] [src]."))

		if(!do_after(user, 10, NONE, src, BUSY_ICON_HOSTILE))
			return

		user.visible_message(span_warning("[user] throws [G] [ladder_dir_name] [src]!"),
		span_warning("You throw [G] [ladder_dir_name] [src]"))
		user.drop_held_item()
		G.forceMove(ladder_dest.loc)
		G.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		step_away(G, src, rand(1, 5))

		if(!G.active)
			G.activate(user)

	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I
		var/ladder_dir_name
		var/obj/structure/ladder/ladder_dest
		if(up && down)
			ladder_dir_name = tgui_alert(user, "Throw up or down?", "Ladder", list("Up", "Down", "Cancel"), 0)
			switch(ladder_dir_name)
				if("Up")
					ladder_dir_name = "up"
					ladder_dest = up
				if("Down")
					ladder_dir_name = "up"
					ladder_dest = down
				else
					return
		else if(up)
			ladder_dir_name = "up"
			ladder_dest = up
		else if(down)
			ladder_dir_name = "down"
			ladder_dest = down
		else
			return //just in case

		user.visible_message(span_warning("[user] takes position to throw [F] [ladder_dir_name] [src]."),
		span_warning("You take position to throw [F] [ladder_dir_name] [src]."))

		if(!do_after(user, 10, NONE, src, BUSY_ICON_HOSTILE))
			return

		user.visible_message(span_warning("[user] throws [F] [ladder_dir_name] [src]!"),
		span_warning("You throw [F] [ladder_dir_name] [src]"))
		user.drop_held_item()
		F.forceMove(ladder_dest.loc)
		F.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		step_away(F, src, rand(1, 5))

	else
		return attack_hand(user)
