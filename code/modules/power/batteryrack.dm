//Machines
//The one that works safely.
/obj/machinery/power/smes/batteryrack
	name = "power cell rack PSU"
	desc = "A rack of power cells working as a PSU."
	charge = 0 //you dont really want to make a potato PSU which already is overloaded
	input_level = 0
	output_level = 0
	input_level_max = 0
	output_level_max = 0
	icon_state = "gsmes"
	var/cells_amount = 0
	var/capacitors_amount = 0

	// Smaller capacity, but higher I/O
	// Starts fully charged, as it's used in substations. This replaces Engineering SMESs round start charge.
/obj/machinery/power/smes/batteryrack/substation
	name = "Substation PSU"
	desc = "A rack of power cells working as a PSU. This one seems to be equipped for higher power loads."
	output_level = 150000
	input_level = 150000

	// One high capacity cell, two regular cells. Lots of room for engineer upgrades
	// Also five basic capacitors. Again, upgradeable.
/obj/machinery/power/smes/batteryrack/substation/add_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/batteryrack
	component_parts += new /obj/item/cell/high
	component_parts += new /obj/item/cell
	component_parts += new /obj/item/cell
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor

/obj/machinery/power/smes/batteryrack/Initialize()
	. = ..()
	add_parts()
	RefreshParts()
	start_processing()


//Maybe this should be moved up to obj/machinery
/obj/machinery/power/smes/batteryrack/proc/add_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/batteryrack
	component_parts += new /obj/item/cell/high
	component_parts += new /obj/item/cell/high
	component_parts += new /obj/item/cell/high



/obj/machinery/power/smes/batteryrack/RefreshParts()
	capacitors_amount = 0
	cells_amount = 0
	var/max_level = 0 //for both input and output
	for(var/obj/item/stock_parts/capacitor/CP in component_parts)
		max_level += CP.rating
		capacitors_amount++
	input_level_max = 50000 + max_level * 20000
	output_level_max = 50000 + max_level * 20000

	var/C = 0
	for(var/obj/item/cell/PC in component_parts)
		C += PC.maxcharge
		cells_amount++
	capacity = C * 40   //Basic cells are such crap. Hyper cells needed to get on normal SMES levels.


/obj/machinery/power/smes/batteryrack/update_icon()
	overlays.Cut()
	if(machine_stat & BROKEN)
		return

	if (outputting)
		overlays += image('icons/obj/power.dmi', "gsmes_outputting")
	if(inputting)
		overlays += image('icons/obj/power.dmi', "gsmes_charging")

	var/clevel = chargedisplay()
	if(clevel>0)
		overlays += image('icons/obj/power.dmi', "gsmes_og[clevel]")



/obj/machinery/power/smes/batteryrack/chargedisplay()
	return round(4 * charge/(capacity ? capacity : 5e6))


/obj/machinery/power/smes/batteryrack/attackby(obj/item/I, mob/user, params) //these can only be moved by being reconstructed, solves having to remake the powernet.
	. = ..() //SMES attackby for now handles screwdriver, cable coils and wirecutters, no need to repeat that here

	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		return

	if(iscrowbar(I))
		if(charge >= (capacity / 100))
			to_chat(user, "<span class='warning'>Better let [src] discharge before dismantling it.</span>")
			return

		if(outputting || input_attempt)
			to_chat(user, "<span class='warning'>Turn off the [src] before dismantling it.</span>")
			return

		playsound(get_turf(src), 'sound/items/crowbar.ogg', 25, 1)
		var/obj/machinery/constructable_frame/machine_frame/M = new(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/O in component_parts)
			if(O.reliability != 100 && crit_fail)
				O.crit_fail = TRUE
			O.forceMove(loc)
		qdel(src)

	else if((istype(I, /obj/item/stock_parts/capacitor) && (capacitors_amount < 5)) || (istype(I, /obj/item/cell) && (cells_amount < 5)))
		if(charge >= (capacity / 100))
			to_chat(user, "<span class='warning'>Better let [src] discharge before putting your hand inside it.</span>")
			return

		if(outputting || input_attempt)
			to_chat(user, "<span class='warning'>Turn off the [src] before dismantling it.</span>")
			return

		if(!user.transferItemToLoc(I, src))
			return

		component_parts += I
		RefreshParts()
		to_chat(user, "<span class='notice'>You upgrade the [src] with [I].</span>")


