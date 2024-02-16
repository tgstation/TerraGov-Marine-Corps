/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	anchored = TRUE
	coverage = 30
	var/wait = 0
	var/piping_layer = PIPING_LAYER_DEFAULT


/obj/machinery/pipedispenser/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = "PIPING LAYER: <A href='?src=[REF(src)];layer_down=1'>--</A><b>[piping_layer]</b><A href='?src=[REF(src)];layer_up=1'>++</A><BR>"

	var/recipes = GLOB.atmos_pipe_recipes

	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		dat += "<b>[category]:</b><ul>"

		for(var/i in cat_recipes)
			var/datum/pipe_info/I = i
			dat += I.Render(src)

		dat += "</ul>"

	var/datum/browser/popup = new(user, "pipedispenser", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/pipedispenser/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["makepipe"])
		if(wait < world.time)
			var/p_type = text2path(href_list["makepipe"])
			if (!verify_recipe(GLOB.atmos_pipe_recipes, p_type))
				return
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/pipe/P = new (loc, p_type, p_dir)
			P.setPipingLayer(piping_layer)
			wait = world.time + 10

	if(href_list["makemeter"])
		if(wait < world.time )
			new /obj/item/pipe_meter(loc)
			wait = world.time + 15

	if(href_list["layer_up"])
		piping_layer = clamp(++piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX)

	if(href_list["layer_down"])
		piping_layer = clamp(--piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX)

	updateUsrDialog()


/obj/machinery/pipedispenser/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/pipe) || istype(I, /obj/item/pipe_meter))
		to_chat(usr, span_notice("You put [I] back into [src]."))
		qdel(I)

	else if(iswrench(I))
		if(anchored)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, span_notice("You begin to unfasten \the [src] from the floor..."))

			if(!do_after(user, 40, NONE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("[user] unfastens \the [src].", \
				span_notice(" You have unfastened \the [src]. Now it can be pulled somewhere else."), \
				"You hear ratchet.")
			anchored = FALSE
			machine_stat |= MAINT

			if(user.interactee == src)
				usr << browse(null, "window=pipedispenser")
		else
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, span_notice("You begin to fasten \the [src] to the floor..."))

			if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD))
				return

			user.visible_message("[user] fastens \the [src].", \
				span_notice(" You have fastened \the [src]. Now it can dispense pipes."), \
				"You hear ratchet.")
			anchored = TRUE
			machine_stat &= ~MAINT
			power_change()

/obj/machinery/pipedispenser/proc/verify_recipe(recipes, path)
	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		for(var/i in cat_recipes)
			var/datum/pipe_info/info = i
			if (path == info.id)
				return TRUE
	return FALSE


/obj/machinery/pipedispenser/disposal
	name = "disposal pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses pipes that will ultimately be used to move trash around."


//Allow you to drag-drop disposal pipes and transit tubes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/disposalconstruct/pipe, mob/user)
	. = ..()
	if(user.incapacitated() || !istype(pipe) || get_dist(user, src) > 1 || get_dist(src, pipe) > 1 || pipe.anchored)
		return

	user.balloon_alert(user, "Recycled pipe.")
	qdel(pipe)

/obj/machinery/pipedispenser/disposal/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat = ""
	var/recipes = GLOB.disposal_pipe_recipes

	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		dat += "<b>[category]:</b><ul>"

		for(var/i in cat_recipes)
			var/datum/pipe_info/I = i
			dat += I.Render(src)

		dat += "</ul>"

	var/datum/browser/popup = new(user, "pipedispenser", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["dmake"])
		if(wait < world.time)
			var/p_type = text2path(href_list["dmake"])
			if (!verify_recipe(GLOB.disposal_pipe_recipes, p_type))
				return
			var/obj/structure/disposalconstruct/C = new (loc, p_type)

			//if(!C.can_place())
			//	to_chat(usr, span_warning("There's not enough room to build that here!"))
			//	qdel(C)
			//	return
			if(href_list["dir"])
				C.setDir(text2num(href_list["dir"]))
			C.update_icon()
			wait = world.time + 15

// adding a pipe dispensers that spawn unhooked from the ground
/obj/machinery/pipedispenser/orderable
	anchored = FALSE

/obj/machinery/pipedispenser/disposal/orderable
	anchored = FALSE
