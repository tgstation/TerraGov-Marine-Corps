/mob/living/carbon/xenomorph/fire_act()
	if(status_flags & GODMODE)
		return
	return ..()

/mob/living/carbon/xenomorph/ex_act(severity)
	if(status_flags & (INCORPOREAL|GODMODE))
		return


	var/bomb_armor = soft_armor.getRating("bomb")
	var/bomb_effective_armor = (bomb_armor/100)*get_sunder()
	var/bomb_damage_multiplier = max(0, 1 - bomb_effective_armor)
	var/bomb_slow_multiplier = max(0, 1 - 3.5*bomb_effective_armor)
	var/bomb_sunder_multiplier = max(0, 1 - bomb_effective_armor)


	if(bomb_armor >= 100)
		return //immune

	//lowered to account for new armor values but keep old gibs
	//probs needs to be a define somewhere
	var/gib_min_armor = 10
	if(severity == EXPLODE_DEVASTATE && bomb_armor < gib_min_armor)
		return gib()    //Gibs unprotected benos

	//Slowdown and stagger
	var/ex_slowdown = (2 + (4 - severity)) * bomb_slow_multiplier

	add_slowdown(max(0, ex_slowdown)) //Slowdown 2 for sentiel from nade
	adjust_stagger(max(0, ex_slowdown - 2)) //Stagger 2 less than slowdown

	//Sunder
	var/sunder_loss = 50*(3 - severity) * bomb_sunder_multiplier
	adjust_sunder(max(0, sunder_loss))

	//Damage
	var/ex_damage = 40 + rand(0, 20) + 50*(4 - severity)  //changed so overall damage stays similar
	ex_damage *= bomb_damage_multiplier

	apply_damage(ex_damage/2, BRUTE, updating_health = TRUE)
	apply_damage(ex_damage/2, BURN, updating_health = TRUE)


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

	if(!damage) //If we've actually taken damage, check whether we alert the hive
		return

	if(!COOLDOWN_CHECK(src, xeno_health_alert_cooldown))
		return
	//If we're alive and health is less than either the alert threshold, or the alert trigger percent, whichever is greater, and we're not on alert cooldown, trigger the hive alert
	if(stat == DEAD || (health > max(XENO_HEALTH_ALERT_TRIGGER_THRESHOLD, maxHealth * XENO_HEALTH_ALERT_TRIGGER_PERCENT)) || xeno_caste.caste_flags & CASTE_DO_NOT_ALERT_LOW_LIFE)
		return

	var/list/filter_list = list()
	for(var/i in hive.get_all_xenos())

		var/mob/living/carbon/xenomorph/X = i
		if(!X.client) //Don't bother if they don't have a client; also runtime filters
			continue

		if(X == src) //We don't need an alert about ourself.
			filter_list += X //Add the xeno to the filter list

		if(X.client.prefs.mute_xeno_health_alert_messages) //Build the filter list; people who opted not to receive health alert messages
			filter_list += X //Add the xeno to the filter list

	xeno_message("Our sister [name] is badly hurt with <font color='red'>([health]/[maxHealth])</font> health remaining at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, hivenumber, FALSE, src, 'sound/voice/alien_help1.ogg', TRUE, filter_list, /obj/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, xeno_health_alert_cooldown, XENO_HEALTH_ALERT_COOLDOWN) //set the cooldown.

	return damage

///Handles overheal for xeno receiving damage
#define HANDLE_OVERHEAL(amount) \
	if(overheal && amount > 0) { \
		var/reduction = min(amount, overheal); \
		amount -= reduction; \
		adjustOverheal(src, -reduction); \
	} \

/mob/living/carbon/xenomorph/adjustBruteLoss(amount, updating_health = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_XENOMORPH_BRUTE_DAMAGE, amount, amount_mod)
	for(var/i in amount_mod)
		amount -= i

	HANDLE_OVERHEAL(amount)

	bruteloss = max(bruteloss + amount, 0)

	if(updating_health)
		updatehealth()

/mob/living/carbon/xenomorph/adjustFireLoss(amount, updating_health = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_XENOMORPH_BURN_DAMAGE, amount, amount_mod)
	for(var/i in amount_mod)
		amount -= i

	HANDLE_OVERHEAL(amount)

	fireloss = max(fireloss + amount, 0)

	if(updating_health)
		updatehealth()

/mob/living/carbon/xenomorph/proc/apply_healing(amount = 0, damagetype = BRUTE, updating_health = FALSE)
	SEND_SIGNAL(src, COMSIG_XENOMORPH_HEALED_BY_ABILITY, amount, damagetype)

	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(-amount)
		if(BURN)
			adjustFireLoss(-amount)

	if(updating_health)
		updatehealth()
	return amount

#undef HANDLE_OVERHEAL

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
			victim.visible_message(span_danger("\The [victim] is scalded with hissing green blood!"), \
			span_danger("You are splattered with sizzling blood! IT BURNS!"))
			if(victim.stat != CONSCIOUS && !(victim.species.species_flags & NO_PAIN) && prob(60))
				victim.emote("scream") //Topkek
			victim.take_limb_damage(0, rand(10, 25)) //Sizzledam! This automagically burns a random existing body part.
