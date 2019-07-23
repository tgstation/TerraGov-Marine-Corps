/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	var/shattered = FALSE

/obj/structure/mirror/Initialize()
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_y = 30
		if(SOUTH)
			pixel_y = -30
		if(EAST)
			pixel_x = 30
		if(WEST)
			pixel_x = -30

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

		if(H.a_intent == INTENT_HARM)
			if(shattered)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 25, 1)
				return
			if(prob(30) || H.species.can_shred(H))
				user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
				shatter()
			else
				user.visible_message("<span class='danger'>[user] hits [src] and bounces off!</span>")
			return

		var/userloc = H.loc

		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.

		//handle facial hair (if necessary)
		if(H.gender == MALE)
			var/list/species_facial_hair = list()
			if(H.species)
				for(var/i in GLOB.facial_hair_styles_list)
					var/datum/sprite_accessory/facial_hair/tmp_facial = GLOB.facial_hair_styles_list[i]
					if(H.species.name in tmp_facial.species_allowed)
						species_facial_hair += i
			else
				species_facial_hair = GLOB.facial_hair_styles_list

			var/new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in species_facial_hair
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

		var/new_style = input(user, "Select a hair style", "Grooming")  as null|anything in species_hair
		if(userloc != H.loc)
			return	//no tele-grooming
		if(new_style)
			H.h_style = new_style

		H.update_hair()

/obj/structure/mirror/attack_alien(mob/living/carbon/xenomorph/M)
	M.do_attack_animation(src)
	if(shattered)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 25, 1)
		return TRUE

	if(M.a_intent == INTENT_HELP)
		M.visible_message("<span class='warning'>\The [M] oogles its own reflection in [src].</span>", \
		"<span class='warning'>We oogle our own reflection in [src].</span>", null, 5)
	else
		M.visible_message("<span class='danger'>\The [M] smashes [src]!</span>", \
		"<span class='danger'>We smash [src]!</span>", null, 5)
		shatter()

/obj/structure/mirror/proc/shatter()
	if(shattered)
		return
	shattered = TRUE
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, 1)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(obj/item/projectile/Proj)
	if(prob(Proj.damage * 2))
		if(!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 25, 1)
	..()
	return TRUE


/obj/structure/mirror/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(shattered)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 25, 1)
		return

	else if(prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)

/obj/structure/mirror/attack_animal(mob/user as mob)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	if(shattered)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 25, 1)
		return
	user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
	shatter()
