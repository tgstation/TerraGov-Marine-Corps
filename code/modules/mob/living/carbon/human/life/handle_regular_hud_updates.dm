//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_hud_updates()

	//Now handle what we see on our screen
	if(!client || isnull(client))
		return 0

	if(stat != DEAD) //the dead get zero fullscreens

		update_sight()

		if(stat == UNCONSCIOUS && health <= config.health_threshold_crit)
			var/severity = 0
			switch(health)
				if(-20 to -10) severity = 1
				if(-30 to -20) severity = 2
				if(-40 to -30) severity = 3
				if(-50 to -40) severity = 4
				if(-60 to -50) severity = 5
				if(-70 to -60) severity = 6
				if(-80 to -70) severity = 7
				if(-90 to -80) severity = 8
				if(-95 to -90) severity = 9
				if(-INFINITY to -95) severity = 10
			overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
		else
			clear_fullscreen("crit")
			if(oxyloss)
				var/severity = 0
				switch(oxyloss)
					if(10 to 20) severity = 1
					if(20 to 25) severity = 2
					if(25 to 30) severity = 3
					if(30 to 35) severity = 4
					if(35 to 40) severity = 5
					if(40 to 45) severity = 6
					if(45 to INFINITY) severity = 7
				overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
			else
				clear_fullscreen("oxy")


			//Fire and Brute damage overlay (BSSR)
			var/hurtdamage = src.getBruteLoss() + src.getFireLoss() + damageoverlaytemp
			damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
			if(hurtdamage)
				var/severity = 0
				switch(hurtdamage)
					if(5 to 15) severity = 1
					if(15 to 30) severity = 2
					if(30 to 45) severity = 3
					if(45 to 70) severity = 4
					if(70 to 85) severity = 5
					if(85 to INFINITY) severity = 6
				overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
			else
				clear_fullscreen("brute")


		if(blinded)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")

		if (disabilities & NEARSIGHTED)
			if(glasses)
				var/obj/item/clothing/glasses/G = glasses
				if(!G.prescription)
					overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
				else
					clear_fullscreen("nearsighted")
			else
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


		if(hud_used)
			if(hud_used.locate_leader && hud_used.locate_leader.alpha && prob(25)) //not invisible, 25% to not call it all the time
				locate_squad_leader()

			if(hud_used.healths)
				if(analgesic)
					hud_used.healths.icon_state = "health_health_numb"
				else
					switch(hal_screwyhud)
						if(1)	hud_used.healths.icon_state = "health6"
						if(2)	hud_used.healths.icon_state = "health7"
						else
							var/perceived_health = health - traumatic_shock
							if(species && species.flags & NO_PAIN)
								perceived_health = health

							switch(perceived_health)
								if(100 to INFINITY)		hud_used.healths.icon_state = "health0"
								if(80 to 100)			hud_used.healths.icon_state = "health1"
								if(60 to 80)			hud_used.healths.icon_state = "health2"
								if(40 to 60)			hud_used.healths.icon_state = "health3"
								if(20 to 40)			hud_used.healths.icon_state = "health4"
								if(0 to 20)				hud_used.healths.icon_state = "health5"
								else					hud_used.healths.icon_state = "health6"

			if(hud_used.nutrition_icon)
				switch(nutrition)
					if(450 to INFINITY)				hud_used.nutrition_icon.icon_state = "nutrition0"
					if(350 to 450)					hud_used.nutrition_icon.icon_state = "nutrition1"
					if(250 to 350)					hud_used.nutrition_icon.icon_state = "nutrition2"
					if(150 to 250)					hud_used.nutrition_icon.icon_state = "nutrition3"
					else							hud_used.nutrition_icon.icon_state = "nutrition4"

			if(hud_used.pressure_icon)
				hud_used.pressure_icon.icon_state = "pressure[pressure_alert]"

			if(hud_used.toxin_icon)
				if(hal_screwyhud == 4 || phoron_alert)	hud_used.toxin_icon.icon_state = "tox1"
				else									hud_used.toxin_icon.icon_state = "tox0"
			if(hud_used.oxygen_icon)
				if(hal_screwyhud == 3 || oxygen_alert)	hud_used.oxygen_icon.icon_state = "oxy1"
				else									hud_used.oxygen_icon.icon_state = "oxy0"
			if(hud_used.fire_icon)
				if(fire_alert)							hud_used.fire_icon.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
				else									hud_used.fire_icon.icon_state = "fire0"

			if(hud_used.bodytemp_icon)
				if (!species)
					switch(bodytemperature) //310.055 optimal body temp
						if(370 to INFINITY)		hud_used.bodytemp_icon.icon_state = "temp4"
						if(350 to 370)			hud_used.bodytemp_icon.icon_state = "temp3"
						if(335 to 350)			hud_used.bodytemp_icon.icon_state = "temp2"
						if(320 to 335)			hud_used.bodytemp_icon.icon_state = "temp1"
						if(300 to 320)			hud_used.bodytemp_icon.icon_state = "temp0"
						if(295 to 300)			hud_used.bodytemp_icon.icon_state = "temp-1"
						if(280 to 295)			hud_used.bodytemp_icon.icon_state = "temp-2"
						if(260 to 280)			hud_used.bodytemp_icon.icon_state = "temp-3"
						else					hud_used.bodytemp_icon.icon_state = "temp-4"
				else
					var/temp_step
					if(bodytemperature >= species.body_temperature)
						temp_step = (species.heat_level_1 - species.body_temperature)/4

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


		if(interactee)
			interactee.check_eye(src)
		else
			var/isRemoteObserve = 0
			if((mRemote in mutations) && remoteview_target)
				if(remoteview_target.stat == CONSCIOUS)
					isRemoteObserve = 1
			if(!isRemoteObserve && client && !client.adminobs)
				remoteview_target = null
				reset_view(null)
	return 1
