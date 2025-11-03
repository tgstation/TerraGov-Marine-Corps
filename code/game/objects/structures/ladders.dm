// Basic ladder. By default links to the z-level above/below.
/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "ladder11"
	base_icon_state = "ladder"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	obj_flags = CAN_BE_HIT | BLOCK_Z_OUT_DOWN
	///the ladder below this one
	VAR_FINAL/obj/structure/ladder/down
	///the ladder above this one
	VAR_FINAL/obj/structure/ladder/up
	/// Ladders crafted midround can only link to other ladders crafted midround
	var/crafted = FALSE
	/// travel time for ladder in deciseconds
	var/travel_time = 1 SECONDS

/obj/structure/ladder/Initialize(mapload, obj/structure/ladder/up, obj/structure/ladder/down)
	..()
	GLOB.ladder_list += src
	if(up)
		link_up(up)
	if(down)
		link_down(down)
	var/turf/open/openspace/downturf = get_step_multiz(get_turf(src), DOWN)
	var/turf/open/openspace/upturf = get_step_multiz(get_turf(src), UP)
	if(!downturf && !upturf) //we only add markers to multi-z ladders, sorry Sulaco
		return INITIALIZE_HINT_LATELOAD
	else
		SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "ladder", MINIMAP_LABELS_LAYER))
		return INITIALIZE_HINT_LATELOAD

/obj/structure/ladder/examine(mob/user)
	. = ..()
	. += span_info("[EXAMINE_HINT("Left-click")] it to start moving up; [EXAMINE_HINT("Right-click")] to start moving down.")
	. += span_info("[EXAMINE_HINT("Left-click")] with an item to throw something up; [EXAMINE_HINT("Right-click")] with an item to throw it down.")
	. += span_info("[EXAMINE_HINT("Drag to yourself")] to look up or down.")


/obj/structure/ladder/Destroy(force)
	GLOB.ladder_list -= src
	disconnect()
	return ..()

/// Trait source applied by ladder holes
#define SOURCE_LADDER(ladder) "ladder_[REF(ladder)]"

/// Abstract object used to represent a hole in the floor created by a ladder
/obj/effect/abstract/ladder_hole
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = TRANSPARENT_FLOOR_PLANE
	layer = SPACE_LAYER
	alpha = 254
	/// The ladder that created this hole
	VAR_FINAL/obj/structure/ladder/ladder

/obj/effect/abstract/ladder_hole/Initialize(mapload, obj/structure/ladder/ladder)
	. = ..()
	if(isnull(ladder) || !isopenturf(loc) || isopenspaceturf(loc))
		return INITIALIZE_HINT_QDEL
	for(var/obj/effect/abstract/ladder_hole/hole in loc)
		if(hole.ladder == ladder)
			return INITIALIZE_HINT_QDEL

	src.ladder = ladder
	RegisterSignal(ladder, COMSIG_QDELETING, PROC_REF(cleanup))

	icon = ladder.icon
	icon_state = "[ladder.base_icon_state]_hole"
	render_target = "*[SOURCE_LADDER(ladder)]"

	ADD_KEEP_TOGETHER(loc, SOURCE_LADDER(ladder))
	ADD_TURF_TRANSPARENCY(loc, SOURCE_LADDER(ladder))
	RegisterSignal(loc, COMSIG_TURF_CHANGE, PROC_REF(turf_changing))
	RegisterSignal(loc, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(add_ladder_rim))
	loc.add_filter(SOURCE_LADDER(ladder), 1, alpha_mask_filter(
		x = ladder.pixel_x + ladder.pixel_w,
		y = ladder.pixel_y + ladder.pixel_z,
		render_source = "*[SOURCE_LADDER(ladder)]",
		flags = MASK_INVERSE,
	))
	loc.update_appearance(UPDATE_OVERLAYS)

