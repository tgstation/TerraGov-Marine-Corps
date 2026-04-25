
//items that are frames or assembly used to construct something (table parts, camera assembly, etc...)

/obj/item/frame





// APC FRAME

/obj/item/frame/apc
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/objects.dmi'
	icon_state = "apc_frame"
	atom_flags = CONDUCT

/obj/item/frame/apc/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)

/obj/item/frame/apc/proc/try_build(turf/on_wall, mob/user)
	if (get_dist(on_wall,user)>1)
		return
	var/ndir = get_dir(on_wall,user)
	if (!(ndir in GLOB.cardinals))
		return
	var/turf/loc = get_turf(user)
	var/area/A = get_area(loc)
	if (!isfloorturf(loc))
		loc.balloon_alert(user, "not right here!")
		return
	if (A.requires_power == 0 || istype(A, /area/space))
		balloon_alert(user, "unsuitable area!")
		return
	if (A.get_apc())
		balloon_alert(user, "APC already present!")
		return //only one APC per area
	if (A.always_unpowered)
		balloon_alert(user, "unsuitable area!")
		return
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			balloon_alert(user, "occupied spot!")
			return
		else
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(loc)
			C.amount = 10
			balloon_alert(user, "cuts cables")
			qdel(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	qdel(src)
