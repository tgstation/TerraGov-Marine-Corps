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

	var/power_gen_percent = 0 //80,000W at full capacity
	var/buildstate = FUSION_ENGINE_NO_DAMAGE //What state of building it are we on, 0-3, 1 is "broken", the default
	var/is_on = FALSE  //Is this damn thing on or what?
	var/cur_tick = 0 //Tick updater

	var/obj/item/fuelCell/fusion_cell
	var/fuel_rate = 0 //Rate at which fuel is used.  Based mostly on how long the generator has been running.


/obj/machinery/power/fusion_engine/Initialize()
	. = ..()
	fusion_cell = new(src)

/obj/machinery/power/fusion_engine/should_have_node()
	return TRUE


/obj/machinery/power/fusion_engine/preset/Initialize()
	. = ..()
	fusion_cell.set_fuel_amount(100)
	is_on = TRUE
	power_gen_percent = 99//will get to 100 on first tick, updating fuel_rate in the process
	update_icon()
	start_processing()

/obj/machinery/power/fusion_engine/random/Initialize()
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
	if (fusion_cell.fuel_amount <= 0)
		visible_message("[icon2html(src, viewers(src))] <b>[src]</b> flashes that the fuel cell is empty as the engine seizes.")
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
				visible_message("[icon2html(src, viewers(src))] [span_notice("<b>[src]</b> begins to whirr as it powers up.")]")
				fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.1
			if(50)
				visible_message("[icon2html(src, viewers(src))] [span_notice("<b>[src]</b> begins to hum loudly as it reaches half capacity.")]")
				fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.5
			if(100)
				visible_message("[icon2html(src, viewers(src))] [span_notice("<b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.")]")
				fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE


	add_avail(FUSION_ENGINE_MAX_POWER_GEN * (power_gen_percent / 100) ) //Nope, all good, just add the power
	fusion_cell.take(fuel_rate) //Consumes fuel
	update_icon()

/obj/machinery/power/fusion_engine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		to_chat(user, span_warning("You have no idea how to use that."))
		return FALSE
	interact_hand(user)

/obj/machinery/power/fusion_engine/attack_ai(mob/living/silicon/ai/user)
	interact_hand(user)

//It is a bit messy to split attack_hand into this proc, but it is the easiest way to have the AI be able to toggle them.
/obj/machinery/power/fusion_engine/proc/interact_hand(mob/living/user)
	switch(buildstate)
		if(FUSION_ENGINE_HEAVY_DAMAGE)
			to_chat(user, span_info("Use a blowtorch, then wirecutters, then wrench to repair it."))
			return FALSE
		if(FUSION_ENGINE_MEDIUM_DAMAGE)
			to_chat(user, span_notice("Use a wirecutters, then wrench to repair it."))
			return FALSE
		if(FUSION_ENGINE_LIGHT_DAMAGE)
			to_chat(user, span_notice("Use a wrench to repair it."))
			return FALSE
	if(is_on)
		visible_message("[icon2html(src, viewers(src))] [span_warning("<b>[src]</b> beeps softly and the humming stops as [usr] shuts off the generator.")]")
		is_on = FALSE
		power_gen_percent = 0
		cur_tick = 0
		update_icon()
		stop_processing()
		return TRUE

	if(!fusion_cell)
		to_chat(user, span_notice("The reactor requires a fuel cell before you can turn it on."))
		return FALSE
	if(fusion_cell.fuel_amount == 0)
		to_chat(user, span_warning("The reactor flashes that the fuel cell is empty."))
		return FALSE

	if(fusion_cell.fuel_amount <= 10)
		to_chat(user, "[icon2html(src, user)] [span_warning("<b>[src]</b>: Fuel levels critically low.")]")
	visible_message("[icon2html(src, viewers(src))] [span_warning("<b>[src]</b> beeps loudly as [user] turns the generator on and begins the process of fusion...")]")
	fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.1

	is_on = TRUE
	cur_tick = 0
	update_icon()
	start_processing()
	return TRUE

