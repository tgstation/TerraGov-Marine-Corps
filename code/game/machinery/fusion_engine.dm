//Experimental engine for the Almayer.  Should be fancier.  I expect I'll eventually make it totally seperate from the Geothermal as I don't like the procs... - Apop


/obj/machinery/power/geothermal/fusion
	name = "\improper S-52 fusion reactor"
	desc = "A Westingland S-52 Fusion Reactor. Takes fuels cells and converts them into usable power. It also produces a lot of heat as a byproduct. Sometimes desirable, sometimes not."
	icon = 'icons/Marine/fusion_eng.dmi'
	icon_state = "off-0"
	desc = "A Westingland S-52 Fusion Reactor. Takes fuels cells and converts them to power for the ship, also producing a large amount of heat. Currently in standby mode."
	almayer = 1 //Yup, it's on the Almayer.
	directwired = 0     //Requires a cable directly underneath
	unacidable = 1      //NOPE.jpg
	power_gen_percent = 0 //50,000W at full capacity
	power_generation_max = 50000 //Full capacity
	powernet_connection_failed = 0 //Logic checking for powernets
	buildstate = 0 //What state of building it are we on, 0-3, 1 is "broken", the default
	is_on = 0  //Is this damn thing on or what?
	fail_rate = 5 //% chance of failure each fail_tick check
	fail_check_ticks = 100 //Check for failure every this many ticks
	cur_tick = 0 //Tick updater
	layer = OBJ_LAYER - 0.1 //So cells and other things show properly over it

	//almayer Generator Unique Vars
	var/fusion_cell = 1 //Starts with a fuel cell loaded in.  Maybe replace with the plasma tanks in the future and have it consume plasma?  Possibly remove this later if it's irrelevent.
	var/obj/item/weapon/fuel_cell/cell //The fuel cell the reactor starts with
	var/produce_heat = 1 //Fusion is a VERY warm process. The reactor room should probably be cooled, probably.
	var/fuel_rate = 0 //Rate at which fuel is used. Based mostly on how long the generator has been running.
	var/icon_track = 100 //This is to track the amount of fuel so it selects the proper icon.

	New()
		buildstate = rand(0, 3) //This is needed to set the state for repair interactions
		switch(buildstate)
			if(1) icon_state = "weld"
			if(2) icon_state = "wire"
			if(3) icon_state = "wrench"
		cell = new /obj/item/weapon/fuel_cell
		cell.fuel_amount = rand(15, 100)
		update_icon()
		..()

/obj/machinery/power/geothermal/fusion/examine(mob/user)
	..()
	if(is_on)
		user << "<span class='info'>The reactor is calmy undergoing its fusion reaction. A simple flick of the switch will turn it off.</span>"
	if(!is_on && buildstate == 0) //It's off, waiting calmly
		user << "<span class='info'>The reactor is currently in standby mode. A simple flick of the switch will whirr it up.</span>"
	switch(buildstate)
		if(0)
			user << "<span class='info'>The reactor is in nominal condition. Nothing seems wrong with it.</span>"
		if(1) //Note : Damage goes from 1 (highest) to 3 (almost fixed)
			user << "<span class='warning'>The reactor is in complete disrepair. The internal welding needs to be fixed, some loose wires reconnected and the panels secured again.</span>"
			return
		if(2)
			user << "<span class='warning'>The reactor is seriously damaged. Some loose wires need to be reconnected and the panels secured again.</span>"
			return
		if(3)
			user << "<span class='warning'>The reactor is lighty damaged. The panels need to be secured again.</span>"
			return
	switch(cell.fuel_amount)
		if(0)
			user << "<span class='warning'>The reactor reports no fuel. This might cause a fission failure and break the ractor!</span>"
		if(1 to 10)
			user << "<span class='warning'>The reactor reports that fuel levels are critically low. If the cell isn't replaced now, it will fail and break!</span>"
		if(11 to 25)
			user << "<span class='warning'>The reactor reports that fuel levels are low. The cell will need to be replaced very soon.</span>"
		if(26 to 50)
			user << "<span class='info'>The reactor reports the fuel is now a little under halfway. Might need a change soon enough.</span>"
		if(51 to 75)
			user << "<span class='info'>The reactor reports a bit of fuel has been used. Still a lot left, no urge to switch the cell.</span>"
		if(76 to INFINITY)
			user << "<span class='info'>The reactor reports full or near-full fuel. No shortage anytime soon, cell must be brand new.</span>"

