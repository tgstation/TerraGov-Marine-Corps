//The Area Power Controller (APC), formerly Power Distribution Unit (PDU)
//One per area, needs wire conection to power network

//Controls power to devices in that area
//May be opened to change power cell
//Three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area electrical systems."
	icon = 'icons/obj/machines/apc.dmi'
	icon_state = "apc0"
	anchored = TRUE
	use_power = NO_POWER_USE
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	resistance_flags = UNACIDABLE
	interaction_flags = INTERACT_MACHINE_TGUI
	light_range = 1
	light_power = 0.5
	mouse_over_pointer = MOUSE_HAND_POINTER

	///The area we're affecting
	var/area/area
	///The power cell inside the APC
	var/obj/item/cell/cell
	///The charge of the APC when first spawned
	var/start_charge = 90
	///The type of cell to spawn this APC with
	var/cell_type = /obj/item/cell/apc
	///The current state of the APC cover
	var/opened = APC_COVER_CLOSED
	///Is the APC shorted?
	var/shorted = FALSE
	///State of the lighting channel (off, auto off, on, auto on)
	var/lighting = APC_CHANNEL_AUTO_ON
	///State of the equipment channel (off, auto off, on, auto on)
	var/equipment = APC_CHANNEL_AUTO_ON
	///State of the environmental channel (off, auto off, on, auto on)
	var/environ = APC_CHANNEL_AUTO_ON
	///Is the apc working?
	var/operating = TRUE
	///State of the apc charging (not charging, charging, fully charged)
	var/charging = APC_NOT_CHARGING
	///Can the APC recharge?
	var/chargemode = TRUE
	///Number of ticks where the apc is trying to recharge
	var/chargecount = 0
	///Is the apc interface locked?
	var/locked = TRUE
	///Is the apc cover locked?
	var/coverlocked = TRUE
	///Is the AI locked from using the APC
	var/aidisabled = FALSE
	///Reference to our cable terminal
	var/obj/machinery/power/terminal/terminal = null
	///Amount of power used by the lighting channel
	var/lastused_light = 0
	///Amount of power used by the equipment channel
	var/lastused_equip = 0
	///Amount of power used by the environmental channel
	var/lastused_environ = 0
	///Total amount of power used by the three channels
	var/lastused_total = 0
	var/main_status = APC_EXTERNAL_POWER_NONE
	///State of the electronics inside (missing, installed, secured)
	var/has_electronics = APC_ELECTRONICS_MISSING
	///Used for counting how many times it has been hit, used for Aliens at the moment
	var/beenhit = 0
	///Buffer state that makes apcs not shut off channels immediately as long as theres some power left, effect visible in apcs only slowly losing power
	var/longtermpower = 10
	///Stores the flags related to icon updating
	var/update_state = NONE
	///Stores the flag for the overlays
	var/update_overlay = NONE
	///Used to stop the icon from updating too much
	var/icon_update_needed = FALSE
	///Probability of APC being broken by a shuttle crash on the same z-level
	var/crash_break_probability = 85

/obj/machinery/power/apc/connect_to_network()
	//Override because the APC does not directly connect to the network; it goes through a terminal.
	//The terminal is what the power computer looks for anyway.
	if(terminal)
		terminal.connect_to_network()

/obj/machinery/power/apc/updateUsrDialog()
	if(machine_stat & (BROKEN|MAINT))
		return
	return ..()

