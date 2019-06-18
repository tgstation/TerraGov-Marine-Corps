/mob/living/simple_animal/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10


/mob/living/simple_animal/corgi/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"


/mob/living/simple_animal/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as it is colorful!"
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"


/mob/living/simple_animal/corgi/exoticcorgi/Initialize()
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)


/mob/living/simple_animal/corgi/Ian
	name = "Ian"
	real_name = "Ian"
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"


/mob/living/simple_animal/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"


/mob/living/simple_animal/corgi/narsie/Life()
	. = ..()
	for(var/mob/living/simple_animal/P in range(1, src))
		if(P == src || !prob(5))
			continue

		visible_message("<span class='warning'>[src] devours [P]!</span>", \
		"<span class='cult big bold'>DELICIOUS SOULS</span>")
		playsound(src, 'sound/effects/phasein.ogg', 75, TRUE)
		P.gib()


/mob/living/simple_animal/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	flags_pass = PASSMOB
	mob_size = MOB_SIZE_SMALL


/mob/living/simple_animal/corgi/puppy/mrwiggles
	name = " Mr. Wiggles"
	real_name = "Mr. Wiggles"
	desc = "It's Mr. Wiggles!"


/mob/living/simple_animal/corgi/puppy/void
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"


/mob/living/simple_animal/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "She's tearing you apart."
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"