#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	icon_state = "carp"
	icon_living = "carp"
	icon_dead = "carp_dead"
	icon_gib = "carp_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25

	harm_intent_damage = 8
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")


/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	del_on_death = TRUE


/mob/living/simple_animal/hostile/carp/megacarp
	icon = 'icons/mob/broadMobs.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	maxHealth = 20
	health = 20
	pixel_x = -16
	mob_size = MOB_SIZE_BIG

	obj_damage = 80
	melee_damage_lower = 20
	melee_damage_upper = 20

	var/regen_cooldown = 0


/mob/living/simple_animal/hostile/carp/megacarp/Initialize()
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage_lower += rand(2, 10)
	melee_damage_upper += rand(10, 20)
	maxHealth += rand(30, 60)
	move_to_delay = rand(3, 7)


/mob/living/simple_animal/hostile/carp/megacarp/Life()
	. = ..()
	if(regen_cooldown < world.time)
		heal_overall_damage(4)
		regen_cooldown = world.time + REGENERATION_DELAY


/mob/living/simple_animal/hostile/carp/cayenne
	name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	gender = FEMALE
	speak_emote = list("squeaks")
	AIStatus = AI_OFF


#undef REGENERATION_DELAY