/obj/machinery/power/apc/Initialize(mapload, ndir, building)
	GLOB.apcs_list += src
	wires = new /datum/wires/apc(src)

	// offset 32 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (ndir)
		setDir(ndir)

	switch(dir)
		if(NORTH)
			pixel_y = -32
		if(SOUTH)
			pixel_y = 32
		if(EAST)
			pixel_x = -32
		if(WEST)
			pixel_x = 32

	if(building)
		var/area/A = get_area(src)
		area = A
		opened = APC_COVER_OPENED
		operating = FALSE
		name = "\improper [area.name] APC"
		machine_stat |= MAINT
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(update)), 5)

	start_processing()

	. = ..()

	var/area/A = get_area(src)
	area = A
	name = "\improper [area.name] APC"

	update_icon()
	update() //areas should be lit on startup

	if(mapload)
		has_electronics = APC_ELECTRONICS_SECURED

		//Is starting with a power cell installed, create it and set its charge level
		if(cell_type)
			set_cell(new cell_type(src))
			cell.charge = start_charge * cell.maxcharge / 100.0 //Convert percentage to actual value
			cell.update_icon()


		make_terminal()

		update() //areas should be lit on startup

		//Break few ACPs on the colony
		if(!start_charge && is_ground_level(z) && prob(10))
			addtimer(CALLBACK(src, PROC_REF(set_broken)), 5)

/obj/machinery/power/apc/Destroy()
	GLOB.apcs_list -= src

	area.power_light = 0
	area.power_equip = 0
	area.power_environ = 0
	area.power_change()

	QDEL_NULL(cell)
	QDEL_NULL(wires)
	if(terminal)
		disconnect_terminal()

	return ..()

///Wrapper to guarantee powercells are properly nulled and avoid hard deletes.
/obj/machinery/power/apc/proc/set_cell(obj/item/cell/new_cell)
	if(cell)
		UnregisterSignal(cell, COMSIG_QDELETING)
	cell = new_cell
	if(cell)
		RegisterSignal(cell, COMSIG_QDELETING, PROC_REF(on_cell_deletion))
	update_appearance(UPDATE_ICON)


///Called by the deletion of the referenced powercell.
/obj/machinery/power/apc/proc/on_cell_deletion(obj/item/cell/source, force)
	SIGNAL_HANDLER
	set_cell(null)


/obj/machinery/power/apc/proc/make_terminal()
	//Create a terminal object at the same position as original turf loc
	//Wires will attach to this
	terminal = new(loc)
	terminal.setDir(REVERSE_DIR(dir))
	terminal.master = src

/obj/machinery/power/apc/examine(mob/user)
	. = ..()

	if(machine_stat & BROKEN)
		. += span_info("It appears to be completely broken. It's hard to see what else is wrong with it.")
		return

	if(opened)
		if(has_electronics && terminal)
			. += span_info("The cover is [opened == APC_COVER_REMOVED ? "removed":"open"] and the power cell is [cell ? "installed":"missing"].")
		else
			. += span_info("It's [ !terminal ? "not" : "" ] wired up.")
			. += span_info("The electronics are[!has_electronics?"n't":""] installed.")
	else
		if(machine_stat & MAINT)
			. += span_info("The cover is closed. Something is wrong with it, it doesn't work.")
		else
			. += span_info("The cover is closed.")

	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		. += span_info("The wiring is exposed.")

/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Apc", name)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = DisplayPower(lastused_total),
		"coverLocked" = coverlocked,
		"siliconUser" = issilicon(user),

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = DisplayPower(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on" = list("eqp" = 2),
					"off" = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = DisplayPower(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on" = list("lgt" = 2),
					"off" = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = DisplayPower(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on" = list("env" = 2),
					"off" = list("env" = 1)
				)
			)
		)
	)
	return data


/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell?.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

/obj/machinery/power/apc/proc/can_use(mob/user, loud = FALSE) //used by attack_hand() and Topic()
	if(IsAdminGhost(user))
		return TRUE
	if(isAI(user) && aidisabled)
		if(!loud)
			balloon_alert(user, "eee is disabled")
		return FALSE
	return TRUE

/obj/machinery/power/apc/ui_act(action, list/params)
	. = ..()
	if(. || !can_use(usr, TRUE) || (locked && !usr.has_unlimited_silicon_privilege))
		return
	switch(action)
		if("lock")
			if(usr.has_unlimited_silicon_privilege)
				if((machine_stat & (BROKEN|MAINT)))
					balloon_alert(usr, "APC unresponsive")
				else
					locked = !locked
					update_icon()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(usr)
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_icon()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_icon()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_icon()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_icon()
				update()
			. = TRUE
		if("overload")
			if(usr.has_unlimited_silicon_privilege)
				overload_lighting()
				. = TRUE
	return TRUE

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"


