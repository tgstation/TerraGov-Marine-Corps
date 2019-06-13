/mob/living/simple_animal/mouse
	name = "mouse"
	desc = "It's a nasty, ugly, evil, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	speak = list("Squeak!","SQUEAK!","Squeak?")
	speak_emote = list("squeaks")
	emote_hear = list("squeaks.")
	emote_see = list("runs in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	density = FALSE
	flags_pass = PASSTABLE|PASSGRILLE|PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/body_color //brown, gray and white, leave blank for random
	var/chew_probability = 1


/mob/living/simple_animal/mouse/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, 'sound/effects/mousesqueek.ogg', 100)
	if(!body_color)
		body_color = pick( list("brown","gray","white") )
	icon_state = "mouse_[body_color]"
	icon_living = "mouse_[body_color]"
	icon_dead = "mouse_[body_color]_dead"


/mob/living/simple_animal/mouse/Crossed(atom/movable/AM)
	if(ishuman(AM) && stat == CONSCIOUS)
		var/mob/living/carbon/human/H = AM
		to_chat(H, "<span class='notice'>[icon2html(src, H)] Squeak!</span>")
	return ..()


/mob/living/simple_animal/mouse/handle_automated_action()
	if(prob(chew_probability))
		var/turf/open/floor/F = get_turf(src)
		if(istype(F))
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message("<span class='warning'>[src] chews through the [C]. It's toast!</span>")
					playsound(src, 'sound/effects/sparks2.ogg', 100, 1)
					C.deconstruct()
					death()
				else
					C.deconstruct()
					visible_message("<span class='warning'>[src] chews through the [C].</span>")


/mob/living/simple_animal/mouse/white
	body_color = "white"
	icon_state = "mouse_white"


/mob/living/simple_animal/mouse/gray
	body_color = "gray"
	icon_state = "mouse_gray"


/mob/living/simple_animal/mouse/brown
	body_color = "brown"
	icon_state = "mouse_brown"


/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"