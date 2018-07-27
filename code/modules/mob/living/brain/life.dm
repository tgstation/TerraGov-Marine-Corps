/mob/living/brain/Life()
	set invisibility = 0
	set background = 1
	..()

	if(stat != DEAD)
		//Mutations and radiation
		handle_mutations_and_radiation()

		//Chemicals in the body
		handle_chemicals_in_body()

	//Apparently, the person who wrote this code designed it so that
	//blinded get reset each cycle and then get activated later in the
	//code. Very ugly. I dont care. Moving this stuff here so its easy
	//to find it.
	blinded = null

	//Handle temperature/pressure differences between body and environment
	handle_environment()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()



/mob/living/brain/proc/handle_mutations_and_radiation()

	if (radiation)
		if (radiation > 100)
			radiation = 100
			if(!container)//If it's not in an MMI
				src << "\red You feel weak."
			else//Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
				src << "\red STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED."

		switch(radiation)
			if(1 to 49)
				radiation--
				if(prob(25))
					adjustToxLoss(1)
					updatehealth()

			if(50 to 74)
				radiation -= 2
				adjustToxLoss(1)
				if(prob(5))
					radiation -= 5
					if(!container)
						src << "\red You feel weak."
					else
						src << "\red STATUS: DANGEROUS LEVELS OF RADIATION DETECTED."
				updatehealth()

			if(75 to 100)
				radiation -= 3
				adjustToxLoss(3)
				updatehealth()


/mob/living/brain/proc/handle_environment()
	if(!loc)
		return

	var/env_temperature = loc.return_temperature()

	if((env_temperature > (T0C + 50)) || (env_temperature < (T0C + 10)))
		handle_temperature_damage(HEAD, env_temperature)



/mob/living/brain/proc/handle_temperature_damage(body_part, exposed_temperature)
	if(status_flags & GODMODE) return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)/100, 1.0)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)/100, 1.0)
		adjustFireLoss(5.0*discomfort)



/mob/living/brain/proc/handle_chemicals_in_body()

	reagent_move_delay_modifier = 0
	reagent_shock_modifier = 0
	reagent_pain_modifier = 0

	if(reagents) reagents.metabolize(src)

	confused = max(0, confused - 1)
	// decrement dizziness counter, clamped to 0
	if(resting)
		dizziness = max(0, dizziness - 5)
	else
		dizziness = max(0, dizziness - 1)

	updatehealth()

	return //TODO: DEFERRED


/mob/living/brain/proc/handle_regular_status_updates()	//TODO: comment out the unused bits >_>
	updatehealth()

	if(stat == DEAD)	//DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		if( !container && (health < config.health_threshold_dead || ((world.time - timeofhostdeath) > config.revival_brain_life)) )
			death()
			blinded = 1
			silent = 0
			return 1

		//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
		if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
			if(!(container && istype(container, /obj/item/device/mmi)))
				emp_damage = 0
			else
				emp_damage = round(emp_damage,1)//Let's have some nice numbers to work with
			switch(emp_damage)
				if(31 to INFINITY)
					emp_damage = 30//Let's not overdo it
				if(21 to 30)//High level of EMP damage, unable to see, hear, or speak
					eye_blind = 1
					blinded = 1
					ear_deaf = 1
					silent = 1
					if(!alert)//Sounds an alarm, but only once per 'level'
						emote("alarm")
						src << "\red Major electrical distruption detected: System rebooting."
						alert = 1
					if(prob(75))
						emp_damage -= 1
				if(20)
					alert = 0
					blinded = 0
					eye_blind = 0
					ear_deaf = 0
					silent = 0
					emp_damage -= 1
				if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
					eye_blurry = 1
					ear_damage = 1
					if(!alert)
						emote("alert")
						src << "\red Primary systems are now online."
						alert = 1
					if(prob(50))
						emp_damage -= 1
				if(10)
					alert = 0
					eye_blurry = 0
					ear_damage = 0
					emp_damage -= 1
				if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
					if(!alert)
						emote("notice")
						src << "\red System reboot nearly complete."
						alert = 1
					if(prob(25))
						emp_damage -= 1
				if(1)
					alert = 0
					src << "\red All systems restored."
					emp_damage -= 1

		//Other
		handle_statuses()
	return 1


/mob/living/brain/proc/handle_regular_hud_updates()

	update_sight()

	if (hud_used && hud_used.healths)
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


		if (interactee)
			interactee.check_eye(src)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1


/*/mob/living/brain/emp_act(severity)
	if(!(container && istype(container, /obj/item/device/mmi)))
		return
	else
		switch(severity)
			if(1)
				emp_damage += rand(20,30)
			if(2)
				emp_damage += rand(10,20)
			if(3)
				emp_damage += rand(0,10)
	..()*/