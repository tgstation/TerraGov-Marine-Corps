/*
BioPrinter.
Basically a cheap knock-off of the Protolathe that I wrote in the middle of the night...

*/
/obj/machinery/r_n_d/bioprinter
	name = "Weyland Yutani Brand Bio-Organic Printer(TM)"
	icon_state = "protolathe"
	flags_atom = OPENCONTAINER

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 5000

	var/max_material_storage = 100000 //Probably need to adjust this eventually....
	var/resin_amount = 0.0
	var/blood_amount = 0.0
	var/chitin_amount = 0.0

/obj/machinery/r_n_d/bioprinter/New()
	..()
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
	var/datum/reagents/R = new/datum/reagents(T)		//Holder for the reagents used as materials.
	reagents = R
	R.my_atom = src
	T = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000

/obj/machinery/r_n_d/bioprinter/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (O.is_open_container())
		return 1
	if (istype(O, /obj/item/tool/screwdriver))
		if (!opened)
			opened = 1
			if(linked_console)
				linked_console.linked_lathe = null
				linked_console = null
			icon_state = "protolathe_t"
			user << "You open the maintenance hatch of [src]."
		else
			opened = 0
			icon_state = "protolathe"
			user << "You close the maintenance hatch of [src]."
		return
	if (opened)
		if(istype(O, /obj/item/tool/crowbar))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(istype(I, /obj/item/reagent_container/glass/beaker))
					reagents.trans_to(I, reagents.total_volume)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			while(blood_amount>0)
				new /obj/item/XenoBio/Blood(src.loc)
			while(chitin_amount>0)
				new /obj/item/XenoBio/Chitin(src.loc)
			while(resin_amount>0)
				new /obj/item/XenoBio/Resin(src.loc)
			cdel(src)
			return 1
		else
			user << "\red You can't load the [src.name] while it's opened."
			return 1
	if (disabled)
		return
	if (!linked_console)
		user << "\The Weyland Yutani Brand Bioprinter(TM) must be linked to an R&D console first!"
		return 1
	if (busy)
		user << "\red The Weyland Yutani Brand Bioprinter(TM) is busy. Please wait for completion of previous operation."
		return 1
	if (!istype(O, /obj/item/XenoBio))
		user << "\red You cannot insert this item into the protolathe!"
		return 1
	if (stat)
		return 1

	icon_state = "protolathe"
	busy = 1
	use_power(max(1000, (3750)))
	if (do_after(user, 16, TRUE, 5, BUSY_ICON_GENERIC))
		user << "\blue You add a [O] to the [src.name]."
		icon_state = "protolathe"
		if(istype(O, /obj/item/XenoBio/Blood))
			blood_amount++
			cdel(O)
		if(istype(O, /obj/item/XenoBio/Chitin))
			chitin_amount++
			cdel(O)
		if(istype(O, /obj/item/XenoBio/Resin))
			resin_amount++
			cdel(O)
	busy = 0
	src.updateUsrDialog()
	return


/obj/machinery/r_n_d/bioprinter/attack_hand(mob/user as mob)
	return