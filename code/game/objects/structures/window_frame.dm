/obj/structure/window_frame
	name = "window frame"
	desc = "A big hole in the wall that used to sport a large window. Can be vaulted through"
	icon = 'icons/obj/structures/window_frames.dmi'
	icon_state = "window0_frame"
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	layer = WINDOW_FRAME_LAYER
	density = TRUE
	throwpass = TRUE
	resistance_flags = DROPSHIP_IMMUNE | XENO_DAMAGEABLE
	max_integrity = 150
	climbable = 1 //Small enough to vault over, but you do need to vault over it
	climb_delay = 15 //One second and a half, gotta vault fast
	smoothing_behavior = CARDINAL_SMOOTHING
	smoothing_groups = SMOOTH_GENERAL_STRUCTURES
	var/obj/item/stack/sheet/sheet_type = /obj/item/stack/sheet/glass/reinforced
	var/obj/structure/window/framed/mainship/window_type = /obj/structure/window/framed/mainship
	var/basestate = "window"
	var/junction = 0
	var/reinforced = FALSE
	coverage = 50

/obj/structure/window_frame/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(climbable && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S?.climbable)
		return TRUE

/obj/structure/window_frame/Initialize(mapload, from_window_shatter)
	. = ..()
	var/weed_found
	if(from_window_shatter)
		for(var/obj/alien/weeds/weedwall/window/W in loc)
			weed_found = TRUE
			break
	if(weed_found)
		new /obj/alien/weeds/weedwall/frame(loc) //after smoothing to get the correct junction value


/obj/structure/window_frame/proc/update_nearby_icons()
	smooth_neighbors()

/obj/structure/window_frame/update_icon()
	smooth_self()

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

		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
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
		var/oldloc = loc
		if(!do_mob(user, M, 20, BUSY_ICON_GENERIC) || loc != oldloc)
			return
		M.Paralyze(40)
		user.visible_message(span_warning("[user] pulls [M] onto [src]."),
		span_notice("You pull [M] onto [src]."))
		M.forceMove(loc)


/obj/structure/window_frame/mainship
	icon_state = "ship_window0_frame"
	basestate = "ship_window"

/obj/structure/window_frame/mainship/white
	icon_state = "white_window0_frame"
	basestate = "white_window"
	window_type = /obj/structure/window/framed/mainship/white

/obj/structure/window_frame/mainship/gray
	icon_state = "gray_window0_frame"
	basestate = "gray_window"
	window_type = /obj/structure/window/framed/mainship/gray

/obj/structure/window_frame/colony
	icon_state = "col_window0_frame"
	basestate = "col_window"

/obj/structure/window_frame/colony/reinforced
	icon_state = "col_rwindow0_frame"
	basestate = "col_rwindow"
	reinforced = TRUE
	max_integrity = 300

/obj/structure/window_frame/chigusa
	icon_state = "chig_window0_frame"
	basestate = "chig_window"

/obj/structure/window_frame/wood
	icon_state = "wood_window0_frame"
	basestate = "wood_window"

/obj/structure/window_frame/prison
	icon_state = "prison_rwindow0_frame"
	basestate = "prison_rwindow"

/obj/structure/window_frame/prison/reinforced
	reinforced = TRUE
	max_integrity = 300

/obj/structure/window_frame/prison/hull
	climbable = FALSE
	throwpass = FALSE
	reinforced = TRUE
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
