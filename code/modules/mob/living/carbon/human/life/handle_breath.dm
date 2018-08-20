//Refer to life.dm for caller

/mob/living/carbon/human/proc/breathe()

	//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!

	if(reagents.has_reagent("lexorin"))
		return
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		return
	if(species && (species.flags & NO_BREATHE || species.flags & IS_SYNTHETIC))
		return

	var/list/air_info

	// HACK NEED CHANGING LATER
	if(health < config.health_threshold_crit && !reagents.has_reagent("inaprovaline"))
		losebreath++

	if(losebreath > 0) //Suffocating so do not take a breath
		losebreath--
		if(prob(10)) //Gasp per 10 ticks? Sounds about right.
			spawn emote("gasp")
		if(istype(loc, /atom/movable))
			var/atom/movable/container = loc
			container.handle_internal_lifeform(src)
	else
		//First, check for air from internal atmosphere (using an air tank and mask generally)
		air_info = get_breath_from_internal()

		//No breath from internal atmosphere so get breath from location
		if(!air_info)
			if(istype(loc, /atom/movable))
				var/atom/movable/container = loc
				air_info = container.handle_internal_lifeform(src)
				if(istype(wear_mask) && air_info)
					air_info = wear_mask.filter_air(air_info)//some gas masks can modify the gas we're breathing

			else if(isturf(loc))
				var/turf/T = loc
				air_info = T.return_air()

				if(istype(wear_mask) && air_info)
					air_info = wear_mask.filter_air(air_info)//some gas masks can modify the gas we're breathing

				if(!is_lung_ruptured())
					if(!air_info || air_info[3] < 10 || air_info[3] > 3000)
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
					for(var/obj/effect/particle_effect/smoke/chem/smoke in view(1, src))
						if(smoke.reagents.total_volume)
							smoke.reagents.reaction(src, INGEST)
							spawn(5)
								if(smoke)
									smoke.reagents.copy_to(src, 10) //I dunno, maybe the reagents enter the blood stream through the lungs?
							break //If they breathe in the nasty stuff once, no need to continue checking

		else //Still give container the chance to interact
			if(istype(loc, /atom/movable))
				var/atom/movable/container = loc
				container.handle_internal_lifeform(src)

	handle_breath(air_info)


/mob/living/carbon/human/proc/get_breath_from_internal()
	if(internal)
		if(istype(buckled,/obj/machinery/optable))
			var/obj/machinery/optable/O = buckled
			if(O.anes_tank)
				return O.anes_tank.return_air()
			return null
		if(!contents.Find(internal))
			internal = null
		if(!wear_mask || !(wear_mask.flags_inventory & ALLOWINTERNALS))
			internal = null
		if(internal)
			return internal.return_air()
		else if(hud_used && hud_used.internals)
			hud_used.internals.icon_state = "internal0"
	return null

/mob/living/carbon/human/proc/handle_breath(list/air_info)

	if(status_flags & GODMODE)
		return

	if(!air_info || suiciding)
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
		var/datum/internal_organ/lungs/L = internal_organs_by_name["lungs"]
		if(!L)
			safe_pressure_min = INFINITY //No lungs, how are you breathing?
		else if(L.is_broken())
			safe_pressure_min *= 1.5
		else if(L.is_bruised())
			safe_pressure_min *= 1.25


	var/breath_type

	var/failed_inhale = 0

	if(species.breath_type)
		breath_type = species.breath_type
	else
		breath_type = "oxygen"

	switch(air_info[1])
		if(GAS_TYPE_AIR)
			var/O2_pp = air_info[3]*0.2 //20% oxygen in air
			if(breath_type != "oxygen" || O2_pp < safe_pressure_min)// Too little oxygen
				if(prob(20))
					spawn(0) emote("gasp")
				if (O2_pp == 0)
					O2_pp = 0.01
				var/ratio = O2_pp/safe_pressure_min
				//Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
				adjustOxyLoss(max(HUMAN_MAX_OXYLOSS * (1 - ratio), 0))
				failed_inhale = 1
				oxygen_alert = max(oxygen_alert, 1)

			else 									// We're in safe limits
				adjustOxyLoss(-5)
				oxygen_alert = 0

		if(GAS_TYPE_OXYGEN)
			var/O2_pp = air_info[3]
			if(breath_type != "oxygen" || O2_pp < safe_pressure_min)// Too little oxygen
				if(prob(20))
					spawn(0) emote("gasp")
				if (O2_pp == 0)
					O2_pp = 0.01
				var/ratio = O2_pp/safe_pressure_min
				//Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!)
				adjustOxyLoss(max(HUMAN_MAX_OXYLOSS * (1 - ratio), 0))
				failed_inhale = 1
				oxygen_alert = max(oxygen_alert, 1)

			else 									// We're in safe limits
				adjustOxyLoss(-5)
				oxygen_alert = 0

		if(GAS_TYPE_N2O)
			if(!isYautja(src)) // Prevent Predator anesthetic memes
				var/SA_pp = air_info[3]
				if(SA_pp > 20) // Enough to make us paralysed for a bit
					KnockOut(3) // 3 gives them one second to wake up and run away a bit!
					//Enough to make us sleep as well
					if(SA_pp > 30)
						sleeping = min(sleeping+4, 10)
				else if(SA_pp > 1)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if(prob(20))
						spawn(0) emote(pick("giggle", "laugh"))

		else
			adjustOxyLoss(HUMAN_MAX_OXYLOSS)
			failed_inhale = 1
			oxygen_alert = max(oxygen_alert, 1)


	//Were we able to breathe?
	if(failed_inhale)
		failed_last_breath = 1
	else
		failed_last_breath = 0
		adjustOxyLoss(-5)


	if((air_info[2] < species.cold_level_1 || air_info[2] > species.heat_level_1) && !(COLD_RESISTANCE in mutations))
		if(air_info[2] < species.cold_level_1)
			if(prob(20))
				to_chat(src, "<span class='danger'>You feel your face freezing and icicles forming in your lungs!</span>")
		else if(air_info[2] > species.heat_level_1)
			if(prob(20))
				to_chat(src, "<span class='danger'>You feel your face burning and a searing heat in your lungs!</span>")

		var/breath_temp = air_info[2]

		if(breath_temp < species.cold_level_3)
			apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")
			fire_alert = max(fire_alert, 1)
		else if(breath_temp < species.cold_level_2)
			apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")
			fire_alert = max(fire_alert, 1)
		else if(breath_temp < species.cold_level_1)
			apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")
			fire_alert = max(fire_alert, 1)
		else if(breath_temp > species.heat_level_3)
			apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")
			fire_alert = max(fire_alert, 2)
		else if(breath_temp > species.heat_level_2)
			apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
			fire_alert = max(fire_alert, 2)
		else if(breath_temp > species.heat_level_1)
			apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
			fire_alert = max(fire_alert, 2)

		//Breathing in hot/cold air also heats/cools you a bit
		var/temp_adj = air_info[2] - bodytemperature
		if(temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//Don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//Don't raise temperature as much as if we were directly exposed

		if(temp_adj > BODYTEMP_HEATING_MAX)
			temp_adj = BODYTEMP_HEATING_MAX
		if(temp_adj < BODYTEMP_COOLING_MAX)
			temp_adj = BODYTEMP_COOLING_MAX
		bodytemperature += temp_adj

	return 1
