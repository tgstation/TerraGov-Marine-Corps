//Refer to life.dm for caller

/mob/living/carbon/human/handle_regular_hud_updates()
	. = ..()
	if(!.)
		return FALSE

	update_sight()


	if(HAS_TRAIT(src, TRAIT_PAIN_IMMUNE)) //We can't tell how hurt we are if we can't feel pain
		clear_fullscreen("brute")
		clear_fullscreen("oxy")
		clear_fullscreen("crit")

		if(!hud_used)
			return
		if(hud_used.nutrition_icon)
			hud_used.nutrition_icon.icon_state = "nutrition1"
		if(hud_used.toxin_icon)
			hud_used.toxin_icon.icon_state = "tox0"
		if(hud_used.oxygen_icon)
			hud_used.oxygen_icon.icon_state = "oxy0"
		if(hud_used.fire_icon)
			hud_used.fire_icon.icon_state = "fire0"
		if(hud_used.bodytemp_icon)
			hud_used.bodytemp_icon.icon_state = "temp0"
		return

	if(stat == UNCONSCIOUS && health <= get_crit_threshold())
		var/severity = 0
		switch(health)
			if(-20 to -10)
				severity = 1
			if(-30 to -20)
				severity = 2
			if(-40 to -30)
				severity = 3
			if(-50 to -40)
				severity = 4
			if(-60 to -50)
				severity = 5
			if(-70 to -60)
				severity = 6
			if(-80 to -70)
				severity = 7
			if(-90 to -80)
				severity = 8
			if(-95 to -90)
				severity = 9
			if(-INFINITY to -95)
				severity = 10
		overlay_fullscreen("crit", /atom/movable/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		if(oxyloss)
			var/severity = 0
			switch(oxyloss)
				if(10 to 20)
					severity = 1
				if(20 to 25)
					severity = 2
				if(25 to 30)
					severity = 3
				if(30 to 35)
					severity = 4
				if(35 to 40)
					severity = 5
				if(40 to 45)
					severity = 6
				if(45 to INFINITY)
					severity = 7
			overlay_fullscreen("oxy", /atom/movable/screen/fullscreen/oxy, severity)
		else
			clear_fullscreen("oxy")


		//Fire and Brute damage overlay
		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/severity = 0
			switch(hurtdamage)
				if(5 to 15)
					severity = 1
				if(15 to 30)
					severity = 2
				if(30 to 45)
					severity = 3
				if(45 to 70)
					severity = 4
				if(70 to 85)
					severity = 5
				if(85 to INFINITY)
					severity = 6
			overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
		else
			clear_fullscreen("brute")

	interactee?.check_eye(src)

	if(!hud_used)
		return

	if(hud_used.nutrition_icon)
		switch(nutrition)
			if(NUTRITION_OVERFED to INFINITY)
				hud_used.nutrition_icon.icon_state = "nutrition0"
			if(NUTRITION_HUNGRY to NUTRITION_OVERFED) //Not-hungry.
				hud_used.nutrition_icon.icon_state = "nutrition1" //Empty icon.
			if(NUTRITION_STARVING to NUTRITION_HUNGRY)
				hud_used.nutrition_icon.icon_state = "nutrition3"
			else
				hud_used.nutrition_icon.icon_state = "nutrition4"

	if(hud_used.pressure_icon)
		hud_used.pressure_icon.icon_state = "pressure[pressure_alert]"

	if(hud_used.toxin_icon)
		if(hal_screwyhud == 4)
			hud_used.toxin_icon.icon_state = "tox1"
		else
			hud_used.toxin_icon.icon_state = "tox0"
	if(hud_used.oxygen_icon)
		if(hal_screwyhud == 3 || oxygen_alert)
			hud_used.oxygen_icon.icon_state = "oxy1"
		else
			hud_used.oxygen_icon.icon_state = "oxy0"
	if(hud_used.fire_icon)
		if(fire_alert)
			hud_used.fire_icon.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
		else
			hud_used.fire_icon.icon_state = "fire0"

	if(hud_used.bodytemp_icon)
		if(!species)
			switch(bodytemperature) //310.055 optimal body temp
				if(370 to INFINITY)
					hud_used.bodytemp_icon.icon_state = "temp4"
				if(350 to 370)
					hud_used.bodytemp_icon.icon_state = "temp3"
				if(335 to 350)
					hud_used.bodytemp_icon.icon_state = "temp2"
				if(320 to 335)
					hud_used.bodytemp_icon.icon_state = "temp1"
				if(300 to 320)
					hud_used.bodytemp_icon.icon_state = "temp0"
				if(295 to 300)
					hud_used.bodytemp_icon.icon_state = "temp-1"
				if(280 to 295)
					hud_used.bodytemp_icon.icon_state = "temp-2"
				if(260 to 280)
					hud_used.bodytemp_icon.icon_state = "temp-3"
				else
					hud_used.bodytemp_icon.icon_state = "temp-4"
		else
			var/temp_step
			if(bodytemperature >= species.body_temperature)
				temp_step = (species.heat_level_1 - species.body_temperature) / 4

				if(bodytemperature >= species.heat_level_1)
					hud_used.bodytemp_icon.icon_state = "temp4"
				else if(bodytemperature >= species.body_temperature + temp_step * 3)
					hud_used.bodytemp_icon.icon_state = "temp3"
				else if(bodytemperature >= species.body_temperature + temp_step * 2)
					hud_used.bodytemp_icon.icon_state = "temp2"
				else if(bodytemperature >= species.body_temperature + temp_step * 1)
					hud_used.bodytemp_icon.icon_state = "temp1"
				else
					hud_used.bodytemp_icon.icon_state = "temp0"

			else if(bodytemperature < species.body_temperature)
				temp_step = (species.body_temperature - species.cold_level_1)/4

				if(bodytemperature <= species.cold_level_1)
					hud_used.bodytemp_icon.icon_state = "temp-4"
				else if(bodytemperature <= species.body_temperature - temp_step * 3)
					hud_used.bodytemp_icon.icon_state = "temp-3"
				else if(bodytemperature <= species.body_temperature - temp_step * 2)
					hud_used.bodytemp_icon.icon_state = "temp-2"
				else if(bodytemperature <= species.body_temperature - temp_step * 1)
					hud_used.bodytemp_icon.icon_state = "temp-1"
				else
					hud_used.bodytemp_icon.icon_state = "temp0"


/mob/living/carbon/human/handle_healths_hud_updates()
	if(!hud_used?.healths)
		return

	if(stat == DEAD)
		hud_used.healths.icon_state = "health7"
		return

	if(HAS_TRAIT(src, TRAIT_PAIN_IMMUNE)) //We can't tell how hurt we are if we can't feel pain
		hud_used.healths.icon_state = "health0"
		return

	if(analgesic)
		hud_used.healths.icon_state = "health_numb"
		return

	switch(hal_screwyhud)
		if(1)
			hud_used.healths.icon_state = "health6"
			return
		if(2)
			hud_used.healths.icon_state = "health7"
			return

	if(health < get_crit_threshold())
		hud_used.healths.icon_state = "health6"
		return

	var/perceived_health = health / maxHealth * 100
	if(!(species.species_flags & NO_PAIN))
		perceived_health -= traumatic_shock
	if(!(species.species_flags & NO_STAMINA) && staminaloss > 0)
		perceived_health -= staminaloss

	switch(perceived_health)
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
		else
			hud_used.healths.icon_state = "health5"
