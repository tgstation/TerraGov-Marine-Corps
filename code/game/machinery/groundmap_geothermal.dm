/obj/machinery/power/geothermal
	name = "geothermal power generator"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "geo_broken"
	desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a welding tool, wrench, then wirecutters to repair it."
	anchored = 1
	density = 1
	directwired = 0     //Requires a cable directly underneath
	unacidable = 1      //NOPE.jpg
	var/power_gen_percent = 0 //100,000W at full capacity
	var/power_generation_max = 100000 //Full capacity
	var/powernet_connection_failed = 0 //Logic checking for powernets
	var/buildstate = 1 //What state of building it are we on, 0-3, 1 is "broken", the default
	var/is_on = 0  //Is this damn thing on or what?
	var/fail_rate = 10 //% chance of failure each fail_tick check
	var/fail_check_ticks = 100 //Check for failure every this many ticks
	var/cur_tick = 0 //Tick updater

//We don't want to cut/update the power overlays every single proc. Just when it actually changes. This should save on CPU cycles. Efficiency!
/obj/machinery/power/geothermal/update_icon()
	..()
	if(!buildstate && is_on)
		icon_state = "geo_working"
		desc = "A thermoelectric generator sitting atop a borehole dug deep in the planet's surface. It generates energy by boiling the plasma steam that rises from the well.\nIt is old technology and has a large failure rate, and must be repaired frequently.\nIt is currently on, and beeping randomly amid faint hisses of steam."
		var/image/over = image('icons/turf/ground_map.dmi', src, "turbine0")
		var/changed = 0
		if(power_gen_percent == 5)
			over.icon_state = "turbine0"
			changed = 1
		else if (power_gen_percent == 20)
			over.icon_state = "turbine1"
			changed = 1
		else if (power_gen_percent == 40)
			over.icon_state = "turbine2"
			changed = 1
		else if (power_gen_percent == 60)
			over.icon_state = "turbine3"
			changed = 1
		else if (power_gen_percent == 75)
			over.icon_state = "turbine4"
			changed = 1
		else if (power_gen_percent == 90)
			over.icon_state = "turbine5"
			changed = 1
		else if (power_gen_percent == 99) //99 better than 100, since it could stay at 100 for a long time but not 99
			over.icon_state = "turbine6"
			changed = 1

		if(changed)
			overlays.Cut()
			overlays += over

	else if (!buildstate && !is_on)
		overlays.Cut()
		icon_state = "geo_off"
		desc = "A thermoelectric generator sitting atop a borehole dug deep in the planet's surface. It generates energy by boiling the plasma steam that rises from the well.\nIt is old technology and has a large failure rate, and must be repaired frequently.\nIt is currently turned off and silent."
	else
		overlays.Cut()
		if(buildstate == 1)
			icon_state = "geo_broken"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is heavily damaged. Use a welding tool, wirecutters, then wrench to repair it."
		else if(buildstate == 2)
			icon_state = "geo_broken2"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is damaged. Use a wirecutters, then wrench to repair it."
		else
			icon_state = "geo_broken3"
			desc = "A thermoelectric generator sitting atop a plasma-filled borehole. This one is lightly damaged. Use a wrench to repair it."

/obj/machinery/power/geothermal/New()
	..()
	if(!connect_to_network()) //Should start with a cable piece underneath, if it doesn't, something's messed up in mapping
		powernet_connection_failed = 1

/obj/machinery/power/geothermal/process()
	if(!is_on || buildstate || !anchored) //Default logic checking
		return 0

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
			if(power_gen_percent == 10)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> begins to whirr as it powers up.")
			if(power_gen_percent == 50)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> hums as the internal dynamos reach half speed.")
			if(power_gen_percent == 99)//Flavor text!
				src.visible_message("\icon[src] <b>[src]</b> rumbles loudly as the combustion and thermal chambers reach full strength.")
			add_avail(power_generation_max * (power_gen_percent / 100) ) //Nope, all good, just add the power

/obj/machinery/power/geothermal/proc/check_failure()
	cur_tick++
	if(cur_tick < fail_check_ticks) //Nope, not time for it yet
		return 0
	else if(cur_tick > fail_check_ticks) //Went past with no fail, reset the timer
		cur_tick = 0
		return 0
	if(rand(1,100) < fail_rate) //Oh snap, we failed! Shut it down!
		if(rand(0,3) == 0)
			src.visible_message("\icon[src] \red <b>[src]</b> beeps wildly and a fuse blows! Use wirecutters, then a wrench to repair it.")
			buildstate = 2
		else
			src.visible_message("\icon[src] \red <b>[src]</b> beeps wildly and sprays random pieces everywhere! Use a wrench to repair it.")
			buildstate = 3
		is_on = 0
		power_gen_percent = 0
		update_icon()
		cur_tick = 0
		return 1
	return 0 //Nope, all fine

