#define FUSION_ENGINE_MAX_POWER_GEN	80000 //Full capacity
#define FUSION_ENGINE_FAIL_CHECK_TICKS	1000 //Check for failure every this many ticks
#define FUSION_ENGINE_FULL_STRENGTH_FULL_RATE 0.1
#define FUSION_ENGINE_NO_DAMAGE     0
#define FUSION_ENGINE_LIGHT_DAMAGE  1
#define FUSION_ENGINE_MEDIUM_DAMAGE 2
#define FUSION_ENGINE_HEAVY_DAMAGE  3

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
	var/fail_rate = 5 //% chance of failure each fail_tick check
	var/cur_tick = 0 //Tick updater

	var/obj/item/fuelCell/fusion_cell = new //Starts with a fuel cell loaded in.  Maybe replace with the plasma tanks in the future and have it consume plasma?  Possibly remove this later if it's irrelevent...
	var/fuel_rate = 0 //Rate at which fuel is used.  Based mostly on how long the generator has been running.

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
		buildstate = FUSION_ENGINE_MEDIUM_DAMAGE  //No fuel really fucks it.
		is_on = FALSE
		power_gen_percent = 0
		fail_rate+=2 //Each time the engine is allowed to seize up it's fail rate for the future increases because reasons.
		update_icon()
		stop_processing()
		return FALSE

	if(!check_failure())

		if(power_gen_percent < 100)
			power_gen_percent++

			switch(power_gen_percent) //Flavor text!
				if(10)
					visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> begins to whirr as it powers up.</span>")
					fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.25
				if(50)
					visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> begins to hum loudly as it reaches half capacity.</span>")
					fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.5
				if(100)
					visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.</span>")
					fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE


		add_avail(FUSION_ENGINE_MAX_POWER_GEN * (power_gen_percent / 100) ) //Nope, all good, just add the power
		fusion_cell.take(fuel_rate) //Consumes fuel
		update_icon()

