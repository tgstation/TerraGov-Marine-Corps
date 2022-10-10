/obj/machinery/atmospherics/components/unary/thermomachine
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "freezer"

	name = "thermomachine"
	desc = "Heats or cools gas in connected pipes."

	density = TRUE
	max_integrity = 300
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, "rad" = 100, FIRE = 80, ACID = 30)
	layer = OBJ_LAYER

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/icon_state_off = "freezer"
	var/icon_state_on = "freezer_1"
	var/icon_state_open = "freezer-o"

	var/min_temperature = 0
	var/max_temperature = 0
	var/target_temperature = T20C
	var/heat_capacity = 0
	var/interactive = TRUE // So mapmakers can disable interaction.

/obj/machinery/atmospherics/components/unary/thermomachine/New()
	. = ..()
	initialize_directions = dir

/obj/machinery/atmospherics/components/unary/thermomachine/on_construction()
	..(dir,dir)

/obj/machinery/atmospherics/components/unary/thermomachine/RefreshParts()
	var/B
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		B += M.rating
	heat_capacity = 5000 * ((B - 1) ** 2)

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon()
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		icon_state = icon_state_open
	else if(on && is_operational())
		icon_state = icon_state_on
	else
		icon_state = icon_state_off

/obj/machinery/atmospherics/components/unary/thermomachine/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		add_overlay(getpipeimage(icon, "scrub_cap", initialize_directions))

/obj/machinery/atmospherics/components/unary/thermomachine/freezer
	name = "freezer"
	icon_state = "freezer"
	icon_state_off = "freezer"
	icon_state_on = "freezer_1"
	icon_state_open = "freezer-o"
	max_temperature = T20C
	min_temperature = 170 //actual minimum temperature is defined by RefreshParts()

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on
	on = TRUE
	icon_state = "freezer_1"

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/New()
	. = ..()
	if(target_temperature == initial(target_temperature))
		target_temperature = min_temperature

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom
	name = "cold room freezer"

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/on/coldroom/New()
	. = ..()
	target_temperature = T0C-80

/obj/machinery/atmospherics/components/unary/thermomachine/freezer/RefreshParts()
	..()
	var/L
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	min_temperature = max(T0C - (initial(min_temperature) + L * 15), TCMB) //73.15K with T1 stock parts

/obj/machinery/atmospherics/components/unary/thermomachine/heater
	name = "heater"
	icon_state = "heater"
	icon_state_off = "heater"
	icon_state_on = "heater_1"
	icon_state_open = "heater-o"
	max_temperature = 140 //actual maximum temperature is defined by RefreshParts()
	min_temperature = T20C

/obj/machinery/atmospherics/components/unary/thermomachine/heater/on
	on = TRUE
	icon_state = "heater_1"

/obj/machinery/atmospherics/components/unary/thermomachine/heater/RefreshParts()
	..()
	var/L
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		L += M.rating
	max_temperature = T20C + (initial(max_temperature) * L) //573.15K with T1 stock parts
