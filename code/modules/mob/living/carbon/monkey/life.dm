/mob/living/carbon/monkey/Life()
	..()

	life_tick++

	if (stat != DEAD)

		//Mutations and radiation
		handle_mutations_and_radiation()

		//effects of being grabbed aggressively by another mob
		if(pulledby && pulledby.grab_level)
			handle_grabbed()
	else
		SSmobs.stop_processing(src)

	//Handle temperature/pressure differences between body and environment
	handle_environment()

	if(!client && stat == CONSCIOUS)

		if(prob(33) && canmove && !buckled && isturf(loc) && !pulledby) //won't move if being pulled

			step(src, pick(GLOB.cardinals))

		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))

/mob/living/carbon/monkey/handle_disabilities()
	. = ..()

	if (disabilities & EPILEPSY)
		if ((prob(1) && knocked_out < 10))
			to_chat(src, "<span class='warning'>You have a seizure!</span>")
			KnockOut(10)
	if (disabilities & COUGHING)
		if ((prob(5) && knocked_out <= 1))
			drop_held_item()
			spawn( 0 )
				emote("cough")
				return
	if (disabilities & TOURETTES)
		if ((prob(10) && knocked_out <= 1))
			Stun(10)
			spawn( 0 )
				emote("twitch")
				return
	if (disabilities & NERVOUS)
		if (prob(10))
			stuttering = max(10, stuttering)

/mob/living/carbon/monkey/proc/handle_mutations_and_radiation()

	if(getFireLoss())
		if(prob(50))
			switch(getFireLoss())
				if(1 to 50)
					adjustFireLoss(-1)
				if(51 to 100)
					adjustFireLoss(-5)

	if (radiation)

		if (radiation > 100)
			radiation = 100
			KnockDown(10)
			if(!lying)
				to_chat(src, "<span class='warning'>You feel weak.</span>")
				emote("collapse")

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					KnockDown(3)
					if(!lying)
						to_chat(src, "<span class='warning'>You feel weak.</span>")
						emote("collapse")

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				if(prob(1))
					to_chat(src, "<span class='warning'>You mutate!</span>")
					emote("gasp")

/mob/living/carbon/monkey/handle_breath(list/air_info)
	if(status_flags & GODMODE)
		return
	. = ..(air_info)
	if(!.)
		if(prob(10))
			emote("gasp")
		return FALSE

	var/safe_pressure_min = 16 //Minimum safe partial pressure of breathable gas in kPa

	switch(air_info[1])
		if(GAS_TYPE_AIR)
			var/O2_pp = air_info[3]*0.2 //20% oxygen in air
			if(O2_pp < safe_pressure_min)// Too little oxygen
				if(prob(10))
					emote("gasp")
				if (O2_pp == 0)
					O2_pp = 0.01
				var/ratio = O2_pp/safe_pressure_min
				adjustOxyLoss(max(CARBON_MAX_OXYLOSS * (1 - ratio), 0))
				oxygen_alert = TRUE
				failed_last_breath = TRUE

			else 									// We're in safe limits
				adjustOxyLoss(CARBON_RECOVERY_OXYLOSS)
				oxygen_alert = FALSE
				failed_last_breath = FALSE

		if(GAS_TYPE_OXYGEN)
			var/O2_pp = air_info[3]
			if(O2_pp < safe_pressure_min)// Too little oxygen
				if(prob(10))
					emote("gasp")
				if (O2_pp == 0)
					O2_pp = 0.01
				var/ratio = O2_pp/safe_pressure_min
				adjustOxyLoss(max(CARBON_MAX_OXYLOSS * (1 - ratio), 0))
				oxygen_alert = TRUE
				failed_last_breath = TRUE

			else 									// We're in safe limits
				adjustOxyLoss(CARBON_RECOVERY_OXYLOSS)
				oxygen_alert = FALSE
				failed_last_breath = FALSE

		if(GAS_TYPE_N2O) //Anesthetic
			var/SA_pp = air_info[3]
			if(SA_pp > 30)
				Sleeping(10)
			else if(SA_pp > 20) // Enough to make us paralysed for a bit
				KnockOut(3) // 3 gives them one second to wake up and run away a bit!
				//Enough to make us sleep as well
			else if(SA_pp > 1)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
				if(prob(10))
					emote(pick("giggle", "laugh"))
			failed_last_breath = FALSE


		else
			adjustOxyLoss(CARBON_MAX_OXYLOSS)
			oxygen_alert = TRUE
			failed_last_breath = TRUE

	var/breath_temp = air_info[2]

	if(!ISINRANGE_EX(breath_temp, BODYTEMP_COLD_DAMAGE_LIMIT_ONE, BODYTEMP_HEAT_DAMAGE_LIMIT_ONE))
		if(prob(20))
			if(air_info[2] < BODYTEMP_COLD_DAMAGE_LIMIT_ONE)
				to_chat(src, "<span class='danger'>You feel your face freezing and icicles forming in your lungs!</span>")
			else
				to_chat(src, "<span class='danger'>You feel your face burning and a searing heat in your lungs!</span>")

		switch(breath_temp)
			if(-INFINITY to cold_level_3)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")
				fire_alert = max(fire_alert, 1)
			if(cold_level_3 to cold_level_2)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")
				fire_alert = max(fire_alert, 1)
			if(cold_level_2 to cold_level_1)
				apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")
				fire_alert = max(fire_alert, 1)
			if(heat_level_1 to heat_level_2)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
				fire_alert = max(fire_alert, 2)
			if(heat_level_2 to heat_level_3)
				apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
				fire_alert = max(fire_alert, 2)
			if(heat_level_3 to INFINITY)
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

