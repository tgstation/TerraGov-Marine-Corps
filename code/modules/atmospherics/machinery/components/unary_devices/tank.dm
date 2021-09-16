#define AIR_CONTENTS ((25*ONE_ATMOSPHERE)*(air_contents.volume)/(R_IDEAL_GAS_EQUATION*air_contents.temperature))
/obj/machinery/atmospherics/components/unary/tank
	icon = 'icons/obj/atmospherics/pipes/pressure_tank.dmi'
	icon_state = "generic"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPING_ONE_PER_TURF

	var/volume = 10000 //in liters
	var/gas_type = 0

/obj/machinery/atmospherics/components/unary/tank/New()
	. = ..()
	setPipingLayer(piping_layer)


/obj/machinery/atmospherics/components/unary/tank/air
	icon_state = "grey"
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/unary/tank/toxins
	icon_state = "orange"

/obj/machinery/atmospherics/components/unary/tank/oxygen
	icon_state = "blue"

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	icon_state = "red"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
