//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	icon_state = "d_analyzer"
	var/obj/item/loaded_item = null
	var/decon_mod = 1

	use_power = 1
	idle_power_usage = 30
	active_power_usage = 2500

/obj/machinery/r_n_d/destructive_analyzer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/destructive_analyzer(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/micro_laser(src)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/S in src)
		T += S.rating * 0.1
	T = between (0, T, 1)
	decon_mod = T

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(var/list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(obj/item/I, mob/user, params)
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
		if(iscrowbar(I))
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new(loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/O in component_parts)
				O.forceMove(loc)
			qdel(src)
			return TRUE
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return TRUE

	else if(disabled)
		return

	else if(!linked_console)
		to_chat(user, "<span class='warning'>The destructive analyzer must be linked to an R&D console first!</span>")

	else if(busy)
		to_chat(user, "<span class='warning'>The destructive analyzer is busy right now.</span>")

	else if(!loaded_item)
		if(!I.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return

		var/list/temp_tech = ConvertReqString2List(I.origin_tech)
		if(!length(temp_tech))
			to_chat(user, "<span class='warning'>You cannot deconstruct this item!</span>")
			return
		if(I.reliability < 90 && !I.crit_fail)
			to_chat(user, "<span class='warning'>Item is neither reliable enough nor broken enough to learn from.</span>")
			return
		busy = TRUE
		loaded_item = I
		user.transferItemToLoc(I, src)
		to_chat(user, "<span class='notice'>You add \the [I] to the machine!</span>")
		flick("d_analyzer_la", src)
		spawn(10)
			icon_state = "d_analyzer_l"
			busy = FALSE
		return TRUE

//For testing purposes only.
/*/obj/item/deconstruction_test
	name = "Test Item"
	desc = "WTF?"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "d20"
	g_amt = 5000
	m_amt = 5000
	origin_tech = "materials=5;phorontech=5;syndicate=5;programming=9"*/
