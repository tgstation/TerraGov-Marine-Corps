//Refer to life.dm for caller

/mob/living/carbon/human/handle_fire()
	. = ..()
	if(.)
		return
	var/thermal_protection = get_heat_protection_flags(30000) //If you don't have fire suit level protection, you get a temperature increase and burns
	if((1 - thermal_protection) > 0.0001)
		adjust_bodytemperature(BODYTEMP_HEATING_MAX)
		apply_damage(10, BURN, blocked = FIRE)
	species?.handle_fire(src)
