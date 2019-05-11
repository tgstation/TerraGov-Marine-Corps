/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1
	var/unwrenched = 0
	var/wait = 0
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/machinery/pipedispenser/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/pipedispenser/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/pipedispenser/ui_interact(mob/user)
	. = ..()
	var/dat = "PIPING LAYER: <A href='?src=[REF(src)];layer_down=1'>--</A><b>[piping_layer]</b><A href='?src=[REF(src)];layer_up=1'>++</A><BR>"

	var/recipes = GLOB.atmos_pipe_recipes

	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		dat += "<b>[category]:</b><ul>"

		for(var/i in cat_recipes)
			var/datum/pipe_info/I = i
			dat += I.Render(src)

		dat += "</ul>"

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	onclose(user, "pipedispenser")
	return

/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..())
		return 1
	var/mob/living/L = usr
	if(!anchored || !istype(L) || L.incapacitated() || !in_range(loc, usr))
		usr << browse(null, "window=pipedispenser")
		return 1

	add_fingerprint(usr)
	if(href_list["makepipe"])
		if(wait < world.time)
			var/p_type = text2path(href_list["makepipe"])
			if (!verify_recipe(GLOB.atmos_pipe_recipes, p_type))
				return
			var/p_dir = text2num(href_list["dir"])
			var/obj/item/pipe/P = new (loc, p_type, p_dir)
			P.setPipingLayer(piping_layer)
			P.add_fingerprint(usr)
			wait = world.time + 10
	if(href_list["makemeter"])
		if(wait < world.time )
			new /obj/item/pipe_meter(loc)
			wait = world.time + 15
	if(href_list["layer_up"])
		piping_layer = CLAMP(++piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	if(href_list["layer_down"])
		piping_layer = CLAMP(--piping_layer, PIPING_LAYER_MIN, PIPING_LAYER_MAX)
	ui_interact(L)
	return

/obj/machinery/pipedispenser/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if (istype(W, /obj/item/pipe) || istype(W, /obj/item/pipe_meter))
		to_chat(usr, "<span class='notice'>You put [W] back into [src].</span>")
		qdel(W)
		return
	else if (iswrench(W))
		if (unwrenched==FALSE)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You begin to unfasten \the [src] from the floor...</span>")
			if (do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
				user.visible_message( \
					"[user] unfastens \the [src].", \
					"<span class='notice'> You have unfastened \the [src]. Now it can be pulled somewhere else.</span>", \
					"You hear ratchet.")
				anchored = FALSE
				machine_stat |= MAINT
				unwrenched = TRUE
				if (usr.interactee==src)
					usr << browse(null, "window=pipedispenser")
		else /*if (unwrenched==1)*/
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You begin to fasten \the [src] to the floor...</span>")
			if (do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
				user.visible_message( \
					"[user] fastens \the [src].", \
					"<span class='notice'> You have fastened \the [src]. Now it can dispense pipes.</span>", \
					"You hear ratchet.")
				anchored = TRUE
				machine_stat &= ~MAINT
				unwrenched = FALSE
				power_change()
	else
		return ..()

/obj/machinery/pipedispenser/proc/verify_recipe(recipes, path)
	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		for(var/i in cat_recipes)
			var/datum/pipe_info/info = i
			if (path == info.id)
				return TRUE
	return FALSE

/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = 1
	anchored = 1.0
/obj/machinery/pipedispenser/disposal
	name = "disposal pipe dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	desc = "Dispenses pipes that will ultimately be used to move trash around."
	density = TRUE


//Allow you to drag-drop disposal pipes and transit tubes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/pipe, mob/usr)
	if(!usr.incapacitated())
		return

	if (!istype(pipe, /obj/structure/disposalconstruct))
		return

	if (get_dist(usr, src) > 1 || get_dist(src,pipe) > 1 )
		return

	if (pipe.anchored)
		return

	qdel(pipe)

/obj/machinery/pipedispenser/disposal/attack_hand(mob/user)

	var/dat = ""
	var/recipes = GLOB.disposal_pipe_recipes

	for(var/category in recipes)
		var/list/cat_recipes = recipes[category]
		dat += "<b>[category]:</b><ul>"

		for(var/i in cat_recipes)
			var/datum/pipe_info/I = i
			dat += I.Render(src)

		dat += "</ul>"

	user << browse("<HEAD><TITLE>[src]</TITLE></HEAD><TT>[dat]</TT>", "window=pipedispenser")
	return


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	if(..())
		return 1
	add_fingerprint(usr)
	if(href_list["dmake"])
		if(wait < world.time)
			var/p_type = text2path(href_list["dmake"])
			if (!verify_recipe(GLOB.disposal_pipe_recipes, p_type))
				return
			var/obj/structure/disposalconstruct/C = new (loc, p_type)

			//if(!C.can_place())
			//	to_chat(usr, "<span class='warning'>There's not enough room to build that here!</span>")
			//	qdel(C)
			//	return
			if(href_list["dir"])
				C.setDir(text2num(href_list["dir"]))
			C.add_fingerprint(usr)
			C.update_icon()
			wait = world.time + 15
	return

// adding a pipe dispensers that spawn unhooked from the ground
/obj/machinery/pipedispenser/orderable
	anchored = 0
	unwrenched = 1

/obj/machinery/pipedispenser/disposal/orderable
	anchored = 0
	unwrenched = 1
