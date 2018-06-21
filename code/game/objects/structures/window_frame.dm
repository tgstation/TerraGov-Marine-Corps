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
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable non-border objects allow you to universally climb over others
		return 1
	return 0

/obj/structure/window_frame/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	return 1

/obj/structure/window_frame/New(loc, from_window_shatter)
	..()
	var/weed_found
	if(from_window_shatter)
		for(var/obj/effect/alien/weeds/weedwall/window/W in loc)
			weed_found = TRUE
			break
	spawn(0)
		relativewall()
		relativewall_neighbours()
		if(weed_found)
			new /obj/effect/alien/weeds/weedwall/frame(loc) //after smoothing to get the correct junction value


/obj/structure/window_frame/proc/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window_frame/update_icon()
	relativewall()

/obj/structure/window_frame/Dispose()
	density = 0
	update_nearby_icons()
	for(var/obj/effect/alien/weeds/weedwall/frame/WF in loc)
		cdel(WF)
	. = ..()

/obj/structure/window_frame/attackby(obj/item/W, mob/living/user)
	if(istype(W, sheet_type))
		var/obj/item/stack/sheet/sheet = W
		if(sheet.get_amount() < 2)
			user << "<span class='warning'>You need more [W.name] to install a new window.</span>"
			return
		user.visible_message("<span class='notice'>[user] starts installing a new glass window on the frame.</span>", \
		"<span class='notice'>You start installing a new window on the frame.</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
		if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
			user.visible_message("<span class='notice'>[user] installs a new glass window on the frame.</span>", \
			"<span class='notice'>You install a new window on the frame.</span>")
			sheet.use(2)
			new window_type(loc) //This only works on Almayer windows!
			cdel(src)

	else if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(isXeno(user)) return
		if(isliving(G.grabbed_thing))
			var/mob/living/M = G.grabbed_thing
			if(user.grab_level >= GRAB_AGGRESSIVE)
				if(get_dist(src, M) > 1)
					user << "<span class='warning'>[M] needs to be next to [src].</span>"
				else
					if(user.action_busy)
						return
					user.visible_message("<span class='notice'>[user] starts pulling [M] onto [src].</span>",
					"<span class='notice'>You start pulling [M] onto [src]!</span>")
					var/oldloc = loc
					if(!do_mob(user, M, 20, BUSY_ICON_GENERIC) || loc != oldloc) return
					M.KnockDown(2)
					user.visible_message("<span class='warning'>[user] pulls [M] onto [src].</span>",
					"<span class='notice'>You pull [M] onto [src].</span>")
					M.forceMove(loc)
			else
				user << "<span class='warning'>You need a better grip to do that!</span>"
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
		user << "<span class='warning'>You can't repair this window.</span>"
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
	icon_state = "prison_rwindow0_frame"
	basestate = "prison_rwindow"
	reinforced = TRUE