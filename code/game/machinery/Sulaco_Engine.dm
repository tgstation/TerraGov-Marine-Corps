//Experimental engine for the new Sulaco

/obj/machinery/power/geothermal/sulaco
	name = "Sulaco Power Generator"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "geo_off"
	desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  Currently in standby mode."
	directwired = 0     //Requires a cable directly underneath
	unacidable = 1      //NOPE.jpg
	power_gen_percent = 0 //100,000W at full capacity
	power_generation_max = 100000 //Full capacity
	powernet_connection_failed = 0 //Logic checking for powernets
	buildstate = 0 //What state of building it are we on, 0-3, 1 is "broken", the default
	is_on = 0  //Is this damn thing on or what?
	fail_rate = 1 //% chance of failure each fail_tick check
	fail_check_ticks = 100 //Check for failure every this many ticks
	cur_tick = 0 //Tick updater

	//Sulaco Generator Unique Vars
	var/fusion_cell = 1 //Starts with a fuel cell loaded in.  Maybe replace with the plasma tanks in the future and have it consume plasma?  Possibly remove this later if it's irrelevent...
	var/produce_heat = 1 //Fusion is a VERY warm process.  The reactor room should probably be cooled.
	var/fuel_amount = 100.00 // Amount of Fuel in the cell.
	var/fuel_rate = 0.00
	var/verbalupdate= 0


/obj/machinery/power/geothermal/sulaco/process()
	if(!is_on || buildstate || !anchored) //Default logic checking
		return 0

	//FOR NOW, INFINITE FUEL
	if (fuel_amount < 10)
		fuel_amount = 100

	if(!powernet && !powernet_connection_failed) //Powernet checking, make sure there's valid cables & powernets
		if(!connect_to_network())
			powernet_connection_failed = 1 //God damn it, where'd our network go
			is_on = 0
			spawn(150) // Error! Check again in 15 seconds. Someone could have blown/acided or snipped a cable
				powernet_connection_failed = 0

	else if(powernet) //All good! Let's fire it up!
		if(!check_failure()) //Wait! Check to see if it breaks during processing
			update_icon()
			if(power_gen_percent < 100)
				power_gen_percent++
				fuel_rate = 0.001
			if(power_gen_percent == 10)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> begins to whirr as it powers up.")
				fuel_rate = 0.0025
			if(power_gen_percent == 50)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> begins to hum loudly as it reaches half capacity")
				fuel_rate = 0.005
			if(power_gen_percent == 99)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.")
				fuel_rate = 0.01
			add_avail(power_generation_max * (power_gen_percent / 100) ) //Nope, all good, just add the power
			fuel_amount-=fuel_rate //Removes some fuel from the canister

	if(is_on && powernet && !verbalupdate) //This can probably be changed in the future.  For now, when a fuel cell is ejected, it'll be "useless" no matter how much fuel remains.
		if (fuel_amount > 75)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is mostly full")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  The fuel cell is nearly full."
		if (fuel_amount <= 75 && fuel_amount > 50)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is 75% full")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  The fuel cell is a little above halfway."
		if (fuel_amount <= 50 && fuel_amount > 25)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell at half")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  The fuel cell is a little under halfway."
		if (fuel_amount <= 25 && fuel_amount > 10)
			src.visible_message("\icon[src] <b>[src]</b> displays that it's fuel cell is below half")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  <red>The fuel cell is running low.</red>"
		if (fuel_amount <= 10 && fuel_amount > 0)
			src.visible_message("\icon[src] <b>[src]</b> displasy that the fuel cell is critically low and needs to be replaced")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  <red>The Fuel cell is critically low.</red>"
		if (fuel_amount == 0)
			src.visible_message("\icon[src] <b>[src]</b> flashes that the fuel cell is empty as the engie seizes.")
			desc = "A Westingland S-52 Fusion Reactor.  Takes fuels cells and converts them to power for the ship.  Also produces a large amount of heat.  <red>The reactor ran out of fuel and seized up"
			fuel_rate = 0
			buildstate = 0
			is_on = 0
			fail_rate++ //Each time the engine is allowed to seize up it's fail rate for the future increases
		verbalupdate = 1
		spawn(600)
			verbalupdate = 0




