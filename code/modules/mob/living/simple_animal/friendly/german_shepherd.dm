/mob/living/simple_animal/german_shepherd
	name = "\improper german shepherd"
	real_name = "german shepherd"
	desc = "It's a german shepherd."
	icon = 'icons/mob/pets.dmi'
	icon_state = "german_shep"
	icon_living = "german_shep"
	icon_dead = "german_shep_dead"
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