/mob/living/carbon/monkey/proc/handle_environment()
	var/env_pressure = return_pressure()
	var/env_temperature = return_temperature()

	if(env_pressure < WARNING_HIGH_PRESSURE && env_pressure > WARNING_LOW_PRESSURE && abs(env_temperature - 293.15) < 20 && abs(bodytemperature - BODYTEMP_NORMAL) < 0.5)

		//Hopefully should fix the walk-inside-still-pressure-warning issue.
		if(pressure_alert)
			pressure_alert = 0

		return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

	if(!ISINRANGE(env_temperature, cold_level_1, heat_level_1))
		handle_temperature_damage(HEAD, env_temperature)

	//Account for massive pressure differences
	switch(env_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			adjustBruteLoss( min( ( (env_pressure / HAZARD_HIGH_PRESSURE) -1 )*PRESSURE_DAMAGE_COEFFICIENT , MAX_HIGH_PRESSURE_DAMAGE) )
			pressure_alert = 2
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			pressure_alert = 1
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			pressure_alert = 0
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			pressure_alert = -1
		else
			adjustBruteLoss( LOW_PRESSURE_DAMAGE )
			pressure_alert = -2

	return

/mob/living/carbon/monkey/proc/handle_temperature_damage(body_part, exposed_temperature)
	if(status_flags & GODMODE) return
	var/discomfort = min( abs(exposed_temperature - bodytemperature)/100, 1)
	//adjustFireLoss(2.5*discomfort)

	if(exposed_temperature > bodytemperature)
		adjustFireLoss(20.0*discomfort)

	else
		adjustFireLoss(5.0*discomfort)

/mob/living/carbon/monkey/handle_organs()
	. = ..()
	if(!reagents)
		return
	var/overdosable = TRUE
	var/liverless = FALSE
	if(species)
		if(CHECK_BITFIELD(species.species_flags, NO_CHEM_METABOLIZATION))
			return
		overdosable = CHECK_BITFIELD(species.species_flags, NO_OVERDOSE) ? FALSE : TRUE
		liverless = species.has_organ["liver"]
	reagents.metabolize(src, overdosable, liverless)

/mob/living/carbon/monkey/handle_regular_hud_updates()
	. = ..()
	if(!(.))
		return FALSE

	update_sight()

	if(hud_used.pressure_icon)
		hud_used.pressure_icon.icon_state = "pressure[pressure_alert]"

	if (hud_used.toxin_icon)
		hud_used.toxin_icon.icon_state = "tox[phoron_alert ? 1 : 0]"
	if (hud_used.oxygen_icon)
		hud_used.oxygen_icon.icon_state = "oxy[oxygen_alert ? 1 : 0]"
	if (hud_used.fire_icon)
		hud_used.fire_icon.icon_state = "fire[fire_alert ? 2 : 0]"

	//NOTE: the alerts dont reset when youre out of danger. dont blame me,
	//blame the person who coded them. Temporary fix added.

	if(hud_used.bodytemp_icon)
		switch(bodytemperature) //310.055 optimal body temp
			if(345 to INFINITY)
				hud_used.bodytemp_icon.icon_state = "temp4"
			if(335 to 345)
				hud_used.bodytemp_icon.icon_state = "temp3"
			if(327 to 335)
				hud_used.bodytemp_icon.icon_state = "temp2"
			if(316 to 327)
				hud_used.bodytemp_icon.icon_state = "temp1"
			if(300 to 316)
				hud_used.bodytemp_icon.icon_state = "temp0"
			if(295 to 300)
				hud_used.bodytemp_icon.icon_state = "temp-1"
			if(280 to 295)
				hud_used.bodytemp_icon.icon_state = "temp-2"
			if(260 to 280)
				hud_used.bodytemp_icon.icon_state = "temp-3"
			else
				hud_used.bodytemp_icon.icon_state = "temp-4"





	if(stat != DEAD) //the dead get zero fullscreens

		if(interactee)
			interactee.check_eye(src)
		else if(client)
			reset_view(null)

	return 1

/mob/living/carbon/monkey/proc/handle_random_events()
	if (prob(1) && prob(2))
		spawn(0)
			emote("scratch")
			return

///FIRE CODE
/mob/living/carbon/monkey/handle_fire()
	if(..())
		return
	adjustFireLoss(6)
	return
//END FIRE CODE