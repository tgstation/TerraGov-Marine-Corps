// the SMES
// stores power

#define SMESMAXCHARGELEVEL 200000
#define SMESMAXOUTPUT 200000
#define SMESRATE 0.05			// rate of internal charge to external power

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	interaction_flags = INTERACT_MACHINE_TGUI
	resistance_flags = CRUSHER_IMMUNE
	var/capacity = 5e5		//Maximum amount of power it can hold
	var/charge = 1e5		//Current amount of power it holds

	var/input_attempt = TRUE //attempting to charge ?
	var/inputting = TRUE
	var/input_level = 50000 //amount of power the SMES attempts to charge by
	var/input_level_max = SMESMAXCHARGELEVEL //cap on input level
	var/input_available = 0 //amount of charge available from input last tick

	var/output_attempt = TRUE //attempting to output ?
	var/outputting = TRUE
	var/output_level = 50000 //amount of power the SMES attempts to output
	var/output_level_max = SMESMAXOUTPUT // cap on output level
	var/output_used = 0 //amount of power actually outputted. may be less than output_level if the powernet returns excess power

	var/obj/machinery/power/terminal/terminal

/obj/machinery/power/smes/examine(user)
	. = ..()
	if(!terminal)
		. += span_warning("This SMES has no power terminal!")
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		. += span_notice("The maintenance hatch is open.")

/obj/machinery/power/smes/Initialize(mapload)
	. = ..()
	if(!powernet)
		connect_to_network()

	dir_loop:
		for(var/d in GLOB.cardinals)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term?.dir == REVERSE_DIR(d))
					terminal = term
					break dir_loop
	if(!terminal)
		machine_stat |= BROKEN
		return
	terminal.master = src
	if(!terminal.powernet)
		terminal.connect_to_network()
	update_icon()
	start_processing()

/obj/machinery/power/smes/Destroy()
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/smes/should_have_node()
	return TRUE

/obj/machinery/power/smes/update_overlays()
	. = ..()

	if(CHECK_BITFIELD(machine_stat, (PANEL_OPEN|BROKEN)))
		return

	. += image('icons/obj/power.dmi', "smes_op[outputting]")

	if(inputting)
		. += image('icons/obj/power.dmi', "smes_oc1")
	else if (input_attempt)
		. += image('icons/obj/power.dmi', "smes_oc0")

	var/clevel = chargedisplay()
	if(clevel>0)
		. += image('icons/obj/power.dmi', "smes_og[clevel]")


/obj/machinery/power/smes/proc/chargedisplay()
	return clamp(round(5.5*charge/capacity),0,5)


/obj/machinery/power/smes/process()
	if(machine_stat & BROKEN)
		return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting

	//inputting
	if(terminal && input_attempt)
		input_available = terminal.surplus()

		if(inputting)
			if(input_available > 0)		  // if there's power available, try to charge
				var/load = min(min((capacity-charge)/SMESRATE, input_level), input_available)		// charge at set rate, limited to spare capacity
				charge += load * SMESRATE // increase the charge
				terminal.add_load(load)   // add the load to the terminal side network
			else
				inputting = FALSE		  // if not enough capacity, stop inputting

		else
			if(input_attempt && input_available > 0)
				inputting = TRUE
	else
		inputting = FALSE

	//outputting
	if(output_attempt)
		if(outputting)
			output_used = min(charge/SMESRATE, output_level)		//limit output to that stored

			if (add_avail(output_used))				// add output to powernet if it exists (smes side)
				charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < 0.0001)		// either from no charge or set to 0
				outputting = FALSE
		else if(output_attempt && charge > output_level && output_level > 0)
			outputting = TRUE
		else
			output_used = 0
	else
		outputting = FALSE

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting)
		update_icon()

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(machine_stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount
	var/clev = chargedisplay()

	charge += excess * SMESRATE			// restore unused power
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay() ) //if needed updates the icons overlay
		update_icon()

// create a terminal object pointing towards the SMES
// wires will attach to this
/obj/machinery/power/smes/proc/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.setDir(get_dir(T,src))
	terminal.master = src
	machine_stat &= ~BROKEN

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null
		machine_stat |= BROKEN

/obj/machinery/power/smes/add_load(amount)
	if(terminal?.powernet)
		return terminal.add_load(amount)
	return FALSE