/obj/effect/abstract/ladder_hole/Destroy()
	if(isnull(ladder))
		return ..()

	if(isopenturf(loc))
		UnregisterSignal(loc, list(COMSIG_TURF_CHANGE, COMSIG_ATOM_UPDATE_OVERLAYS))
		REMOVE_KEEP_TOGETHER(loc, SOURCE_LADDER(ladder))
		REMOVE_TURF_TRANSPARENCY(loc, SOURCE_LADDER(ladder))
		loc.remove_filter(SOURCE_LADDER(ladder))
		loc.update_appearance(UPDATE_OVERLAYS)

	UnregisterSignal(ladder, COMSIG_QDELETING)
	ladder = null

	return ..()

///sig handler to clean us up with parent
/obj/effect/abstract/ladder_hole/proc/cleanup()
	SIGNAL_HANDLER

	// the ladder will qdel us in its Destroy regardless, when it unlinks
	// this is just an extra layer of safety, in case the ladder gets moved or something
	qdel(src)

///sig handler for when turf changes
/obj/effect/abstract/ladder_hole/proc/turf_changing(datum/source, path, new_baseturfs, flags, list/datum/callback/post_change_callbacks)
	SIGNAL_HANDLER

	post_change_callbacks += CALLBACK(ladder, TYPE_PROC_REF(/obj/structure/ladder, make_base_transparent))
	qdel(src)

///adds ladder rim iconstate to the overlays
/obj/effect/abstract/ladder_hole/proc/add_ladder_rim(turf/source, list/overlays)
	SIGNAL_HANDLER

	var/mutable_appearance/rim = mutable_appearance(
		icon = ladder.icon,
		icon_state = "[ladder.base_icon_state]_rim",
		layer = TURF_DECAL_LAYER,
		plane = FLOOR_PLANE,
		offset_spokesman = source,
	)
	rim.pixel_w = ladder.pixel_w
	rim.pixel_x = ladder.pixel_x
	rim.pixel_y = ladder.pixel_y
	rim.pixel_z = ladder.pixel_z

	overlays += rim

/// Makes the base of the ladder transparent
/obj/structure/ladder/proc/make_base_transparent()
	if(!SSmapping.level_trait(z, ZTRAIT_DOWN)) // Ladders which are actually teleporting you to another z level
		return
	pixel_z = initial(pixel_z) + 12
	new /obj/effect/abstract/ladder_hole(loc, src)

/// Clears any ladder holes created by this ladder
/obj/structure/ladder/proc/clear_base_transparency()
	pixel_z = initial(pixel_z)
	for(var/obj/effect/abstract/ladder_hole/hole in loc)
		if(hole.ladder == src)
			qdel(hole)

#undef SOURCE_LADDER

/// Links this ladder to passed ladder (which should generally be below it)
/obj/structure/ladder/proc/link_down(obj/structure/ladder/down_ladder)
	if(down)
		return

	down = down_ladder
	down_ladder.up = src
	down_ladder.update_appearance(UPDATE_ICON_STATE)
	update_appearance(UPDATE_ICON_STATE)
	make_base_transparent()

/// Unlinks this ladder from the ladder below it.
/obj/structure/ladder/proc/unlink_down()
	if(!down)
		return

	down.up = null
	down.update_appearance(UPDATE_ICON_STATE)
	down = null
	update_appearance(UPDATE_ICON_STATE)
	clear_base_transparency()

/// Links this ladder to passed ladder (which should generally be above it)
/obj/structure/ladder/proc/link_up(obj/structure/ladder/up_ladder)
	if(up)
		return

	up = up_ladder
	up_ladder.down = src
	up_ladder.make_base_transparent()
	up_ladder.update_appearance(UPDATE_ICON_STATE)
	update_appearance(UPDATE_ICON_STATE)

/// Unlinks this ladder from the ladder above it.
/obj/structure/ladder/proc/unlink_up()
	if(!up)
		return

	up.down = null
	up.clear_base_transparency()
	up.update_appearance(UPDATE_ICON_STATE)
	up = null
	update_appearance(UPDATE_ICON_STATE)

/// Helper to unlink everything
/obj/structure/ladder/proc/disconnect()
	unlink_down()
	unlink_up()

