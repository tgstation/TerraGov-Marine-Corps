/mob/living/brain/Life(seconds_per_tick, times_fired)
	set invisibility = 0
	set background = 1
	..()

	//Handle temperature/pressure differences between body and environment
	handle_environment()

/mob/living/brain/blur_eyes()
	return

/mob/living/brain/adjust_blurriness()
	return

/mob/living/brain/set_blurriness()
	return

/mob/living/brain/proc/handle_environment()
	if(!loc)
		return

	var/env_temperature = loc.return_temperature()

	if((env_temperature > (T0C + 50)) || (env_temperature < (T0C + 10)))
		handle_temperature_damage(HEAD, env_temperature)



/mob/living/brain/proc/handle_temperature_damage(body_part, exposed_temperature)
	if(status_flags & GODMODE)
		return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)/100, 1.0)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)/100, 1.0)
		adjustFireLoss(5.0*discomfort)



/mob/living/brain/handle_organs()
	. = ..()

	reagents?.metabolize(src, can_overdose = TRUE)

/mob/living/brain/update_stat()
	.=..()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(!container && (health < get_death_threshold() || ((world.time - timeofhostdeath) > CONFIG_GET(number/revival_brain_life))) )
			death()
			blind_eyes(1)
			return 1

		//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
		if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
			if(!(container && istype(container, /obj/item/mmi)))
				emp_damage = 0
			else
				emp_damage = round(emp_damage,1)//Let's have some nice numbers to work with
			switch(emp_damage)
				if(31 to INFINITY)
					emp_damage = 30//Let's not overdo it
				if(21 to 30)//High level of EMP damage, unable to see, hear, or speak
					set_blindness(2)
					set_ear_damage(deaf = 1)
					if(!alert)//Sounds an alarm, but only once per 'level'
						emote("alarm")
						to_chat(src, span_warning("Major electrical distruption detected: System rebooting."))
						alert = 1
					if(prob(75))
						emp_damage -= 1
				if(20)
					alert = 0
					adjust_blindness(-1)
					set_ear_damage(deaf = 0)
					emp_damage -= 1
				if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
					blur_eyes(1)
					ear_damage = 1
					if(!alert)
						emote("alert")
						to_chat(src, span_warning("Primary systems are now online."))
						alert = 1
					if(prob(50))
						emp_damage -= 1
				if(10)
					alert = 0
					set_blurriness(0)
					ear_damage = 0
					emp_damage -= 1
				if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
					if(!alert)
						emote("notice")
						to_chat(src, span_warning("System reboot nearly complete."))
						alert = 1
					if(prob(25))
						emp_damage -= 1
				if(1)
					alert = 0
					to_chat(src, span_warning("All systems restored."))
					emp_damage -= 1

	return 1


/mob/living/brain/handle_regular_hud_updates()
	. = ..()

	update_sight()

	if (hud_used?.healths)
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

		interactee?.check_eye(src)

	return 1
