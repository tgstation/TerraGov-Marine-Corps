//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_environment(datum/gas_mixture/environment)

	if(!environment)
		return

	//Stuff like the xenomorph's plasma regen happens here.
	species.handle_environment_special(src)

	//Moved pressure calculations here for use in skip-processing check.
	var/pressure = environment.return_pressure()
	var/adjusted_pressure = calculate_affecting_pressure(pressure)

	//Check for contaminants before anything else because we don't want to skip it.
	for(var/g in environment.gas)
		if(gas_data.flags[g] & XGM_GAS_CONTAMINANT && environment.gas[g] > gas_data.overlay_limit[g] + 1)
			pl_effects()
			break

	if(!istype(get_turf(src), /turf/space)) //Space is not meant to change your body temperature.
		var/loc_temp = T0C
		if(istype(loc, /obj/mecha))
			var/obj/mecha/M = loc
			loc_temp =  M.return_temperature()
		else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			loc_temp = loc:air_contents.temperature
		else
			loc_temp = environment.temperature

		if(adjusted_pressure < species.warning_high_pressure && adjusted_pressure > species.warning_low_pressure && abs(loc_temp - bodytemperature) < 20 && bodytemperature < species.heat_level_1 && bodytemperature > species.cold_level_1)
			pressure_alert = 0
			return //Temperatures are within normal ranges, fuck all this processing. ~Ccomp

		//Body temperature adjusts depending on surrounding atmosphere based on your thermal protection
		var/temp_adj = 0
		if(loc_temp < bodytemperature) //Place is colder than we are
			var/thermal_protection = get_flags_cold_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				temp_adj = (1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR) //This will be negative
		else if (loc_temp > bodytemperature) //Place is hotter than we are
			var/thermal_protection = get_flags_heat_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				temp_adj = (1 - thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)

		//Use heat transfer as proportional to the gas density. However, we only care about the relative density vs standard 101 kPa/20 C air. Therefore we can use mole ratios
		var/relative_density = environment.total_moles / MOLES_CELLSTANDARD
		temp_adj *= relative_density

		if(temp_adj > BODYTEMP_HEATING_MAX)
			temp_adj = BODYTEMP_HEATING_MAX
		if(temp_adj < BODYTEMP_COOLING_MAX)
			temp_adj = BODYTEMP_COOLING_MAX
		bodytemperature += temp_adj

	//+/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > species.heat_level_1)
		//Body temperature is too hot.
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)
			return 1 //Godmode
		switch(bodytemperature)
			if(species.heat_level_1 to species.heat_level_2)
				take_overall_damage(burn = HEAT_DAMAGE_LEVEL_1, used_weapon = "High Body Temperature")
				fire_alert = max(fire_alert, 2)
			if(species.heat_level_2 to species.heat_level_3)
				take_overall_damage(burn = HEAT_DAMAGE_LEVEL_2, used_weapon = "High Body Temperature")
				fire_alert = max(fire_alert, 2)
			if(species.heat_level_3 to INFINITY)
				take_overall_damage(burn = HEAT_DAMAGE_LEVEL_3, used_weapon = "High Body Temperature")
				fire_alert = max(fire_alert, 2)

	else if(bodytemperature < species.cold_level_1)
		fire_alert = max(fire_alert, 1)
		if(status_flags & GODMODE)
			return 1 //Godmode
		if(!istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
			switch(bodytemperature)
				if(-INFINITY to species.cold_level_3)
					take_overall_damage(burn = COLD_DAMAGE_LEVEL_3, used_weapon = "Low Body Temperature")
					fire_alert = max(fire_alert, 1)
				if(species.cold_level_3 to species.cold_level_2)
					take_overall_damage(burn = COLD_DAMAGE_LEVEL_2, used_weapon = "Low Body Temperature")
					fire_alert = max(fire_alert, 1)
				if(species.cold_level_2 to species.cold_level_1)
					take_overall_damage(burn = COLD_DAMAGE_LEVEL_1, used_weapon = "Low Body Temperature")
					fire_alert = max(fire_alert, 1)

	//Account for massive pressure differences.  Done by Polymorph
	//Made it possible to actually have something that can protect against high pressure... Done by Errorage. Polymorph now has an axe sticking from his head for his previous hardcoded nonsense!
	if(status_flags & GODMODE)
		return 1 //Godmode

	if(adjusted_pressure >= species.hazard_high_pressure)
		var/pressure_damage = min(((adjusted_pressure / species.hazard_high_pressure) - 1) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE)
		take_overall_damage(brute=pressure_damage, used_weapon = "High Pressure")
		pressure_alert = 2
	else if(adjusted_pressure >= species.warning_high_pressure)
		pressure_alert = 1
	else if(adjusted_pressure >= species.warning_low_pressure)
		pressure_alert = 0
	else if(adjusted_pressure >= species.hazard_low_pressure)
		pressure_alert = -1
	else
		if(!(COLD_RESISTANCE in mutations))
			take_overall_damage(brute = LOW_PRESSURE_DAMAGE, used_weapon = "Low Pressure")
			if(getOxyLoss() < 55) //11 OxyLoss per 4 ticks when wearing internals;    unconsciousness in 16 ticks, roughly half a minute
				adjustOxyLoss(4)  //16 OxyLoss per 4 ticks when no internals present; unconsciousness in 13 ticks, roughly twenty seconds
			pressure_alert = -2
		else
			pressure_alert = -1

	if(isturf(loc) && !stat)
		var/obj/effect/particle_effect/smoke/xeno_weak/X = locate() in loc
		if(X)
			X.affect(src)
		var/obj/effect/particle_effect/smoke/xeno_burn/Z = locate() in loc
		if(Z)
			Z.affect(src)
