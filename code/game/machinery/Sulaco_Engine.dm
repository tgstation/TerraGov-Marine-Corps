//Experimental engine for the Almayer.  Should be fancier.  I expect I'll eventually make it totally seperate from the Geothermal as I don't like the procs... - Apop


/obj/machinery/power/geothermal/sulaco
	name = "/improper S-52 Fusion Reactor"
	icon = 'icons/Marine/almayer_eng.dmi'
	icon_state = "off-100"
	desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  Currently in standby mode."
	almayer = 1 //Yup, it's on the Almayer.
	directwired = 0     //Requires a cable directly underneath
	unacidable = 1      //NOPE.jpg
	power_gen_percent = 0 //100,000W at full capacity
	power_generation_max = 100000 //Full capacity
	powernet_connection_failed = 0 //Logic checking for powernets
	buildstate = 0 //What state of building it are we on, 0-3, 1 is "broken", the default
	is_on = 0  //Is this damn thing on or what?
	fail_rate = 5 //% chance of failure each fail_tick check
	fail_check_ticks = 100 //Check for failure every this many ticks
	cur_tick = 0 //Tick updater

	//Sulaco Generator Unique Vars
	var/fusion_cell = 1 //Starts with a fuel cell loaded in.  Maybe replace with the plasma tanks in the future and have it consume plasma?  Possibly remove this later if it's irrelevent...
	var/produce_heat = 1 //Fusion is a VERY warm process.  The reactor room should probably be cooled... Probably...
	var/fuel_amount = 100.00 // Amount of Fuel in the cell.
	var/fuel_rate = 0.00 //Rate at which fuel is used.  Based mostly on how long the generator has been running.
	var/verbalupdate= 0 //For the verbal announcer so it doesn't shit all over the place constantly.
	var/icon_track = 100 //This is to track the amount of fuel so it selects the proper icon.


/obj/machinery/power/geothermal/sulaco/process()
	if(!is_on || buildstate || !anchored) //Default logic checking
		return 0


	if(!powernet && !powernet_connection_failed) //Powernet checking, make sure there's valid cables & powernets
		if(!connect_to_network())
			powernet_connection_failed = 1
			is_on = 0
			spawn(150) // Error! Check again in 15 seconds. Someone could have blown/acided or snipped a cable
				powernet_connection_failed = 0

	else if(powernet) //All good! Let's fire it up!
		if(!check_failure()) //THIS STILL NEEDS A SMIDGE OF WORK, AND PROBABLY IT'S OWN PROC SINCE I'M GHETTOING UP THE REGULAR ONE...
			update_icon()
			if(power_gen_percent < 100)
				power_gen_percent++
				fuel_rate = 0.01
			if(power_gen_percent == 10)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> begins to whirr as it powers up.")
				fuel_rate = 0.025
			if(power_gen_percent == 50)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> begins to hum loudly as it reaches half capacity")
				fuel_rate = 0.05
			if(power_gen_percent == 99)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.")
				fuel_rate = 0.1
			add_avail(power_generation_max * (power_gen_percent / 100) ) //Nope, all good, just add the power
			fuel_amount-=fuel_rate //Consumes fuel

	if(is_on && powernet && !verbalupdate) //This can probably be changed in the future.  For now, when a fuel cell is ejected, it'll be "useless" no matter how much fuel remains.
		if (fuel_amount > 75)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is mostly full")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  The fuel cell is nearly full."
			icon_track = 100
		if (fuel_amount <= 75 && fuel_amount > 50)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is 75% full")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  The fuel cell is a little above halfway."
			icon_track = 75
		if (fuel_amount <= 50 && fuel_amount > 25)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell at half")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  The fuel cell is a little under halfway."
			icon_track = 50
		if (fuel_amount <= 25 && fuel_amount > 10)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is below half")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  <red>The fuel cell is running low.</red>"
			icon_track = 25
		if (fuel_amount <= 10 && fuel_amount > 0)
			src.visible_message("\icon[src] <b>[src]</b> displasy that the fuel cell is critically low and needs to be replaced")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  <red>The Fuel cell is critically low.</red>"
			icon_track = 10
		if (fuel_amount == 0)
			src.visible_message("\icon[src] <b>[src]</b> flashes that the fuel cell is empty as the engine seizes.")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  <red>The reactor ran out of fuel and seized up"
			fuel_rate = 0
			buildstate = 0  //No fuel really fucks it.
			is_on = 0
			icon_track = 0
			fail_rate++ //Each time the engine is allowed to seize up it's fail rate for the future increases because reasons.
			icon = "weld"
			return 0
		icon_state = "on-[icon_track]" //Makes sure it gets the proper icon
		update_icon() //Gonna either make a new one of these with blackjack and hooker or just ignore it 5ever.
		verbalupdate = 1
		spawn(600)
			verbalupdate = 0


