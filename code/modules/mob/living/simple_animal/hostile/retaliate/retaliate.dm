/mob/living/simple_animal/hostile/retaliate
	var/list/enemies = list()

/mob/living/simple_animal/hostile/retaliate/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(M.used_intent.type == INTENT_HELP)
		if(enemies.len)
			if(tame)
				enemies = list()
				src.visible_message("<span class='notice'>[src] calms down.</span>")
				LoseTarget()

/mob/living/simple_animal/hostile/retaliate
	var/aggressive = 0

/mob/living/simple_animal/hostile/retaliate/ListTargets()
	if(aggressive)
		return ..()
	else
		if(!enemies.len)
			return list()
		var/list/see = ..()
		see &= enemies // Remove all entries that aren't in enemies
		return see

/mob/living/simple_animal/hostile/retaliate/proc/Retaliate()
//	var/list/around = view(src, vision_range)
	toggle_ai(AI_ON)
	var/list/around = hearers(vision_range, src)

	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/M = A
			if(faction_check_mob(M) && attack_same || !faction_check_mob(M))
				enemies |= M
//		else if(ismecha(A))
//			var/obj/mecha/M = A
//			if(M.occupant)
//				enemies |= M
//				enemies |= M.occupant

	for(var/mob/living/simple_animal/hostile/retaliate/H in around)
		if(faction_check_mob(H) && !attack_same && !H.attack_same)
			H.enemies |= enemies
	return 0

/mob/living/simple_animal/hostile/retaliate/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(. > 0 && stat == CONSCIOUS)
		Retaliate()
