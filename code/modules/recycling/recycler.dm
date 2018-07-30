
/obj/machinery/recycler
	name = "recycler"
	desc = "A large crushing machine used to recycle trash."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "separator-AO1"
	layer = ABOVE_MOB_LAYER
	anchored = 1
	density = 1
	var/recycle_dir = NORTH
	var/list/stored_matter =  list("metal" = 0, "glass" = 0)
	var/last_recycle_sound //for sound cooldown
	var/ignored_items = list(/obj/item/limb)

/obj/machinery/recycler/New()
	..()
	update_icon()


/obj/machinery/recycler/power_change()
	..()
	update_icon()


/obj/machinery/recycler/update_icon()
	icon_state = "separator-AO[(stat & (BROKEN|NOPOWER)) ? "0":"1"]"


/obj/machinery/recycler/Bumped(atom/movable/AM)
	if(stat & (BROKEN|NOPOWER))
		return
	var/move_dir = get_dir(loc, AM.loc)
	if(!AM.anchored && move_dir == recycle_dir)
		if(istype(AM, /obj/item))
			recycle(AM)
		else
			AM.loc = loc


/obj/machinery/recycler/proc/recycle(obj/item/I)
	var/turf/T = get_turf(I)

	for(var/forbidden_path in ignored_items)
		if(istype(I, forbidden_path))
			I.loc = loc
			return

	if(istype(I, /obj/item/storage))
		var/obj/item/storage/S = I
		for(var/obj/item/X in S.contents)
			S.remove_from_storage(X, T)
			recycle(X)

	if(I.matter)
		for(var/material in I.matter)
			if(isnull(stored_matter[material]))
				continue
			var/total_material = I.matter[material]
			//If it's a stack, we eat multiple sheets.
			if(istype(I,/obj/item/stack))
				var/obj/item/stack/stack = I
				total_material *= stack.get_amount()

			stored_matter[material] += total_material
	cdel(I)
	if(last_recycle_sound < world.time)
		playsound(loc, 'sound/items/Welder.ogg', 30, 1)
		last_recycle_sound = world.time + 50

