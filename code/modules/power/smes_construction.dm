// Constructable SMES version. Based on Coils. Each SMES can hold 6 Coils by default.
// Each coil adds 250kW I/O and 5M capacity.
// This is second version, now subtype of regular SMES.




// SMES itself
/obj/machinery/power/smes/buildable
	var/max_coils = 6 			//30M capacity, 1.5MW input/output when fully upgraded /w default coils
	var/cur_coils = 1 			// Current amount of installed coils
	var/safeties_enabled = TRUE	// If 0 modifications can be done without discharging the SMES, at risk of critical failure.
	var/failing = FALSE			// If 1 critical failure has occured and SMES explosion is imminent.
	resistance_flags = UNACIDABLE|CRUSHER_IMMUNE

/obj/machinery/power/smes/buildable/empty
	charge = 0

/obj/machinery/power/smes/buildable/empty/dist
	name = "colony distribution SMES"

/obj/machinery/power/smes/buildable/empty/backup
	name = "backup power SMES"

/obj/machinery/power/smes/buildable/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stack/cable_coil(src,30)
	component_parts += new /obj/item/circuitboard/machine/smes(src)

	// Allows for mapped-in SMESs with larger capacity/IO
	for(var/i = 1, i <= cur_coils, i++)
		component_parts += new /obj/item/stock_parts/smes_coil(src)

	recalc_coils()

/obj/machinery/power/smes/buildable/proc/recalc_coils()
	if ((cur_coils <= max_coils) && (cur_coils >= 1))
		capacity = 0
		input_level_max = 0
		output_level_max = 0
		for(var/obj/item/stock_parts/smes_coil/C in component_parts)
			capacity += C.ChargeCapacity
			input_level_max += C.IOCapacity
			output_level_max += C.IOCapacity
		charge = between(0, charge, capacity)
		return 1
	else
		return 0

	// SMESs store very large amount of power. If someone screws up (ie: Disables safeties and attempts to modify the SMES) very bad things happen.
	// Bad things are based on charge percentage.
	// Possible effects:
	// Sparks - Lets out few sparks, mostly fire hazard if phoron present. Otherwise purely aesthetic.
	// Shock - Depending on intensity harms the user. Insultated Gloves protect against weaker shocks, but strong shock bypasses them.
	// EMP Pulse - Lets out EMP pulse discharge which screws up nearby electronics.
	// Light Overload - X% chance to overload each lighting circuit in connected powernet. APC based.
	// APC Failure - X% chance to destroy APC causing very weak explosion too. Won't cause hull breach or serious harm.
	// SMES Explosion - X% chance to destroy the SMES, in moderate explosion. May cause small hull breach.
/obj/machinery/power/smes/buildable/proc/total_system_failure(intensity = 0, mob/user as mob)
	if (!intensity)
		return

	var/mob/living/carbon/human/h_user = null
	if (!ishuman(user))
		return
	else
		h_user = user


	// Preparations
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	// Check if user has protected gloves.
	var/user_protected = 0
	if(h_user.gloves)
		var/obj/item/clothing/gloves/G = h_user.gloves
		if(G.siemens_coefficient == 0)
			user_protected = 1


	switch (intensity)
		if (0 to 15)
			// Small overcharge
			// Sparks, Weak shock
			s.set_up(2, 1, src)
			s.start()
			if (user_protected && prob(80))
				to_chat(h_user, "Small electrical arc almost burns your hand. Luckily you had your gloves on!")
			else
				to_chat(h_user, "Small electrical arc sparks and burns your hand as you touch the [src]!")
				h_user.adjustFireLoss(rand(5,10))
				h_user.Unconscious(4 SECONDS)
			charge = 0

		if (16 to 35)
			// Medium overcharge
			// Sparks, Medium shock, Weak EMP
			s.set_up(4,1,src)
			s.start()
			if (user_protected && prob(25))
				to_chat(h_user, "Medium electrical arc sparks and almost burns your hand. Luckily you had your gloves on!")
			else
				to_chat(h_user, "Medium electrical sparks as you touch the [src], severely burning your hand!")
				h_user.adjustFireLoss(rand(10,25))
				h_user.Unconscious(10 SECONDS)
			INVOKE_ASYNC(src, PROC_REF(empulse), loc, 2, 4)
			charge = 0

		if (36 to 60)
			// Strong overcharge
			// Sparks, Strong shock, Strong EMP, 10% light overload. 1% APC failure
			s.set_up(7,1,src)
			s.start()
			if (user_protected)
				to_chat(h_user, "Strong electrical arc sparks between you and [src], ignoring your gloves and burning your hand!")
				h_user.adjustFireLoss(rand(25,60))
				h_user.Unconscious(16 SECONDS)
			else
				to_chat(h_user, "Strong electrical arc sparks between you and [src], knocking you out for a while!")
				h_user.adjustFireLoss(rand(35,75))
				h_user.Unconscious(24 SECONDS)
			INVOKE_ASYNC(src, PROC_REF(empulse), loc, 8, 16)
			charge = 0
			apcs_overload(1, 10)
			visible_message("Caution. Output regulators malfunction. Uncontrolled discharge detected.")

		if (61 to INFINITY)
			// Massive overcharge
			// Sparks, Near - instantkill shock, Strong EMP, 25% light overload, 5% APC failure. 50% of SMES explosion. This is bad.
			s.set_up(10,1,src)
			s.start()
			to_chat(h_user, "Massive electrical arc sparks between you and [src]. Last thing you can think about is \"Oh shit...\"")
			// Remember, we have few gigajoules of electricity here.. Turn them into crispy toast.
			h_user.adjustFireLoss(rand(150,195))
			h_user.Unconscious(50 SECONDS)
			INVOKE_ASYNC(src, PROC_REF(empulse), loc, 32, 64)
			charge = 0
			apcs_overload(5, 25)
			visible_message("Caution. Output regulators malfunction. Significant uncontrolled discharge detected.")

			if (prob(50))
				visible_message("DANGER! Magnetic containment field unstable! Containment field failure imminent!")
				failing = 1
				// 30 - 60 seconds and then BAM!
				spawn(rand(300,600))
					if(!failing) // Admin can manually set this var back to 0 to stop overload, for use when griffed.
						update_icon()
						visible_message("Magnetic containment stabilised.")
						return
					visible_message("DANGER! Magnetic containment field failure in 3 ... 2 ... 1 ...")
					explosion(loc, 2, 3, 5, 0, 8)
					// Not sure if this is necessary, but just in case the SMES *somehow* survived..
					qdel(src)



	// Gets powernet APCs and overloads lights or breaks the APC completely, depending on percentages.