/obj/machinery/power/fusion_engine/attack_hand(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You have no idea how to use that.</span>")
		return FALSE
	add_fingerprint(user)
	switch(buildstate)
		if(FUSION_ENGINE_HEAVY_DAMAGE)
			to_chat(user, "<span class='info'>Use a blowtorch, then wirecutters, then wrench to repair it.</span>")
			return FALSE
		if(FUSION_ENGINE_MEDIUM_DAMAGE)
			to_chat(user, "<span class='notice'>Use a wirecutters, then wrench to repair it.</span>")
			return FALSE
		if(FUSION_ENGINE_LIGHT_DAMAGE)
			to_chat(user, "<span class='notice'>Use a wrench to repair it.</span>")
			return FALSE
	if(is_on)
		visible_message("[icon2html(src, viewers(src))] <span class='warning'><b>[src]</b> beeps softly and the humming stops as [usr] shuts off the generator.</span>")
		is_on = FALSE
		power_gen_percent = 0
		cur_tick = 0
		update_icon()
		stop_processing()
		return TRUE

	if(!fusion_cell)
		to_chat(user, "<span class='notice'>The reactor requires a fuel cell before you can turn it on.</span>")
		return FALSE
	if(fusion_cell.fuel_amount == 0)
		to_chat(user, "<span class='warning'>The reactor flashes that the fuel cell is empty.</span>")
		return FALSE

	if(fusion_cell.fuel_amount <= 10)
		to_chat(user, "[icon2html(src, user)] <span class='warning'><b>[src]</b>: Fuel levels critically low.</span>")
	visible_message("[icon2html(src, viewers(src))] <span class='warning'><b>[src]</b> beeps loudly as [user] turns the generator on and begins the process of fusion...</span>")
	fuel_rate = FUSION_ENGINE_FULL_STRENGTH_FULL_RATE * 0.1

	is_on = TRUE
	cur_tick = 0
	update_icon()
	start_processing()
	return TRUE

/obj/machinery/power/fusion_engine/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/fuelCell))
		if(is_on)
			to_chat(user, "<span class='warning'>The [src] needs to be turned off first.</span>")
			return TRUE
		if(!fusion_cell)
			if(user.transferItemToLoc(O, src))
				fusion_cell = O
				update_icon()
				to_chat(user, "<span class='notice'>You load the [src] with the [O].</span>")
			return TRUE
		else
			to_chat(user, "<span class='warning'>You need to remove the fuel cell from [src] first.</span>")
			return TRUE
		return TRUE
	else if(iswelder(O))
		if(buildstate == FUSION_ENGINE_HEAVY_DAMAGE)
			var/obj/item/tool/weldingtool/WT = O
			if(WT.remove_fuel(1, user))
				if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
					user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s internals.</span>",
					"<span class='notice'>You fumble around figuring out [src]'s internals.</span>")
					var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
					if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
						return
				playsound(loc, 'sound/items/weldingtool_weld.ogg', 25)
				user.visible_message("<span class='notice'>[user] starts welding [src]'s internal damage.</span>",
				"<span class='notice'>You start welding [src]'s internal damage.</span>")
				if(do_after(user, 200, TRUE, 5, BUSY_ICON_BUILD))
					if(buildstate != FUSION_ENGINE_HEAVY_DAMAGE || is_on || !WT.isOn())
						return FALSE
					playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
					buildstate = FUSION_ENGINE_MEDIUM_DAMAGE
					user.visible_message("<span class='notice'>[user] welds [src]'s internal damage.</span>",
					"<span class='notice'>You weld [src]'s internal damage.</span>")
					update_icon()
					return TRUE
			else
				to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
				return FALSE
	else if(iswirecutter(O))
		if(buildstate == FUSION_ENGINE_MEDIUM_DAMAGE && !is_on)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s wiring.</span>",
				"<span class='notice'>You fumble around figuring out [src]'s wiring.</span>")
				var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
					return
			playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts securing [src]'s wiring.</span>",
			"<span class='notice'>You start securing [src]'s wiring.</span>")
			if(do_after(user, 120, TRUE, 12, BUSY_ICON_BUILD))
				if(buildstate != FUSION_ENGINE_MEDIUM_DAMAGE || is_on)
					return FALSE
				playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
				buildstate = FUSION_ENGINE_LIGHT_DAMAGE
				user.visible_message("<span class='notice'>[user] secures [src]'s wiring.</span>",
				"<span class='notice'>You secure [src]'s wiring.</span>")
				update_icon()
				return TRUE
	else if(iswrench(O))
		if(buildstate == FUSION_ENGINE_LIGHT_DAMAGE && !is_on)
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='notice'>[user] fumbles around figuring out [src]'s tubing and plating.</span>",
				"<span class='notice'>You fumble around figuring out [src]'s tubing and plating.</span>")
				var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
					return
			playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts repairing [src]'s tubing and plating.</span>",
			"<span class='notice'>You start repairing [src]'s tubing and plating.</span>")
			if(do_after(user, 150, TRUE, 15, BUSY_ICON_BUILD))
				if(buildstate != FUSION_ENGINE_LIGHT_DAMAGE || is_on)
					return FALSE
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				buildstate = FUSION_ENGINE_NO_DAMAGE
				user.visible_message("<span class='notice'>[user] repairs [src]'s tubing and plating.</span>",
				"<span class='notice'>You repair [src]'s tubing and plating.</span>")
				update_icon()
				return TRUE
	else if(iscrowbar(O))
		if(buildstate != FUSION_ENGINE_NO_DAMAGE)
			to_chat(user, "<span class='warning'>You must repair the generator before working with its fuel cell.</span>")
			return
		if(is_on)
			to_chat(user, "<span class='warning'>You must turn off the generator before working with its fuel cell.</span>")
			return
		if(!fusion_cell)
			to_chat(user, "<span class='warning'>There is no cell to remove.</span>")
		else
			if(user.mind && user.mind.cm_skills && user.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				user.visible_message("<span class='warning'>[user] fumbles around figuring out [src]'s fuel receptacle.</span>",
				"<span class='warning'>You fumble around figuring out [src]'s fuel receptacle.</span>")
				var/fumbling_time = 100 - 20 * user.mind.cm_skills.engineer
				if(!do_after(user, fumbling_time, TRUE, 5, BUSY_ICON_BUILD))
					return
			playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts prying [src]'s fuel receptacle open.</span>",
			"<span class='notice'>You start prying [src]'s fuel receptacle open.</span>")
			if(do_after(user, 100, TRUE, 15, BUSY_ICON_BUILD))
				if(buildstate != FUSION_ENGINE_NO_DAMAGE || is_on || !fusion_cell)
					return FALSE
				user.visible_message("<span class='notice'>[user] pries [src]'s fuel receptacle open and removes the cell.</span>",
				"<span class='notice'>You pry [src]'s fuel receptacle open and remove the cell..</span>")
				fusion_cell.update_icon()
				user.put_in_hands(fusion_cell)
				fusion_cell = null
				update_icon()
				return TRUE
	else
		return ..()

