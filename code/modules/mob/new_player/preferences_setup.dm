datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
	proc/randomize_appearance_for(var/mob/living/carbon/human/H)
		if(H)
			if(H.gender == MALE)
				gender = MALE
			else
				gender = FEMALE
		s_tone = random_skin_tone()
		h_style = random_hair_style(gender, species)
		f_style = random_facial_hair_style(gender, species)
		randomize_hair_color("hair")
		randomize_hair_color("facial")
		randomize_eyes_color()
		randomize_skin_color()
		underwear = rand(1,underwear_m.len)
		undershirt = rand(1,undershirt_t.len)
		backbag = 2
		age = rand(AGE_MIN,AGE_MAX)
		if(H)
			copy_to(H,1)


	proc/randomize_hair_color(var/target = "hair")
		if(prob (75) && target == "facial") // Chance to inherit hair color
			r_facial = r_hair
			g_facial = g_hair
			b_facial = b_hair
			return

		var/red
		var/green
		var/blue

		var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
		switch(col)
			if("blonde")
				red = 255
				green = 255
				blue = 0
			if("black")
				red = 0
				green = 0
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 51
			if("copper")
				red = 255
				green = 153
				blue = 0
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("wheat")
				red = 255
				green = 255
				blue = 153
			if("old")
				red = rand (100, 255)
				green = red
				blue = red
			if("punk")
				red = rand (0, 255)
				green = rand (0, 255)
				blue = rand (0, 255)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		switch(target)
			if("hair")
				r_hair = red
				g_hair = green
				b_hair = blue
			if("facial")
				r_facial = red
				g_facial = green
				b_facial = blue

	proc/randomize_eyes_color()
		var/red
		var/green
		var/blue

		var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
		switch(col)
			if("black")
				red = 0
				green = 0
				blue = 0
			if("grey")
				red = rand (100, 200)
				green = red
				blue = red
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 0
			if("blue")
				red = 51
				green = 102
				blue = 204
			if("lightblue")
				red = 102
				green = 204
				blue = 255
			if("green")
				red = 0
				green = 102
				blue = 0
			if("albino")
				red = rand (200, 255)
				green = rand (0, 150)
				blue = rand (0, 150)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		r_eyes = red
		g_eyes = green
		b_eyes = blue

	proc/randomize_skin_color()
		var/red
		var/green
		var/blue

		var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
		switch(col)
			if("black")
				red = 0
				green = 0
				blue = 0
			if("grey")
				red = rand (100, 200)
				green = red
				blue = red
			if("brown")
				red = 102
				green = 51
				blue = 0
			if("chestnut")
				red = 153
				green = 102
				blue = 0
			if("blue")
				red = 51
				green = 102
				blue = 204
			if("lightblue")
				red = 102
				green = 204
				blue = 255
			if("green")
				red = 0
				green = 102
				blue = 0
			if("albino")
				red = rand (200, 255)
				green = rand (0, 150)
				blue = rand (0, 150)

		red = max(min(red + rand (-25, 25), 255), 0)
		green = max(min(green + rand (-25, 25), 255), 0)
		blue = max(min(blue + rand (-25, 25), 255), 0)

		r_skin = red
		g_skin = green
		b_skin = blue


	proc/update_preview_icon()		//seriously. This is horrendous.
		if(updating_icon)
			return
		updating_icon = 1
		cdel(preview_icon_front)
		cdel(preview_icon_side)
		cdel(preview_icon)

		var/g = "m"
		if(gender == FEMALE)	g = "f"

		var/icon/icobase
		var/datum/species/current_species = all_species[species]

		if(current_species)
			icobase = current_species.icobase
		else
			icobase = 'icons/mob/human_races/r_human.dmi'

		preview_icon = new /icon(icobase, "torso_[g]")
		preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
		preview_icon.Blend(new /icon(icobase, "head_[g]"), ICON_OVERLAY)

		for(var/name in list("r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","l_arm","l_hand"))
			if(organ_data[name] == "amputated") continue

			var/icon/temp = new /icon(icobase, "[name]")
			if(organ_data[name] == "cyborg")
				temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))

			preview_icon.Blend(temp, ICON_OVERLAY)

		//Tail
		if(current_species && (current_species.tail))
			var/icon/temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[current_species.tail]_s")
			preview_icon.Blend(temp, ICON_OVERLAY)

		// Skin color
		if(current_species && (current_species.flags & HAS_SKIN_COLOR))
			preview_icon.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)

		// Skin tone
		if(current_species && (current_species.flags & HAS_SKIN_TONE))
			if (s_tone >= 0)
				preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			else
				preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

		var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			eyes_s.Blend(hair_s, ICON_OVERLAY)

		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			eyes_s.Blend(facial_s, ICON_OVERLAY)

		var/icon/underwear_s = null
		if(underwear > 0 && underwear < 7 && current_species.flags & HAS_UNDERWEAR)
			underwear_s = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "underwear[underwear]_[g]_s")

		var/icon/undershirt_s = null
		if(undershirt > 0 && undershirt < 5 && current_species.flags & HAS_UNDERWEAR)
			undershirt_s = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "undershirt[undershirt]_s")

		var/icon/clothes_s = null
		if(job_marines_low & ROLE_MARINE_STANDARD)
			clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "2"), ICON_OVERLAY)
			clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helmet"), ICON_OVERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)

		else if(job_marines_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
			switch(job_marines_high)
				if(ROLE_MARINE_STANDARD)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "2"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
				if(ROLE_MARINE_ENGINEER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_engineer_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "6"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helmett"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "meson"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinepackt"), ICON_OVERLAY)
				if(ROLE_MARINE_LEADER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "7"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helml"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
				if(ROLE_MARINE_MEDIC)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_medic_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "1"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helmetm"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinepackm"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "medicbag"), ICON_OVERLAY)
				if(ROLE_MARINE_SPECIALIST)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "2"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "spec"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinepack"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
				if(ROLE_MARINE_SMARTGUN)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "lamp-off"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "8"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "m56_goggles"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helmet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "powerpack"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
		else if(job_command_high)
			switch(job_command_high)
				if(ROLE_COMMANDING_OFFICER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "CO_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "egloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head_0.dmi', "centcomcaptain"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m4a3_holster_g"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_BRIDGE_OFFICER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "BO_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "rocap"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m4a3_holster_g"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_EXECUTIVE_OFFICER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "XO_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "cap"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m44_holster_g"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_PILOT_OFFICER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "pilot_flightsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "pilot"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/Marine/marine_armor.dmi', "helmetp"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m39_holster_full"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_CORPORATE_LIAISON)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "liaison_regular_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_SYNTHETIC)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "E_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_MILITARY_POLICE)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "MP_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/marine/marine_armor.dmi', "mp"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/marine/marine_armor.dmi', "beretred"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sunhud"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "security"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_CHIEF_MP)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "WO_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/marine/marine_armor.dmi', "warrant_officer"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/marine/marine_armor.dmi', "beretwo"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sunhud"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "security"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)

		else if(job_engi_high)
			switch(job_engi_high)
				if(ROLE_CHIEF_ENGINEER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "EC_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatt"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_MAINTENANCE_TECH)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "E_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatt"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_REQUISITION_OFFICER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "RO_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/marine/marine_armor.dmi', "cargocap"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m44_holster_g"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_REQUISITION_TECH)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "cargo_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/marine/marine_armor.dmi', "band2"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatt"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
		else if(job_medsci_high)
			switch(job_medsci_high)
				if(ROLE_CHIEF_MEDICAL_OFFICER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "cmo_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoatg"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatm"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "electronic"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_CIVILIAN_DOCTOR)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "scrubsgreen_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoat_open"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head_0.dmi', "surgcap_green"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatm"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "electronic"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)
				if(ROLE_CIVILIAN_RESEARCHER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "research_jumpsuit_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoat_open"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatm"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "electronic"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mob.dmi', "id"), ICON_OVERLAY)

				/*if(ATMOSTECH)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "atmos_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
					if(prob(1))
						clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "firesuit"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

				if(AI)//Gives AI and borgs assistant-wear, so they can still customize their character
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "grey_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "straight_jacket"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "cardborg_h"), ICON_OVERLAY)
					if(backbag == 2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					else if(backbag == 3 || backbag == 4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				if(CYBORG)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "grey_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "cardborg"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "cardborg_h"), ICON_OVERLAY)
					if(backbag == 2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					else if(backbag == 3 || backbag == 4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

				// Colonial Marines
				if(MPOLICE)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "sec_corporate_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "baton"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "riot"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

				if(EXECUTIVE || BRIDGE)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "hop_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "hosberet"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "security"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "armor"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

				if(COMMANDER)
					clothes_s = new /icon('icons/mob/uniform_0.dmi', "mcomm_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/belt.dmi', "security"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/head_0.dmi', "centcomcaptain"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "armor"), ICON_OVERLAY)
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "mcommpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

 				if(ROLE_CIVILIAN_DOCTOR)
 					clothes_s = new /icon('icons/mob/uniform_0.dmi', "medical_s")
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/items_lefthand.dmi', "firstaid"), ICON_UNDERLAY)
					clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoat_open"), ICON_OVERLAY)
					switch(backbag)
						if(2)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
						if(3)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
						if(4)
							clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				*/

		if(disabilities & NEARSIGHTED)
			preview_icon.Blend(new /icon('icons/mob/eyes.dmi', "mBCG"), ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)
		if(underwear_s)
			preview_icon.Blend(underwear_s, ICON_OVERLAY)
		if(undershirt_s)
			preview_icon.Blend(undershirt_s, ICON_OVERLAY)
		if(clothes_s)
			preview_icon.Blend(clothes_s, ICON_OVERLAY)
		preview_icon_front = new(preview_icon, dir = SOUTH)
		preview_icon_side = new(preview_icon, dir = WEST)

		cdel(eyes_s)
		cdel(underwear_s)
		cdel(undershirt_s)
		cdel(clothes_s)
		updating_icon = 0
