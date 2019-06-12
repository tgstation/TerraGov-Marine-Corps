

/*
AIR ALARM ITEM
Handheld air alarm frame, for placing on walls
Code shamelessly copied from apc_frame
*/
/obj/item/frame/air_alarm
	name = "air alarm frame"
	desc = "Used for building Air Alarms"
	icon = 'icons/obj/objects.dmi'
	icon_state = "alarm_bitem"
	flags_atom = CONDUCT

/obj/item/frame/air_alarm/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)

/obj/item/frame/air_alarm/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in GLOB.cardinals))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!isfloorturf(loc))
		to_chat(usr, "<span class='warning'>Air Alarm cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "<span class='warning'>Air Alarm cannot be placed in this area.</span>")
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new /obj/machinery/alarm(loc, ndir, 1)
	qdel(src)

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
	flags_atom = CONDUCT

/obj/item/frame/fire_alarm/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)

/obj/item/frame/fire_alarm/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return

	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in GLOB.cardinals))
		return

	var/turf/loc = get_turf(usr)
	var/area/A = loc.loc
	if (!isfloorturf(loc))
		to_chat(usr, "<span class='warning'>Fire Alarm cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || A.name == "Space")
		to_chat(usr, "<span class='warning'>Fire Alarm cannot be placed in this area.</span>")
		return

	if(gotwallitem(loc, ndir))
		to_chat(usr, "<span class='warning'>There's already an item on this wall!</span>")
		return

	new /obj/machinery/firealarm(loc, ndir, 1)

	qdel(src)