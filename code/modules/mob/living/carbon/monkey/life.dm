//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/mob/living/carbon/monkey
	var/oxygen_alert = 0
	var/phoron_alert = 0
	var/fire_alert = 0
	var/pressure_alert = 0

	var/temperature_alert = 0


/mob/living/carbon/monkey/Life()
	set invisibility = 0
	set background = 1
	if (monkeyizing)	return
	if (update_muts)
		update_muts=0
		domutcheck(src,null,MUTCHK_FORCED)
	..()

	life_tick++

	if (stat != DEAD)
		//First, resolve location and get a breath

		if(life_tick%2==0)
			//Only try to take a breath every 4 seconds, unless suffocating
			breathe()

		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

		//Disabilities
		handle_disabilities()

		//effects of being grabbed aggressively by another mob
		if(pulledby && pulledby.grab_level)
			handle_grabbed()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	handle_environment()


	//Check if we're on fire
	handle_fire()


	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()

	if(!client && stat == CONSCIOUS)

		if(prob(33) && canmove && !buckled && isturf(loc) && !pulledby) //won't move if being pulled

			step(src, pick(cardinal))

		if(prob(1))
			emote(pick("scratch","jump","roll","tail"))
	updatehealth()

/mob/living/carbon/monkey

	proc/handle_disabilities()

		if (disabilities & EPILEPSY)
			if ((prob(1) && knocked_out < 10))
				src << "\red You have a seizure!"
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

	proc/handle_mutations_and_radiation()

		if(getFireLoss())
			if((COLD_RESISTANCE in mutations) || prob(50))
				switch(getFireLoss())
					if(1 to 50)
						adjustFireLoss(-1)
					if(51 to 100)
						adjustFireLoss(-5)

		if ((HULK in mutations) && health <= 25)
			mutations.Remove(HULK)
			src << "\red You suddenly feel very weak."
			KnockDown(3)
			emote("collapse")

		if (radiation)

			if (radiation > 100)
				radiation = 100
				KnockDown(10)
				if(!lying)
					src << "\red You feel weak."
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
							src << "\red You feel weak."
							emote("collapse")

				if(75 to 100)
					radiation -= 3
					adjustToxLoss(3)
					if(prob(1))
						src << "\red You mutate!"
						randmutb(src)
						domutcheck(src,null)
						emote("gasp")

	proc/breathe()
		if(reagents)

			if(reagents.has_reagent("lexorin")) return

		if(!loc) return //probably ought to make a proper fix for this, but :effort: --NeoFite

		var/list/air_info

		if(health < 0)
			losebreath++
		if(losebreath>0) //Suffocating so do not take a breath
			losebreath--
			if (prob(75)) //High chance of gasping for air
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
					if(istype(wear_mask, /obj/item/clothing/mask) && air_info)
						var/obj/item/clothing/mask/M = wear_mask
						air_info = M.filter_air(air_info)
				else if(isturf(loc))
					var/turf/T = loc
					air_info = T.return_air()

					if(istype(wear_mask, /obj/item/clothing/mask) && air_info)
						var/obj/item/clothing/mask/M = wear_mask
						air_info = M.filter_air(air_info)

					// Handle chem smoke effect  -- Doohl
					var/block = 0
					if(wear_mask)
						if(istype(wear_mask, /obj/item/clothing/mask/gas))
							block = 1

					if(!block)
						for(var/obj/effect/particle_effect/smoke/chem/smoke in view(1, src))
							if(smoke.reagents.total_volume)
								smoke.reagents.reaction(src, INGEST)
								spawn(5)
									if(smoke)
										smoke.reagents.copy_to(src, 10) // I dunno, maybe the reagents enter the blood stream through the lungs?
								break // If they breathe in the nasty stuff once, no need to continue checking


			else //Still give container the chance to interact
				if(istype(loc, /atom/movable))
					var/atom/movable/container = loc
					container.handle_internal_lifeform(src)

		handle_breath(air_info)


	proc/get_breath_from_internal()
		if(internal)
			if (!contents.Find(internal))
				internal = null
			if (!wear_mask || !(wear_mask.flags_inventory & ALLOWINTERNALS) )
				internal = null
			if(internal)
				if (hud_used && hud_used.internals)
					hud_used.internals.icon_state = "internal1"
				return internal.return_air()
			else
				if (hud_used && hud_used.internals)
					hud_used.internals.icon_state = "internal0"
		return null

	proc/handle_breath(list/air_info)
		if(status_flags & GODMODE)
			return

		if(!air_info)
			adjustOxyLoss(7)
			oxygen_alert = max(oxygen_alert, 1)
			return 0

		var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa

		switch(air_info[1])
			if(GAS_TYPE_AIR)
				var/O2_pp = air_info[3]*0.2 //20% oxygen in air
				if(O2_pp < safe_oxygen_min)// Too little oxygen
					if(prob(20))
						spawn(0) emote("gasp")
					if (O2_pp == 0)
						O2_pp = 0.01
					var/ratio = safe_oxygen_min/O2_pp
					adjustOxyLoss(min(5*ratio, 7)) // Don't fuck them up too fast (space only does 7 after all!)
					oxygen_alert = max(oxygen_alert, 1)

				else 									// We're in safe limits
					adjustOxyLoss(-5)
					oxygen_alert = 0

			if(GAS_TYPE_OXYGEN)
				var/O2_pp = air_info[3]
				if(O2_pp < safe_oxygen_min)// Too little oxygen
					if(prob(20))
						spawn(0) emote("gasp")
					if (O2_pp == 0)
						O2_pp = 0.01
					var/ratio = safe_oxygen_min/O2_pp
					adjustOxyLoss(min(5*ratio, 7)) // Don't fuck them up too fast (space only does 7 after all!)
					oxygen_alert = max(oxygen_alert, 1)

				else 									// We're in safe limits
					adjustOxyLoss(-5)
					oxygen_alert = 0

			if(GAS_TYPE_N2O) //Anesthetic
				var/SA_pp = air_info[3]
				if(SA_pp > 20) // Enough to make us paralysed for a bit
					KnockOut(3) // 3 gives them one second to wake up and run away a bit!
					//Enough to make us sleep as well
					if(SA_pp > 30)
						sleeping = min(sleeping+2, 10)
				else if(SA_pp > 1)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if(prob(20))
						spawn(0) emote(pick("giggle", "laugh"))


			else
				adjustOxyLoss(7)
				oxygen_alert = max(oxygen_alert, 1)


		if(air_info[2] > (T0C+66)) // Hot air hurts :(
			if(prob(20))
				src << "\red You feel a searing heat in your lungs!"
			fire_alert = max(fire_alert, 2)
		else
			fire_alert = 0

		//Temporary fixes to the alerts.

		return 1

	proc/handle_environment()
		var/env_pressure = return_pressure()
		var/env_temperature = return_temperature()

		if(env_pressure < WARNING_HIGH_PRESSURE && env_pressure > WARNING_LOW_PRESSURE && abs(env_temperature - 293.15) < 20 && abs(bodytemperature - 310.14) < 0.5)

			//Hopefully should fix the walk-inside-still-pressure-warning issue.
			if(pressure_alert)
				pressure_alert = 0

			return // Temperatures are within normal ranges, fuck all this processing. ~Ccomp

		if(env_temperature > (T0C + 50) || env_temperature < env_low_temp_resistance)
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
				if( !(COLD_RESISTANCE in mutations) )
					adjustBruteLoss( LOW_PRESSURE_DAMAGE )
					pressure_alert = -2
				else
					pressure_alert = -1

		return

	proc/handle_temperature_damage(body_part, exposed_temperature)
		if(status_flags & GODMODE) return
		var/discomfort = min( abs(exposed_temperature - bodytemperature)/100, 1)
		//adjustFireLoss(2.5*discomfort)

		if(exposed_temperature > bodytemperature)
			adjustFireLoss(20.0*discomfort)

		else
			adjustFireLoss(5.0*discomfort)

	proc/handle_chemicals_in_body()

		reagent_move_delay_modifier = 0
		reagent_shock_modifier = 0
		reagent_pain_modifier = 0

		if(reagents && reagents.reagent_list.len)
			reagents.metabolize(src)

		if (drowsyness)
			drowsyness--
			eye_blurry = max(2, eye_blurry)
			if (prob(5))
				sleeping += 1
				KnockOut(5)

		if(confused)
			confused = max(0, confused - 1)

		if(resting)
			dizziness = max(0, dizziness - 5)
		else
			dizziness = max(0, dizziness - 1)

		return //TODO: DEFERRED

	proc/handle_regular_status_updates()

		if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
			blinded = 1
			silent = 0
		else				//ALIVE. LIGHTS ARE ON
			updatehealth()
			if(health < config.health_threshold_dead || !has_brain())
				death()
				blinded = 1
				stat = DEAD
				silent = 0
				return 1

			//UNCONSCIOUS. NO-ONE IS HOME
			if( (getOxyLoss() > 25) || (config.health_threshold_crit > health) )
				if( health <= 20 && prob(1) )
					spawn(0)
						emote("gasp")
				if(!reagents.has_reagent("inaprovaline"))
					adjustOxyLoss(1)
				KnockOut(3)
			if(halloss > 100)
				src << "<span class='notice'>You're in too much pain to keep going...</span>"
				for(var/mob/O in oviewers(src, null))
					O.show_message("<B>[src]</B> slumps to the ground, too weak to continue fighting.", 1)
				KnockOut(10)
				setHalLoss(99)

			if(knocked_out)
				AdjustKnockedout(-1)
				blinded = 1
				stat = UNCONSCIOUS
				if(halloss > 0)
					adjustHalLoss(-3)
			else if(sleeping)
				handle_dreams()
				adjustHalLoss(-3)
				sleeping = max(sleeping-1, 0)
				blinded = 1
				stat = UNCONSCIOUS
				if( prob(10) && health && !hal_crit )
					spawn(0)
						emote("snore")
			else if(resting)
				if(halloss > 0)
					adjustHalLoss(-3)
			//CONSCIOUS
			else
				stat = CONSCIOUS
				if(halloss > 0)
					adjustHalLoss(-1)

			//Eyes
			if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
				blinded = 1
			else if(eye_blind)			//blindness, heals slowly over time
				eye_blind = max(eye_blind-1,0)
				blinded = 1
			else if(eye_blurry)			//blurry eyes heal slowly
				eye_blurry = max(eye_blurry-1, 0)

			//Ears
			if(sdisabilities & DEAF)		//disabled-deaf, doesn't get better on its own
				ear_deaf = max(ear_deaf, 1)
			else if(ear_deaf)			//deafness, heals slowly over time
				ear_deaf = max(ear_deaf-1, 0)
			else if(ear_damage < 25)	//ear damage heals slowly under this threshold. otherwise you'll need earmuffs
				ear_damage = max(ear_damage-0.05, 0)

			//Other
			handle_statuses()
		return 1


	proc/handle_regular_hud_updates()

		update_sight()

		if (hud_used)
			if(hud_used.healths)
				if (stat != DEAD)
					switch(health)
						if(100 to INFINITY)
							hud_used.healths.icon_state = "health0"
						if(80 to 100)
							hud_used.healths.icon_state = "health1"
						if(60 to 80)
							hud_used.healths.icon_state = "health2"
						if(40 to 60)
							hud_used.healths.icon_state = "health3"
						if(20 to 40)
							hud_used.healths.icon_state = "health4"
						if(0 to 20)
							hud_used.healths.icon_state = "health5"
						else
							hud_used.healths.icon_state = "health6"
				else
					hud_used.healths.icon_state = "health7"


			if(hud_used.pressure_icon)	hud_used.pressure_icon.icon_state = "pressure[pressure_alert]"

			if (hud_used.toxin_icon)	hud_used.toxin_icon.icon_state = "tox[phoron_alert ? 1 : 0]"
			if (hud_used.oxygen_icon)	hud_used.oxygen_icon.icon_state = "oxy[oxygen_alert ? 1 : 0]"
			if (hud_used.fire_icon)	hud_used.fire_icon.icon_state = "fire[fire_alert ? 2 : 0]"
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
			if(blinded)
				overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
			else
				clear_fullscreen("blind")

				if (disabilities & NEARSIGHTED)
					overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
				else
					clear_fullscreen("nearsighted")

				if(eye_blurry)
					overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
				else
					clear_fullscreen("blurry")
				if(druggy)
					overlay_fullscreen("high", /obj/screen/fullscreen/high)
				else
					clear_fullscreen("high")


			if(interactee)
				interactee.check_eye(src)
			else
				if(client && !client.adminobs)
					reset_view(null)

		return 1

	proc/handle_random_events()
		if (prob(1) && prob(2))
			spawn(0)
				emote("scratch")
				return

///FIRE CODE
	handle_fire()
		if(..())
			return
		adjustFireLoss(6)
		return
//END FIRE CODE