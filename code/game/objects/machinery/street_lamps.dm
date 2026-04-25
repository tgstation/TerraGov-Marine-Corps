// Streetlights
/obj/machinery/streetlight/street
	name = "Colony Streetlight"
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "street_off"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 220
	density = FALSE

/obj/machinery/streetlight/street/update_icon_state()
	var/area/street_light_area = get_area(src)
	if(obj_integrity != initial(max_integrity))
		icon_state = "street_dmg"
		set_light(0)
	else if(street_light_area.power_light)
		icon_state = "street_on"
		set_light(5, 5, COLOR_WHITE)
	else
		icon_state = "street_off"
		set_light(0)

// Traffic

/obj/machinery/streetlight/traffic
	name = "traffic light"
	desc = "A traffic light"
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "trafficlight"
	bound_width = 32
	bound_height = 32
	density = FALSE
	max_integrity = 200
	layer = MOB_BELOW_PIGGYBACK_LAYER
	resistance_flags = XENO_DAMAGEABLE

/obj/machinery/streetlight/traffic/update_icon_state()
	var/area/traffic_light_area = get_area(src)
	if(obj_integrity != initial(max_integrity))
		icon_state = "trafficlight_damaged"
		set_light(0)
	else if(traffic_light_area.power_light)
		icon_state = "trafficlight_on"
		set_light(2, 5, COLOR_WHITE)
	else
		icon_state = "trafficlight"
		set_light(0)

/obj/machinery/streetlight/traffic_alt
	name = "traffic light"
	desc = "A traffic light"
	icon = 'icons/obj/structures/prop/urban/64x64_urbanrandomprops.dmi'
	icon_state = "trafficlight_alt"
	bound_width = 32
	bound_height = 32
	density = FALSE
	max_integrity = 200
	layer = ABOVE_MOB_LAYER
	resistance_flags = XENO_DAMAGEABLE

/obj/machinery/streetlight/traffic_alt/update_icon_state()
	if(obj_integrity != initial(max_integrity))
		icon_state = "trafficlight_alt_damaged"
		set_light(0)
	else if(light_on)
		icon_state = "trafficlight_alt_on"
		set_light(7, 5, COLOR_WHITE)
	else
		icon_state = "trafficlight_alt"
		set_light(0)

/obj/machinery/streetlight/engineer_circular
	name = "circular light"
	icon_state = "engineerlight_off"
	desc = "A huge circular light"
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	density = FALSE
	resistance_flags = RESIST_ALL
	wrenchable = FALSE
	layer = HIGH_TURF_LAYER
	light_color =  "#00ffa0"
	light_power = 6

/obj/machinery/streetlight/engineer_circular/update_icon_state()
	var/area/engineer_circular_area = get_area(src)
	if(obj_integrity != initial(max_integrity))
		icon_state = "engineerlight_off"
		set_light(0)
	else if(engineer_circular_area.power_light)
		icon_state = "engineerlight_on"
		set_light(7, 5, COLOR_WHITE)
	else
		icon_state = "engineerlight_off"
		set_light(0)

/obj/machinery/streetlight/Destroy()
	. = ..()
	set_light(0)
