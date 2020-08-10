
GLOBAL_LIST_EMPTY(landing_lights)
// DS lights
/obj/machinery/landinglight
	name = "landing light"
	icon = 'icons/obj/landinglights.dmi'
	icon_state = "landingstripetop"
	desc = "A landing light, if it's flashing stay clear!"
	var/id = "" // ID for landing zone
	anchored = TRUE
	density = FALSE
	layer = BELOW_TABLE_LAYER
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = AREA_USAGE_LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE

/obj/machinery/landinglight/Initialize()
	. = ..()
	if(id == "")
		stack_trace("Invalid ID set on /obj/machinery/landinglight at x:[x] y:[y] z:[z]")
		return INITIALIZE_HINT_QDEL

	turn_off()
	GLOB.landing_lights += src

/obj/machinery/landinglight/Destroy()
	GLOB.landing_lights -= src
	return ..()

/obj/machinery/landinglight/proc/turn_off()
	icon_state = "landingstripe"
	set_light(0)

/obj/machinery/landinglight/proc/turn_on()
	icon_state = "landingstripe0"
	set_light(2)

/obj/machinery/landinglight/delayone/turn_on()
	icon_state = "landingstripe1"
	set_light(2)

/obj/machinery/landinglight/delaytwo/turn_on()
	icon_state = "landingstripe2"
	set_light(2)

/obj/machinery/landinglight/delaythree/turn_on()
	icon_state = "landingstripe3"
	set_light(2)

/obj/machinery/landinglight/delayzero/ds1
	id = "alamo" // ID for landing zone
/obj/machinery/landinglight/delayone/ds1
	id = "alamo" // ID for landing zone
/obj/machinery/landinglight/delaytwo/ds1
	id = "alamo" // ID for landing zone
/obj/machinery/landinglight/delaythree/ds1
	id = "alamo" // ID for landing zone

/obj/machinery/landinglight/delayzero/ds2
	id = "normandy" // ID for landing zone
/obj/machinery/landinglight/delayone/ds2
	id = "normandy" // ID for landing zone
/obj/machinery/landinglight/delaytwo/ds2
	id = "normandy" // ID for landing zone
/obj/machinery/landinglight/delaythree/ds2
	id = "normandy" // ID for landing zone



/proc/get_landing_lights(shuttle, zlevel)
	. = list()
	for(var/i in GLOB.landing_lights)
		var/obj/machinery/landinglight/light = i
		if(light.id == shuttle && light.z == zlevel)
			. += light
