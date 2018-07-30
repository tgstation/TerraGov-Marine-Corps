/mob/living/carbon/Xenomorph/ex_act(severity)

	flash_eyes()

	if(severity < 3 && stomach_contents.len)
		for(var/mob/M in stomach_contents)
			M.ex_act(severity + 1)

	var/b_loss = 0
	var/f_loss = 0
	switch(severity)
		if(1)
			switch(xeno_explosion_resistance)
				if(3)
					apply_damage(rand(125, 175), BRUTE) //Used to be rand(200, 300) which would one-shot most things. Tanks have severity 1 explosions on direct hits...
					updatehealth()
				if(2)
					KnockDown(6)
					apply_damage(rand(125, 175), BRUTE)
					updatehealth()
				if(1)
					if(prob(80))
						KnockOut(2)
					KnockDown(8)
					apply_damage(rand(125, 175), BRUTE)
					updatehealth()
				else
					gib()
			return

		if(2)
			switch(xeno_explosion_resistance)
				if(3)
					b_loss += rand(21, 26)
					f_loss += rand(21, 26)
					apply_damage(b_loss, BRUTE)
					apply_damage(f_loss, BURN)
					updatehealth()
					return
				if(2)
					KnockDown(4)
				if(1)
					KnockDown(6)
				if(0)
					if(prob(80))
						KnockOut(4)
					KnockDown(8)

			b_loss += rand(60, 75)
			f_loss += rand(60, 75)

		if(3)
			switch(xeno_explosion_resistance)
				if(3)
					b_loss += rand(10, 15)
					f_loss += rand(10, 15)
					apply_damage(b_loss, BRUTE)
					apply_damage(f_loss, BURN)
					updatehealth()
					return
				if(2)
					if(!knocked_down) //so marines can't chainstun with grenades
						KnockDown(2)
				if(1)
					if(!knocked_down)
						KnockDown(3)
				if(0)
					if(prob(40))
						KnockOut(2)
					if(!knocked_down)
						KnockDown(4)

			b_loss += rand(30, 45)
			f_loss += rand(30, 45)

	apply_damage(b_loss, BRUTE)
	apply_damage(f_loss, BURN)
	updatehealth()


/mob/living/carbon/Xenomorph/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, used_weapon = null, sharp = 0, edge = 0)
	if(!damage) return

	//We still want to check for blood splash before we get to the damage application.
	var/chancemod = 0
	if(used_weapon && sharp)
		chancemod += 10
	if(used_weapon && edge) //Pierce weapons give the most bonus
		chancemod += 12
	if(def_zone != "chest") //Which it generally will be, vs xenos
		chancemod += 5

	if(damage > 12) //Light damage won't splash.
		check_blood_splash(damage, damagetype, chancemod)

	if(stat == DEAD) return

	if(warding_aura && damage > 0) //Damage reduction. Every half point of warding decreases damage by 2.5 %. Maximum is 25 % at 5 pheromone strength.
		damage = round(damage * ((100 - (warding_aura * 5)) / 100))

	if(def_zone == "head" || def_zone == "eyes" || def_zone == "mouth") //Little more damage vs the head
		damage = round(damage * 8 / 7)

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)

	updatehealth()
	return 1

/mob/living/carbon/Xenomorph/proc/check_blood_splash(damage = 0, damtype = BRUTE, chancemod = 0, radius = 1)
	if(!damage)
		return 0
	var/chance = 20 //base chance
	if(damtype == BRUTE) chance += 5
	chance += chancemod + (damage * 0.33)
	var/turf/T = loc
	if(!T || !istype(T))
		return

	if(radius > 1 || prob(chance))

		var/obj/effect/decal/cleanable/blood/xeno/decal = locate(/obj/effect/decal/cleanable/blood/xeno) in T

		if(!decal) //Let's not stack blood, it just makes lagggggs.
			add_splatter_floor(T) //Drop some on the ground first.
		else
			if(decal.random_icon_states && length(decal.random_icon_states) > 0) //If there's already one, just randomize it so it changes.
				decal.icon_state = pick(decal.random_icon_states)

		var/splash_chance = 40 //Base chance of getting splashed. Decreases with # of victims.
		var/distance = 0 //Distance, decreases splash chance.
		var/i = 0 //Tally up our victims.

		for(var/mob/living/carbon/human/victim in range(radius,src)) //Loop through all nearby victims, including the tile.
			distance = get_dist(src,victim)

			splash_chance = 80 - (i * 5)
			if(victim.loc == loc) splash_chance += 30 //Same tile? BURN
			splash_chance += distance * -15
			if(victim.species && victim.species.name == "Yautja")
				splash_chance -= 70 //Preds know to avoid the splashback.

			if(splash_chance > 0 && prob(splash_chance)) //Success!
				i++
				victim.visible_message("<span class='danger'>\The [victim] is scalded with hissing green blood!</span>", \
				"<span class='danger'>You are splattered with sizzling blood! IT BURNS!</span>")
				if(prob(60) && !victim.stat && !(victim.species.flags & NO_PAIN))
					victim.emote("scream") //Topkek
				victim.take_limb_damage(0, rand(10, 25)) //Sizzledam! This automagically burns a random existing body part.
