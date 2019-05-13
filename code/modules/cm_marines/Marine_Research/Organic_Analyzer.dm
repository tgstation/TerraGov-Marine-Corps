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


/obj/machinery/r_n_d/organic_analyzer/attackby(var/obj/O as obj, var/mob/user as mob)
	if (shocked)
		shock(user,50)
	if (isscrewdriver(O))
		if (!opened)
			opened = 1
			if(linked_console)
				linked_console.linked_destroy = null
				linked_console = null
			icon_state = "d_analyzer_t"
			to_chat(user, "You open the maintenance hatch of [src].")
		else
			opened = 0
			icon_state = "d_analyzer"
			to_chat(user, "You close the maintenance hatch of [src].")
		return
	if (opened)
		if(iscrowbar(O))
			playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				I.loc = src.loc
			qdel(src)
			return 1
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return 1
	if (disabled)
		return
	if (!linked_console)
		to_chat(user, "<span class='warning'> The Nanotrasen Brand Organic Analyzer must be linked to an R&D console first!</span>")
		return
	if (busy)
		to_chat(user, "<span class='warning'> The Nanotrasen Brand Organic Analyzer is busy right now.</span>")
		return
	if (istype(O, /obj/item/XenoBio) && !loaded_item)
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>Can't do anything with that, maybe something organic...!</span>")
			return
		//var/list/temp_tech = ConvertReqString2List(O.origin_tech) //This warning might just be Byond being silly.
		busy = 1
		loaded_item = O
		user.drop_held_item()
		O.loc = src
		to_chat(user, "<span class='notice'>You add the [O.name] to the machine!</span>")
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = 0
		return 1
	return