/obj/machinery/power/fusion_engine/examine(mob/user)
	..()
	if(ishuman(user))
		if(buildstate != FUSION_ENGINE_NO_DAMAGE)
			to_chat(user, "<span class='info'>It's broken.</span>")
			switch(buildstate)
				if(FUSION_ENGINE_HEAVY_DAMAGE)
					to_chat(user, "<span class='info'>Use a blowtorch, then wirecutters, then wrench to repair it.</span>")
				if(FUSION_ENGINE_MEDIUM_DAMAGE)
					to_chat(user, "<span class='info'>Use a wirecutters, then wrench to repair it.</span>")
				if(FUSION_ENGINE_LIGHT_DAMAGE)
					to_chat(user, "<span class='info'>Use a wrench to repair it.</span>")
			return FALSE

		if(!is_on)
			to_chat(user, "<span class='info'>It looks offline.</span>")
		else
			to_chat(user, "<span class='info'>The power gauge reads: [power_gen_percent]%</span>")
		if(fusion_cell)
			to_chat(user, "<span class='info'>You can see a fuel cell in the receptacle.</span>")
			if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.engineer >= SKILL_ENGINEER_MT)
				switch(fusion_cell.fuel_amount)
					if(0 to 10)
						to_chat(user, "<span class='danger'>The fuel cell is critically low.</span>")
					if(11 to 25)
						to_chat(user, "<span class='warning'>The fuel cell is running low.</span>")
					if(26 to 50)
						to_chat(user, "<span class='info'>The fuel cell is a little under halfway.</span>")
					if(51 to 75)
						to_chat(user, "<span class='info'>The fuel cell is a little above halfway.</span>")
					if(76 to 99)
						to_chat(user, "<span class='info'>The fuel cell is nearly full.</span>")
					if(100)
						to_chat(user, "<span class='info'>The fuel cell is full.</span>")
		else
			to_chat(user, "<span class='info'>There is no fuel cell in the receptacle.</span>")

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


/obj/machinery/power/fusion_engine/proc/check_failure()
	if(cur_tick < FUSION_ENGINE_FAIL_CHECK_TICKS) //Nope, not time for it yet
		cur_tick++
		return FALSE
	cur_tick = 0 //reset the timer
	if(rand(1,100) < fail_rate) //Oh snap, we failed! Shut it down!
		if(prob(25))
			visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> beeps wildly and a fuse blows! Use wirecutters, then a wrench to repair it.")
			buildstate = FUSION_ENGINE_MEDIUM_DAMAGE
		else
			visible_message("[icon2html(src, viewers(src))] <span class='notice'><b>[src]</b> beeps wildly and sprays random pieces everywhere! Use a wrench to repair it.")
			buildstate = FUSION_ENGINE_LIGHT_DAMAGE
		is_on = FALSE
		power_gen_percent = 0
		update_icon()
		stop_processing()

		return TRUE
	else
		return FALSE

#undef FUSION_ENGINE_MAX_POWER_GEN
#undef FUSION_ENGINE_FAIL_CHECK_TICKS
#undef FUSION_ENGINE_NO_DAMAGE
#undef FUSION_ENGINE_LIGHT_DAMAGE
#undef FUSION_ENGINE_MEDIUM_DAMAGE
#undef FUSION_ENGINE_HEAVY_DAMAGE

//FUEL CELL
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
	..()
	if(ishuman(user))
		to_chat(user, "The fuel indicator reads: [get_fuel_percent()]%")

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
