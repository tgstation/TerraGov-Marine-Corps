/obj/machinery/mech_bay_recharge_port
	name = "mech bay power port"
	desc = "This port recharges a mech's internal power cell."
	density = TRUE
	dir = EAST
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	///Weakref to currently recharging mech on our recharging_turf
	var/datum/weakref/recharging_mech_ref
	///Ref to charge console for seeing charge for this port, cyclical reference
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	///Power unit per second to charge by
	var/recharge_power = 25
	///turf that will be checked when a mech wants to charge. directly one turf in the direction it is facing
	var/turf/recharging_turf

/obj/machinery/mech_bay_recharge_port/Initialize(mapload)
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/Destroy()
	if (recharge_console?.recharge_port == src)
		recharge_console.recharge_port = null
	return ..()

/obj/machinery/mech_bay_recharge_port/setDir(new_dir)
	. = ..()
	recharging_turf = get_step(loc, dir)

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	. = ..()
	var/total_rating = 0
	for(var/obj/item/stock_parts/capacitor/cap in component_parts)
		total_rating += cap.rating
	recharge_power = total_rating * 12.5

/obj/machinery/mech_bay_recharge_port/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Recharge power <b>[siunit(recharge_power, "W", 1)]</b>.")

/obj/machinery/mech_bay_recharge_port/process(delta_time)
	if(machine_stat & NOPOWER || !recharge_console)
		return
	var/obj/vehicle/sealed/mecha/recharging_mech = recharging_mech_ref?.resolve()
	if(!recharging_mech)
		recharging_mech = locate(/obj/vehicle/sealed/mecha) in recharging_turf
		if(recharging_mech)
			recharging_mech_ref = WEAKREF(recharging_mech)
			recharge_console.update_icon()
	if(!recharging_mech?.cell)
		return
	if(recharging_mech.cell.charge < recharging_mech.cell.maxcharge)
		var/delta = min(recharge_power * delta_time, recharging_mech.cell.maxcharge - recharging_mech.cell.charge)
		recharging_mech.give_power(delta)
		use_power(delta + active_power_usage)
	else
		recharge_console.update_icon()
	if(recharging_mech.loc != recharging_turf)
		recharging_mech_ref = null
		recharge_console.update_icon()


/obj/machinery/mech_bay_recharge_port/attackby(obj/item/I, mob/user, params)
	if(default_change_direction_wrench(user, I))
		recharging_turf = get_step(loc, dir)
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/computer/mech_bay_power_console
	name = "mech bay power control console"
	desc = "Displays the status of mechs connected to the recharge station."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	screen_overlay = "recharge_comp"
	broken_icon = "computer_yellow_broken"
	light_color = LIGHT_COLOR_PINK
	///Ref to charge port fwe are viewing data for, cyclical reference
	var/obj/machinery/mech_bay_recharge_port/recharge_port

/obj/machinery/computer/mech_bay_power_console/Initialize(mapload)
	. = ..()
	reconnect()

/obj/machinery/computer/mech_bay_power_console/Destroy()
	if (recharge_port?.recharge_console == src)
		recharge_port.recharge_console = null
	return ..()

/obj/machinery/computer/mech_bay_power_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MechBayPowerConsole", name)
		ui.open()

/obj/machinery/computer/mech_bay_power_console/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("reconnect")
			reconnect()
			. = TRUE
			update_icon()

/obj/machinery/computer/mech_bay_power_console/ui_data(mob/user)
	var/list/data = list()
	if(QDELETED(recharge_port))
		return data

	data["recharge_port"] = list("mech" = null)
	var/obj/vehicle/sealed/mecha/recharging_mech = recharge_port.recharging_mech_ref?.resolve()

	if(!recharging_mech)
		return data
	data["recharge_port"]["mech"] = list("health" = recharging_mech.obj_integrity, "maxhealth" = recharging_mech.max_integrity, "cell" = null, "name" = recharging_mech.name)

	if(QDELETED(recharging_mech.cell))
		return data
	data["recharge_port"]["mech"]["cell"] = list(
	"charge" = recharging_mech.cell.charge,
	"maxcharge" = recharging_mech.cell.maxcharge
	)
	return data

///Checks for nearby recharge ports to link to
/obj/machinery/computer/mech_bay_power_console/proc/reconnect()
	if(recharge_port)
		return
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in range(1)
	if(!recharge_port)
		for(var/direction in GLOB.cardinals)
			var/turf/target = get_step(src, direction)
			target = get_step(target, direction)
			recharge_port = locate(/obj/machinery/mech_bay_recharge_port) in target
			if(recharge_port)
				break
	if(!recharge_port)
		return
	if(!recharge_port.recharge_console)
		recharge_port.recharge_console = src
	else
		recharge_port = null

/obj/machinery/computer/mech_bay_power_console/update_overlays()
	screen_overlay = initial(screen_overlay)

	var/obj/vehicle/sealed/mecha/recharging_mech = recharge_port?.recharging_mech_ref?.resolve()
	if(recharging_mech?.cell && recharging_mech.cell.charge >= recharging_mech.cell.maxcharge)
		screen_overlay = "[screen_overlay]_on"

	return ..()