/obj/machinery/power/geothermal/attack_hand(mob/user as mob)
	if(!anchored) return 0 //Shouldn't actually be possible
	if(!ishuman(user) || user.stat) //I see dead or unconscious people!
		user << "\red You have no idea how to use that." //No xenos or mankeys
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
		src.visible_message("\icon[src] \red <b>[src]</b> beeps softly and the humming stops as [usr] shuts off the turbines.")
		is_on = 0
		power_gen_percent = 0
		cur_tick = 0
		update_icon()
		return 1
	src.visible_message("\icon[src] \red <b>[src]</b> beeps loudly as [usr] turns on the turbines and the generator begins spinning up.")
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
				update_icon()
				return
	..() //Deal with everything else, like hitting with stuff
	return

//Putting these here since it's power-related

/obj/machinery/colony_floodlight_switch
	name = "Colony Floodlight Switch"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "panelnopower"
	desc = "This switch controls the floodlights surrounding the archaeology complex. It only functions when there is power."
	density = 0
	anchored = 1
	var/ispowered = 0
	var/turned_on = 0 //has to be toggled in engineering
	use_power = 1
	unacidable = 1
	var/list/floodlist = list() // This will save our list of floodlights on the map

/obj/machinery/colony_floodlight_switch/New() //Populate our list of floodlights so we don't need to scan for them ever again
	sleep(5) //let's make sure it exists first..
	for(var/obj/machinery/colony_floodlight/F in world)
		floodlist += F
		F.fswitch = src
	..()

/obj/machinery/colony_floodlight/Del()
	SetLuminosity(0)
	..()

/obj/machinery/colony_floodlight_switch/update_icon()
	if(!ispowered)
		icon_state = "panelnopower"
	else if(turned_on)
		icon_state = "panelon"
	else
		icon_state = "paneloff"

/obj/machinery/colony_floodlight_switch/power_change()
	..()
	if((stat & NOPOWER))
		if(ispowered && turned_on)
			toggle_lights()
		ispowered = 0
		turned_on = 0
		update_icon()
	else
		ispowered = 1
		update_icon()

/obj/machinery/colony_floodlight_switch/proc/toggle_lights()
	for(var/obj/machinery/colony_floodlight/F in floodlist)
		if(!istype(F) || isnull(F) || F.damaged) continue //Missing or damaged, skip it

		spawn(rand(0,50))
			if(F.is_lit) //Shut it down
				F.SetLuminosity(0)
			else
				F.SetLuminosity(F.lum_value)
			F.is_lit = !(F.is_lit)
			F.update_icon()
	return 0

/obj/machinery/colony_floodlight_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/colony_floodlight_switch/attack_hand(mob/user as mob)
	if(!ishuman(user))
		user << "Nice try."
		return 0
	if(!ispowered)
		user << "Nothing happens."
		return 0
	playsound(src,'sound/machines/click.ogg', 50, 1)
	use_power(5)
	toggle_lights()
	turned_on = !(src.turned_on)
	update_icon()
	return 1

/obj/machinery/colony_floodlight
	name = "Colony Floodlight"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "floodoff"
	density = 1
	anchored = 1
	var/damaged = 0 //Can be smashed by xenos
	var/is_lit = 0
	unacidable = 1
	var/power_tick = 800 // power each floodlight takes up per process
	use_power = 0 //It's the switch that uses the actual power, not the lights
	var/obj/machinery/colony_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area
	var/lum_value = 7

/obj/machinery/colony_floodlight/update_icon()
	if(damaged)
		icon_state = "flooddmg"
	else if(is_lit)
		icon_state = "floodon"
	else
		icon_state = "floodoff"

/obj/machinery/colony_floodlight/process()
	if(isnull(fswitch) || damaged ||!is_lit) return 0 //The heck, where's the switch?!
	if(!fswitch.ispowered || !fswitch.turned_on) return 0
	fswitch.use_power(power_tick) //Make the switch use up the power, not the floodlight, since they don't have areas

/obj/machinery/colony_floodlight/attackby(obj/item/weapon/W as obj, mob/user as mob)
	var/obj/item/weapon/weldingtool/WT = W
	if(istype(WT))
		if(!damaged) return
		if(WT.remove_fuel(0, user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
			user.visible_message("[user.name] starts to weld the damage to [src.name].","You start to weld the damage to [src.name].")
			if (do_after(user,200))
				if(!src || !WT.isOn()) return
				damaged = 0
				user << "You finish welding."
				if(is_lit)
					SetLuminosity(lum_value)
				update_icon()
				return 1
		else
			user << "\red You need more welding fuel to complete this task."
			return 0
	..()
	return 0

/obj/machinery/colony_floodlight/attack_hand(mob/user as mob)
	if(ishuman(user))
		user << "Nothing happens. Looks like it's powered elsewhere."
		return 0
	else if(!is_lit)
		user << "Why bother? It's just some weird metal thing."
		return 0
	else
		if(damaged)
			user << "It's already damaged."
			return 0
		else
			if(isXenoLarva(user))
				user.visible_message("[user.name] starts biting the [src.name]!","In a rage, you start biting the bright light, but with no effect!")
				return //Larvae can't do shit
			user.visible_message("[user.name] starts to slash away at [src.name]!","In a rage, you start to slash and claw at the bright light!")
			if(do_after(user,50))
				if(!src) return 0
				damaged = 1
				SetLuminosity(0)
				user << "You slash up the light! Raar!"
				playsound(src, 'sound/weapons/blade1.ogg', 50, 1)
				update_icon()
				return 0
	..()
	return