/obj/structure/ladder/LateInitialize()
	// By default, discover ladders above and below us vertically
	var/turf/base = get_turf(src)

	if(isnull(down))
		var/obj/structure/ladder/new_down = locate() in GET_TURF_BELOW(base)
		if (new_down && crafted == new_down.crafted)
			link_down(new_down)

	if(isnull(up))
		var/obj/structure/ladder/new_up = locate() in GET_TURF_ABOVE(base)
		if (new_up && crafted == new_up.crafted)
			link_up(new_up)

	// Linking updates our icon, so if we failed both links we need a manual update
	if(isnull(down) && isnull(up))
		update_appearance(UPDATE_ICON_STATE)

/obj/structure/ladder/update_icon_state()
	icon_state = "[base_icon_state][!!up][!!down]"
	return ..()

/**
 * Actually try to use the ladder as a standard mob
 * * user: mob to make go up or down
 * * going_up: whether we move to the up or down ladder
 */
/obj/structure/ladder/proc/use(mob/user, going_up = TRUE)
	if(!in_range(src, user) || LAZYACCESS(user.do_actions, src))
		return

	if(!up && !down)
		balloon_alert(user, "doesn't lead anywhere!")
		return
	if(going_up ? !up : !down)
		balloon_alert(user, "can't go any further [going_up ? "up" : "down"]!")
		return
	if(user.buckled && user.buckled.anchored)
		balloon_alert(user, "buckled to something anchored!")
		return
	if(travel_time)
		INVOKE_ASYNC(src, PROC_REF(start_travelling), user, going_up)
	else
		travel(user, going_up)
	add_fingerprint(user, "climb ladder")

/obj/structure/ladder/proc/start_travelling(mob/user, going_up)
	show_initial_fluff_message(user, going_up)
	// Misc bonuses to the climb speed.
	var/misc_multiplier = 1

	var/final_travel_time = (travel_time) * misc_multiplier

	if(do_after(user, final_travel_time, target = src))
		travel(user, going_up)

/// The message shown when the player starts climbing the ladder
/obj/structure/ladder/proc/show_initial_fluff_message(mob/user, going_up)
	var/up_down = going_up ? "up" : "down"
	user.balloon_alert_to_viewers("climbing [up_down]...")

///handles actual teleportation of mobs
/obj/structure/ladder/proc/travel(mob/user, going_up = TRUE, is_ghost = FALSE)
	var/obj/structure/ladder/ladder = going_up ? up : down
	if(!ladder)
		balloon_alert(user, "there's nothing that way!")
		return
	var/response = SEND_SIGNAL(user, COMSIG_LADDER_TRAVEL, src, ladder, going_up)
	if(response & LADDER_TRAVEL_BLOCK)
		return

	var/turf/target = get_turf(ladder)
	user.zMove(target = target, z_move_flags = ZMOVE_CHECK_PULLEDBY|ZMOVE_ALLOW_BUCKLED|ZMOVE_INCLUDE_PULLED)

	if(!is_ghost)
		show_final_fluff_message(user, ladder, going_up)

	// to avoid having players hunt for the pixels of a ladder that goes through several stories and is
	// partially covered by the sprites of their mobs, a radial menu will be displayed over them.
	// this way players can keep climbing up or down with ease until they reach an end.
	if(ladder.up && ladder.down)
		ladder.show_options(user, is_ghost)

/// The messages shown after the player has finished climbing. Players can see this happen from either src or the destination so we've 2 POVs here
/obj/structure/ladder/proc/show_final_fluff_message(mob/user, obj/structure/ladder/destination, going_up)
	var/up_down = going_up ? "up" : "down"

	//POV of players around the source
	visible_message(span_notice("[user] climbs [up_down] [src]."))
	//POV of players around the destination
	user.balloon_alert_to_viewers("climbed [up_down]")

