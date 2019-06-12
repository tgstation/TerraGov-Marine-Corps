/mob/living/simple_animal/hostile/retaliate
	var/list/enemies = list()


/mob/living/simple_animal/hostile/retaliate/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.stat)
			return L
		else
			enemies -= L


/mob/living/simple_animal/hostile/retaliate/ListTargets()
	if(!enemies.len)
		return list()
	var/list/see = ..()
	see &= enemies // Remove all entries that aren't in enemies
	return see


/mob/living/simple_animal/hostile/retaliate/proc/Retaliate()
	var/list/around = view(src, world.view)

	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/L = A
			if((L.faction == faction && attack_same) || L.faction != faction)
				enemies |= L

	for(var/mob/living/simple_animal/hostile/retaliate/H in around)
		if((H.faction == faction && attack_same) || H.faction != faction)
			H.enemies |= enemies
	return FALSE


/mob/living/simple_animal/hostile/retaliate/adjustBruteLoss(damage)
	. = ..()
	Retaliate()