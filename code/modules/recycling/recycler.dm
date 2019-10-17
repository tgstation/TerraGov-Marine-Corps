/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle trash."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	density = TRUE
	var/list/stored_materials = list(/datum/material/metal = 0, /datum/material/glass = 0)


/obj/machinery/recycler/update_icon()
	icon_state = "separator-AO[(machine_stat & (BROKEN|NOPOWER)) ? "0":"1"]"


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
			S.remove_from_storage(X, loc)
			recycle(X)

	for(var/material in I.materials)
		if(isnull(stored_materials[material]))
			continue

		var/total_material = I.materials[material]
		//If it's a stack, we eat multiple sheets.
		if(istype(I,/obj/item/stack))
			var/obj/item/stack/stack = I
			total_material *= stack.get_amount()

		stored_materials[material] += total_material

	qdel(I)
	playsound(loc, 'sound/items/welder.ogg', 30, 1)