/obj/machinery/power/apc/proc/update()
	if(operating && !shorted)
		area.power_light = (lighting > 1)
		area.power_equip = (equipment > 1)
		area.power_environ = (environ > 1)
	else
		area.power_light = 0
		area.power_equip = 0
		area.power_environ = 0
	area.power_change()


/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = 3
			environ = 3
			update_icon()
			update()

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0


/obj/machinery/power/apc/add_load(amount)
	if(terminal?.powernet)
		return terminal.add_load(amount)
	return 0


/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0


/obj/machinery/power/apc/process()
	if(icon_update_needed)
		update_icon()
	if(machine_stat & (BROKEN|MAINT))
		return
	if(!area.requires_power)
		return

	lastused_light = area.usage(STATIC_LIGHTS)
	lastused_light += area.usage(LIGHT)
	lastused_equip = area.usage(EQUIP)
	lastused_equip += area.usage(STATIC_EQUIP)
	lastused_environ = area.usage(ENVIRON)
	lastused_environ += area.usage(STATIC_ENVIRON)
	area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	var/excess = surplus()

	if(!avail())
		main_status = APC_EXTERNAL_POWER_NONE
	else if(excess < 0)
		main_status = APC_EXTERNAL_POWER_LOW
	else
		main_status = APC_EXTERNAL_POWER_GOOD

	if(cell && !shorted)
		// draw power from cell as before to power the area
		var/cellused = min(cell.charge, GLOB.CELLRATE * lastused_total)	// clamp deduction to a max, amount left in cell
		cell.use(cellused)

		if(excess > lastused_total)		// if power excess recharge the cell
										// by the same amount just used
			cell.give(cellused)
			add_load(cellused / GLOB.CELLRATE)		// add the load used to recharge the cell


		else		// no excess, and not enough per-apc
			if((cell.charge / GLOB.CELLRATE + excess) >= lastused_total)		// can we draw enough from cell+grid to cover last usage?
				cell.charge = min(cell.maxcharge, cell.charge + GLOB.CELLRATE * excess)	//recharge with what we can
				add_load(excess)		// so draw what we can from the grid
				charging = APC_NOT_CHARGING

			else	// not enough power available to run the last tick!
				charging = APC_NOT_CHARGING
				chargecount = 0
				// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
				equipment = autoset(equipment, 0)
				lighting = autoset(lighting, 0)
				environ = autoset(environ, 0)


		// set channels depending on how much charge we have left

		// Allow the APC to operate as normal if the cell can charge
		if(charging && longtermpower < 10)
			longtermpower += 1
		else if(longtermpower > -10)
			longtermpower -= 2

		if(cell.charge <= 0)					// zero charge, turn all off
			equipment = autoset(equipment, 0)
			lighting = autoset(lighting, 0)
			environ = autoset(environ, 0)
			area.poweralert(0, src)
		else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
			equipment = autoset(equipment, 2)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else if(cell.percent() < 30 && longtermpower < 0)			// <30%, turn off lighting
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 2)
			environ = autoset(environ, 1)
			area.poweralert(0, src)
		else									// otherwise all can be on
			equipment = autoset(equipment, 1)
			lighting = autoset(lighting, 1)
			environ = autoset(environ, 1)
			area.poweralert(1, src)
			if(cell.percent() > 75)
				area.poweralert(1, src)

		// now trickle-charge the cell
		if(chargemode && charging == APC_CHARGING && operating)
			if(excess > 0)		// check to make sure we have enough to charge
				// Max charge is capped to % per second constant
				var/ch = min(excess*GLOB.CELLRATE, cell.maxcharge*GLOB.CHARGELEVEL)
				add_load(ch/GLOB.CELLRATE) // Removes the power we're taking from the grid
				cell.give(ch) // actually recharge the cell

			else
				charging = APC_NOT_CHARGING		// stop charging
				chargecount = 0

		// show cell as fully charged if so
		if(cell.charge >= cell.maxcharge)
			cell.charge = cell.maxcharge
			charging = APC_FULLY_CHARGED

		if(chargemode)
			if(!charging)
				if(excess > cell.maxcharge * GLOB.CHARGELEVEL)
					chargecount++
				else
					chargecount = 0

				if(chargecount == 10)

					chargecount = 0
					charging = APC_CHARGING

		else // chargemode off
			charging = APC_NOT_CHARGING
			chargecount = 0

	else // no cell, switch everything off
		charging = APC_NOT_CHARGING
		chargecount = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		area.poweralert(0, src)

	// update icon & area power if anything changed
	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if(last_ch != charging)
		queue_icon_update()