/// Shows a radial menu that players can use to climb up and down a stair.
/obj/structure/ladder/proc/show_options(mob/user, is_ghost = FALSE)
	var/list/tool_list = list()
	tool_list["Up"] = image(icon = 'icons/mob/screen/arrows.dmi', icon_state = "point_arrow", dir = NORTH)
	tool_list["Down"] = image(icon = 'icons/mob/screen/arrows.dmi', icon_state = "point_arrow", dir = SOUTH)

	var/datum/callback/check_menu
	if(!is_ghost)
		check_menu = CALLBACK(src, PROC_REF(check_menu), user)
	var/result = show_radial_menu(user, src, tool_list, custom_check = check_menu, require_near = !is_ghost, tooltips = TRUE)

	var/going_up
	switch(result)
		if("Up")
			going_up = TRUE
		if("Down")
			going_up = FALSE
		else
			return

	if(is_ghost || !travel_time)
		travel(user, going_up, is_ghost)
	else
		INVOKE_ASYNC(src, PROC_REF(start_travelling), user, going_up)

///callback for if we can use the menu
/obj/structure/ladder/proc/check_menu(mob/user, is_ghost)
	if(user.incapacitated() || (!user.Adjacent(src)))
		return FALSE
	return TRUE

/obj/structure/ladder/attack_hand(mob/user, list/modifiers)
	// no parentcall to skip interact stuff. ideally replace with just using INTERACT_ATOM_ATTACK_HAND from tg
	use(user)
	return TRUE

/obj/structure/ladder/attack_hand_alternate(mob/living/user)
	. = ..()
	if(.)
		return
	use(user, going_up = FALSE)
	return TRUE

/obj/structure/ladder/attack_hivemind(mob/living/carbon/xenomorph/hivemind/user)
	. = ..()
	if(.)
		return
	if (!up && !down)
		balloon_alert(user, "doesn't lead anywhere!")
		return
	if(!up) //only goes down
		travel(user, going_up = FALSE, is_ghost = FALSE)
	else if(!down) //only goes up
		travel(user, going_up = TRUE, is_ghost = FALSE)
	else //goes both ways
		show_options(user, is_ghost = FALSE)

/obj/structure/ladder/attack_larva(mob/living/carbon/xenomorph/larva/user)
	. = ..()
	if(.)
		return
	if (!up && !down)
		balloon_alert(user, "doesn't lead anywhere!")
		return
	if(!up) //only goes down
		travel(user, going_up = FALSE, is_ghost = FALSE)
	else if(!down) //only goes up
		travel(user, going_up = TRUE, is_ghost = FALSE)
	else //goes both ways
		show_options(user, is_ghost = FALSE)

/obj/structure/ladder/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	. = ..()
	if(.)
		return
	use(xeno_attacker, going_up=!isrightclick)
	return TRUE

/obj/structure/ladder/attack_animal(mob/living/simple_animal/user)
	. = ..()
	if(.)
		return
	if (!up && !down)
		balloon_alert(user, "doesn't lead anywhere!")
		return
	if(!up) //only goes down
		travel(user, going_up = FALSE, is_ghost = FALSE)
	else if(!down) //only goes up
		travel(user, going_up = TRUE, is_ghost = FALSE)
	else //goes both ways
		show_options(user, is_ghost = FALSE)

/obj/structure/ladder/attackby(obj/item/item, mob/user, params)
	. = ..()
	if(.)
		return
	throw_object(item, user, TRUE)
	return TRUE

