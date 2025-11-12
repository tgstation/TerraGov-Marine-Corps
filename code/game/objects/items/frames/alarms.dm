/*
FIRE ALARM ITEM
Handheld fire alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/frame/fire_alarm
	name = "fire alarm frame"
	desc = "Used for building Fire Alarms"
	icon = 'icons/obj/objects.dmi'
	icon_state = "fire_bitem"
	atom_flags = CONDUCT

/obj/item/frame/fire_alarm/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)

/obj/item/frame/fire_alarm/proc/try_build(turf/on_wall, mob/user)
	if (get_dist(on_wall,user)>1)
		return

	var/ndir = get_dir(on_wall,user)
	if (!(ndir in GLOB.cardinals))
		return

	var/turf/loc = get_turf(user)
	var/area/A = loc.loc
	if(!isfloorturf(loc))
		loc.balloon_alert(user, "bad spot!")
		return
	if(A.requires_power == 0 || istype(A, /area/space))
		loc.balloon_alert(user, "bad area!")
		return

	if(gotwallitem(loc, ndir))
		loc.balloon_alert(user, "already occupied!")
		return

	new /obj/machinery/firealarm(loc, ndir, 1)

	qdel(src)
