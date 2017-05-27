//Refer to life.dm for caller

/mob/living/carbon/human/proc/breathe()

	//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!

	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return
	if(species && (species.flags & NO_BREATHE || species.flags & IS_SYNTHETIC))
		return

	var/datum/gas_mixture/environment = loc.return_air()
	var/datum/gas_mixture/breath

	// HACK NEED CHANGING LATER
	if(health < config.health_threshold_crit && !reagents.has_reagent("inaprovaline"))
		losebreath++

	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if(prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn emote("gasp")
		if(istype(loc, /obj/))
			var/obj/location_as_object = loc
			location_as_object.handle_internal_lifeform(src, 0)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		breath = get_breath_from_internal(BREATH_VOLUME) //Super hacky -- TLE
		//breath = get_breath_from_internal(0.5) //Manually setting to old BREATH_VOLUME amount -- TLE

		//No breath from internal atmosphere so get breath from location
		if(!breath)
			if(isobj(loc))
				var/obj/location_as_object = loc
				breath = location_as_object.handle_internal_lifeform(src, BREATH_MOLES)
			else if(isturf(loc))
				var/breath_moles = 0
				breath_moles = environment.total_moles*BREATH_PERCENTAGE
				breath = loc.remove_air(breath_moles)

				if(istype(wear_mask, /obj/item/clothing/mask) && breath)
					var/obj/item/clothing/mask/M = wear_mask
					var/datum/gas_mixture/filtered = M.filter_air(breath)
					loc.assume_air(filtered)

				if(!is_lung_ruptured())
					if(!breath || breath.total_moles < BREATH_MOLES / 5 || breath.total_moles > BREATH_MOLES * 5)
						if(prob(5))
							rupture_lung()

				//Handle filtering
				var/block = 0
				if(wear_mask)
					if(wear_mask.flags_inventory & BLOCKGASEFFECT)
						block = 1
				if(glasses)
					if(glasses.flags_inventory & BLOCKGASEFFECT)
						block = 1
				if(head)
					if(head.flags_inventory & BLOCKGASEFFECT)
						block = 1

				if(!block)
					for(var/obj/effect/effect/smoke/chem/smoke in view(1, src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) //I dunno, maybe the reagents enter the blood stream through the lungs?
							break //If they breathe in the nasty stuff once, no need to continue checking

		else //Still give containing object the chance to interact
			if(istype(loc, /obj/))
				var/obj/location_as_object = loc
				location_as_object.handle_internal_lifeform(src, 0)

	handle_breath(breath)
	if(breath)
		loc.assume_air(breath)
		//Spread some viruses while we are at it
		if(virus2.len > 0)
			if(prob(10) && get_infection_chance(src))
				for(var/mob/living/carbon/M in view(1,src))
					src.spread_disease_to(M)

/mob/living/carbon/human/proc/get_breath_from_internal(volume_needed)
	if(internal)
		if(!contents.Find(internal))
			internal = null
		if(!wear_mask || !(wear_mask.flags_inventory & ALLOWINTERNALS))
			internal = null
		if(internal)
			return internal.remove_air_volume(volume_needed)
		else if(hud_used && hud_used.internals)
			hud_used.internals.icon_state = "internal0"
	return null

/mob/living/carbon/human/proc/handle_breath(datum/gas_mixture/breath)

	if(status_flags & GODMODE)
		return

	if(!breath || (breath.total_moles == 0) || suiciding)
		if(suiciding)
			adjustOxyLoss(2) //If you are suiciding, you should die a little bit faster
			failed_last_breath = 1
			oxygen_alert = max(oxygen_alert, 1)
			return 0
		if(health > config.health_threshold_crit)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_last_breath = 1
		else
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)
			failed_last_breath = 1

		oxygen_alert = max(oxygen_alert, 1)

		return 0

	var/safe_pressure_min = 16 //Minimum safe partial pressure of breathable gas in kPa

	//Lung damage increases the minimum safe pressure.
	if(species.has_organ["lungs"])
		var/datum/organ/internal/lungs/L = internal_organs_by_name["lungs"]
		if(!L)
			safe_pressure_min = INFINITY //No lungs, how are you breathing?
		else if(L.is_broken())
			safe_pressure_min *= 1.5
		else if(L.is_bruised())
			safe_pressure_min *= 1.25

	var/safe_exhaled_max = 10
	var/safe_toxins_max = 0.005
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/inhaled_gas_used = 0

	var/breath_pressure = (breath.total_moles*R_IDEAL_GAS_EQUATION*breath.temperature)/BREATH_VOLUME

	var/inhaling
	var/poison
	var/exhaling

	var/breath_type
	var/poison_type
	var/exhale_type

	var/failed_inhale = 0
	var/failed_exhale = 0

	if(species.breath_type)
		breath_type = species.breath_type
	else
		breath_type = "oxygen"
	inhaling = breath.gas[breath_type]

	if(species.poison_type)
		poison_type = species.poison_type
	else
		poison_type = "phoron"
	poison = breath.gas[poison_type]

	if(species.exhale_type)
		exhale_type = species.exhale_type
		exhaling = breath.gas[exhale_type]
	else
		exhaling = 0

	var/inhale_pp = (inhaling/breath.total_moles) * breath_pressure
	var/toxins_pp = (poison/breath.total_moles) * breath_pressure
	var/exhaled_pp = (exhaling/breath.total_moles) * breath_pressure

	//Not enough to breathe
	if(inhale_pp < safe_pressure_min)
		if(prob(20))
			spawn emote("gasp")
		var/ratio = inhale_pp/safe_pressure_min
		//Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
		adjustOxyLoss(max(HUMAN_MAX_OXYLOSS * (1 - ratio), 0))
		failed_inhale = 1
		oxygen_alert = max(oxygen_alert, 1)
	else
		// We're in safe limits
		oxygen_alert = 0

	inhaled_gas_used = inhaling/6
	breath.adjust_gas(breath_type, -inhaled_gas_used, update = 0) //update afterwards

	if(exhale_type)
		breath.adjust_gas_temp(exhale_type, inhaled_gas_used, bodytemperature, update = 0) //Update afterwards

		//Too much exhaled gas in the air
		if(exhaled_pp > safe_exhaled_max)
			if (!co2_alert|| prob(15))
				var/word = pick("extremely dizzy", "short of breath", "faint", "confused")
				src << "<span class='danger'>You feel [word].</span>"

			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			co2_alert = 1
			failed_exhale = 1

		else if(exhaled_pp > safe_exhaled_max * 0.7)
			if(!co2_alert || prob(1))
				var/word = pick("dizzy", "short of breath", "faint", "momentarily confused")
				src << "<span class='warning'>You feel [word].</span>"

			//Scale linearly from 0 to 1 between safe_exhaled_max and safe_exhaled_max*0.7
			var/ratio = 1.0 - (safe_exhaled_max - exhaled_pp)/(safe_exhaled_max * 0.3)

			//Give them some oxyloss, up to the limit - we don't want people falling unconcious due to CO2 alone until they're pretty close to safe_exhaled_max.
			if(getOxyLoss() < 50 * ratio)
				adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			co2_alert = 1
			failed_exhale = 1

		else if(exhaled_pp > safe_exhaled_max * 0.6)
			if(prob(0.3))
				var/word = pick("a little dizzy", "short of breath")
				src << "<span class='warning'>You feel [word].</span>"

		else
			co2_alert = 0

	//Too much poison in the air.
	if(toxins_pp > safe_toxins_max)
		var/ratio = (poison/safe_toxins_max) * 10
		if(reagents)
			reagents.add_reagent("toxin", Clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
			breath.adjust_gas(poison_type, -poison/6, update = 0) //update after
		phoron_alert = max(phoron_alert, 1)
	else
		phoron_alert = 0

	//If there's some other shit in the air lets deal with it here.
	if(breath.gas["sleeping_agent"])
		var/SA_pp = (breath.gas["sleeping_agent"] / breath.total_moles) * breath_pressure

		//Enough to make us paralysed for a bit
		if(SA_pp > SA_para_min)
			Paralyse(3) //3 gives them one second to wake up and run away a bit!

			//Enough to make us sleep as well
			if(SA_pp > SA_sleep_min)
				sleeping = min(sleeping+4, 10)

		//There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		else if(SA_pp > 0.15)
			if(prob(20))
				spawn(0) emote(pick("giggle", "laugh"))
		breath.adjust_gas("sleeping_agent", -breath.gas["sleeping_agent"]/6, update = 0) //Update after

	//Were we able to breathe?
	if(failed_inhale || failed_exhale)
		failed_last_breath = 1
	else
		failed_last_breath = 0
		adjustOxyLoss(-5)

	//Hot air hurts :(
	var/rebreather = wear_mask && wear_mask.flags_inventory & ALLOWREBREATH ? 1:0 //If you have rebreather equipped, don't damage the lungs
	if((breath.temperature < species.cold_level_1 || breath.temperature > species.heat_level_1) && !(COLD_RESISTANCE in mutations) && !rebreather)
		if(breath.temperature < species.cold_level_1)
			if(prob(20))
				src << "<span class='danger'>You feel your face freezing and icicles forming in your lungs!</span>"
		else if(breath.temperature > species.heat_level_1)
			if(prob(20))
				src << "<span class='danger'>You feel your face burning and a searing heat in your lungs!</span>"

		switch(breath.temperature)
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
		var/temp_adj = breath.temperature - bodytemperature
		if(temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//Don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//Don't raise temperature as much as if we were directly exposed

		var/relative_density = breath.total_moles / (MOLES_CELLSTANDARD * BREATH_PERCENTAGE)
		temp_adj *= relative_density

		if(temp_adj > BODYTEMP_HEATING_MAX)
			temp_adj = BODYTEMP_HEATING_MAX
		if(temp_adj < BODYTEMP_COOLING_MAX)
			temp_adj = BODYTEMP_COOLING_MAX
		bodytemperature += temp_adj

	breath.update_values()
	return 1
