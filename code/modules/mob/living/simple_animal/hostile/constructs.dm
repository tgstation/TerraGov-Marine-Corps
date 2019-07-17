/mob/living/simple_animal/hostile/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	gender = NEUTER
	speak_emote = list("hisses")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	speak_chance = 1
	icon = 'icons/mob/mob.dmi'
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = TRUE
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	healable = FALSE
	AIStatus = AI_OFF
	del_on_death = TRUE
	deathmessage = "collapses in a shattered heap."


/mob/living/simple_animal/hostile/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked, clawed shell constructed to assassinate enemies and sow chaos behind enemy lines."
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 65
	health = 65
	melee_damage_lower = 20
	melee_damage_upper = 20
	retreat_distance = 2
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'


/mob/living/simple_animal/hostile/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar'Sie's armies."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 5
	melee_damage_upper = 5
	retreat_distance = 10
	minimum_distance = 10
	attacktext = "rams"
	attack_sound = 'sound/weapons/punch2.ogg'


/mob/living/simple_animal/hostile/construct/armored
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A massive, armored construct built to spearhead attacks and soak up enemy fire."
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 150
	health = 150
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	obj_damage = 90
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "smashes their armored gauntlet into"
	speed = 2.5
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = NONE
	mob_size = MOB_SIZE_BIG
	force_threshold = 10