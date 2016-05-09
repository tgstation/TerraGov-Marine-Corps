/mob/living/carbon/Xenomorph/ex_act(severity)

	if(!blinded)
		flick("flash", flash)

	var/b_loss = 0
	var/f_loss = 0
	switch (severity)
		if (1.0)
			if(is_robotic || istype(src,/mob/living/carbon/Xenomorph/Crusher))
				adjustBruteLoss(rand(200,300))
				updatehealth()
				return
			gib()
			return
		if (2.0)
			if(is_robotic || istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Robots and crushers are immune.
				return
			b_loss += rand(45,55)
			f_loss += rand(45,65)
			Weaken(12)
			if(guard_aura)
				b_loss = round(b_loss / 2)
			adjustBruteLoss(b_loss)
			adjustFireLoss(f_loss)
			updatehealth()
			return
		if(3.0)
			if(is_robotic || istype(src,/mob/living/carbon/Xenomorph/Crusher)) //Robots and crushers are immune.
				return
			b_loss += rand(20,40)
			f_loss += rand(25,50)
			if (prob(40))
				Paralyse(2)
			Weaken(rand(4,6))
			if(guard_aura)
				b_loss = round(b_loss / 2)
			adjustBruteLoss(b_loss)
			adjustFireLoss(f_loss)
			updatehealth()
			return
	return

/mob/living/carbon/Xenomorph/blob_act()
	return

/mob/living/carbon/Xenomorph/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/used_weapon = null, var/sharp = 0, var/edge = 0)
	if(!damage)	return 0
	if(stat == DEAD) return 0 //Quit beating a dead horse! I mean xeno

	if(guard_aura && damage > 0)
		damage = round(damage * 6 / 7) //Slight damage reduction.

	if(def_zone == "head" || def_zone == "eyes" || def_zone == "mouth")
		damage = round(damage * 8 / 7) //Little more damage vs the head.

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)

	var/chancemod = 0
	if(used_weapon && sharp) chancemod += 10
	if(used_weapon && edge) chancemod += 12 //Pierce weapons give the most bonus.
	if(def_zone != "chest") chancemod += 5 //Which it generally will be, vs xenos

	if(damage > 12) //Light damage won't splash.
		check_blood_splash(damage, damagetype, chancemod)
	updatehealth()
	return 1

/mob/living/carbon/Xenomorph/proc/check_blood_splash(var/damage = 0, var/damtype = BRUTE, var/chancemod = 0)
	if(!damage) return 0
	var/chance = 10 //base chance
	if(damtype == BRUTE) chance += 5
	chance += chancemod
	chance += (damage / 3) //A fair bonus based on damage. 30 dam : +10% splash, 60 dam(glaive) : +20%
	var/turf/T = loc
	if(!T || !istype(T)) return 0
	if(src.stat == DEAD) //Well. Maybe a smaller chance.. To stop marines from running around hacking them up I guess.
		chance -= 20

	if(!prob(chance)) return 0 //Failed the check.

	//Success! Splash somea dat bluds
	var/obj/effect/decal/cleanable/blood/xeno/decal = locate(/obj/effect/decal/cleanable/blood/xeno) in T

	if(!decal) //Let's not stack blood, it just makes lagggggs.
		T.add_blood_floor(src) //Drop some on the ground first.
	else
		if(decal.random_icon_states && length(decal.random_icon_states) > 0) //If there's already one, just randomize it so it changes.
			decal.icon_state = pick(decal.random_icon_states)

	var/splash_chance = 40 //Base chance of getting splashed. Decreases with # of victims.
	var/distance = 0 //Distance, decreases splash chance.
	var/i = 0 //Tally up our victims.

	for(var/mob/living/carbon/human/victim in range(1,src)) //Loop through all nearby victims, including the tile.
		distance = get_dist(src,victim)
		splash_chance = 40 - (i * 5)
		if(victim.loc == src.loc)
			splash_chance += 30 //Same tile? BURN
		if(distance > 1)
			splash_chance -= 25 //Much less chance at 2 tiles.
		if(victim.species && victim.species.name == "Yautja")
			splash_chance -= 40 //Preds know to avoid the splashback.
		if(splash_chance > 0 && prob(splash_chance)) //Success!
			i++
			victim.visible_message("\green [victim] is scalded with hissing green blood!","\green <b>You are splattered with sizzling blood! IT BURNS!!<b>")
			if(prob(60) && !victim.stat)
				victim.emote("scream") //Topkek
			victim.take_organ_damage(0,rand(10,25))  //Sizzledam! This automagically burns a random existing body part
	return