//The shitty one that will blow up.
/obj/machinery/power/smes/batteryrack/makeshift
	name = "makeshift PSU"
	desc = "A rack of batteries connected by a mess of wires posing as a PSU."
	var/overcharge_percent = 0


/obj/machinery/power/smes/batteryrack/makeshift/add_parts()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/machine/ghettosmes
	component_parts += new /obj/item/cell/high
	component_parts += new /obj/item/cell/high
	component_parts += new /obj/item/cell/high



/obj/machinery/power/smes/batteryrack/makeshift/update_icon()
	overlays.Cut()
	if(machine_stat & BROKEN)	return

	if (outputting)
		overlays += image('icons/obj/power.dmi', "gsmes_outputting")
	if(inputting)
		overlays += image('icons/obj/power.dmi', "gsmes_charging")
	if (overcharge_percent > 100)
		overlays += image('icons/obj/power.dmi', "gsmes_overcharge")
	else
		var/clevel = chargedisplay()
		if(clevel>0)
			overlays += image('icons/obj/power.dmi', "gsmes_og[clevel]")
	return

//This mess of if-elses and magic numbers handles what happens if the engies don't pay attention and let it eat too much charge
//What happens depends on how much capacity has the ghetto smes and how much it is overcharged.
//Under 1.2M: 5% of ion_act() per process() tick from 125% and higher overcharges. 1.2M is achieved with 3 high cells.
//[1.2M-2.4M]: 6% ion_act from 120%. 1% of EMP from 140%.
//(2.4M-3.6M] :7% ion_act from 115%. 1% of EMP from 130%. 1% of non-hull-breaching explosion at 150%.
//(3.6M-INFI): 8% ion_act from 115%. 2% of EMP from 125%. 1% of Hull-breaching explosion from 140%.
/obj/machinery/power/smes/batteryrack/makeshift/proc/overcharge_consequences()
	switch (capacity)
		if (0 to (1.2e6-1))
			if (overcharge_percent >= 125)
				if (prob(5))
					ion_act()
		if (1.2e6 to 2.4e6)
			if (overcharge_percent >= 120)
				if (prob(6))
					ion_act()
			else
				return
			if (overcharge_percent >= 140)
				if (prob(1))
					empulse(src.loc, 3, 8, 1)
		if ((2.4e6+1) to 3.6e6)
			if (overcharge_percent >= 115)
				if (prob(7))
					ion_act()
			else
				return
			if (overcharge_percent >= 130)
				if (prob(1))
					empulse(src.loc, 3, 8, 1)
			if (overcharge_percent >= 150)
				if (prob(1))
					explosion(loc, 1, 2, 4, 5, small_animation = TRUE)
		if ((3.6e6+1) to INFINITY)
			if (overcharge_percent >= 115)
				if (prob(8))
					ion_act()
			else
				return
			if (overcharge_percent >= 125)
				if (prob(2))
					empulse(src.loc, 4, 10, 1)
			if (overcharge_percent >= 140)
				if (prob(1))
					explosion(loc, 2, 4, 6, 8, small_animation = TRUE)
		else //how the hell was this proc called for negative charge
			charge = 0


#define SMESRATE 0.05			// rate of internal charge to external power
/obj/machinery/power/smes/batteryrack/makeshift/process()
	if(machine_stat & BROKEN)	return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = inputting
	var/last_onln = outputting
	var/last_overcharge = overcharge_percent

	if(terminal)
		var/excess = terminal.surplus()

		if(inputting)
			if(excess >= 0)		// if there's power available, try to charge
				var/load = min((capacity * 1.5 - charge)/SMESRATE, input_level)		// charge at set rate, limited to spare capacity
				load = add_load(load)		// add the load to the terminal side network
				charge += load * SMESRATE	// increase the charge


			else					// if not enough capacity
				inputting = 0		// stop charging

		else
			if (input_attempt && excess > 0 && excess >= input_level)
				inputting = TRUE

	if(outputting)		// if outputting
		output_used = min( charge/SMESRATE, output_level)		//limit output to that stored
		charge -= output_used*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)
		add_avail(output_used)				// add output to powernet (smes side)
		if(charge < 0.0001)
			outputting = 0					// stop output if charge falls to zero

	overcharge_percent = round((charge / capacity) * 100)
	if (overcharge_percent > 115) //115% is the minimum overcharge for anything to happen
		overcharge_consequences()

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != inputting || last_onln != outputting || ((overcharge_percent > 100) ^ (last_overcharge > 100)))
		update_icon()
	return

#undef SMESRATE