/obj/machinery/power/geothermal/fusion/process()
	if(!is_on || buildstate || !anchored) //Default logic checking
		return 0
	if(cell.fuel_amount <= 0)
		visible_message("\icon[src] <b>The [name]</b> flashes that the fuel cell is empty as the engine seizes, spitting out an empty fuel cell on the side.")
		cell.forceMove(loc)
		cell.update_icon()
		cell = null
		fuel_rate = 0
		buildstate = 1  //No fuel really fucks it.
		is_on = 0
		icon_track = 0
		fail_rate += 2 //Each time the engine is allowed to seize up it's fail rate for the future increases because reasons.
		update_icon()
		r_FAL
	if(!powernet && !powernet_connection_failed) //Powernet checking, make sure there's valid cables & powernets
		if(!connect_to_network())
			powernet_connection_failed = 1
			is_on = 0
			spawn(150) // Error! Check again in 15 seconds. Someone could have blown/acided or snipped a cable
				powernet_connection_failed = 0
	else if(powernet) //All good! Let's fire it up!
		if(!check_failure()) //THIS STILL NEEDS A SMIDGE OF WORK, AND PROBABLY IT'S OWN PROC SINCE I'M GHETTOING UP THE REGULAR ONE.

			if(power_gen_percent < 100) power_gen_percent++

			switch(power_gen_percent) //Flavor text!
				if(10)
					visible_message("\icon[src] <span class='notice'><b>The [name]</b> begins to whirr as it powers up.</span>")
					fuel_rate = 0.025
				if(50)
					visible_message("\icon[src] <span class='notice'><b>The [name]</b> begins to hum loudly as it reaches half capacity.</span>")
					fuel_rate = 0.05
				if(99)
					visible_message("\icon[src] <span class='notice'><b>The [name]</b> rumbles loudly as the combustion and thermal chambers reach full strength.</span>")
					fuel_rate = 0.1

			add_avail(power_generation_max * (power_gen_percent / 100)) //Nope, all good, just add the power
			cell.fuel_amount -= fuel_rate //Consumes fuel

	if(is_on && powernet) //This can probably be changed in the future.  For now, when a fuel cell is ejected, it'll be "useless" no matter how much fuel remains.
		update_icon()

/obj/machinery/power/geothermal/fusion/update_icon()

	if(buildstate)
		switch(buildstate)
			if(1)
				icon_state = "weld"
			if(2)
				icon_state = "wire"
			if(3)
				icon_state = "wrench"
		return
	switch(cell.fuel_amount)
		if(1 to 10)
			//visible_message("\icon[src] <b>[src]</b> displasy that the fuel cell is critically low and needs to be replaced")
			icon_track = 10
		if(11 to 25)
			//visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is below half")
			icon_track = 25
		if(26 to 50)
			//visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell at half")
			icon_track = 50
		if(51 to 75)
			//visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is 75% full")
			icon_track = 75
		if(76 to INFINITY)
			//visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is mostly full")
			icon_track = 100
	icon_state = "[is_on ? "on":"off"]-[icon_track]" //Makes sure it gets the proper icon

/obj/machinery/power/geothermal/fusion/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/fuel_cell))
		if(is_on)
			user << "<span class='warning'>[src] needs to be turned off before you can swap the fuel cell.</span>"
			r_TRU
		cell.forceMove(loc)
		cell.update_icon()
		user.temp_drop_inv_item(W)
		cell = W
		update_icon()
		user.visible_message("<span class='notice'>[user] ejects the fuell cell inside [src] and replaces it with a new one.</span>",
		"<span class='notice'>You eject the fuell cell inside [src] and replace it with a new one.</span>")
		r_TRU
	return ..()

/obj/machinery/power/geothermal/fusion/attack_hand(mob/user as mob)
	if(!anchored) //Shouldn't actually be possible
		user << "MAKE AN AHELP RIGHT AWAY, BECAUSE SHIT IS SOMEHOW FUCKED - ERROR: ALM001."
		r_FAL
	if(cell.fuel_amount <= 0)
		user << "<span class='warning'>The emergency power kicks in and a message flashes across the screen. The cell is depleted.</span>"
		r_FAL
	if(!ishuman(user) || user.stat)
		user << "<span class='warning'>You have no idea how to use that.</span>" //No ayylamos
		r_FAL
	add_fingerprint(user)
	switch(buildstate)
		if(1)
			user << "<span class='info'>Use a welding tool, then wirecutters, then a wrench to repair it.</span>"
			r_FAL
		if(2)
			user << "<span class='notice'>Use a wirecutters, then a wrench to repair it.</span>"
			r_FAL
		if(3)
			user << "<span class='notice'>Use a wrench to repair it.</span>"
			r_FAL
	if(is_on)
		visible_message("\icon[src] <span class='warning'><b>The [name]</b> beeps softly and the humming stops as [user] shuts off the generator.</span>")
		is_on = 0
		power_gen_percent = 0
		cur_tick = 0
		update_icon()
		r_TRU
	visible_message("\icon[src] <span class='warning'><b>The [name]</b> beeps loudly as [user] turns the generator on and it begins the process of fusion.</span>")
	fuel_rate = 0.01
	is_on = 1
	cur_tick = 0
	update_icon()
	r_TRU

