/mob/living/carbon/xenomorph/ex_act(severity)

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
					b_loss += rand(70, 80)
					f_loss += rand(70, 80)
					add_slowdown(3)
				if(2)
					KnockDown(6)
					adjust_stagger(4)
					add_slowdown(4)
					b_loss += rand(75, 85)
					f_loss += rand(75, 85)
				if(1)
					if(prob(80))
						KnockOut(2)
					KnockDown(8)
					adjust_stagger(5)
					add_slowdown(5)
					b_loss += rand(80, 90)
					f_loss += rand(80, 90)
				else
					gib()
					return

		if(2)
			b_loss += rand(80, 100)
			f_loss += rand(80, 100)
			switch(xeno_explosion_resistance)
				if(3)
					b_loss *= XENO_EXPLOSION_RESIST_3_MODIFIER
					f_loss *= XENO_EXPLOSION_RESIST_3_MODIFIER
					apply_damage(b_loss, BRUTE)
					apply_damage(f_loss, BURN)
					updatehealth()
					return
				if(2)
					KnockDown(4)
					adjust_stagger(1)
					add_slowdown(3)
				if(1)
					KnockDown(6)
					adjust_stagger(4)
					add_slowdown(4)
				if(0)
					if(prob(80))
						KnockOut(4)
					KnockDown(8)
					adjust_stagger(5)
					add_slowdown(5)

		if(3)
			b_loss += rand(40, 50)
			f_loss += rand(40, 50)
			switch(xeno_explosion_resistance)
				if(3)
					b_loss *= XENO_EXPLOSION_RESIST_3_MODIFIER
					f_loss *= XENO_EXPLOSION_RESIST_3_MODIFIER
					apply_damage(b_loss, BRUTE)
					apply_damage(f_loss, BURN)
					updatehealth()
					return
				if(2)
					if(!knocked_down) //so marines can't chainstun with grenades
						KnockDown(2)
					add_slowdown(1)
				if(1)
					if(!knocked_down)
						KnockDown(3)
					adjust_stagger(2)
					add_slowdown(2)
				if(0)
					if(prob(40))
						KnockOut(2)
					if(!knocked_down)
						KnockDown(4)
					adjust_stagger(4)
					add_slowdown(4)

	apply_damage(b_loss, BRUTE)
	apply_damage(f_loss, BURN)
	updatehealth()


/mob/living/carbon/xenomorph/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, used_weapon = null, sharp = 0, edge = 0)
	if(blocked >= 1) //total negation
		return FALSE

	if(blocked)
		damage *= CLAMP(1-blocked,0.00,1.00) //Percentage reduction

	if(!damage) //no damage
		return FALSE

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

	SEND_SIGNAL(src, COMSIG_XENOMORPH_TAKING_DAMAGE, damage)

	if(stat == DEAD)
		return FALSE

	damage = process_rage_damage(damage, src)

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage, FALSE)
		if(BURN)
			adjustFireLoss(damage, FALSE)

	updatehealth()
	return TRUE


/mob/living/carbon/xenomorph/adjustBruteLoss(amount, process_rage = TRUE)
	if(process_rage)
		amount = process_rage_damage(amount)
	bruteloss = CLAMP(bruteloss + amount, 0, maxHealth - xeno_caste.crit_health)

/mob/living/carbon/xenomorph/adjustFireLoss(amount, process_rage = TRUE)
	if(process_rage)
		amount = process_rage_damage(amount)
	fireloss = CLAMP(fireloss + amount, 0, maxHealth - xeno_caste.crit_health)

/mob/living/carbon/xenomorph/proc/process_rage_damage(damage)
	return damage

/mob/living/carbon/xenomorph/proc/check_blood_splash(damage = 0, damtype = BRUTE, chancemod = 0, radius = 1)
	if(!damage)
		return FALSE
	var/chance = 20 //base chance
	if(damtype == BRUTE)
		chance += 5
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

			if(splash_chance > 0 && prob(splash_chance)) //Success!
				i++
				victim.visible_message("<span class='danger'>\The [victim] is scalded with hissing green blood!</span>", \
				"<span class='danger'>You are splattered with sizzling blood! IT BURNS!</span>")
				if(prob(60) && !victim.stat && !(victim.species.species_flags & NO_PAIN))
					victim.emote("scream") //Topkek
				victim.take_limb_damage(0, rand(10, 25)) //Sizzledam! This automagically burns a random existing body part.
