//Refer to life.dm for caller

/mob/living/carbon/human/handle_fire()
	if(..())
		return
	var/thermal_protection = get_flags_heat_protection(30000) //If you don't have fire suit level protection, you get a temperature increase and burns
	if((1 - thermal_protection) > 0.0001)
		bodytemperature += BODYTEMP_HEATING_MAX
		adjustFireLoss(5)
