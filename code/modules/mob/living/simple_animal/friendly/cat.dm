/mob/living/simple_animal/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	flags_pass = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"


/mob/living/simple_animal/cat/space
	name = "space cat"
	desc = "It's a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"


/mob/living/simple_animal/cat/original
	name = "Batsy"
	desc = "The product of alien DNA and bored geneticists."
	gender = FEMALE
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"


/mob/living/simple_animal/cat/kitten
	name = "kitten"
	desc = "D'aaawwww."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	density = FALSE
	flags_pass = PASSMOB
	mob_size = MOB_SIZE_SMALL


/mob/living/simple_animal/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	gender = FEMALE


/mob/living/simple_animal/cat/Jones
	name = "Jones"
	real_name = "Jones"
	desc = "Old and grumpy cat."
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"


/mob/living/simple_animal/cat/floppa
	name = "\improper floppa"
	real_name = "floppa"
	desc = "A caracal with very floppy ears. Its mere presence inspires fear."
	icon = 'icons/mob/pets.dmi'
	icon_state = "floppa"
	icon_living = "floppa"
	icon_dead = "floppa_dead"
	health = 200
	maxHealth = 200

/mob/living/simple_animal/cat/martin
	name = "Martin"
	desc = "Requisition's very own caracal. You wonder how much requisition paid to get this dogdang creature on board."
	icon = 'icons/mob/pets.dmi'
	icon_state = "martin"
	icon_living = "martin"
	icon_dead = "martin_dead"
	gender = MALE
	emote_see = list("shakes its head.", "shivers.", "points at the supply console.", "looks at the abyss that is the ASRS Elevator.", "counts the requisition points.", "looks at the supply drop.", "stares at the marines inside requisition", "wants to order some pizza")
	health = 200
	maxHealth = 200


/mob/living/simple_animal/cat/Life()
	if(!stat && !buckled && !client)
		if(prob(1))
			emote("me", 1, pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
			icon_state = "[icon_living]_rest"
			set_resting(TRUE)
		else if(prob(1))
			emote("me", 1, pick("sits down.", "crouches on its hind legs.", "looks alert."))
			icon_state = "[icon_living]_sit"
			set_resting(TRUE)
		else if(prob(1))
			if(resting)
				emote("me", 1, pick("gets up and meows.", "walks around.", "stops resting."))
				icon_state = "[icon_living]"
				set_resting(FALSE)
			else
				emote("me", 1, pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

	return ..()


/mob/living/simple_animal/cat/MouseDrop(atom/over_object)
	. = ..()

	if(!ishuman(over_object))
		return

	var/mob/living/carbon/human/H = over_object
	if(H.incapacitated())
		return

	if(H.l_hand && H.r_hand)
		return

	var/obj/item/clothing/head/cat/C = new
	C.name = name
	C.desc = desc
	C.icon_state = initial(icon_state)
	C.cat = src
	forceMove(C)
	H.put_in_hands(C)


/obj/item/clothing/head/cat
	name = "Cat"
	desc = "Kitty!!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "cat2"
	flags_armor_features = ARMOR_NO_DECAP
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 10, "bio" = 5, "rad" = 0, "fire" = 50, "acid" = 50)
	var/mob/living/simple_animal/cat/cat

/obj/item/clothing/head/cat/Destroy()
	if(cat)
		cat.forceMove(get_turf(src))
		cat = null
	return ..()


/obj/item/clothing/head/cat/throw_at(atom/target, range, speed, thrower, spin)
	qdel(src)


/obj/item/clothing/head/cat/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	qdel(src)


/obj/item/clothing/head/cat/dropped(mob/user)
	. = ..()
	if(loc == user)
		return
	qdel(src)