/obj/structure/ladder/attackby_alternate(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(.)
		return
	throw_object(attacking_item, user, FALSE)
	return TRUE

///throws an item held by a user up or down a ladder
/obj/structure/ladder/proc/throw_object(obj/item/item, mob/user, going_up=TRUE)
	if(going_up && !up)
		balloon_alert(user, "no stairs above!")
		return
	if(!going_up && !down)
		balloon_alert(user, "no stairs below!")
		return
	var/turf/destination = going_up ? get_turf(up) : get_turf(down)
	if(!do_after(user, 1 SECONDS, NONE, src))
		return
	var/ladder_dir_name = going_up ? "up" : "down"
	user.visible_message(span_warning("[user] throws [item] [ladder_dir_name] [src]!"),
		span_warning("You throw [item] [ladder_dir_name] [src]"))
	user.dropItemToGround(item)
	item.forceMove(destination)
	item.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
	step_away(item, src, rand(1, 5))
	if(istype(item, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/nade = item
		if(!nade.active)
			nade.activate(user)

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/structure/ladder/attack_ghost(mob/dead/observer/user)
	ghost_use(user)
	return ..()

///Ghosts use the byond default popup menu function on right click, so this is going to work a little differently for them.
/obj/structure/ladder/proc/ghost_use(mob/user)
	if (!up && !down)
		balloon_alert(user, "doesn't lead anywhere!")
		return
	if(!up) //only goes down
		travel(user, going_up = FALSE, is_ghost = TRUE)
	else if(!down) //only goes up
		travel(user, going_up = TRUE, is_ghost = TRUE)
	else //goes both ways
		show_options(user, is_ghost = TRUE)


/obj/structure/ladder/check_eye(mob/user)
	//Are we capable of looking?
	. = ..()
	if(user.incapacitated() || get_dist(user, src) > 1 || is_blind(user) || user.lying_angle || !user.client)
		user.unset_interaction()

/obj/structure/ladder/on_set_interaction(mob/user)
	user.reset_perspective(src)

/obj/structure/ladder/on_unset_interaction(mob/user)
	..()
	user.reset_perspective(null)

///Peeking up/down
/obj/structure/ladder/MouseDrop(over_object, src_location, over_location)
	if(over_object != usr || !in_range(src, usr))
		return
	if(usr.incapacitated() || is_blind(usr) || usr.lying_angle)
		to_chat(usr, "You can't do that in your current state.")
		return
	if (!up && !down)
		balloon_alert(usr, "doesn't lead anywhere!")
		return

	if(up && down)
		switch(tgui_alert(usr, "Look up or down the ladder?", "Ladder", list("Up", "Down", "Cancel")))
			if("Up")
				usr.visible_message(span_notice("[usr] looks up [src]!"),
				span_notice("You look up [src]!"))
				usr.set_interaction(up)

			if("Down")
				usr.visible_message(span_notice("[usr] looks down [src]!"),
				span_notice("You look down [src]!"))
				usr.set_interaction(down)

			if("Cancel")
				return

	else if(up)
		usr.visible_message(span_notice("[usr] looks up [src]!"),
		span_notice("You look up [src]!"))
		usr.set_interaction(up)

	else if(down)
		usr.visible_message(span_notice("[usr] looks down [src]!"),
		span_notice("You look down [src]!"))
		usr.set_interaction(down)


// Indestructible away mission ladders which link based on a mapped ID and height value rather than X/Y/Z.
/obj/structure/ladder/id_linked
	name = "sturdy ladder"
	desc = "An extremely sturdy metal ladder."
	resistance_flags = INDESTRUCTIBLE
	var/id
	var/height = 0  // higher numbers are considered physically higher

/obj/structure/ladder/id_linked/LateInitialize()
	// Override the parent to find ladders based on being height-linked
	if (!id || (up && down))
		update_appearance()
		return

	for(var/obj/structure/ladder/id_linked/unbreakable_ladder in GLOB.ladder_list)
		if (unbreakable_ladder.id != id)
			continue  // not one of our pals
		if (!down && unbreakable_ladder.height == height - 1)
			down = unbreakable_ladder
			unbreakable_ladder.up = src
			unbreakable_ladder.update_appearance()
			if (up)
				break  // break if both our connections are filled
		else if (!up && unbreakable_ladder.height == height + 1)
			up = unbreakable_ladder
			unbreakable_ladder.down = src
			unbreakable_ladder.update_appearance()
			if (down)
				break  // break if both our connections are filled

	update_appearance()

/obj/structure/ladder/id_linked/update_overlays()
	. = ..()
	if(down)
		var/mutable_appearance/rim = mutable_appearance(
			icon = icon,
			icon_state = "[base_icon_state]_rim",
			layer = TURF_DECAL_LAYER,
			plane = FLOOR_PLANE,
			offset_spokesman = src,
		)
		var/mutable_appearance/hole = mutable_appearance(
			icon = icon,
			icon_state = "[base_icon_state]_hole",
			layer = TURF_DECAL_LAYER,
			plane = FLOOR_PLANE,
			offset_spokesman = src,
		)
		hole.color = COLOR_BLACK
		. += hole
		. += rim
