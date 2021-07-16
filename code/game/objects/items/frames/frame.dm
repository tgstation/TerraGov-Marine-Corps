
//items that are frames or assembly used to construct something (table parts, camera assembly, etc...)

/obj/item/frame





// APC FRAME

/obj/item/frame/apc
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/objects.dmi'
	icon_state = "apc_frame"
	flags_atom = CONDUCT

/obj/item/frame/apc/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, 2)
		qdel(src)

/obj/item/frame/apc/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(on_wall,usr)
	if (!(ndir in GLOB.cardinals))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = get_area(loc)
	if (!isfloorturf(loc))
		to_chat(usr, span_warning("APC cannot be placed on this spot."))
		return
	if (A.requires_power == 0 || istype(A, /area/space))
		to_chat(usr, span_warning("APC cannot be placed in this area."))
		return
	if (A.get_apc())
		to_chat(usr, span_warning("This area already has APC."))
		return //only one APC per area
	if (A.always_unpowered)
		to_chat(usr, span_warning("This area is unsuitable for an APC."))
		return
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			to_chat(usr, span_warning("There is another network terminal here."))
			return
		else
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(loc)
			C.amount = 10
			to_chat(usr, "You cut the cables and disassemble the unused power terminal.")
			qdel(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	qdel(src)
