/obj/machinery/hydro_floodlight_switch
	name = "Biodome Floodlight Switch"
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

/obj/machinery/hydro_floodlight_switch/New() //Populate our list of floodlights so we don't need to scan for them ever again
	sleep(5) //let's make sure it exists first..
	for(var/obj/machinery/hydro_floodlight/F in machines)
		floodlist += F
		F.fswitch = src
	..()
	start_processing()

/obj/machinery/hydro_floodlight_switch/process()
	var/lightpower = 0
	for(var/obj/machinery/hydro_floodlight/H in floodlist)
		if(!H.is_lit)
			continue
		lightpower += H.power_tick
	use_power(lightpower)

/obj/machinery/hydro_floodlight_switch/update_icon()
	if(!ispowered)
		icon_state = "panelnopower"
	else if(turned_on)
		icon_state = "panelon"
	else
		icon_state = "paneloff"

/obj/machinery/hydro_floodlight_switch/power_change()
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

/obj/machinery/hydro_floodlight_switch/proc/toggle_lights()
	for(var/obj/machinery/hydro_floodlight/F in floodlist)
		if(!istype(F) || isnull(F) || F.damaged) continue //Missing or damaged, skip it

		spawn(rand(0,50))
			if(F.is_lit) //Shut it down
				F.SetLuminosity(0)
			else
				F.SetLuminosity(F.lum_value)
			F.is_lit = !(F.is_lit)
			F.update_icon()
	return 0

/obj/machinery/hydro_floodlight_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/hydro_floodlight_switch/attack_hand(mob/user as mob)
	if(!ishuman(user))
		to_chat(user, "Nice try.")
		return 0
	if(!ispowered)
		to_chat(user, "Nothing happens.")
		return 0
	playsound(src,'sound/machines/click.ogg', 15, 1)
	use_power(5)
	toggle_lights()
	turned_on = !(src.turned_on)
	update_icon()
	return 1

/obj/machinery/hydro_floodlight
	name = "Biodome Floodlight"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "floodoff"
	density = 1
	anchored = 1
	var/damaged = 0 //Can be smashed by xenos
	var/is_lit = 0
	unacidable = 1
	var/power_tick = 800 // power each floodlight takes up per process
	use_power = 0 //It's the switch that uses the actual power, not the lights
	var/obj/machinery/hydro_floodlight_switch/fswitch = null //Reverse lookup for power grabbing in area
	var/lum_value = 7

	Dispose()
		SetLuminosity(0)
		. = ..()

/obj/machinery/hydro_floodlight/update_icon()
	if(damaged)
		icon_state = "flooddmg"
	else if(is_lit)
		icon_state = "floodon"
	else
		icon_state = "floodoff"

/obj/machinery/hydro_floodlight/attackby(obj/item/W as obj, mob/user as mob)
	var/obj/item/tool/weldingtool/WT = W
	if(istype(WT))
		if(!damaged) return
		if(WT.remove_fuel(0, user))
			playsound(src.loc, 'sound/items/weldingtool_weld.ogg', 25)
			user.visible_message("[user] starts welding [src]'s damage.</span>",
			"You start welding [src]'s damage.</span>")
			if(do_after(user, 200, TRUE, 5, BUSY_ICON_BUILD))
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 25, 1)
				if(!src || !WT.isOn()) return
				damaged = 0
				user.visible_message("[user] finishes welding [src]'s damage.</span>",
				"You finish welding [src]'s damage.</span>")
				if(is_lit)
					SetLuminosity(lum_value)
				update_icon()
				return 1
		else
			to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			return 0
	..()
	return 0

/obj/machinery/hydro_floodlight/attack_hand(mob/user as mob)
	if(ishuman(user))
		to_chat(user, "<span class='warning'>Nothing happens. Looks like it's powered elsewhere.</span>")
		return 0
	else if(!is_lit)
		to_chat(user, "<span class='warning'>Why bother? It's just some weird metal thing.</span>")
		return 0
	else
		if(damaged)
			to_chat(user, "<span class='warning'>It's already damaged.</span>")
			return 0
		else
			if(isXenoLarva(user))
				return //Larvae can't do shit
			if(user.get_active_hand())
				to_chat(user, "<span class='warning'>You need your claws empty for this!</span>")
				return FALSE
			user.visible_message("<span class='danger'>[user] starts to slash and claw away at [src]!</span>",
			"<span class='danger'>You start slashing and clawing at [src]!</span>")
			if(do_after(user, 50, TRUE, 5, BUSY_ICON_HOSTILE) && !damaged) //Not when it's already damaged.
				if(!src) return 0
				damaged = 1
				SetLuminosity(0)
				user.visible_message("<span class='danger'>[user] slashes up [src]!</span>",
				"<span class='danger'>You slash up [src]!</span>")
				playsound(src, 'sound/weapons/blade1.ogg', 25, 1)
				update_icon()
				return 0
	..()