/obj/machinery/power/geothermal/sulaco/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/fuelCell))
		if(src.is_on)
			user << "\red The [src] needs to be turned off first..."
			return 1
		if(src.fuel_amount>50)
			user << "\red The current cell is more than half full."
			return 1
		del(W) //FUEL CELL IS CURRENTLY CONSUMED.  Maybe eventually dump one out.
		src.fuel_amount = 100
		src.icon_track = 100
		user << "\green The empty cell is ejected into space and a fresh one takes it's place."  //Temporarily just throw away used fuel cells, maybe eventually "pop" them out for use?
		return 1
	return ..()



//FUEL CELL
/obj/item/weapon/fuelCell
	name = "/improper WL-6 Universal Fuel Cell"
	icon = 'icons/Marine/shuttle-parts.dmi'
	icon_state = "cell-full"
	desc = "A single-use fuel cell designed to work as a power source for the Cheyenne-Class transport or for Westingland S-52 Reactors."



/obj/machinery/power/geothermal/sulaco/attack_hand(mob/user as mob)
	if(!anchored) //Shouldn't actually be possible
		usr << "MAKE AN AHELP RIGHT AWAY, BECAUSE SHIT IS SOMEHOW FUCKED - ERROR: ALM001."
		return 0
	if(!ishuman(user) || user.stat)
		user << "\red You have no idea how to use that." //No ayylamos
		return 0
	add_fingerprint(user)
	if(buildstate == 1)
		usr << "Use a welding tool, then wirecutters, then wrench to repair it."
		return 0
	else if (buildstate == 2)
		usr << "Use a wirecutters, then wrench to repair it."
		return 0
	else if (buildstate == 3)
		usr << "Use a wrench to repair it."
		return 0
	if(is_on)
		src.visible_message("\icon[src] \red <b>[src]</b> beeps softly and the humming stops as [usr] shuts off the generator.")
		icon = "off-[icon_track]"
		is_on = 0
		power_gen_percent = 0
		cur_tick = 0
		update_icon()
		return 1
	src.visible_message("\icon[src] \red <b>[src]</b> beeps loudly as [usr] turns the generator on and beings the process of fusion...")
	is_on = 1
	cur_tick = 0
	update_icon()
	return 1



/obj/machinery/power/geothermal/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/weldingtool))
		if(buildstate == 1 && !is_on)
			var/obj/item/weapon/weldingtool/WT = O
			if(WT.remove_fuel(0, user))
				playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("[user.name] starts to weld the damage to [src.name].","You start to weld the damage to [src.name]. Stand still!")
				if (do_after(user,200))
					if(!src || !WT.isOn()) return
					buildstate = 2
					user << "You finish welding."
					icon_state = "wire"
					update_icon()
					return
			else
				user << "\red You need more welding fuel to complete this task."
				return
	if(istype(O,/obj/item/weapon/wirecutters))
		if(buildstate == 2 && !is_on)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
			user.visible_message("[user.name] starts to secure the wiring on [src.name].","You start to secure the wiring. Stand still!")
			if(do_after(user,120))
				if(!src) return
				buildstate = 3
				user << "You finish securing the wires."
				icon_state = "wrench"
				update_icon()
				return
	if(istype(O,/obj/item/weapon/wrench))
		if(buildstate == 3 && !is_on)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
			user.visible_message("[user.name] starts to repair the tubes and plating on [src.name].","You start to repair the plating. Stand still!")
			if(do_after(user,150))
				if(!src) return
				buildstate = 0
				is_on = 0
				user << "You finish repairing the plating. The generator looks good to go! Press it to turn it on."
				icon_state = "off"
				update_icon()
				return
	..()
	return