/obj/machinery/power/smes/buildable/proc/apcs_overload(failure_chance, overload_chance)
	if (!src.powernet)
		return

	for(var/obj/machinery/power/terminal/T in src.powernet.nodes)
		if(istype(T.master, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/A = T.master
			if (prob(overload_chance))
				A.overload_lighting()
			if (prob(failure_chance))
				A.set_broken()

	// Failing SMES has special icon overlay.
/obj/machinery/power/smes/buildable/update_icon()
	if (failing)
		overlays.Cut()
		overlays += image('icons/obj/power.dmi', "smes_crit")
	else
		..()

/obj/machinery/power/smes/buildable/attackby(obj/item/I, mob/user, params)
	// No more disassembling of overloaded SMESs. You broke it, now enjoy the consequences.
	if(failing)
		to_chat(user, span_warning("The [src]'s screen is flashing with alerts. It seems to be overloaded! Touching it now is probably not a good idea."))
		return
	// If parent returned 1:
	// - Hatch is open, so we can modify the SMES
	// - No action was taken in parent function (terminal de/construction atm).
	. = ..()

	if(!.)
		return

	// Charged above 1% and safeties are enabled.
	if((charge > (capacity / 100)) && safeties_enabled && !ismultitool(I))
		to_chat(user, span_warning("Safety circuit of [src] is preventing modifications while it's charged!"))
		return

	if(outputting || input_attempt)
		to_chat(user, span_warning("Turn off the [src] first!"))
		return

	// Probability of failure if safety circuit is disabled (in %)
	var/failure_probability = round((charge / capacity) * 100)

	// If failure probability is below 5% it's usually safe to do modifications
	if(failure_probability < 5)
		failure_probability = 0

	// Crowbar - Disassemble the SMES.
	if(iscrowbar(I))
		if(terminal)
			to_chat(user, span_warning("You have to disassemble the terminal first!"))
			return

		playsound(get_turf(src), 'sound/items/crowbar.ogg', 25, 1)
		to_chat(user, span_warning("You begin to disassemble the [src]!"))

		if(!do_after(user, 10 SECONDS * cur_coils, NONE, src, BUSY_ICON_BUILD)) // More coils = takes longer to disassemble. It's complex so largest one with 5 coils will take 50s
			return

		if(failure_probability && prob(failure_probability))
			total_system_failure(failure_probability, user)
			return

		to_chat(user, span_warning("You have disassembled the SMES cell!"))
		var/obj/machinery/constructable_frame/machine_frame/M = new(loc)
		M.state = 2
		M.icon_state = "box_1"
		for(var/obj/O in component_parts)
			if(O.reliability != 100 && crit_fail)
				O.crit_fail = TRUE
			O.forceMove(loc)
		qdel(src)

	// Superconducting Magnetic Coil - Upgrade the SMES
	else if(istype(I, /obj/item/stock_parts/smes_coil))
		if(cur_coils >= max_coils)
			to_chat(user, span_warning("You can't insert more coils to this SMES unit!"))
			return

		if(failure_probability && prob(failure_probability))
			total_system_failure(failure_probability, user)
			return

		to_chat(user, "You install the coil into the SMES unit!")
		if(!user.transferItemToLoc(I, src))
			return

		cur_coils ++
		component_parts += I
		recalc_coils()

	// Multitool - Toggle the safeties.
	else if(ismultitool(I))
		safeties_enabled = !safeties_enabled
		to_chat(user, span_warning("You [safeties_enabled ? "connected" : "disconnected"] the safety circuit."))
		visible_message("[icon2html(src, viewers(src))] <b>[src]</b> beeps: \"Caution. Safety circuit has been: [safeties_enabled ? "re-enabled" : "disabled. Please excercise caution."]\"")
