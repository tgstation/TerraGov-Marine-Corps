/mob/living/simple_animal/hostile/faithless
	name = "The Faithless"
	desc = "The Wish Granter's faith in humanity, incarnate."
	icon_state = "faithless"
	icon_living = "faithless"
	icon_dead = "faithless_dead"
	gender = MALE
	speak_chance = 0
	turns_per_move = 5
	response_help = "passes through"
	response_disarm = "shoves"
	response_harm = "hits"
	emote_taunt = list("wails")
	taunt_chance = 25
	speed = 0
	maxHealth = 80
	health = 80

	harm_intent_damage = 10
	obj_damage = 50
	melee_damage = 15
	attacktext = "grips"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	speak_emote = list("growls")


/mob/living/simple_animal/hostile/faithless/AttackingTarget()
	. = ..()
	if(. && prob(12) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.Paralyze(20 SECONDS)
		C.visible_message(span_danger("\The [src] knocks down \the [C]!"), \
				span_userdanger("\The [src] knocks you down!"))
