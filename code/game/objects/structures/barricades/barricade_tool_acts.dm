/obj/structure/barricade/wirecutter_act(mob/living/user, obj/item/I)
	if(!(barricade_flags & BARRICADE_IS_WIRED) || LAZYACCESS(user.do_actions, src))
		return FALSE

	balloon_alert_to_viewers("removing wire...")

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return TRUE

	playsound(loc, 'sound/items/wirecutter.ogg', 25, TRUE)
	balloon_alert_to_viewers("removed")
	modify_max_integrity(max_integrity - 50)
	barricade_flags |= BARRICADE_CAN_WIRE
	DISABLE_BITFIELD(barricade_flags, BARRICADE_IS_WIRED)
	AddComponent(/datum/component/climbable)
	update_appearance(UPDATE_ICON)
	new /obj/item/stack/barbed_wire(loc)

/obj/structure/barricade/screwdriver_act(mob/living/user, obj/item/I)
	if(!(barricade_flags & BARRICADE_CAN_MOVE))
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	if(!COOLDOWN_FINISHED(src, tool_cooldown))
		return FALSE

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)
	switch(build_state)
		if(BARRICADE_FIRM) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
				var/fumbling_time = 1 SECONDS * ( skill_level - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return FALSE

			for(var/obj/structure/barricade/B in loc)
				if(B != src && B.dir == dir)
					balloon_alert(user, "already a barricade here!")
					return FALSE

			if(!do_after(user, 1, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("bolt protection panel removed")
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			build_state = BARRICADE_ANCHORED
			return TRUE

		if(BARRICADE_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
				var/fumbling_time = 1 SECONDS * ( skill_level - user.skills.getRating(SKILL_CONSTRUCTION) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return TRUE
			balloon_alert_to_viewers("bolt protection panel replaced")
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			build_state = BARRICADE_FIRM
			return TRUE

/obj/structure/barricade/crowbar_act(mob/living/user, obj/item/I)
	if(!(barricade_flags & BARRICADE_CAN_MOVE))
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	if(!COOLDOWN_FINISHED(src, tool_cooldown))
		return FALSE
	if(build_state != BARRICADE_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing.
		return FALSE

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)
	if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
		var/fumbling_time = 5 SECONDS * ( skill_level - user.skills.getRating(SKILL_CONSTRUCTION))
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	balloon_alert_to_viewers("disassembling...")
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)

	if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
		return TRUE

	user.visible_message(span_notice("[user] takes [src]'s panels apart."),
	span_notice("You take [src]'s panels apart."))
	playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
	deconstruct(!get_self_acid())
	return TRUE

/obj/structure/barricade/wrench_act(mob/living/user, obj/item/I)
	if(!(barricade_flags & BARRICADE_CAN_MOVE))
		return FALSE
	if(LAZYACCESS(user.do_actions, src))
		return FALSE
	if(!COOLDOWN_FINISHED(src, tool_cooldown))
		return FALSE

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)
	switch(build_state)
		if(BARRICADE_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
				var/fumbling_time = 1 SECONDS * ( skill_level - user.skills.getRating(SKILL_CONSTRUCTION))
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return FALSE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return FALSE

			anchored = FALSE
			modify_max_integrity(initial(max_integrity) * 0.5)
			build_state = BARRICADE_LOOSE
			balloon_alert_to_viewers("anchor bolts loosened")
			update_appearance(UPDATE_ICON) //unanchored changes layer
			return TRUE

		if(BARRICADE_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
			var/turf/mystery_turf = get_turf(src)
			if(!isopenturf(mystery_turf))
				balloon_alert(user, "can't anchor here!")
				return

			var/turf/open/T = mystery_turf
			var/area/area = get_area(T)
			if(!T.allow_construction || area.area_flags & NO_CONSTRUCTION) //We shouldn't be able to anchor in areas we're not supposed to build; loophole closed.
				balloon_alert(user, "can't anchor here!")
				return FALSE

			if(user.skills.getRating(SKILL_CONSTRUCTION) < skill_level)
				var/fumbling_time = 1 SECONDS * ( skill_level - user.skills.getRating(SKILL_CONSTRUCTION))
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return FALSE

			for(var/obj/structure/barricade/B in loc)
				if(B == src)
					continue
				if(B.dir != dir)
					continue
				balloon_alert(user, "already a barricade here!")
				return FALSE

			playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
			if(!do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE

			balloon_alert_to_viewers("anchor bolts secured")
			build_state = BARRICADE_ANCHORED
			anchored = TRUE
			modify_max_integrity(initial(max_integrity))
			update_appearance(UPDATE_ICON) //unanchored changes layer
			return TRUE

