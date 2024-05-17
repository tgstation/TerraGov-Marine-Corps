/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle trash."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o1"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	density = TRUE
	//Pointing west because that's the only sprite we got
	dir = NORTH

/obj/machinery/recycler/update_icon_state()
	. = ..()
	icon_state = "grinder-o[(machine_stat & (BROKEN|NOPOWER)) ? "0":"1"]"

/obj/machinery/recycler/Bumped(atom/movable/AM)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	var/move_dir = get_dir(loc, AM.loc)
	if(!AM.anchored && move_dir == dir)
		if(isitem(AM))
			recycle(AM)
		else
			AM.forceMove(loc)

/obj/machinery/recycler/proc/recycle(obj/item/I)
	if(istype(I, /obj/item/storage))
		var/obj/item/storage/S = I
		for(var/obj/item/X in S.contents)
			S.storage_datum.remove_from_storage(X, loc)
			recycle(X)

	qdel(I)
	playsound(loc, 'sound/items/welder.ogg', 30, 1)
