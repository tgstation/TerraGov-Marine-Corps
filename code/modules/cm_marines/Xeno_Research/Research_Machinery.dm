/obj/machinery/Research_Machinery
	name = "Research Machinery"
	icon = 'icons/Marine/Research/Research_Machinery.dmi'
	density = TRUE
	anchored = TRUE

	var/obj/machinery/computer/XenoRnD/linked_console = null

	var/busy = FALSE
	var/opened = FALSE
	use_power = TRUE
	idle_power_usage = 30
	active_power_usage = 2500

/obj/machinery/Research_Machinery/attackby(var/obj/O as obj, var/mob/user as mob)
	if (istype(O, /obj/item/tool/screwdriver))
		if (!opened)
			opened = TRUE
			if(linked_console)
				linked_console.linked_dissector = null
				linked_console = null
			icon_state = "d_analyzer_t"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			opened = FALSE
			icon_state = "d_analyzer"
			to_chat(user, "You close the maintenance hatch of [src].")
		return
	if (opened)
		if(istype(O, /obj/item/tool/crowbar))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				I.loc = src.loc
			qdel(src)
			return TRUE
		else
			to_chat(user, "\red You can't load into [src] while it's opened.")
			return TRUE
	if (!linked_console)
		to_chat(user, "\red The [src] must be linked to an R&D console first!")
		return
	if (busy)
		to_chat(user, "\red The [src] is busy right now.")
		return

//Organic Dissector
/obj/machinery/Research_Machinery/dissector
	name = "Organic dissector"
	icon_state = "d_analyzer"
	var/obj/item/marineResearch/xenomorph/loaded_item = null
	var/decon_mod = TRUE

	idle_power_usage = 30
	active_power_usage = 2500

/obj/machinery/Research_Machinery/dissector/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/dissector(src) //We'll need it's own board one day.
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	return INITIALIZE_HINT_NORMAL

/obj/machinery/Research_Machinery/dissector/attackby(var/obj/O as obj, var/mob/user as mob)
	. = ..()
	if(.)
		return TRUE
	if (istype(O, /obj/item) && !loaded_item)
		if(isrobot(user)) //Don't put your module items in there!
			return
		if(istype(O, /obj/item/sampler))
			var/obj/item/sampler/A = O
			if(!A.filled)
				to_chat(user, "\red [O.name] is empty!")
				return TRUE
			A.filled = FALSE
			loaded_item = A.sample
			A.sample = null
			A.update_icon()
			to_chat(user, "\blue You add the [loaded_item.name] to the machine!")
			flick("d_analyzer_la", src)
			spawn(10)
				icon_state = "d_analyzer_l"
				busy = FALSE
			return TRUE
		if(!istype(O, /obj/item/marineResearch/xenomorph))
			to_chat(user, "\red Can't do anything with that, maybe something organic...!")
			return
		busy = TRUE
		loaded_item = O
		user.drop_held_item()
		O.loc = src
		to_chat(user, "\blue You add the [O.name] to the machine!")
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = FALSE
		return TRUE
	else
		to_chat(user, "\red Can't do anything with that, maybe something organic...!")
	return

//Armory Protolathe
/obj/machinery/Research_Machinery/marineprotolathe
	name = "Armory Protolathe"
	icon_state = "protolathe"
	flags_atom = OPENCONTAINER

	idle_power_usage = 30
	active_power_usage = 5000

	var/list/material_storage = list("metal" = 0.0, "glass" = 0.0, "biomass" = 0.0)
	var/max_stored = 100000
	var/list/max_per_resource = list("metal" = null, "glass" = null, "biomass" = null)

