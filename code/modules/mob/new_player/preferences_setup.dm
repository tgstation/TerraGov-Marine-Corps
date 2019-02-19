/datum/preferences/proc/randomize_appearance_for(var/mob/living/carbon/human/H)
	if(H)
		if(H.gender == MALE)
			gender = MALE
		else
			gender = FEMALE

	ethnicity = random_ethnicity()
	body_type = random_body_type()

	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)
	randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_eyes_color()
	randomize_species_specific()
	underwear = rand(1, GLOB.underwear_m.len)
	undershirt = rand(1, GLOB.undershirt_t.len)
	backbag = 2
	age = rand(AGE_MIN,AGE_MAX)
	if(H)
		copy_to(H, TRUE)


/datum/preferences/proc/randomize_hair_color(target = "hair")
	if(prob (75) && target == "facial")
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/red
	var/green
	var/blue

	switch(pick(15;"black", 15;"grey", 15;"brown", 15;"lightbrown", 5;"white", 15;"blonde", 10;"red"))
		if("black")
			red = 10
			green = 10
			blue = 10
		if("grey")
			red = 50
			green = 50
			blue = 50
		if("brown")
			red = 70
			green = 35
			blue = 0
		if("lightbrown")
			red = 100
			green = 50
			blue = 0
		if("white")
			red = 235
			green = 235
			blue = 235
		if("blonde")
			red = 240
			green = 240
			blue = 0
		if("red")
			red = 128
			green = 0
			blue = 0

	red = CLAMP(red + rand(-25, 25), 0, 255)
	green = CLAMP(green + rand(-25, 25), 0, 255)
	blue = CLAMP(blue + rand(-25, 25), 0, 255)

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	switch(pick(15;"black", 15;"green", 15;"brown", 15;"blue", 15;"lightblue", 5;"red"))
		if("black")
			red = 10
			green = 10
			blue = 10
		if("green")
			red = 200
			green = 0
			blue = 0
		if("brown")
			red = 100
			green = 50
			blue = 0
		if("blue")
			red = 0
			green = 0
			blue = 200
		if("lightblue")
			red = 0
			green = 150
			blue = 255
		if("red")
			red = 220
			green = 0
			blue = 0

	red = CLAMP(red + rand(-25, 25), 0, 255)
	green = CLAMP(green + rand(-25, 25), 0, 255)
	blue = CLAMP(blue + rand(-25, 25), 0, 255)

	r_eyes = red
	g_eyes = green
	b_eyes = blue


