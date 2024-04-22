/mob/living/simple_animal/hostile/retaliate/bat
	name = "bat"
	desc = ""
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	turns_per_move = 1
	response_help_continuous = "brushes aside"
	response_help_simple = "brush aside"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak_chance = 0
	maxHealth = 50
	health = 50
	spacewalk = TRUE
	see_in_dark = 10
	harm_intent_damage = 6
	melee_damage_lower = 6
	melee_damage_upper = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 1)
	pass_flags = PASSTABLE
	faction = list("hostile")
	attack_sound = 'sound/blank.ogg'
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	movement_type = FLYING
	speak_emote = list("squeaks")
	var/max_co2 = 0 //to be removed once metastation map no longer use those for Sgt Araneus
	var/min_oxy = 0
	var/max_tox = 0


	//Space bats need no air to fly in.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0

/mob/living/simple_animal/hostile/retaliate/bat/Initialize()
	. = ..()
	verbs += list(/mob/living/simple_animal/hostile/retaliate/bat/proc/bat_up,
	/mob/living/simple_animal/hostile/retaliate/bat/proc/bat_down) 

/mob/living/simple_animal/hostile/retaliate/bat/proc/bat_up()
	set category = "Bat Form"
	set name = "Move Up"

	if(zMove(UP, TRUE))
		to_chat(src, "<span class='notice'>I fly upwards.</span>")

/mob/living/simple_animal/hostile/retaliate/bat/proc/bat_down()
	set category = "Bat Form"
	set name = "Move Down"

	if(zMove(DOWN, TRUE))
		to_chat(src, "<span class='notice'>I fly down.</span>")
