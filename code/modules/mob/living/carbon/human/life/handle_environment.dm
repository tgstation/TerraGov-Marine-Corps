//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_environment()
	if(!loc)
		return

	//Moved pressure calculations here for use in skip-processing check.
	var/pressure = loc.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)
	var/loc_temp = loc.return_temperature()

	if(!isspaceturf(get_turf(src))) //Space is not meant to change your body temperature.

		if(adjusted_pressure < species.warning_high_pressure && adjusted_pressure > species.warning_low_pressure && abs(loc_temp - bodytemperature) < 20 && bodytemperature < species.heat_level_1 && bodytemperature > species.cold_level_1)
			clear_alert(ALERT_PRESSURE)
			clear_alert(ALERT_TEMPERATURE)
			return //Temperatures are within normal ranges, fuck all this processing. ~Ccomp

		//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection
		var/temp_adj = 0
		if(loc_temp < bodytemperature) //Place is colder than we are
			var/thermal_protection = get_cold_protection_flags(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				temp_adj = (1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR) //This will be negative

		else if (loc_temp > bodytemperature) //Place is hotter than we are
			var/thermal_protection = get_heat_protection_flags(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				temp_adj = (1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

		adjust_bodytemperature(temp_adj, BODYTEMP_COOLING_MAX, BODYTEMP_HEATING_MAX)

	//+/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > species.heat_level_1)
		//Body temperature is too hot.
		var/heat_severity
		if(bodytemperature > species.heat_level_1)
			heat_severity = 1
		if(bodytemperature > species.heat_level_2)
			heat_severity = 2
		if(bodytemperature > species.heat_level_3)
			heat_severity = 3
		throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/hot, heat_severity)
		if(status_flags & GODMODE)
			return 1 //Godmode

		if(bodytemperature > species.heat_level_3)
			take_overall_damage(HEAT_DAMAGE_LEVEL_3, BURN)
		else if(bodytemperature > species.heat_level_2)
			take_overall_damage(HEAT_DAMAGE_LEVEL_2, BURN)
		else if(bodytemperature > species.heat_level_1)
			take_overall_damage(HEAT_DAMAGE_LEVEL_1, BURN)
	else if(bodytemperature < species.cold_level_1)
		//Body temperature is too cold.
		var/cold_severity
		if(bodytemperature < species.cold_level_1)
			cold_severity = 1
		if(bodytemperature < species.cold_level_2)
			cold_severity = 2
		if(bodytemperature < species.cold_level_3)
			cold_severity = 3
		throw_alert(ALERT_TEMPERATURE, /atom/movable/screen/alert/cold, cold_severity)

		if(status_flags & GODMODE)
			return 1 //Godmode

		if(!istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))

			if(bodytemperature < species.cold_level_3)
				take_overall_damage(COLD_DAMAGE_LEVEL_3, BURN)
			else if(bodytemperature < species.cold_level_2)
				take_overall_damage(COLD_DAMAGE_LEVEL_2, BURN)
			else if(bodytemperature < species.cold_level_1)
				take_overall_damage(COLD_DAMAGE_LEVEL_1, BURN)

	//Account for massive pressure differences.  Done by Polymorph
	//Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!
	if(status_flags & GODMODE)
		return 1 //Godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		var/pressure_damage = min(((adjusted_pressure / species.hazard_high_pressure) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE)
		take_overall_damage(pressure_damage)
		throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 2)
	else if(adjusted_pressure >= species.warning_high_pressure)
		throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/highpressure, 1)
	else if(adjusted_pressure >= species.warning_low_pressure)
		clear_alert(ALERT_PRESSURE)
	else if(adjusted_pressure >= species.hazard_low_pressure)
		throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 1)
	else
		take_overall_damage(LOW_PRESSURE_DAMAGE)
		if(getOxyLoss() < 55) //11 OxyLoss per 4 ticks when wearing internals;    unconsciousness in 16 ticks, roughly half a minute
			adjustOxyLoss(4)  //16 OxyLoss per 4 ticks when no internals present; unconsciousness in 13 ticks, roughly twenty seconds
		throw_alert(ALERT_PRESSURE, /atom/movable/screen/alert/lowpressure, 2)
