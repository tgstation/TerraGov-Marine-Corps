/mob/living/carbon/Xenomorph/ex_act(severity)

	if(!blinded)
		flick("flash", flash)

	var/b_loss = 0
	var/f_loss = 0
	switch (severity)
		if (1.0)
			gib()
			return
		if (2.0)
			b_loss += rand(40,60)
			f_loss += rand(40,60)
			Weaken(3)
		if(3.0)
			b_loss += rand(10,40)
			f_loss += rand(10,40)
			if (prob(20))
				Paralyse(1)
			Weaken(rand(0,2))

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)
	updatehealth()

/mob/living/carbon/Xenomorph/blob_act()
	return

/mob/living/carbon/Xenomorph/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/used_weapon = null, var/sharp = 0, var/edge = 0)
	if(!damage)	return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)

	var/chancemod = 0
	if(used_weapon && sharp) chancemod += 10
	if(used_weapon && edge) chancemod += 12 //Pierce weapons give the most bonus.
	if(def_zone == "chest") chancemod += 3 //Which it generally will be, vs xenos

	if(damage > 15) //Light damage won't splash.
		check_blood_splash(damage, damagetype, chancemod)
	updatehealth()
	return 1

/mob/living/carbon/Xenomorph/proc/check_blood_splash(var/damage = 0, var/damtype = BRUTE, var/chancemod = 0)
	if(!damage) return 0
	var/chance = 10 //base chance
	if(damtype == BRUTE) chance += 5
	chance += chancemod
	chance += (damage / 3) //A fair bonus based on damage. 30 dam : +10% splash, 60 dam(glaive) : +20%
	var/turf/simulated/T = loc
	if(!T || !istype(T)) return 0
	if(src.stat == DEAD) //Well. Maybe a smaller chance.. To stop marines from running around hacking them up I guess.
		chance -= 20

	if(!prob(chance)) return 0 //Failed the check.

	//Success! Splash somea dat bluds
	T.add_blood_floor(src) //Drop some on the ground first.

	var/splash_chance = 50 //Base chance of getting splashed. Decreases with # of victims.
	var/distance = 0 //Distance, decreases splash chance.
	var/i = 0 //Tally up our victims.



	for(var/mob/living/carbon/human/victim in range(2)) //Loop through all nearby victims, including the tile.
		distance = get_dist(src,victim)
		splash_chance = 50 - (i * 3)
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
			victim.take_organ_damage(0,rand(20,90))  //Sizzledam! This automagically burns a random existing body part, with overlays.
			if(prob(30)) //So good, you do it twice!
				victim.take_organ_damage(0,rand(10,70))   //The 0 is for brute damage.
	return

//Deal with armor deflection.
/mob/living/carbon/Xenomorph/bullet_act(var/obj/item/projectile/Proj) //wrapper
	if(Proj && istype(Proj) )
		var/dmg = Proj.damage
		if(istype(Proj,/obj/item/projectile/bullet/m56)) dmg += 10 //Smartgun hits weak points easier.
		if(prob(armor_deflection - dmg))
			visible_message("\blue The [src]'s thick exoskeleton deflects \the [Proj]!","\blue Your thick exoskeleton deflected \the [Proj]!")
			return -1
	..(Proj) //Do normal stuff
