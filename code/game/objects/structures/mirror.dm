/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	hit_sound = 'sound/effects/Glasshit.ogg'
	destroy_sound = SFX_SHATTER
	density = FALSE
	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	var/shattered = FALSE

/obj/structure/mirror/Initialize(mapload)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = -14
		if(SOUTH)
			pixel_y = 27
		if(EAST)
			pixel_x = -22
		if(WEST)
			pixel_x = 22

/obj/structure/mirror/broken
	icon_state = "mirror_broke"
	shattered = TRUE

/obj/structure/mirror/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(shattered)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/userloc = H.loc

		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.physique == MALE)
			var/list/species_facial_hair = list()
			if(H.species)
				for(var/i in GLOB.facial_hair_styles_list)
					var/datum/sprite_accessory/facial_hair/tmp_facial = GLOB.facial_hair_styles_list[i]
					if(H.species.name in tmp_facial.species_allowed)
						species_facial_hair += i
			else
				species_facial_hair = GLOB.facial_hair_styles_list

			var/new_style = tgui_input_list(user, "Select a facial hair style", "Grooming", species_facial_hair)
			if(userloc != H.loc)
				return	//no tele-grooming
			if(new_style)
				H.f_style = new_style

		//handle normal hair
		var/list/species_hair = list()
		if(H.species)
			for(var/i in GLOB.hair_styles_list)
				var/datum/sprite_accessory/hair/tmp_hair = GLOB.hair_styles_list[i]
				if(H.species.name in tmp_hair.species_allowed)
					species_hair += i
		else
			species_hair = GLOB.hair_styles_list

		var/new_style = tgui_input_list(user, "Select a hair style", "Grooming", species_hair)
		if(userloc != H.loc)
			return	//no tele-grooming
		if(new_style)
			H.h_style = new_style

		H.update_hair()
