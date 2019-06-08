/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	icon_state = "protolathe"

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 5000

	var/max_material_storage = 100000 //All this could probably be done better with a list but meh.
	var/m_amount = 0.0
	var/g_amount = 0.0
	var/gold_amount = 0.0
	var/silver_amount = 0.0
	var/phoron_amount = 0.0
	var/uranium_amount = 0.0
	var/diamond_amount = 0.0


/obj/machinery/r_n_d/protolathe/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/protolathe(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/reagent_container/glass/beaker(src)
	component_parts += new /obj/item/reagent_container/glass/beaker(src)
	RefreshParts()


/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	return m_amount + g_amount + gold_amount + silver_amount + phoron_amount + uranium_amount + diamond_amount

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/reagent_container/glass/G in component_parts)
		T += G.reagents.maximum_volume
	create_reagents(T, REFILLABLE)
	T = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000

/obj/machinery/r_n_d/protolathe/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(shocked)
		shock(user, 50)

	else if(I.is_open_container())
		return TRUE

	else if(isscrewdriver(I))
		opened = !opened
		if(opened)
			if(linked_console)
				linked_console.linked_lathe = null
				linked_console = null
			icon_state = "protolathe_t"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			icon_state = "protolathe"
			to_chat(user, "You close the maintenance hatch of [src].")

	else if(opened)
		if(!iscrowbar(I))
			to_chat(user, "<span class='warning'>You can't load \the [src] while it's opened.</span>")
			return TRUE

		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/O in component_parts)
			if(istype(O, /obj/item/reagent_container/glass/beaker))
				reagents.trans_to(O, reagents.total_volume)
			if(O.reliability != 100 && crit_fail)
				O.crit_fail = TRUE
			O.forceMove(loc)
		if(m_amount >= 3750)
			var/obj/item/stack/sheet/metal/G = new(loc)
			G.amount = round(m_amount / G.perunit)
		if(g_amount >= 3750)
			var/obj/item/stack/sheet/glass/G = new(loc)
			G.amount = round(g_amount / G.perunit)
		if(phoron_amount >= 2000)
			var/obj/item/stack/sheet/mineral/phoron/G = new(loc)
			G.amount = round(phoron_amount / G.perunit)
		if(silver_amount >= 2000)
			var/obj/item/stack/sheet/mineral/silver/G = new(loc)
			G.amount = round(silver_amount / G.perunit)
		if(gold_amount >= 2000)
			var/obj/item/stack/sheet/mineral/gold/G = new(loc)
			G.amount = round(gold_amount / G.perunit)
		if(uranium_amount >= 2000)
			var/obj/item/stack/sheet/mineral/uranium/G = new(loc)
			G.amount = round(uranium_amount / G.perunit)
		if(diamond_amount >= 2000)
			var/obj/item/stack/sheet/mineral/diamond/G = new(loc)
			G.amount = round(diamond_amount / G.perunit)
		qdel(src)
		return TRUE

	else if(disabled)
		return

	else if(!linked_console)
		to_chat(user, "\The protolathe must be linked to an R&D console first!")
		return TRUE

	else if(busy)
		to_chat(user, "<span class='warning'>The protolathe is busy. Please wait for completion of previous operation.</span>")
		return TRUE

	else if(!istype(I, /obj/item/stack/sheet))
		to_chat(user, "<span class='warning'>You cannot insert this item into the protolathe!</span>")
		return TRUE

	else if(machine_stat)
		return TRUE

	else
		var/obj/item/stack/sheet/stack = I
		if(TotalMaterials() + stack.perunit > max_material_storage)
			to_chat(user, "<span class='warning'>The protolathe's material bin is full. Please remove material before adding more.</span>")
			return TRUE

		var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
		if(QDELETED(I))
			return
		if(amount < 0)//No negative numbers
			amount = 0
		if(amount == 0)
			return
		if(amount > stack.get_amount())
			amount = stack.get_amount()
		if(max_material_storage - TotalMaterials() < (amount*stack.perunit))//Can't overfill
			amount = min(stack.amount, round((max_material_storage-TotalMaterials())/stack.perunit))

		overlays += "protolathe_[stack.name]"
		sleep(10)
		overlays -= "protolathe_[stack.name]"

		icon_state = "protolathe"
		busy = TRUE
		use_power(max(1000, (3750 * amount / 10)))
		var/stacktype = stack.type
		stack.use(amount)

		if(!do_after(user, 15, TRUE, src))
			return

		to_chat(user, "<span class='notice'>You add [amount] sheets to \the [src].</span>")
		icon_state = "protolathe"
		switch(stacktype)
			if(/obj/item/stack/sheet/metal)
				m_amount += amount * 3750
			if(/obj/item/stack/sheet/glass)
				g_amount += amount * 3750
			if(/obj/item/stack/sheet/mineral/gold)
				gold_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/silver)
				silver_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/phoron)
				phoron_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/uranium)
				uranium_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/diamond)
				diamond_amount += amount * 2000
			else
				new stacktype(loc, amount)
		busy = FALSE
		updateUsrDialog()

//This is to stop these machines being hackable via clicking.
/obj/machinery/r_n_d/protolathe/attack_hand(mob/user as mob)
	return