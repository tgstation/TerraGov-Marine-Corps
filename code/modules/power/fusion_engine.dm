#define FUSION_ENGINE_MAX_POWER_GEN 80000 //Full capacity
#define FUSION_ENGINE_FAIL_CHECK_TICKS 1000 //Check for failure every this many ticks
#define FUSION_ENGINE_FULL_STRENGTH_FULL_RATE 0.1
#define FUSION_ENGINE_NO_DAMAGE 0
#define FUSION_ENGINE_LIGHT_DAMAGE 1
#define FUSION_ENGINE_MEDIUM_DAMAGE 2
#define FUSION_ENGINE_HEAVY_DAMAGE 3

/obj/machinery/power/fusion_engine
	name = "\improper S-52 fusion reactor"
	icon = 'icons/Marine/fusion_eng.dmi'
	icon_state = "off"
	desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat."
	resistance_flags = UNACIDABLE
	anchored = TRUE
	density = TRUE

	/// The % of how much of our max power we're putting out, 80,000W at full capacity
	var/power_gen_percent = 0
	//What state of damage are we on
	var/buildstate = FUSION_ENGINE_NO_DAMAGE
	/// Is the generator on?
	var/is_on = FALSE
	/// The cell inside the generator
	var/obj/item/fuel_cell/fusion_cell
	/// Rate at which fuel is used.  Based mostly on how long the generator has been running.
	var/fuel_rate = 0


/obj/machinery/power/fusion_engine/Initialize(mapload)
	. = ..()
	fusion_cell = new(src)

/obj/machinery/power/fusion_engine/should_have_node()
	return TRUE


/obj/machinery/power/fusion_engine/preset/Initialize(mapload)
	. = ..()
	fusion_cell.set_fuel_amount(100)
	is_on = TRUE
	power_gen_percent = 99//will get to 100 on first tick, updating fuel_rate in the process
	update_icon()
	start_processing()

/obj/machinery/power/fusion_engine/random/Initialize(mapload)
	. = ..()
	switch(rand(1,100))
		if(1 to 5)
			buildstate = FUSION_ENGINE_HEAVY_DAMAGE
		if(6 to 15)
			buildstate = FUSION_ENGINE_MEDIUM_DAMAGE
		if(16 to 30)
			buildstate = FUSION_ENGINE_LIGHT_DAMAGE
		else
			fusion_cell.set_fuel_amount(rand(0,30))
	update_icon()

/obj/machinery/power/fusion_engine/power_change()
	return

/obj/machinery/power/fusion_engine/process()
	if(!is_on || buildstate || !anchored || !powernet || !fusion_cell) //Default logic checking
		if(is_on)
			is_on = FALSE
			power_gen_percent = 0
			update_icon()
			stop_processing()
		return FALSE
	if(fusion_cell.fuel_amount <= 0)
		balloon_alert_to_viewers("Is out of fuel")
		fuel_rate = 0
		is_on = FALSE
		power_gen_percent = 0
		update_icon()
		stop_processing()
		return FALSE

	if(power_gen_percent < 100)
		power_gen_percent++

		switch(power_gen_percent) //Flavor text!
			if(10)
				balloon_alert_to_viewers("begins to whirr as it powers up")
				fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.1
			if(50)
				balloon_alert_to_viewers("hums as it reaches half capacity")
				fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.5
			if(100)
				balloon_alert_to_viewers("rumbles as it reaches full strength")
				fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE


	add_avail(FUSION_ENGINE_MAX_POWER_GEN * (power_gen_percent / 100) ) //Nope, all good, just add the power
	fusion_cell.take(fuel_rate) //Consumes fuel
	update_icon()

/obj/machinery/power/fusion_engine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		balloon_alert(user, "You can't use that")
		return FALSE
	interact_hand(user)

/obj/machinery/power/fusion_engine/attack_ai(mob/living/silicon/ai/user)
	return interact_hand(user)

//It is a bit messy to split attack_hand into this proc, but it is the easiest way to have the AI be able to toggle them.
/obj/machinery/power/fusion_engine/proc/interact_hand(mob/living/user)
	switch(buildstate)
		if(FUSION_ENGINE_HEAVY_DAMAGE)
			balloon_alert(user, "Use blowtorch to start repairs")
			return FALSE
		if(FUSION_ENGINE_MEDIUM_DAMAGE)
			balloon_alert(user, "Use wirecutters to fix the circuitry")
			return FALSE
		if(FUSION_ENGINE_LIGHT_DAMAGE)
			balloon_alert(user, "Use a wrench to finish the repair")
			return FALSE
	if(is_on)
		balloon_alert_to_viewers("[usr] shuts off the generator.")
		is_on = FALSE
		power_gen_percent = 0
		update_icon()
		stop_processing()
		return TRUE

	if(!fusion_cell)
		balloon_alert(user, "Can't, requires a fuel cell")
		return FALSE
	if(!fusion_cell.fuel_amount)
		balloon_alert(user, "Fuel cell is empty")
		return FALSE

	if(fusion_cell.fuel_amount <= 10)
		balloon_alert_to_viewers("Fuel levels critically low")
	balloon_alert_to_viewers("turns the generator on")
	fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.1

	is_on = TRUE
	update_icon()
	start_processing()
	return TRUE

