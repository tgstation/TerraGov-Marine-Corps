
//-----Monkey Yeti Thing
/mob/living/carbon/monkey/yiren
	name = "Yiren"
	desc = "Weird, but cute."
	icon_state = "yirenkey1"

/mob/living/carbon/monkey/yiren/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	//Moved these vars here for use in the fuck-it-skip-processing check.
	var/pressure = environment.return_pressure()
	if(pressure < WARNING_HIGH_PRESSURE && pressure > WARNING_LOW_PRESSURE && abs(environment.temperature - 293.15) < 20 && abs(bodytemperature - 310.14) < 0.5 && environment.gas["phoron"] < MOLES_PHORON_VISIBLE)


		//Hopefully should fix the walk-inside-still-pressure-warning issue.
		if(pressure_alert)
			pressure_alert = 0

		return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if((environment.temperature > (T0C + 50)) || (environment.temperature < ICE_PLANET_min_cold_protection_temperature))
		var/transfer_coefficient = 1

		handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat==2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences
	switch(pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			pressure_alert = -1
		else
			if( !(COLD_RESISTANCE in mutations) )
				adjustBruteLoss( LOW_PRESSURE_DAMAGE )
				pressure_alert = -2
			else
				pressure_alert = -1

	return
