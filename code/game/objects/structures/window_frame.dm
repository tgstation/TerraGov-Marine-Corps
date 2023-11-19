/obj/structure/window_frame
	name = "window frame"
	desc = "A big hole in the wall that used to sport a large window. Can be vaulted through"
	icon = 'icons/obj/smooth_objects/regular_window_frame.dmi'
	icon_state = "white_window_frame-0"
	base_icon_state = "white_window_frame"
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	layer = WINDOW_FRAME_LAYER
	density = TRUE
	resistance_flags = DROPSHIP_IMMUNE | XENO_DAMAGEABLE
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	max_integrity = 150
	climbable = TRUE
	climb_delay = 1.5 SECONDS
	soft_armor = list(MELEE = 0, BULLET = 70, LASER = 70, ENERGY = 70, BOMB = 50, BIO = 100, FIRE = 50, ACID = 0)
	var/obj/item/stack/sheet/sheet_type = /obj/item/stack/sheet/glass/reinforced
	var/obj/structure/window/framed/mainship/window_type = /obj/structure/window/framed/mainship
	var/basestate = "window"
	var/junction = 0
	var/reinforced = FALSE
	coverage = 50
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FRAME)
	canSmoothWith = list(
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FRAME,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
	)

/obj/structure/window_frame/Initialize(mapload, from_window_shatter)
	. = ..()
	var/weed_found
	if(from_window_shatter)
		for(var/obj/alien/weeds/weedwall/window/W in loc)
			weed_found = W
			break
	if(weed_found)
		qdel(weed_found)
		new /obj/alien/weeds/weedwall/window/frame(loc) //after smoothing to get the correct junction value

	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/window_frame/proc/update_nearby_icons()
	QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/window_frame/update_icon()
	QUEUE_SMOOTH(src)

/obj/structure/window_frame/Destroy()
	density = FALSE
	update_nearby_icons()
	var/obj/alien/weeds/weedwall/window_wall_weeds = locate() in loc
	if(window_wall_weeds)
		qdel(window_wall_weeds)
		new /obj/alien/weeds(loc)
	return ..()

/obj/structure/window_frame/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, sheet_type))
		var/obj/item/stack/sheet/sheet = I
		if(sheet.get_amount() < 2)
			to_chat(user, span_warning("You need more [I] to install a new window."))
			return
		user.visible_message(span_notice("[user] starts installing a new glass window on the frame."), \
		span_notice("You start installing a new window on the frame."))
		playsound(src, 'sound/items/deconstruct.ogg', 25, 1)

		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD))
			return

		user.visible_message(span_notice("[user] installs a new glass window on the frame."), \
		span_notice("You install a new window on the frame."))
		sheet.use(2)
		new window_type(loc) //This only works on Theseus windows!
		qdel(src)

	else if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(isxeno(user))
			return

		if(!isliving(G.grabbed_thing))
			return

		var/mob/living/M = G.grabbed_thing
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return

		if(get_dist(src, M) > 1)
			to_chat(user, span_warning("[M] needs to be next to [src]."))
			return

		if(user.do_actions)
			return

		user.visible_message(span_notice("[user] starts pulling [M] onto [src]."),
		span_notice("You start pulling [M] onto [src]!"))
		if(!do_after(user, 2 SECONDS, NONE, M, BUSY_ICON_GENERIC))
			return
		M.Paralyze(4 SECONDS)
		user.visible_message(span_warning("[user] pulls [M] onto [src]."),
		span_notice("You pull [M] onto [src]."))
		M.forceMove(loc)


/obj/structure/window_frame/mainship
	icon = 'icons/obj/smooth_objects/ship_window_frame.dmi'
	icon_state = "ship_window_frame-0"
	basestate = "ship_window_frame"
	base_icon_state = "ship_window_frame"

/obj/structure/window_frame/mainship/white
	icon = 'icons/obj/smooth_objects/white_window_frame.dmi'
	icon_state = "white_window_frame-0"
	basestate = "white_window_frame"
	base_icon_state = "white_window_frame"
	window_type = /obj/structure/window/framed/mainship/white

/obj/structure/window_frame/mainship/gray
	icon = 'icons/obj/smooth_objects/gray_window_frame.dmi'
	icon_state = "gray_window_frame-0"
	basestate = "gray_window_frame"
	base_icon_state = "gray_window_frame"
	window_type = /obj/structure/window/framed/mainship/gray

/obj/structure/window_frame/colony
	icon = 'icons/obj/smooth_objects/col_window_frame.dmi'
	icon_state = "col_window_frame-0"
	base_icon_state = "col_window_frame"
	basestate = "col_window_frame"

/obj/structure/window_frame/colony/reinforced
	icon = 'icons/obj/smooth_objects/col_rwindow_frame.dmi'
	icon_state = "col_rwindow_frame-0"
	basestate = "col_rwindow_frame"
	base_icon_state = "col_rwindow_frame"
	reinforced = TRUE
	max_integrity = 300

/obj/structure/window_frame/colony/reinforced/weakened
	max_integrity = 150

/obj/structure/window_frame/chigusa
	icon = 'icons/obj/smooth_objects/chigusa_window_frame.dmi'
	icon_state = "chigusa_window_frame-0"
	basestate = "chigusa_window_frame"
	base_icon_state = "chigusa_window_frame"

/obj/structure/window_frame/wood
	icon = 'icons/obj/smooth_objects/wood_window_frame.dmi'
	icon_state = "wood_window_frame-0"
	basestate = "wood_window_frame"
	base_icon_state = "wood_window_frame"

/obj/structure/window_frame/prison
	icon = 'icons/obj/smooth_objects/prison_rwindow_frame.dmi'
	icon_state = "col_rwindow_frame-0"
	basestate = "col_rwindow_frame"
	base_icon_state = "col_rwindow_frame"

/obj/structure/window_frame/prison/reinforced
	reinforced = TRUE
	max_integrity = 300

/obj/structure/window_frame/prison/hull
	climbable = FALSE
	allow_pass_flags = NONE
	reinforced = TRUE
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE

/obj/structure/window_frame/mainship/dropship
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FRAME, SMOOTH_GROUP_CANTERBURY)
	canSmoothWith = list(
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FRAME,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_CANTERBURY,
	)