/obj/machinery/power/fusion_engine/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/fuel_cell))
		return ..()

	if(is_on)
		balloon_alert(user, "Cannot, needs turned off first")
		return

	if(fusion_cell)
		balloon_alert(user, "Need to remove fuel cell first")
		return

	if(user.transferItemToLoc(I, src))
		fusion_cell = I
		update_icon()
		balloon_alert(user, "You load the [src] with the [I].")

/obj/machinery/power/fusion_engine/welder_act(mob/living/user, obj/item/O)
	. = ..()
	if(!iswelder(O))
		return FALSE

	var/obj/item/tool/weldingtool/WT = O
	if(buildstate != FUSION_ENGINE_HEAVY_DAMAGE)
		balloon_alert(user, "Doesn't need welding")
		return FALSE

	if(!(WT.remove_fuel(1, user)))
		balloon_alert(user, "Need more welding fuel")
		return FALSE

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		balloon_alert_to_viewers("Fumbles with [src]'s internals")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
			return FALSE
	playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
	balloon_alert_to_viewers("Starts welding some damage")
	add_overlay(GLOB.welding_sparks)
	if(!do_after(user, 20 SECONDS - (user.skills.getRating(SKILL_ENGINEER) * 3 SECONDS) , NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
		return FALSE
	if(buildstate != FUSION_ENGINE_HEAVY_DAMAGE || is_on)
		cut_overlay(GLOB.welding_sparks)
		return FALSE
	playsound(loc, 'sound/items/welder2.ogg', 25, 1)
	buildstate = FUSION_ENGINE_MEDIUM_DAMAGE
	balloon_alert_to_viewers("[user] starts welds some damage")
	cut_overlay(GLOB.welding_sparks)
	update_icon()
	record_generator_repairs(user)
	return TRUE

/obj/machinery/power/fusion_engine/wirecutter_act(mob/living/user, obj/item/O)
	. = ..()

	if(!iswirecutter(O))
		return FALSE

	if(is_on)
		balloon_alert(user, "Turn it off first!")
		return FALSE

	if(buildstate != FUSION_ENGINE_MEDIUM_DAMAGE)
		balloon_alert(user, "Doesn't need wire adjustments")
		return FALSE

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		balloon_alert_to_viewers("Fumbles with [src]'s wiring")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE

	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	balloon_alert_to_viewers("Starts securing [src]'s wiring")
	if(!do_after(user,  10 SECONDS - (user.skills.getRating(SKILL_ENGINEER) * 2 SECONDS), NONE, src, BUSY_ICON_BUILD) || buildstate != FUSION_ENGINE_MEDIUM_DAMAGE || is_on)
		return FALSE
	playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
	buildstate = FUSION_ENGINE_LIGHT_DAMAGE
	balloon_alert_to_viewers("Secures [src]'s wiring")
	update_icon()
	record_generator_repairs(user)
	return TRUE

/obj/machinery/power/fusion_engine/wrench_act(mob/living/user, obj/item/O)
	. = ..()
	if(!iswrench(O))
		return FALSE

	if(buildstate != FUSION_ENGINE_LIGHT_DAMAGE)
		balloon_alert(user, "Doesn't need pipe adjustments")
		return FALSE

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		balloon_alert_to_viewers("Fumbles with [src]'s tubing")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	balloon_alert_to_viewers("Starts repairing [src]'s tubing")
	if(!do_after(user,  15 SECONDS - (user.skills.getRating(SKILL_ENGINEER) * 3 SECONDS), NONE, src, BUSY_ICON_BUILD) && buildstate == FUSION_ENGINE_LIGHT_DAMAGE && !is_on)
		return FALSE
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	buildstate = FUSION_ENGINE_NO_DAMAGE
	balloon_alert_to_viewers("Repairs [src]'s tubing")
	update_icon()
	record_generator_repairs(user)
	return TRUE

/obj/machinery/power/fusion_engine/crowbar_act(mob/living/user, obj/item/O)
	. = ..()
	if(buildstate != FUSION_ENGINE_NO_DAMAGE)
		balloon_alert(user, "You must repair the generator first")
		return
	if(is_on)
		balloon_alert(user, "You must turn the generator off first")
		return
	if(!fusion_cell)
		balloon_alert(user, "There is no cell to remove")
		return

	if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_ENGI)
		balloon_alert_to_viewers("Fumbles with [src]'s fuel bay")
		var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating(SKILL_ENGINEER)
		if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return FALSE
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	balloon_alert_to_viewers("Starts prying [src]'s fuel bay open")
	if(!do_after(user, 10 SECONDS - (user.skills.getRating(SKILL_ENGINEER) * 2 SECONDS), NONE, src, BUSY_ICON_BUILD) && buildstate == FUSION_ENGINE_NO_DAMAGE && !is_on && fusion_cell)
		return FALSE
	balloon_alert_to_viewers("Pries [src]'s fuel bay open and removes the cell")
	fusion_cell.update_icon()
	user.put_in_hands(fusion_cell)
	fusion_cell = null
	update_icon()
	return TRUE

/obj/machinery/power/fusion_engine/examine(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	if(buildstate != FUSION_ENGINE_NO_DAMAGE)
		. += span_info("It's broken.")
		switch(buildstate)
			if(FUSION_ENGINE_HEAVY_DAMAGE)
				. += span_info("Use a blowtorch, then wirecutters, then wrench to repair it.")
			if(FUSION_ENGINE_MEDIUM_DAMAGE)
				. += span_info("Use a wirecutters, then wrench to repair it.")
			if(FUSION_ENGINE_LIGHT_DAMAGE)
				. += span_info("Use a wrench to repair it.")
		return

	if(!is_on)
		. += span_info("It looks offline.")
	else
		. += span_info("The power gauge reads: [power_gen_percent]%")
	if(fusion_cell)
		. += span_info("You can see a fuel cell in the receptacle.")
		if(user.skills.getRating(SKILL_ENGINEER) >= SKILL_ENGINEER_MASTER)
			switch(fusion_cell.fuel_amount)
				if(0 to 10)
					. += span_danger("The fuel cell is critically low.")
				if(11 to 25)
					. += span_warning("The fuel cell is running low.")
				if(26 to 50)
					. += span_info("The fuel cell is a little under halfway.")
				if(51 to 75)
					. += span_info("The fuel cell is a little above halfway.")
				if(76 to 99)
					. += span_info("The fuel cell is nearly full.")
				if(100)
					. += span_info("The fuel cell is full.")
	else
		. += span_info("There is no fuel cell in the receptacle.")

/obj/machinery/power/fusion_engine/update_icon()
	switch(buildstate)
		if(FUSION_ENGINE_NO_DAMAGE)
			if(fusion_cell?.fuel_amount > 0)
				var/pstatus = is_on ? "on" : "off"
				switch(fusion_cell.fuel_amount)
					if(1 to 10)
						icon_state = "[pstatus]-10"
					if(11 to 25)
						icon_state = "[pstatus]-25"
					if(26 to 50)
						icon_state = "[pstatus]-50"
					if(51 to 75)
						icon_state = "[pstatus]-75"
					if(76 to INFINITY)
						icon_state = "[pstatus]-100"
			else
				icon_state = "off"

		if(FUSION_ENGINE_HEAVY_DAMAGE)
			icon_state = "weld"
		if(FUSION_ENGINE_MEDIUM_DAMAGE)
			icon_state = "wire"
		if(FUSION_ENGINE_LIGHT_DAMAGE)
			icon_state = "wrench"

#undef FUSION_ENGINE_MAX_POWER_GEN
#undef FUSION_ENGINE_FAIL_CHECK_TICKS
#undef FUSION_ENGINE_NO_DAMAGE
#undef FUSION_ENGINE_LIGHT_DAMAGE
#undef FUSION_ENGINE_MEDIUM_DAMAGE
#undef FUSION_ENGINE_HEAVY_DAMAGE

//FUEL CELL
/obj/item/fuel_cell
	name = "\improper WL-6 universal fuel cell"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "cell-empty"
	desc = "A rechargable fuel cell designed to work as a power source for the Cheyenne-Class transport or for Westingland S-52 Reactors."
	/// The amount of fuel currently in the cell
	var/fuel_amount = 0
	/// The maximum amount of fuel the cell holds
	var/max_fuel_amount = 100

/obj/item/fuel_cell/low
	icon_state = "cell-low"
	fuel_amount = 25

/obj/item/fuel_cell/medium
	icon_state = "cell-medium"
	fuel_amount = 50

/obj/item/fuel_cell/high
	icon_state = "cell-high"
	fuel_amount = 75

/obj/item/fuel_cell/full
	icon_state = "cell-full"
	fuel_amount = 100

/obj/item/fuel_cell/random/Initialize(mapload)
	. = ..()
	fuel_amount = rand(0,100)
	update_icon()

/obj/item/fuel_cell/update_icon()
	switch(get_fuel_percent())
		if(-INFINITY to 0)
			icon_state = "cell-empty"
		if(0 to 25)
			icon_state = "cell-low"
		if(25 to 75)
			icon_state = "cell-medium"
		if(75 to 99)
			icon_state = "cell-high"
		else
			icon_state = "cell-full"

/obj/item/fuel_cell/examine(mob/user)
	. = ..()
	if(ishuman(user))
		. += "The fuel indicator reads: [get_fuel_percent()]%"

/obj/item/fuel_cell/proc/get_fuel_percent()
	return round(100*fuel_amount/max_fuel_amount)

/obj/item/fuel_cell/proc/is_regenerated()
	return (fuel_amount == max_fuel_amount)

/obj/item/fuel_cell/proc/give(amount)
	fuel_amount = min(fuel_amount + amount, max_fuel_amount)

/obj/item/fuel_cell/proc/take(amount)
	fuel_amount = max(fuel_amount - amount, 0)

/obj/item/fuel_cell/proc/set_fuel_amount(amount)
	if(amount < 0 || amount > max_fuel_amount)
		return
	fuel_amount = amount
