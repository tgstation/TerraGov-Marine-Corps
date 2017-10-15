/obj/structure/window_frame
	name = "window frame"
	desc = "A big hole in the wall that used to sport a large window. Can be vaulted through"
	icon = 'icons/turf/almayer.dmi'
	icon_state = "rwindow0_frame"
	density = 1
	throwpass = TRUE
	climbable = 1 //Small enough to vault over, but you do need to vault over it
	climb_delay = 15 //One second and a half, gotta vault fast
	var/obj/item/stack/sheet/sheet_type = /obj/item/stack/sheet/glass/reinforced
	var/obj/structure/window/reinforced/almayer/window_type = /obj/structure/window/reinforced/almayer
	var/basestate = "window"
	var/junction = 0

	tiles_with = list(
		/turf/simulated/wall)

	var/tiles_special[] = list(/obj/machinery/door/airlock,
		/obj/structure/window/reinforced/almayer,
		/obj/structure/girder,
		/obj/structure/window_frame/almayer)

/obj/structure/window_frame/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group || (height == 0)) return 1 //Air can pass through a window-sized hole
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return 1
	return 0

/obj/structure/window_frame/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	return 1

/obj/structure/window_frame/New()
	spawn(10)
		relativewall()
		relativewall_neighbours()

/obj/structure/window_frame/proc/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window_frame/update_icon()
	relativewall()

/obj/structure/window_frame/Dispose()
	density = 0
	update_nearby_tiles()
	update_nearby_icons()
	. = ..()

/obj/structure/window_frame/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, sheet_type))
		var/obj/item/stack/sheet/sheet = W
		if(sheet.get_amount() < 2)
			user << "<span class='warning'>You need more [W.name] to install a new window.</span>"
			return
		user.visible_message("<span class='notice'>[user] starts installing a new glass window on the frame.</span>", \
		"<span class='notice'>You start installing a new window on the frame.</span>")
		playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
		if(do_after(user, 20, TRUE, 5, BUSY_ICON_CLOCK))
			user.visible_message("<span class='notice'>[user] installs a new glass window on the frame.</span>", \
			"<span class='notice'>You install a new window on the frame.</span>")
			sheet.use(2)
			new window_type(loc) //This only works on Almayer windows!
			cdel(src)

	else if(istype(W, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = W
		if(isliving(G.grabbed_thing))
			var/mob/living/M = G.grabbed_thing
			if(user.grab_level >= GRAB_AGGRESSIVE)
				if(get_dist(src, M) > 1)
					user << "<span class='warning'>[M] needs to be next to [src].</span>"
				else
					user.visible_message("<span class='notice'>[user] starts pulling [M] onto [src]...</span>",
					"<span class='notice'>You start pulling [M] onto [src]!</span>")
					var/oldloc = loc
					if(!do_mob(user, M, 20, BUSY_ICON_CLOCK) || loc != oldloc) return
					M.KnockDown(2)
					user.visible_message("<span class='warning'>[user] pulls [M] onto [src].</span>",
					"<span class='notice'>You pull [M] onto [src].</span>")
					M.forceMove(loc)
			else
				user << "<span class='warning'>You need a better grip to do that!</span>"
	else
		. = ..()



/obj/structure/window_frame/almayer
	icon_state = "rwindow0_frame"

/obj/structure/window_frame/almayer/white
	icon_state = "wwindow0_frame"
	basestate = "wwindow"
	window_type = /obj/structure/window/reinforced/almayer/white

/obj/structure/window_frame/almayer/colony
	icon_state = "cwindow0_frame"
	basestate = "cwindow"

/obj/structure/window_frame/almayer/colony/reinforced
	icon_state = "crwindow0_frame"
	basestate = "crwindow"

/obj/structure/window_frame/chigusa
	icon = 'icons/turf/chigusa.dmi'
	icon_state = "rwindow0_frame"

/obj/structure/window_frame/wood
	icon = 'icons/turf/wood.dmi'
	icon_state = "window0_frame"
	basestate = "window"