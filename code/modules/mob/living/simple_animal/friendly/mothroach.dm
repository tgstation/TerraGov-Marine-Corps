/mob/living/simple_animal/mothroach
	name = "Mothroach"
	desc = "This is the adorable and wildly successful by-product of multiple attempts at genetically mixing mothpeople with cockroaches."
	icon = 'icons/mob/mothroach.dmi'
	icon_state = "mafiosoroach"
	icon_living = "mafiosoroach"
	icon_dead = "mafiosoroach_dead"
	speak_emote = list("flutters")
	health = 25
	maxHealth = 25
	faction = list("Mothroach")
	response_help = "pets"
	response_disarm = "shoos"
	response_harm = "punches"
	allow_pass_flags = PASS_MOB
	pass_flags = PASS_LOW_STRUCTURE|PASS_MOB
	mob_size = MOB_SIZE_SMALL
