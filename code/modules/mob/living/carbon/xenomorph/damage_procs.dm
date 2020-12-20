/mob/living/carbon/xenomorph/fire_act()
	if(status_flags & GODMODE)
		return
	return ..()

/mob/living/carbon/xenomorph/ex_act(severity, input_stagger_override = 0, input_slowdown_override = 0)
	if(status_flags & GODMODE)
		return

	if(severity < EXPLODE_LIGHT) //Actually means higher.
		for(var/i in stomach_contents)
			var/mob/living/carbon/prey = i
			prey.ex_act(severity + 1)
	var/bomb_armor = soft_armor.getRating("bomb")
	var/b_loss = 0
	var/f_loss = 0
	var/stagger_stacks
	var/slowdown_stacks

	switch(severity)
		if(EXPLODE_DEVASTATE)
			switch(bomb_armor)
				if(XENO_BOMB_RESIST_4 to INFINITY)
					slowdown_stacks = 2
					return
				if(XENO_BOMB_RESIST_3 to XENO_BOMB_RESIST_4)
					b_loss = rand(70, 80)
					f_loss = rand(70, 80)
					slowdown_stacks = 3
					adjust_sunder(80)
				if(XENO_BOMB_RESIST_2 to XENO_BOMB_RESIST_3)
					b_loss = rand(75, 85)
					f_loss = rand(75, 85)
					stagger_stacks = 4
					slowdown_stacks = 4
					adjust_sunder(90)
				if(XENO_BOMB_RESIST_1 to XENO_BOMB_RESIST_2)
					b_loss = rand(80, 90)
					f_loss = rand(80, 90)
					stagger_stacks = 5
					slowdown_stacks = 5
					adjust_sunder(100)
				else //Lower than XENO_BOMB_RESIST_1
					return gib()
		if(EXPLODE_HEAVY)
			switch(bomb_armor)
				if(XENO_BOMB_RESIST_4 to INFINITY)
					add_slowdown(1)
					return
				if(XENO_BOMB_RESIST_3 to XENO_BOMB_RESIST_4)
					b_loss = rand(50, 60)
					f_loss = rand(50, 60)
					slowdown_stacks = 2
					adjust_sunder(35)
				if(XENO_BOMB_RESIST_2 to XENO_BOMB_RESIST_3)
					b_loss = rand(55, 55)
					f_loss = rand(55, 55)
					stagger_stacks = 1
					slowdown_stacks = 3
					adjust_sunder(40)
				if(XENO_BOMB_RESIST_1 to XENO_BOMB_RESIST_2)
					b_loss = rand(60, 70)
					f_loss = rand(60, 70)
					stagger_stacks = 4
					slowdown_stacks = 4
					adjust_sunder(45)
				else //Lower than XENO_BOMB_RESIST_1
					b_loss = rand(65, 75)
					f_loss = rand(65, 75)
					stagger_stacks = 5
					slowdown_stacks = 5
					adjust_sunder(50)
		if(EXPLODE_LIGHT)
			switch(bomb_armor)
				if(XENO_BOMB_RESIST_4 to INFINITY)
					return //Immune
				if(XENO_BOMB_RESIST_3 to XENO_BOMB_RESIST_4)
					b_loss = rand(30, 40)
					f_loss = rand(30, 40)
				if(XENO_BOMB_RESIST_2 to XENO_BOMB_RESIST_3)
					b_loss = rand(35, 45)
					f_loss = rand(35, 45)
					slowdown_stacks = 1
				if(XENO_BOMB_RESIST_1 to XENO_BOMB_RESIST_2)
					b_loss = rand(40, 50)
					f_loss = rand(40, 50)
					stagger_stacks = 2
					slowdown_stacks = 2
				else //Lower than XENO_BOMB_RESIST_1
					b_loss = rand(45, 55)
					f_loss = rand(45, 55)
					stagger_stacks = 4
					slowdown_stacks = 4

	if(input_stagger_override)
		stagger_stacks = max(0, input_stagger_override)

	if(input_slowdown_override)
		slowdown_stacks = max(0, input_slowdown_override)

	adjust_stagger(stagger_stacks)
	add_slowdown(slowdown_stacks)
	apply_damage(b_loss, BRUTE)
	apply_damage(f_loss, BURN)
	UPDATEHEALTH(src)


/mob/living/carbon/xenomorph/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE)
	if(status_flags & (GODMODE))
		return
	var/hit_percent = (100 - blocked) * 0.01

	if(hit_percent <= 0) //total negation
		return 0

	damage *= CLAMP01(hit_percent) //Percentage reduction

	if(!damage) //no damage
		return 0

	//We still want to check for blood splash before we get to the damage application.
	var/chancemod = 0
	if(sharp)
		chancemod += 10
	if(edge) //Pierce weapons give the most bonus
		chancemod += 12
	if(def_zone != "chest") //Which it generally will be, vs xenos
		chancemod += 5

	if(damage > 12) //Light damage won't splash.
		check_blood_splash(damage, damagetype, chancemod)

	SEND_SIGNAL(src, COMSIG_XENOMORPH_TAKING_DAMAGE, damage)

	if(stat == DEAD)
		return FALSE

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage)
		if(BURN)
			adjustFireLoss(damage)

	if(updating_health)
		updatehealth()

	regen_power = -xeno_caste.regen_delay //Remember, this is in deciseconds.

	return damage


/mob/living/carbon/xenomorph/adjustBruteLoss(amount, updating_health = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_XENOMORPH_BRUTE_DAMAGE, amount, amount_mod)
	for(var/i in amount_mod)
		amount -= i

	bruteloss = clamp(bruteloss + amount, 0, maxHealth - xeno_caste.crit_health)

	if(updating_health)
		updatehealth()


/mob/living/carbon/xenomorph/adjustFireLoss(amount, updating_health = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_XENOMORPH_BURN_DAMAGE, amount, amount_mod)
	for(var/i in amount_mod)
		amount -= i

	fireloss = clamp(fireloss + amount, 0, maxHealth - xeno_caste.crit_health)

	if(updating_health)
		updatehealth()


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

		if(!(xeno_caste.caste_flags & CASTE_ACID_BLOOD))
			return
		var/splash_chance = 40 //Base chance of getting splashed. Decreases with # of victims.
		var/distance = 0 //Distance, decreases splash chance.
		var/i = 0 //Tally up our victims.
		for(var/mob/living/carbon/human/victim in range(radius,src)) //Loop through all nearby victims, including the tile.
			distance = get_dist(src,victim)

			splash_chance = 80 - (i * 5)
			if(victim.loc == loc)
				splash_chance += 30 //Same tile? BURN
			splash_chance += distance * -15
			i++
			victim.visible_message("<span class='danger'>\The [victim] is scalded with hissing green blood!</span>", \
			"<span class='danger'>You are splattered with sizzling blood! IT BURNS!</span>")
			if(victim.stat != CONSCIOUS && !(victim.species.species_flags & NO_PAIN) && prob(60))
				victim.emote("scream") //Topkek
			victim.take_limb_damage(0, rand(10, 25)) //Sizzledam! This automagically burns a random existing body part.