/obj/machinery/power/fusion_engine/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/fuelCell))
		if(is_on)
			to_chat(user, span_warning("The [src] needs to be turned off first."))
			return
		if(fusion_cell)
			to_chat(user, span_warning("You need to remove the fuel cell from [src] first."))
			return
		if(user.transferItemToLoc(I, src))
			fusion_cell = I
			update_icon()
			to_chat(user, span_notice("You load the [src] with the [I]."))
		return TRUE
	else
		return ..()

/obj/machinery/power/fusion_engine/welder_act(mob/living/user, obj/item/O)
	if(buildstate == FUSION_ENGINE_HEAVY_DAMAGE)
		var/obj/item/tool/weldingtool/WT = O
		if(WT.remove_fuel(1, user))
			if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
				user.visible_message(span_notice("[user] fumbles around figuring out [src]'s internals."),
				span_notice("You fumble around figuring out [src]'s internals."))
				var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
				if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
					return FALSE
			playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
			user.visible_message(span_notice("[user] starts welding [src]'s internal damage."),
			span_notice("You start welding [src]'s internal damage."))
			if(do_after(user, 200, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
				if(buildstate != FUSION_ENGINE_HEAVY_DAMAGE || is_on)
					return FALSE
				playsound(loc, 'sound/items/welder2.ogg', 25, 1)
				buildstate = FUSION_ENGINE_MEDIUM_DAMAGE
				user.visible_message(span_notice("[user] welds [src]'s internal damage."),
				span_notice("You weld [src]'s internal damage."))
				update_icon()
				return TRUE
		else
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return FALSE

/obj/machinery/power/fusion_engine/wirecutter_act(mob/living/user, obj/item/O)
	if(buildstate == FUSION_ENGINE_MEDIUM_DAMAGE && !is_on)
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out [src]'s wiring."),
			span_notice("You fumble around figuring out [src]'s wiring."))
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return FALSE
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		user.visible_message(span_notice("[user] starts securing [src]'s wiring."),
		span_notice("You start securing [src]'s wiring."))
		if(!do_after(user, 120, TRUE, src, BUSY_ICON_BUILD) || buildstate != FUSION_ENGINE_MEDIUM_DAMAGE || is_on)
			return FALSE
		playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
		buildstate = FUSION_ENGINE_LIGHT_DAMAGE
		user.visible_message(span_notice("[user] secures [src]'s wiring."),
		span_notice("You secure [src]'s wiring."))
		update_icon()
		return TRUE

/obj/machinery/power/fusion_engine/wrench_act(mob/living/user, obj/item/O)
	if(buildstate == FUSION_ENGINE_LIGHT_DAMAGE && !is_on)
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message(span_notice("[user] fumbles around figuring out [src]'s tubing and plating."),
			span_notice("You fumble around figuring out [src]'s tubing and plating."))
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return FALSE
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		user.visible_message(span_notice("[user] starts repairing [src]'s tubing and plating."),
		span_notice("You start repairing [src]'s tubing and plating."))
		if(do_after(user, 150, TRUE, src, BUSY_ICON_BUILD) && buildstate == FUSION_ENGINE_LIGHT_DAMAGE && !is_on)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			buildstate = FUSION_ENGINE_NO_DAMAGE
			user.visible_message(span_notice("[user] repairs [src]'s tubing and plating."),
			span_notice("You repair [src]'s tubing and plating."))
			update_icon()
			return TRUE

/obj/machinery/power/fusion_engine/crowbar_act(mob/living/user, obj/item/O)
	if(buildstate != FUSION_ENGINE_NO_DAMAGE)
		to_chat(user, span_warning("You must repair the generator before working with its fuel cell."))
		return
	if(is_on)
		to_chat(user, span_warning("You must turn off the generator before working with its fuel cell."))
		return
	if(!fusion_cell)
		to_chat(user, span_warning("There is no cell to remove."))
	else
		if(user.skills.getRating("engineer") < SKILL_ENGINEER_ENGI)
			user.visible_message(span_warning("[user] fumbles around figuring out [src]'s fuel receptacle."),
			span_warning("You fumble around figuring out [src]'s fuel receptacle."))
			var/fumbling_time = 10 SECONDS - 2 SECONDS * user.skills.getRating("engineer")
			if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
				return FALSE
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		user.visible_message(span_notice("[user] starts prying [src]'s fuel receptacle open."),
		span_notice("You start prying [src]'s fuel receptacle open."))
		if(do_after(user, 100, TRUE, src, BUSY_ICON_BUILD) && buildstate == FUSION_ENGINE_NO_DAMAGE && !is_on && fusion_cell)
			user.visible_message(span_notice("[user] pries [src]'s fuel receptacle open and removes the cell."),
			span_notice("You pry [src]'s fuel receptacle open and remove the cell.."))
			fusion_cell.update_icon()
			user.put_in_hands(fusion_cell)
			fusion_cell = null
			update_icon()
			return TRUE


/obj/machinery/power/fusion_engine/examine(mob/user)
	. = ..()
	if(ishuman(user))
		if(buildstate != FUSION_ENGINE_NO_DAMAGE)
			. += span_info("It's broken.")
			switch(buildstate)
				if(FUSION_ENGINE_HEAVY_DAMAGE)
					. += span_info("Use a blowtorch, then wirecutters, then wrench to repair it.")
				if(FUSION_ENGINE_MEDIUM_DAMAGE)
					. += span_info("Use a wirecutters, then wrench to repair it.")
				if(FUSION_ENGINE_LIGHT_DAMAGE)
					. += span_info("Use a wrench to repair it.")
			return FALSE

		if(!is_on)
			. += span_info("It looks offline.")
		else
			. += span_info("The power gauge reads: [power_gen_percent]%")
		if(fusion_cell)
			. += span_info("You can see a fuel cell in the receptacle.")
			if(user.skills.getRating("engineer") >= SKILL_ENGINEER_MASTER)
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

//FUEL CELL // todo for gods sake no camelcase
/obj/item/fuelCell
	name = "\improper WL-6 universal fuel cell"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "cell-empty"
	desc = "A rechargable fuel cell designed to work as a power source for the Cheyenne-Class transport or for Westingland S-52 Reactors."
	var/fuel_amount = 0
	var/max_fuel_amount = 100

/obj/item/fuelCell/low
	icon_state = "cell-low"
	fuel_amount = 25

/obj/item/fuelCell/medium
	icon_state = "cell-medium"
	fuel_amount = 50

/obj/item/fuelCell/high
	icon_state = "cell-high"
	fuel_amount = 75

/obj/item/fuelCell/full
	icon_state = "cell-full"
	fuel_amount = 100

/obj/item/fuelCell/random/Initialize()
	. = ..()
	fuel_amount = rand(0,100)
	update_icon()

/obj/item/fuelCell/update_icon()
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

/obj/item/fuelCell/examine(mob/user)
	. = ..()
	if(ishuman(user))
		. += "The fuel indicator reads: [get_fuel_percent()]%"

/obj/item/fuelCell/proc/get_fuel_percent()
	return round(100*fuel_amount/max_fuel_amount)

/obj/item/fuelCell/proc/is_regenerated()
	return (fuel_amount == max_fuel_amount)

/obj/item/fuelCell/proc/give(amount)
	fuel_amount = min(fuel_amount + amount, max_fuel_amount)

/obj/item/fuelCell/proc/take(amount)
	fuel_amount = max(fuel_amount - amount, 0)

/obj/item/fuelCell/proc/set_fuel_amount(amount)
	if(amount < 0 || amount > max_fuel_amount)
		return
	fuel_amount = amount