/obj/machinery/Research_Machinery/marineprotolathe/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/marineprotolathe(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	RefreshParts()
	return INITIALIZE_HINT_NORMAL

/obj/machinery/Research_Machinery/marineprotolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	return material_storage["metal"] + material_storage["glass"] + material_storage["biomass"]

/obj/machinery/Research_Machinery/marineprotolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_stored= T * 7500
	max_per_resource = list("metal" = round(max_stored/3), "glass" = round(max_stored/3), "biomass" = round(max_stored/3))

/obj/machinery/Research_Machinery/marineprotolathe/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (O.is_open_container())
		return TRUE
	if (istype(O, /obj/item/tool/screwdriver))
		if (!opened)
			opened = TRUE
			if(linked_console)
				linked_console.linked_lathe = null
				linked_console = null
			icon_state = "protolathe_off"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			opened = FALSE
			icon_state = "protolathe"
			to_chat(user, "You close the maintenance hatch of [src].")
		return
	if (opened)
		if(istype(O, /obj/item/tool/crowbar))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				I.loc = src.loc
			if(material_storage["metal"] >= 3750)
				var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal(src.loc)
				G.amount = round(material_storage["metal"] / G.perunit)
			if(material_storage["glass"] >= 3750)
				var/obj/item/stack/sheet/glass/G = new /obj/item/stack/sheet/glass(src.loc)
				G.amount = round(material_storage["glass"] / G.perunit)
			if(material_storage["biomass"] > 0)
				visible_message("<span class='danger'>All biomass has been splattered across the floor!</span>")
				new /obj/effect/decal/cleanable/blood/xeno(src.loc)
			if(linked_console)
				linked_console.linked_lathe = null
				linked_console = null
			qdel(src)
			return TRUE

	if(istype(O, /obj/item/marineResearch/xenomorph))
		if(TotalMaterials() > max_stored)
			return TRUE
		if(max_per_resource["biomass"] <= material_storage["biomass"])
			to_chat(user, "\red The protolathe's biomass bin is full.")
			return TRUE
		user.drop_held_item()
		material_storage["biomass"] += 500
		qdel(O)
		return TRUE

	if(istype(O, /obj/item/sampler))
		var/obj/item/sampler/samp = O
		if(!samp.filled)
			to_chat(user, "\red Sampler is empty!")
			return TRUE
		if(max_per_resource["biomass"] <= material_storage["biomass"])
			to_chat(user, "\red The protolathe's biomass bin is full.")
			return TRUE
		material_storage["biomass"] += 50
		samp.filled = FALSE
		samp.sample = null
		samp.update_icon()
		return TRUE

	if(istype(O,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = O
		if (material_storage[S.name] + S.perunit > max_per_resource[S.name])
			to_chat(user, "\red The protolathe's [S.name] material bin is full. Please remove material before adding more.")
			return TRUE

	var/obj/item/stack/sheet/stack = O
	var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
	if(!O)
		return
	if(amount < 0)//No negative numbers
		amount = 0
	if(amount == 0)
		return
	if(amount > stack.get_amount())
		amount = stack.get_amount()
	if(istype(stack, /obj/item/stack/sheet/metal))
		if(max_per_resource["metal"] - material_storage[stack.name] < (amount*stack.perunit))//Can't overfill
			amount = min(stack.amount, round((max_per_resource[stack.name] - material_storage[stack.name])/stack.perunit))
	if(istype(stack, /obj/item/stack/sheet/glass))
		if(max_per_resource["glass"] - material_storage[stack.name] < (amount*stack.perunit))//Can't overfill
			amount = min(stack.amount, round((max_per_resource[stack.name] - material_storage[stack.name])/stack.perunit))

	busy = TRUE
	use_power(max(1000, (3750*amount/10)))
	stack.use(amount)
	to_chat(user, "\blue You add [amount] sheets to the [src.name].")
	if(istype(stack, /obj/item/stack/sheet/metal))
		material_storage["metal"] += amount * 3750
	if(istype(stack, /obj/item/stack/sheet/glass))
		material_storage["glass"] += amount * 3750
	busy = FALSE
	src.updateUsrDialog()