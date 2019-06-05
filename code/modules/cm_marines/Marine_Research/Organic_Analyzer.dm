//This is the Organic Analyzer, used to analyzie Xeno parts and organs.  It will DESTROY THE COMPONENT.
//I'm thinking that "autopsy" will generate a "vial" of blood, pieces of Chitin, and a rando organ.

/*
Note: Must be placed within 3 tiles of the NT Research Console
*/
/obj/machinery/r_n_d/organic_analyzer
	name = "Nanotrasen Brand Organic Analyzer(TM)"
	icon_state = "d_analyzer"
	var/obj/item/loaded_item = null
	var/decon_mod = 1

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 2500

/obj/machinery/r_n_d/organic_analyzer/New()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/destructive_analyzer(src) //We'll need it's own board one day.
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	RefreshParts()

/obj/machinery/r_n_d/organic_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in src)
		T += S.rating * 0.1
	T = between (0, T, 1)
	decon_mod = T

/obj/machinery/r_n_d/organic_analyzer/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/organic_analyzer/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(shocked)
		shock(user, 50)

	else if(isscrewdriver(I))
		opened = !opened
		if(opened)
			if(linked_console)
				linked_console.linked_destroy = null
				linked_console = null
			icon_state = "d_analyzer_t"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			icon_state = "d_analyzer"
			to_chat(user, "You close the maintenance hatch of [src].")

	else if(opened)
		if(!iscrowbar(I))
			to_chat(user, "<span class='warning'>You can't load the [name] while it's opened.</span>")
			return TRUE

		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/O in component_parts)
			O.forceMove(loc)
		qdel(src)
		return TRUE

	else if(disabled)
		return

	else if(!linked_console)
		to_chat(user, "<span class='warning'> The Nanotrasen Brand Organic Analyzer must be linked to an R&D console first!</span>")
		return

	else if(busy)
		to_chat(user, "<span class='warning'> The Nanotrasen Brand Organic Analyzer is busy right now.</span>")
		return

	if(istype(I, /obj/item/XenoBio) && !loaded_item)
		if(!I.origin_tech)
			to_chat(user, "<span class='warning'>Can't do anything with that, maybe something organic...!</span>")
			return
		loaded_item = I
		user.drop_held_item()
		I.forceMove(src)
		to_chat(user, "<span class='notice'>You add the [I] to the machine!</span>")
		flick("d_analyzer_la", src)