//val 0 = off, 1 = off(auto) 2 = on, 3 = on(auto)
//on 0 = off, 1 = auto-on, 2 = auto-off

/proc/autoset(val, on)

	switch(on)
		if(0) //Turn things off
			switch(val)
				if(2) //If on, return off
					return 0
				if(3) //If auto-on, return auto-off
					return 1

		if(1) //Turn things auto-on
			if(val == 1) //If auto-off, return auto-on
				return 3

		if(2) //Turn things auto-off
			if(val == 3) //If auto-on, return auto-off
				return 1
	return val


/obj/machinery/power/apc/emp_act(severity)
	. = ..()
	if(cell)
		cell.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update_icon()
	update()
	addtimer(CALLBACK(src, PROC_REF(reset), APC_RESET_EMP), 60 SECONDS)

/obj/machinery/power/apc/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			cell?.ex_act(1) //More lags woohoo
			qdel(src)
			return
		if(EXPLODE_HEAVY)
			if(prob(50))
				return
			set_broken()
			if(!cell || prob(50))
				return
		if(EXPLODE_LIGHT)
			if(prob(75))
				return
			set_broken()
			if(!cell || prob(75))
				return
		if(EXPLODE_WEAK)
			if(prob(80))
				return
			set_broken()
			if(!cell || prob(85))
				return

	cell.ex_act(severity)


/obj/machinery/power/apc/proc/set_broken()
	//Aesthetically much better!
	visible_message(span_warning("[src]'s screen flickers with warnings briefly!"))
	addtimer(CALLBACK(src, PROC_REF(do_break)), rand(2, 5))


/obj/machinery/power/apc/proc/do_break()
	visible_message(span_danger("[src]'s screen suddenly explodes in rain of sparks and small debris!"))
	machine_stat |= BROKEN
	operating = FALSE
	update_icon()
	update()


//Overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting()
	if(!operating || shorted)
		return
	if(cell?.charge >= 20)
		cell.use(20)
		INVOKE_ASYNC(src, PROC_REF(break_lights))


/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/L in get_area(src))
		L.broken()
		stoplag()


/obj/machinery/power/apc/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null


/obj/machinery/power/apc/proc/toggle_breaker(mob/user)
	if(machine_stat & (NOPOWER|BROKEN|MAINT))
		return

	operating = !operating
	log_combat(user, src, "turned [operating ? "on" : "off"]")
	update()
	update_icon()


//------Various APCs ------//

// mapping helpers
/obj/machinery/power/apc/drained
	start_charge = 0

/obj/machinery/power/apc/lowcharge
	start_charge = 25

/obj/machinery/power/apc/potato
	cell_type = /obj/item/cell/potato

/obj/machinery/power/apc/weak
	cell_type = /obj/item/cell

/obj/machinery/power/apc/high
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/super
	cell_type = /obj/item/cell/super

/obj/machinery/power/apc/hyper
	cell_type = /obj/item/cell/hyper

//------Marine ship APCs ------//

/obj/machinery/power/apc/mainship
	req_access = list(ACCESS_MARINE_ENGINEERING)
	cell_type = /obj/item/cell/high

/obj/machinery/power/apc/mainship/hardened
	name = "hardened area power controller"
	desc = "A control terminal for the area electrical systems. This one is hardened against sudden power fluctuations caused by electrical grid damage."
	crash_break_probability = 0