/obj/machinery/power/smes/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)

		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			to_chat(user, span_notice("You open the maintenance hatch of [src]."))
			icon_state = "[initial(icon_state)]_o"
		else
			to_chat(user, span_notice("You close the maintenance hatch of [src]."))
			icon_state = "[initial(icon_state)]"

		update_icon()

	else if(iscablecoil(I))
		var/obj/item/stack/cable_coil/C = I

		var/dir = get_dir(user, src)
		if(ISDIAGONALDIR(dir))//we don't want diagonal click
			return

		if(terminal)
			to_chat(user, span_warning("This SMES already has a power terminal!"))
			return

		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			to_chat(user, span_warning("You must open the maintenance panel first!"))
			return

		var/turf/T = get_turf(user)
		if(T.intact_tile) //is the floor plating removed ?
			to_chat(user, span_warning("You must first remove the floor plating!"))
			return

		if(C.get_amount() < 10)
			to_chat(user, span_warning("You need more wires!"))
			return

		to_chat(user, span_notice("You start building the power terminal..."))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)

		if(!do_after(user, 50, NONE, src, BUSY_ICON_BUILD) || C.get_amount() < 10)
			return

		var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
		if(prob(50))
			electrocute_mob(user, N, N, 1, TRUE)

		C.use(10)
		user.visible_message(\
			"[user.name] has built a power terminal.",\
			span_notice("You build the power terminal."))

		//build the terminal and link it to the network
		make_terminal(T)
		terminal.connect_to_network()
		connect_to_network()


	else if(iswirecutter(I) && terminal && CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		terminal.deconstruct(user)


/obj/machinery/power/smes/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", name)
		ui.open()

/obj/machinery/power/smes/ui_data()
	var/list/data = list(
		"capacity" = capacity,
		"capacityPercent" = round(100*charge/capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevel_text" = DisplayPower(input_level),
		"inputLevelMax" = input_level_max,
		"inputAvailable" = input_available,
		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputLevel_text" = DisplayPower(output_level),
		"outputLevelMax" = output_level_max,
		"outputUsed" = output_used,
	)
	return data

/obj/machinery/power/smes/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			update_icon()
			. = TRUE
		if("tryoutput")
			output_attempt = !output_attempt
			update_icon()
			. = TRUE
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = tgui_input_number(usr, "New input target (0-[input_level_max]):", name, input_level)
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = clamp(target, 0, input_level_max)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = tgui_input_number(usr, "New output target (0-[output_level_max]):", name, output_level)
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = output_level_max
				. = TRUE
			else if(adjust)
				target = output_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				output_level = clamp(target, 0, output_level_max)

/obj/machinery/power/smes/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["cmode"])
		input_attempt = !input_attempt
		update_icon()

	else if(href_list["online"])
		output_attempt = !output_attempt
		update_icon()

	else if(href_list["input"])
		switch( href_list["input"] )
			if("min")
				input_level = 0
			if("max")
				input_level = input_level_max
			if("set")
				input_level = tgui_input_number(usr, "Enter new input level (0-[input_level_max])", "SMES Input Power Control", input_level)
		input_level = clamp(input_level,0,input_level_max)

	else if( href_list["output"] )
		switch( href_list["output"] )
			if("min")
				output_level = 0
			if("max")
				output_level = output_level_max
			if("set")
				output_level = tgui_input_number(usr, "Enter new output level (0-[output_level_max])", "SMES Output Power Control", output_level)
		output_level = clamp(output_level,0,output_level_max)


/obj/machinery/power/smes/proc/ion_act()
	if(is_ground_level(z))
		if(prob(1)) //explosion
			visible_message(span_warning("\The [src] is making strange noises!"), null, span_warning(" You hear sizzling electronics."))
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect_system/smoke_spread/smoke = new(src)
			smoke.set_up(1, loc)
			smoke.start()
			explosion(loc, light_impact_range = 2, flash_range = 3)
			qdel(src)
			return
		if(prob(15)) //Power drain
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
		if(prob(5)) //smoke only
			var/datum/effect_system/smoke_spread/smoke = new(src)
			smoke.set_up(1, loc)
			smoke.start()

/obj/machinery/power/smes/emp_act(severity)
	outputting = FALSE
	inputting = FALSE
	output_level = 0
	charge = max(charge - 1e6/severity, 0)
	addtimer(CALLBACK(src, PROC_REF(reset_power_level)), 10 SECONDS)
	..()

/obj/machinery/power/smes/proc/reset_power_level()
	output_level = initial(output_level)
	inputting = initial(inputting)
	outputting = initial(outputting)

/obj/machinery/power/smes/preset
	input_level = 180000
	output_level = 100000

/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."
	capacity = 9000000
	output_level = SMESMAXOUTPUT

/obj/machinery/power/smes/magical/process()
	charge = 9000000
	..()

/proc/rate_control(S, V, C, Min=1, Max=5, Limit=null)
	var/href = "<A href='?src=[text_ref(S)];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate


/obj/machinery/power/smes/can_terminal_dismantle()
	return CHECK_BITFIELD(machine_stat, PANEL_OPEN)

#undef SMESRATE
