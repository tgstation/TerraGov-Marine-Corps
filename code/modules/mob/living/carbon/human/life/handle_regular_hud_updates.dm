//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_hud_updates()

	if(hud_updateflag) //Update our mob's hud overlays, AKA what others see floating above our head
		handle_hud_list()

	//Now handle what we see on our screen
	if(!client || isnull(client))
		return 0

	for(var/image/hud in client.images)
		if(copytext(hud.icon_state,1,4) == "hud") //Ugly, but icon comparison is worse, I believe
			client.images.Remove(hud)

	client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson)

	if(hud_used && hud_used.damageoverlay && hud_used.damageoverlay.overlays)
		hud_used.damageoverlay.overlays = null
		hud_used.damageoverlay.overlays = list()

	if(stat == UNCONSCIOUS)
		//Critical damage passage overlay
		if(health <= config.health_threshold_crit)
			var/image/I
			switch(health)
				if(-20 to -10)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage1")
				if(-30 to -20)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage2")
				if(-40 to -30)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage3")
				if(-50 to -40)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage4")
				if(-60 to -50)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage5")
				if(-70 to -60)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage6")
				if(-80 to -70)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage7")
				if(-90 to -80)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage8")
				if(-95 to -90)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage9")
				if(-INFINITY to -95)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "passage10")
			if(hud_used) hud_used.damageoverlay.overlays += I
	else
		//Oxygen damage overlay
		if(oxyloss)
			var/image/I
			switch(oxyloss)
				if(10 to 20)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay1")
				if(20 to 25)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay2")
				if(25 to 30)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay3")
				if(30 to 35)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay4")
				if(35 to 40)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay5")
				if(40 to 45)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay6")
				if(45 to INFINITY)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "oxydamageoverlay7")
			if(hud_used) hud_used.damageoverlay.overlays += I

		//Fire and Brute damage overlay (BSSR)
		var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
		damageoverlaytemp = 0 // We do this so we can detect if someone hits us or not.
		if(hurtdamage)
			var/image/I
			switch(hurtdamage)
				if(10 to 25)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay1")
				if(25 to 40)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay2")
				if(40 to 55)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay3")
				if(55 to 70)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay4")
				if(70 to 85)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay5")
				if(85 to INFINITY)
					I = image("icon" = 'icons/mob/screen1_full.dmi', "icon_state" = "brutedamageoverlay6")
			if(hud_used) hud_used.damageoverlay.overlays += I

	if(stat == DEAD)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		if(!druggy)
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if(hud_used && hud_used.healths) hud_used.healths.icon_state = "health7" //DEAD healthmeter

	else
		sight &= ~(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = species.darksight
		see_invisible = see_in_dark > 2 ? SEE_INVISIBLE_LEVEL_ONE : SEE_INVISIBLE_LIVING
		if(dna)
			switch(dna.mutantrace)
				if("slime")
					see_in_dark = 3
					see_invisible = SEE_INVISIBLE_LEVEL_ONE
				if("shadow")
					see_in_dark = 8
					see_invisible = SEE_INVISIBLE_LEVEL_ONE

		if(XRAY in mutations)
			sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
			see_in_dark = 8
			if(!druggy)
				see_invisible = SEE_INVISIBLE_LEVEL_TWO

		var/tmp/glasses_processed = 0
		if(glasses)
			glasses_processed = 1
			process_glasses(glasses)

		if(wear_ear)
			process_earpiece()

		if(!glasses_processed)
			see_invisible = SEE_INVISIBLE_LIVING

		if(hud_used && hud_used.healths)
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

		if(hud_used && hud_used.nutrition_icon)
			switch(nutrition)
				if(450 to INFINITY)				hud_used.nutrition_icon.icon_state = "nutrition0"
				if(350 to 450)					hud_used.nutrition_icon.icon_state = "nutrition1"
				if(250 to 350)					hud_used.nutrition_icon.icon_state = "nutrition2"
				if(150 to 250)					hud_used.nutrition_icon.icon_state = "nutrition3"
				else							hud_used.nutrition_icon.icon_state = "nutrition4"

		if(hud_used && hud_used.pressure_icon)
			hud_used.pressure_icon.icon_state = "pressure[pressure_alert]"

		if(hud_used && hud_used.toxin_icon)
			if(hal_screwyhud == 4 || phoron_alert)	hud_used.toxin_icon.icon_state = "tox1"
			else									hud_used.toxin_icon.icon_state = "tox0"
		if(hud_used && hud_used.oxygen_icon)
			if(hal_screwyhud == 3 || oxygen_alert)	hud_used.oxygen_icon.icon_state = "oxy1"
			else									hud_used.oxygen_icon.icon_state = "oxy0"
		if(hud_used && hud_used.fire_icon)
			if(fire_alert)							hud_used.fire_icon.icon_state = "fire[fire_alert]" //fire_alert is either 0 if no alert, 1 for cold and 2 for heat.
			else									hud_used.fire_icon.icon_state = "fire0"

		if(hud_used && hud_used.bodytemp_icon)
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
		if(hud_used && hud_used.blind_icon)
			if(blinded)		hud_used.blind_icon.plane = 0
			else			hud_used.blind_icon.plane = -80

		if(disabilities & NEARSIGHTED)	//This looks meh but saves a lot of memory by not requiring to add var/prescription to every /obj/item
			if(glasses)
				var/obj/item/clothing/glasses/G = glasses
				if(!G.prescription)
					client.screen += global_hud.vimpaired
			else
				client.screen += global_hud.vimpaired

		if(eye_blurry)			client.screen += global_hud.blurry
		if(druggy)				client.screen += global_hud.druggy

		var/masked = 0

		if(istype(head, /obj/item/clothing/head/welding) || istype(head, /obj/item/clothing/head/helmet/space/unathi))
			var/obj/item/clothing/head/welding/O = head
			if(!O.up && tinted_weldhelh)
				client.screen += global_hud.darkMask
				masked = 1

		if(!masked && istype(glasses, /obj/item/clothing/glasses/welding))
			var/obj/item/clothing/glasses/welding/O = glasses
			if(!O.up && tinted_weldhelh)
				client.screen += global_hud.darkMask

		if(istype(wear_mask, /obj/item/clothing/mask/facehugger) && hud_used)
			hud_used.blind_icon.layer = 18

		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
		else
			var/isRemoteObserve = 0
			if((mRemote in mutations) && remoteview_target)
				if(remoteview_target.stat == CONSCIOUS)
					isRemoteObserve = 1
			if(!isRemoteObserve && client && !client.adminobs)
				remoteview_target = null
				reset_view(null)
	return 1
