#define MAX_SUPPLY_DROPS 4

/obj/machinery/computer/supplydrop_console
	name = "supply drop console"
	desc = "used by shipside staff to issue supply drops to squad beacons"
	icon_state = "supplydrop"
	interaction_flags = INTERACT_MACHINE_TGUI
	///Time between two supply drops
	var/launch_cooldown = 2 MINUTES
	COOLDOWN_DECLARE(next_fire)
	///If true, the last squad will be memorised
	var/squad_lock = null
	///The squad wich we will look for beacons
	var/datum/squad/current_squad = null
	///The beacon we will send the supplies
	var/obj/item/squad_beacon/current_beacon = null
	///The content sent
	var/list/supplies = list()
	///X offset of the drop, relative to the supply beacon loc
	var/x_offset = 0
	///Y offset of the drop, relative to the supply beacon loc
	var/y_offset = 0

/obj/machinery/computer/supplydrop_console/Initialize()
	. = ..()
	if(!isnull(squad_lock))
		current_squad = SSjob.squads[squad_lock]

/obj/machinery/computer/supplydrop_console/Destroy()
	current_squad = null
	current_beacon = null
	return ..()

/obj/machinery/computer/supplydrop_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SupplyDropConsole", name)
		ui.open()


/obj/machinery/computer/supplydrop_console/ui_static_data(mob/user)
	. = ..()
	.["squads"] = list()
	for(var/squad in SSjob.active_squads)
		.["squads"] += list(squad)

/obj/machinery/computer/supplydrop_console/ui_data(mob/user)
	. = ..()
	.["squad_lock"] = squad_lock
	.["launch_cooldown"] = launch_cooldown
	.["current_squad"] = current_squad?.name
	.["current_beacon"] = list(
		"name" = current_squad?.sbeacon?.name,
		"x_coords" = current_squad?.sbeacon?.loc.x,
		"y_coords" = current_squad?.sbeacon?.loc.y
	)
	.["supplies_count"] = length(supplies)
	.["next_fire"] = COOLDOWN_TIMELEFT(src, next_fire)
	.["x_offset"] = x_offset
	.["y_offset"] = y_offset


/obj/machinery/computer/supplydrop_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_squad")
			var/datum/squad/selected_squad = SSjob.squads[params["select_squad"]]
			if(!istype(selected_squad))
				return
			current_squad = selected_squad
			refresh_squad_pad()

		if("set_x")
			var/new_x = text2num(params["set_x"])
			if(!new_x)
				return
			x_offset = new_x

		if("set_y")
			var/new_y = text2num(params["set_y"])
			if(!new_y)
				return
			y_offset = new_y

		if("refresh_pad")
			refresh_squad_pad()

		if("send_beacon")
			if(!COOLDOWN_CHECK(src, next_fire))
				return

			if(!current_squad?.sbeacon)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>There was an issue with that squads beacon. Check it's still active.</span>")
				return

			if(!length(supplies))
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>There wasn't any supplies found on the squads supply pad. Double check the pad.</span>")
				return

			var/area/A = get_area(current_squad.sbeacon)
			if(A && A.ceiling >= CEILING_DEEP_UNDERGROUND)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [current_squad.sbeacon.name]'s signal is too weak. It is probably deep underground.</span>")
				return

			var/turf/T = get_turf(current_squad.sbeacon)
			if(!istype(T))
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [current_squad.sbeacon.name] was not detected on the ground.</span>")
				return
			if(isspaceturf(T) || T.density)
				to_chat(usr, "[icon2html(src, usr)] <span class='warning'>The [current_squad.sbeacon.name]'s landing zone appears to be obstructed or out of bounds.</span>")
				return

			COOLDOWN_START(src, next_fire, launch_cooldown)
			current_squad.send_supplydrop(supplies, x_offset, y_offset)

///Look for the corresponding drop pad, and its possible content
/obj/machinery/computer/supplydrop_console/proc/refresh_squad_pad()
	if(!current_squad) //Prevent runtime error
		return
	supplies = list()
	if(!current_squad.drop_pad) //The links somewhat disapear after loading the map, didn't find the cause
		for(var/obj/structure/supply_drop/S in GLOB.supply_pad_list)
			S.force_link()
	for(var/obj/C in current_squad.drop_pad.loc)
		if(is_type_in_typecache(C, GLOB.supply_drops) && !C.anchored) //Can only send vendors and crates
			supplies.Add(C)
		if(supplies.len > MAX_SUPPLY_DROPS)
			break

///Start the supply drop process
/datum/squad/proc/send_supplydrop(list/supplies, x_offset = 0, y_offset = 0)
	if(!sbeacon)
		stack_trace("Trying to send a supply drop without a squad beacon")
		return

	if(!length(supplies) || length(supplies) > MAX_SUPPLY_DROPS)
		stack_trace("Trying to send a supply drop with an invalid amount of items [length(supplies)]")
		return

	var/turf/T = get_turf(sbeacon)
	if(!istype(T) || isspaceturf(T) || T.density)
		stack_trace("Trying to send a supply drop to a beacon on an invalid turf")
		return

	x_offset = clamp(round(x_offset), -5, 5)
	y_offset = clamp(round(y_offset), -5, 5)

	drop_pad.visible_message("<span class='boldnotice'>The supply drop is now loading into the launch tube! Stand by!</span>")
	drop_pad.visible_message("<span class='warning'>\The [drop_pad] whirrs as it beings to load the supply drop into a launch tube. Stand clear!</span>")
	for(var/obj/C in supplies)
		C.anchored = TRUE //to avoid accidental pushes
	message_squad("Supply Drop Incoming!")
	playsound(drop_pad.loc, 'sound/effects/bamf.ogg', 50, TRUE) 
	sbeacon.visible_message("[icon2html(sbeacon, viewers(sbeacon))] <span class='boldnotice'>The [sbeacon.name] begins to beep!</span>")
	addtimer(CALLBACK(src, .proc/fire_supplydrop, supplies, x_offset, y_offset), 10 SECONDS)

///Make the supplies teleport
/datum/squad/proc/fire_supplydrop(list/supplies, x_offset, y_offset)
	if(QDELETED(sbeacon))
		drop_pad.visible_message("[icon2html(drop_pad, usr)] <span class='warning'>Launch aborted! Supply beacon signal lost.</span>")
		return

	for(var/obj/C in supplies)
		if(QDELETED(C))
			supplies.Remove(C)
			continue
		if(C.loc != drop_pad.loc) //Crate no longer on pad somehow, abort.
			supplies.Remove(C)
			C.anchored = FALSE

	if(!supplies.len)
		drop_pad.visible_message("[icon2html(drop_pad, usr)] <span class='warning'>Launch aborted! No deployable object detected on the drop pad.</span>")
		return

	var/turf/T = get_turf(sbeacon)
	T.visible_message("<span class='boldnotice'>A supply drop falls from the sky!</span>")
	playsound(T,'sound/effects/bamf.ogg', 50, TRUE)  //Ehhhhhhhhh.
	playsound(drop_pad.loc,'sound/effects/bamf.ogg', 50, TRUE)  //Ehh
	for(var/obj/C in supplies)
		C.anchored = FALSE
		var/turf/TC = locate(T.x + x_offset, T.y + y_offset, T.z)
		C.forceMove(TC)
		TC.ceiling_debris_check(2)
	drop_pad.visible_message("[icon2html(drop_pad, viewers(src))] <span class='boldnotice'>Supply drop launched! Another launch will be available in two minutes.</span>")