/obj/machinery/power/geothermal/fusion/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/weldingtool))
		if(buildstate == 1 && !is_on)
			var/obj/item/weapon/weldingtool/WT = O
			if(WT.remove_fuel(0, user))
				playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
				user.visible_message("<span class='notice'>[user] starts welding the damage to [src].</span>",
				"<span class='notice'>You start welding the damage to [src].</span>")
				if(do_after(user, 200, TRUE, 5, BUSY_ICON_CLOCK))
					if(!src || !WT.isOn()) r_FAL
					buildstate = 2
					user.visible_message("<span class='notice'>[user] finishes welding the damage to [src].</span>",
					"<span class='notice'>You finish welding the damage to [src].</span>")
					update_icon()
					r_TRU
			else
				user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
				r_FAL
	if(istype(O, /obj/item/weapon/wirecutters))
		if(buildstate == 2 && !is_on)
			playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts securing the wiring on [src].</span>",
			"<span class='notice'>You start securing the wiring on [src].</span>")
			if(do_after(user, 120, TRUE, 5, BUSY_ICON_CLOCK))
				if(!src) r_FAL
				buildstate = 3
				user.visible_message("<span class='notice'>[user] finishes securing the wiring on [src].</span>",
				"<span class='notice'>You finish securing the wiring on [src].</span>")
				update_icon()
				r_TRU
	if(istype(O, /obj/item/weapon/wrench))
		if(buildstate == 3 && !is_on)
			playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
			user.visible_message("<span class='notice'>[user] starts repairing the tubes and plating on [src].</span>",
			"<span class='notice'>You start repairing the tubes and plating on [src].</span>")
			if(do_after(user, 150, TRUE, 5, BUSY_ICON_CLOCK))
				if(!src) r_FAL
				buildstate = 0
				is_on = 0
				user.visible_message("<span class='notice'>[user] finishes repairing the tubes and plating on [src].</span>",
				"<span class='notice'>You start repairing the tubes and plating on [src]. It now looks good to go, just need to flip the switch.</span>")
				update_icon()
				r_TRU
	..()

//FUEL CELL
/obj/item/weapon/fuel_cell
	name = "\improper WL-6 universal fuel cell"
	desc = "A single-use fuel cell designed to work as a power source for the Cheyenne-Class transport or for Westingland S-52 Reactors."
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "cell-full"
	var/fuel_amount = 100 //The amount of fuel inside the fuel cell

/obj/item/weapon/fuel_cell/examine(mob/user)
	..()
	switch(fuel_amount)
		if(0)
			user << "<span class='info'>The fuel cell is dead gray. No more power out of this one, it's been sucked dry by the engines.</span>"
		if(1 to 25)
			user << "<span class='info'>The fuel cell barely has any amber coloring left behind its dull, gray glass. Only worth a little more use.</span>"
		if(26 to 50)
			user << "<span class='info'>The fuel cell is still amber-colored, but the glow has dimmed. Still good for a bit, surely.</span>"
		if(51 to 75)
			user << "<span class='info'>The fuel cell is still glowing, albeit a more muted amber. It has clearly been used a bit already.</span>"
		if(76 to INFINITY)
			user << "<span class='info'>The fuel cell is glowing a healthy amber, showing it is still well charged. As good as new.</span>"

//This only needs to happen when the cell is ejected for now, so we can easily manually call this
/obj/item/weapon/fuel_cell/update_icon()
	switch(fuel_amount)
		if(0)
			icon_state = "cell-empty"
		if(1 to 25)
			icon_state = "cell-low"
		if(26 to 50)
			icon_state = "cell-medium"
		if(51 to 75)
			icon_state = "cell-high"
		if(76 to INFINITY)
			icon_state = "cell-full"
