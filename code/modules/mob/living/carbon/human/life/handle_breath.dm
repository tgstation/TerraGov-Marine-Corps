//Refer to life.dm for caller

/mob/living/carbon/human/need_breathe()
	if((species?.species_flags & NO_BREATHE) && health > get_crit_threshold())
		set_Losebreath(0, TRUE)
		setOxyLoss(0, TRUE)
		oxygen_alert = FALSE
		failed_last_breath = FALSE
		return FALSE
	return ..()

/mob/living/carbon/human/handle_breath(list/air_info)
	if(status_flags & GODMODE)
		return
	. = ..(air_info)
	if(!.)
		if(prob(10) && !(species?.species_flags & NO_BREATHE))
			emote("gasp")
		return FALSE

	if(!is_lung_ruptured())
		if((!air_info || !ISINRANGE_EX(air_info[3], 10, 3000)) && prob(5))
			rupture_lung()

	var/safe_pressure_min = 16 //Minimum safe partial pressure of breathable gas in kPa

	if(species.has_organ["lungs"])
		var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]
		if(!L)
			safe_pressure_min = INFINITY //No lungs, how are you breathing?
		else if(L.is_broken())
			safe_pressure_min *= 1.5
		else if(L.is_bruised())
			safe_pressure_min *= 1.25


	var/breath_type

	if(species.breath_type)
		breath_type = species.breath_type
	else
		breath_type = "oxygen"

	switch(air_info[1])
		if(GAS_TYPE_AIR)
			var/O2_pp = air_info[3]*0.2 //20% oxygen in air
			if(breath_type != "oxygen" || O2_pp < safe_pressure_min)// Too little oxygen
				if(prob(20))
					emote("gasp")
				if (O2_pp == 0)
					O2_pp = 0.01
				var/ratio = O2_pp/safe_pressure_min
				adjustOxyLoss(max(CARBON_MAX_OXYLOSS * (1 - ratio), 0)) //Don't fuck them up too fast (space only does CARBON_MAX_OXYLOSS after all!)
				oxygen_alert = TRUE
				failed_last_breath = TRUE

			else 									// We're in safe limits
				adjustOxyLoss(CARBON_RECOVERY_OXYLOSS)
				oxygen_alert = FALSE
				failed_last_breath = FALSE

		if(GAS_TYPE_OXYGEN)
			var/O2_pp = air_info[3]
			if(breath_type != "oxygen" || O2_pp < safe_pressure_min)// Too little oxygen
				if(prob(20))
					emote("gasp")
				if (O2_pp == 0)
					O2_pp = 0.01
				var/ratio = O2_pp/safe_pressure_min
				adjustOxyLoss(max(CARBON_MAX_OXYLOSS * (1 - ratio), 0)) //Don't fuck them up too fast (space only does CARBON_MAX_OXYLOSS after all!)
				oxygen_alert = TRUE
				failed_last_breath = TRUE

			else 									// We're in safe limits
				adjustOxyLoss(CARBON_RECOVERY_OXYLOSS)
				oxygen_alert = FALSE
				failed_last_breath = FALSE

		if(GAS_TYPE_N2O)
			var/SA_pp = air_info[3]
			if(SA_pp > 30)
				Sleeping(10)
			else if(SA_pp > 20) // Enough to make us paralysed for a bit
				KnockOut(3) // 3 gives them one second to wake up and run away a bit!
			else if(SA_pp > 1)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(20))
					emote(pick("giggle", "laugh"))
			failed_last_breath = FALSE

		else
			adjustOxyLoss(CARBON_MAX_OXYLOSS)
			oxygen_alert = TRUE
			failed_last_breath = TRUE


	var/breath_temp = air_info[2]

	if(!ISINRANGE_EX(breath_temp, species.cold_level_1, species.heat_level_1))
		if(prob(20))
			if(breath_temp < species.cold_level_1)
				to_chat(src, "<span class='danger'>You feel your face freezing and icicles forming in your lungs!</span>")
			else
				to_chat(src, "<span class='danger'>You feel your face burning and a searing heat in your lungs!</span>")

		switch(breath_temp)
			if(-INFINITY to species.cold_level_3)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")
				fire_alert = max(fire_alert, 1)
			if(species.cold_level_3 to species.cold_level_2)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")
				fire_alert = max(fire_alert, 1)
			if(species.cold_level_2 to species.cold_level_1)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")
				fire_alert = max(fire_alert, 1)
			if(species.heat_level_1 to species.heat_level_2)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
				fire_alert = max(fire_alert, 2)
			if(species.heat_level_2 to species.heat_level_3)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
				fire_alert = max(fire_alert, 2)
			if(species.heat_level_3 to INFINITY)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")
				fire_alert = max(fire_alert, 2)

		//Breathing in hot/cold air also heats/cools you a bit
		var/temp_adj = breath_temp - bodytemperature
		if(temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//Don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//Don't raise temperature as much as if we were directly exposed

		if(temp_adj > BODYTEMP_HEATING_MAX)
			temp_adj = BODYTEMP_HEATING_MAX
		if(temp_adj < BODYTEMP_COOLING_MAX)
			temp_adj = BODYTEMP_COOLING_MAX
		adjust_bodytemperature(temp_adj)

	return TRUE