/datum/preferences/proc/update_preview_icon()
	if(updating_icon)
		return
	updating_icon = TRUE
	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)

	var/g = "m"
	if(gender == FEMALE)
		g = "f"

	var/icon/icobase
	var/datum/species/current_species = GLOB.all_species[species]

	if(current_species)
		icobase = current_species.icobase
	else
		icobase = 'icons/mob/human_races/r_human.dmi'

	var/datum/ethnicity/E = GLOB.ethnicities_list[ethnicity]
	var/datum/body_type/B = GLOB.body_types_list[body_type]

	var/e_icon
	var/b_icon

	if(!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	if(!B)
		b_icon = "mesomorphic"
	else
		b_icon = B.icon_name

	preview_icon = new /icon(icobase, get_limb_icon_name(current_species, b_icon, gender, "torso", e_icon))
	preview_icon.Blend(new /icon(icobase, get_limb_icon_name(current_species, b_icon, gender, "groin", e_icon)), ICON_OVERLAY)
	preview_icon.Blend(new /icon(icobase, get_limb_icon_name(current_species, b_icon, gender, "head", e_icon)), ICON_OVERLAY)

	for(var/name in list("r_arm","r_hand","r_leg","r_foot","l_leg","l_foot","l_arm","l_hand"))
		var/icon/temp = new /icon(icobase, get_limb_icon_name(current_species, b_icon, gender, "[name]", e_icon))
		if(organ_data[name] == "cyborg")
			temp.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))

		preview_icon.Blend(temp, ICON_OVERLAY)

	//Tail
	if(current_species && (current_species.tail))
		var/icon/temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[current_species.tail]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)

	if(current_species && (current_species.name == "Moth"))
		var/datum/sprite_accessory/moth_wings/wings = GLOB.moth_wings_list[moth_wings]
		var/icon/behind = new/icon("icon" = wings.icon, "icon_state" = "m_moth_wings_[wings.icon_state]_BEHIND")
		var/icon/front = new/icon("icon" = wings.icon, "icon_state" = "m_moth_wings_[wings.icon_state]_FRONT")
		preview_icon.Blend(behind, ICON_OVERLAY)
		preview_icon.Blend(front, ICON_OVERLAY)

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	if(!(current_species.flags & HAS_NO_HAIR))
		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_list[h_style]
		if(hair_style)
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
			eyes_s.Blend(hair_s, ICON_OVERLAY)

		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
		if(facial_hair_style)
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
			eyes_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/underwear_s = null
	if(underwear > 0 && underwear < 5 && current_species.flags & HAS_UNDERWEAR)
		underwear_s = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "cryo[underwear]_[g]_s")

	var/icon/undershirt_s = null
	if(undershirt > 0 && undershirt < 5 && current_species.flags & HAS_UNDERWEAR)
		undershirt_s = new/icon("icon" = 'icons/mob/human.dmi', "icon_state" = "cryoshirt[undershirt]_s")

	var/icon/clothes_s = null
	if(job_marines_low & SQUAD_MARINE)
		clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit")
		clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
		clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
		clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "2"), ICON_OVERLAY)
		clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmet"), ICON_OVERLAY)
		clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)

	else if(job_marines_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
		switch(job_marines_high)
			if(SQUAD_MARINE)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "2"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
			if(SQUAD_ENGINEER)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_engineer")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "6"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "meson"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinepackt"), ICON_OVERLAY)
			if(SQUAD_LEADER)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "7"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
			if(SQUAD_MEDIC)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_medic")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "1"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinepackm"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "medicbag"), ICON_OVERLAY)
			if(SQUAD_SPECIALIST)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "2"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "spec"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinepack"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
			if(SQUAD_SMARTGUNNER)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "lamp-off"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "8"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "m56_goggles"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "powerpack"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "marinebelt"), ICON_OVERLAY)
	else if(job_command_high)
		switch(job_command_high)
			if(SHIP_CO)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "CO_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "egloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_0.dmi', "centcomcaptain"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m4a3_holster_g"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_SO)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "BO_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "rocap"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m4a3_holster_g"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_XO)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "XO_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "cap"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m44_holster_g"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_PO)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "pilot_flightsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "pilot"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sun"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "helmetp"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m4a3_holster"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_CL)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "liaison_regular")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_SYNTH)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "E_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_MP)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "MP_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "mp"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "beretred"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sunhud"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "security"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_CMP)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "WO_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "warrant_officer"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "beretwo"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "sunhud"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "security"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_TC)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "marine_tanker")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_1.dmi', "tanker"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "tanker_helmet"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m4a3_holster"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)

	else if(job_engi_high)
		switch(job_engi_high)
			if(SHIP_CE)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "EC_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatt"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_MT)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "E_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatt"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_RO)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "RO_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "cargocap"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesat"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "m44_holster_g"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_CT)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "cargotech")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lightbrowngloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_1.dmi', "band2"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatt"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
	else if(job_medsci_high)
		switch(job_medsci_high)
			if(SHIP_CMO)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "cmo")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoatg"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatm"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "electronic"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_DOCTOR)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "scrubsgreen")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoat_open"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head_0.dmi', "surgcap_green"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatm"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "electronic"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)
			if(SHIP_RESEARCHER)
				clothes_s = new /icon('icons/mob/uniform_0.dmi', "research_jumpsuit")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit_0.dmi', "labcoat_open"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/ears.dmi', "headset"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/eyes.dmi', "healthhud"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "marinesatm"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "electronic"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/mob.dmi', "card-id"), ICON_OVERLAY)

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

	qdel(eyes_s)
	qdel(underwear_s)
	qdel(undershirt_s)
	qdel(clothes_s)
	updating_icon = FALSE


/datum/preferences/proc/randomize_species_specific()
	moth_wings = pick(GLOB.moth_wings_list - "Burnt Off")
