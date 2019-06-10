/mob/living/simple_animal/crab
	name = "crab"
	desc = "Free crabs!"
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks.")
	emote_see = list("clacks.")
	speak_chance = 1
	turns_per_move = 5
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement = TRUE
	friendly = "pinches"


/mob/living/simple_animal/crab/Coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	gender = FEMALE
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"


/mob/living/simple_animal/crab/evil
	name = "Evil Crab"
	real_name = "Evil Crab"
	desc = "Unnerving, isn't it? It has to be planning something nefarious..."
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "stomps"


/mob/living/simple_animal/crab/kreb
	name = "Kreb"
	desc = "This is a real crab. The other crabs are simply gubbucks in disguise!"
	real_name = "Kreb"
	icon_state = "kreb"
	icon_living = "kreb"
	icon_dead = "kreb_dead"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"


/mob/living/simple_animal/crab/evil/kreb
	name = "Evil Kreb"
	real_name = "Evil Kreb"
	icon_state = "evilkreb"
	icon_living = "evilkreb"
	icon_dead = "evilkreb_dead"