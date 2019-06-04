/*
BioPrinter.
Basically a cheap knock-off of the Protolathe that I wrote in the middle of the night...

*/
/obj/machinery/r_n_d/bioprinter
	name = "Nanotrasen Brand Bio-Organic Printer(TM)"
	icon_state = "protolathe"

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 5000

	var/max_material_storage = 100000 //Probably need to adjust this eventually....
	var/resin_amount = 0.0
	var/blood_amount = 0.0
	var/chitin_amount = 0.0

/obj/machinery/r_n_d/bioprinter/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/protolathe(src) //We'll need to make our own board one day
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/reagent_container/glass/beaker(src)
	component_parts += new /obj/item/reagent_container/glass/beaker(src)
	RefreshParts()

/obj/machinery/r_n_d/bioprinter/proc/TotalMaterials()
	return resin_amount+blood_amount+chitin_amount

/obj/machinery/r_n_d/bioprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/reagent_container/glass/G in component_parts)
		T += G.reagents.maximum_volume
	create_reagents(T, REFILLABLE)
	T = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000

/obj/machinery/r_n_d/bioprinter/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(shocked)
		shock(user,50)
		return TRUE

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
		return TRUE

	else if(opened)
		if(!iscrowbar(I))
			to_chat(user, "<span class='warning'>You can't load the [src] while it's opened.</span>")
			return TRUE

		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/O in component_parts)
			if(istype(O, /obj/item/reagent_container/glass/beaker))
				reagents.trans_to(O, reagents.total_volume)
			if(O.reliability != 100 && crit_fail)
				O.crit_fail = 1
			O.forceMove(src)
		for(var/i in 1 to blood_amount)
			new /obj/item/XenoBio/Blood(loc)
		for(var/i in 1 to chitin_amount)
			new /obj/item/XenoBio/Chitin(loc)
		for(var/i in 1 to resin_amount)
			new /obj/item/XenoBio/Resin(loc)
		blood_amount = 0
		chitin_amount = 0
		resin_amount = 0
		qdel(src)
		return TRUE

	else if(disabled)
		return TRUE

	else if(!linked_console)
		to_chat(user, "\The Nanotrasen Brand Bioprinter(TM) must be linked to an R&D console first!")
		return TRUE

	else if(busy)
		to_chat(user, "<span class='warning'> The Nanotrasen Brand Bioprinter(TM) is busy. Please wait for completion of previous operation.</span>")
		return TRUE

	else if(!istype(I, /obj/item/XenoBio))
		to_chat(user, "<span class='warning'>You cannot insert this item into the protolathe!</span>")
		return TRUE

	else if(machine_stat)
		return TRUE

	icon_state = "protolathe"
	busy = TRUE
	use_power(3750)

	if(!do_after(user, 16, TRUE, src))
		busy = FALSE
		return TRUE

	to_chat(user, "<span class='notice'>You add a [I] to the [src].</span>")
	icon_state = "protolathe"
	if(istype(I, /obj/item/XenoBio/Blood))
		blood_amount++
		qdel(I)
	else if(istype(I, /obj/item/XenoBio/Chitin))
		chitin_amount++
		qdel(I)
	else if(istype(I, /obj/item/XenoBio/Resin))
		resin_amount++
		qdel(I)

	busy = FALSE
	updateUsrDialog()


/obj/machinery/r_n_d/bioprinter/attack_hand(mob/user as mob)
	return
