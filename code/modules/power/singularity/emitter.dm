#define EMITTER_DAMAGE_POWER_TRANSFER 450 //used to transfer power to containment field generators

/obj/machinery/power/emitter
	name = "Emitter"
	desc = "It is a heavy duty industrial laser."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter"
	anchored = 0
	density = TRUE
	req_access = list(ACCESS_MARINE_ENGINEERING)
	var/id = null
	use_power = 0	//uses powernet power, not APC power