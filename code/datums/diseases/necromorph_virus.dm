/datum/disease/black_goo/necromorph_virus
	name = "Marker's influence"
	agent = "Unknown Biological Organism X-66"
	survive_mob_death = TRUE //switch to true to make dead infected humans still transform
	max_stages = 2 // Zombies are designed to slowly build up over an extended round. We don't want the payoff for necromorphs to be too slow.

/datum/disease/black_goo/necromorph_virus/stage_act()
	..()
	if(!ishuman(affected_mob)) return
	var/mob/living/carbon/human/H = affected_mob
	if(!H.regenZ) return
	if(age > 1.5*stage_minimum_age) stage_prob = 100 //if it takes too long we force a stage increase
	else stage_prob = initial(stage_prob)
	if(H.stat == DEAD) stage_minimum_age = 75 //the virus progress faster when the host is dead.
	switch(stage)
		if(1)
			H.next_move_slowdown = max(H.next_move_slowdown, 2)
			if(prob(5) || age >= stage_minimum_age-1)
			if(!zombie_transforming)
					zombie_transform(H)
			else if(prob(5))
				H.vomit()
		if(2)
			if(!zombie_transforming && prob(10))
			if(H.stat != DEAD)
				var/healamt = H.stat ? 5 : 1
			if(H.health < H.maxHealth)
				H.adjustFireLoss(-healamt)
				H.adjustBruteLoss(-healamt)
				H.adjustToxLoss(-healamt)
				H.adjustOxyLoss(-healamt)
				H.nutrition = 450 //never hungry
			if(goo_message_cooldown < world.time)
				goo_message_cooldown = world.time + 100
				to_chat(affected_mob, "<span class='red'> Kill... Die... Glory...</span>")


/datum/disease/black_goo/necromorph_virus/proc/necro_transform(mob/living/carbon/human/H)
	set waitfor = 0
	zombie_transforming = TRUE
	H.vomit()
	sleep(50)
	H.AdjustStunned(5)
	sleep(20)
	H.Jitter(500)
	sleep(30)
	if(H && H.loc)
		if(H.stat == DEAD)
		H.revive(TRUE)
		playsound(H.loc, 'sound/hallucinations/wail.ogg', 25, 1)
		H.jitteriness = 0
		H.set_species("Necromorph")
		stage = 2
		zombie_transforming = FALSE

/obj/item/weapon/necromorph_claws
	name = "claws"
	icon = 'icons/mob/human_races/r_zombie.dmi'
	icon_state = "claw_l"
	flags_item = NODROP|DELONDROP
	force = 15
	w_class = 6
	sharp = 1
	attack_verb = list("slashed", "bite", "tore", "scraped", "nibbled")
	pry_capable = IS_PRY_CAPABLE_FORCE
