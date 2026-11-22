/mob/living/simple_animal/mothroach
	name = "Mothroach"
	desc = "This is the adorable and wildly successful by-product of multiple attempts at genetically mixing mothpeople with cockroaches."
	icon = 'icons/mob/mothroach.dmi'
	icon_state = "mothroach"
	icon_living = "mothroach"
	icon_dead = "mothroach_dead"
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

/mob/living/simple_animal/mothroach/moff_boss
	name = "Moffioso"
	desc = "The most evil mothroach known to man. Locked away for his innumerable crimes. Tread lightly when you walk on his turf."
	icon_state = "mafiosoroach"
	icon_living = "mafiosoroach"
	icon_dead = "mafiosoroach_dead"

/mob/living/simple_animal/mothroach/void
	name = "Void Mothroach"
	desc = "Heaven's hell-sent mothroach"
	icon_state = "void_mothroach"
	icon_living = "void_mothroach"
	icon_dead = "void_mothroach_dead"

/mob/living/simple_animal/mothroach/millitary
	name = "Solider Mothroach"
	desc = "A millitary mothroach, likely from the frontlines of the mothroach combat unit, employed by the Grand Nomad Fleet"
	icon_state = "rocketroach"
	icon_living = "rocketroach"
	icon_dead = "rocketroach_dead"
