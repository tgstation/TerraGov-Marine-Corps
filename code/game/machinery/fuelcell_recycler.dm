/obj/machinery/fuelcell_recycler
	name = "fuel cell recycler"
	desc = "A large machine with whirring fans and two cylindrical holes in the top. Used to regenerate fuel cells."
	icon = 'icons/Marine/fusion_eng.dmi'
	icon_state = "recycler"
	anchored = 1.0
	density = 1
	idle_power_usage = 5
	active_power_usage = 15000
	bound_height = 32
	bound_width = 32
	var/obj/item/fuelCell/cell_left = null
	var/obj/item/fuelCell/cell_right = null
	unacidable = 1

/obj/machinery/fuelcell_recycler/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/fuelCell))
		if(!cell_left)
			if(user.drop_inv_item_to_loc(I, src))
				cell_left = I
				start_processing()
		else if(!cell_right)
			if(user.drop_inv_item_to_loc(I, src))
				cell_right = I
				start_processing()
		else
			to_chat(user, "<span class='notice'>The recycler is full!</span>")
			return
		update_icon()
	else
		to_chat(user, "<span class='notice'>You can't see how you'd use [I] with [src]...</span>")
		return

/obj/machinery/fuelcell_recycler/attack_hand(mob/M)
	if(cell_left == null && cell_right == null)
		to_chat(M, "<span class='notice'>The recycler is empty.</span>")
		return

	add_fingerprint(M)

	if(cell_right == null)
		cell_left.update_icon()
		M.put_in_hands(cell_left)
		cell_left = null
		update_icon()
	else if(cell_left == null)
		cell_right.update_icon()
		M.put_in_hands(cell_right)
		cell_right = null
		update_icon()
	else
		if(cell_left.get_fuel_percent() > cell_right.get_fuel_percent())
			cell_left.update_icon()
			M.put_in_hands(cell_left)
			cell_left = null
			update_icon()
		else
			cell_right.update_icon()
			M.put_in_hands(cell_right)
			cell_right = null
			update_icon()

/obj/machinery/fuelcell_recycler/process()
	if(stat & (BROKEN|NOPOWER))
		update_use_power(0)
		update_icon()
		return
	if(!cell_left && !cell_right)
		update_use_power(1)
		update_icon()
		stop_processing()
		return
	else
		var/active = FALSE
		if(cell_left != null)
			if(!cell_left.is_regenerated())
				active = TRUE
				cell_left.give(active_power_usage*(CELLRATE * 0.1))
		if(cell_right != null)
			if(!cell_right.is_regenerated())
				active = TRUE
				cell_right.give(active_power_usage*(CELLRATE * 0.1))
		if(active)
			update_use_power(2)
		else
			update_use_power(1)
			stop_processing()

		update_icon()

/obj/machinery/fuelcell_recycler/power_change()
	..()
	update_icon()

/obj/machinery/fuelcell_recycler/update_icon()
	src.overlays.Cut()

	if(stat & (BROKEN|NOPOWER))
		icon_state = "recycler0"
		if(cell_left != null)
			src.overlays += "recycler-left-cell"
		if(cell_right != null)
			src.overlays += "recycler-right-cell"
		return
	else
		icon_state = "recycler"

	var/overlay_builder = "recycler-"
	if(cell_left == null && cell_right == null)
		return
	if(cell_right == null)
		if(cell_left.is_regenerated())
			overlay_builder += "left-charged"
		else
			overlay_builder += "left-charging"

		src.overlays += overlay_builder
		src.overlays += "recycler-left-cell"
		return
	else if(cell_left == null)
		if(cell_right.is_regenerated())
			overlay_builder += "right-charged"
		else
			overlay_builder += "right-charging"

		src.overlays += overlay_builder
		src.overlays += "recycler-right-cell"
		return
	else // both left and right cells are there
		if(cell_left.is_regenerated())
			overlay_builder += "left-charged"
		else
			overlay_builder += "left-charging"

		if(cell_right.is_regenerated())
			overlay_builder += "-right-charged"
		else
			overlay_builder += "-right-charging"

		src.overlays += overlay_builder
		src.overlays += "recycler-left-cell"
		src.overlays += "recycler-right-cell"
		return
