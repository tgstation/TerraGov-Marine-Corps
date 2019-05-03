/obj/structure/window_frame
	name = "window frame"
	desc = "A big hole in the wall that used to sport a large window. Can be vaulted through"
	icon = 'icons/obj/structures/window_frames.dmi'
	icon_state = "window0_frame"
	layer = WINDOW_FRAME_LAYER
	density = 1
	throwpass = TRUE
	climbable = 1 //Small enough to vault over, but you do need to vault over it
	climb_delay = 15 //One second and a half, gotta vault fast
	var/obj/item/stack/sheet/sheet_type = /obj/item/stack/sheet/glass/reinforced
	var/obj/structure/window/framed/almayer/window_type = /obj/structure/window/framed/almayer
	var/basestate = "window"
	var/junction = 0
	var/reinforced = FALSE

	tiles_with = list(
		/turf/closed/wall)

	var/tiles_special[] = list(/obj/machinery/door/airlock,
		/obj/structure/window/framed,
		/obj/structure/girder,
		/obj/structure/window_frame)

/obj/structure/window_frame/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && climbable && mover.checkpass(PASSTABLE))
		return TRUE
	return FALSE

/obj/structure/window_frame/CheckExit(atom/movable/O as mob|obj, target as turf)
	return TRUE

/obj/structure/window_frame/Initialize(loc, from_window_shatter)
	. = ..()
	var/weed_found
	if(from_window_shatter)
		for(var/obj/effect/alien/weeds/weedwall/window/W in loc)
			weed_found = TRUE
			break
	relativewall()
	relativewall_neighbours()
	if(weed_found)
		new /obj/effect/alien/weeds/weedwall/frame(loc) //after smoothing to get the correct junction value


/obj/structure/window_frame/proc/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window_frame/update_icon()
	relativewall()

/obj/structure/window_frame/Destroy()
	density = 0
	update_nearby_icons()
	for(var/obj/effect/alien/weeds/weedwall/frame/WF in loc)
		qdel(WF)
	. = ..()

/obj/structure/window_frame/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(P.start_cut(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD))
			if(do_after(user, P.calc_delay(user) * PLASMACUTTER_LOW_MOD, TRUE, src, BUSY_ICON_HOSTILE)) //Window frames require half the normal time
				P.cut_apart(user, src.name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_LOW_MOD) //Window frames require half the normal power
				P.debris(loc, 1, 1) //Generate some rods and metal
				qdel(src)
			return

	if(istype(W, sheet_type))
		var/obj/item/stack/sheet/sheet = W
		if(sheet.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need more [W.name] to install a new window.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts installing a new glass window on the frame.</span>", \
		"<span class='notice'>You start installing a new window on the frame.</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
		if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] installs a new glass window on the frame.</span>", \
			"<span class='notice'>You install a new window on the frame.</span>")
			sheet.use(2)
			new window_type(loc) //This only works on Theseus windows!
			qdel(src)

	else if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(isxeno(user)) return
		if(isliving(G.grabbed_thing))
			var/mob/living/M = G.grabbed_thing
			if(user.grab_level >= GRAB_AGGRESSIVE)
				if(get_dist(src, M) > 1)
					to_chat(user, "<span class='warning'>[M] needs to be next to [src].</span>")
				else
					if(user.action_busy)
						return
					user.visible_message("<span class='notice'>[user] starts pulling [M] onto [src].</span>",
					"<span class='notice'>You start pulling [M] onto [src]!</span>")
					if(!do_mob(user, M, 20, BUSY_ICON_HOSTILE))
						return
					M.KnockDown(2)
					user.visible_message("<span class='warning'>[user] pulls [M] onto [src].</span>",
					"<span class='notice'>You pull [M] onto [src].</span>")
					M.forceMove(loc)
			else
				to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
	else
		. = ..()



/obj/structure/window_frame/almayer
	icon_state = "alm_window0_frame"
	basestate = "alm_window"

/obj/structure/window_frame/almayer/white
	icon_state = "white_window0_frame"
	basestate = "white_window"
	window_type = /obj/structure/window/framed/almayer/white

/obj/structure/window_frame/almayer/requisitions/attackby(obj/item/W, mob/living/user)
	if(istype(W, sheet_type))
		to_chat(user, "<span class='warning'>You can't repair this window.</span>")
		return
	..()

/obj/structure/window_frame/colony
	icon_state = "col_window0_frame"
	basestate = "col_window"

/obj/structure/window_frame/colony/reinforced
	icon_state = "col_rwindow0_frame"
	basestate = "col_rwindow"
	reinforced = TRUE

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

/obj/structure/window_frame/prison/hull
	climbable = FALSE
	throwpass = FALSE
	reinforced = TRUE
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
