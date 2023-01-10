/mob/living/carbon/xenomorph/fire_act()
	if(status_flags & GODMODE)
		return
	return ..()

/mob/living/carbon/xenomorph/modify_by_armor(damage_amount, armor_type, penetration, def_zone)
	var/hard_armor_modifier = get_hard_armor(armor_type, def_zone)
	hard_armor_modifier = hard_armor_modifier - (hard_armor_modifier * penetration * 0.01)
	var/soft_armor_modifier = min((1 - ((get_soft_armor(armor_type, def_zone) - penetration) * 0.01)), 1)
	return clamp(((damage_amount - hard_armor_modifier) * soft_armor_modifier), 0, damage_amount)

/mob/living/carbon/xenomorph/ex_act(severity)
	if(status_flags & (INCORPOREAL|GODMODE))
		return

	var/bomb_armor = soft_armor.getRating("bomb")
	if(bomb_armor >= 100)
		return //immune

	var/bomb_effective_armor = (bomb_armor/100)*get_sunder()
	var/bomb_slow_multiplier = max(0, 1 - 3.5*bomb_effective_armor)
	var/bomb_sunder_multiplier = max(0, 1 - bomb_effective_armor)

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
	adjust_sunder(max(0, 50 * (3 - severity) * bomb_sunder_multiplier * get_sunder()))

	//Damage
	var/ex_damage = 40 + rand(0, 20) + 50*(4 - severity)  //changed so overall damage stays similar
	apply_damages(ex_damage * 0.5, ex_damage * 0.5, blocked = BOMB, updating_health = TRUE)


/mob/living/carbon/xenomorph/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration)
	if(status_flags & GODMODE)
		return
	if(damagetype != BRUTE && damagetype != BURN)
		return
	if(isnum(blocked))
		damage -= clamp(damage * (blocked - penetration) * 0.01, 0, damage)
	else
		damage = modify_by_armor(damage, blocked, penetration, def_zone)

	if(!damage) //no damage
		return 0

	if(damage > 12) //Light damage won't splash.
		check_blood_splash(damage, damagetype, 0, 1, sharp, edge)

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

	if(isobj(pulling))
		stop_pulling()


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

	xeno_message("Our sister [name] is badly hurt with <font color='red'>([health]/[maxHealth])</font> health remaining at [AREACOORD_NO_Z(src)]!", "xenoannounce", 5, hivenumber, FALSE, src, 'sound/voice/alien_help1.ogg', TRUE, filter_list, /atom/movable/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, xeno_health_alert_cooldown, XENO_HEALTH_ALERT_COOLDOWN) //set the cooldown.

	return damage

///Handles overheal for xeno receiving damage
#define HANDLE_OVERHEAL(amount) \
	if(overheal && amount > 0) { \
		var/reduction = min(amount, overheal); \
		amount -= reduction; \
		adjustOverheal(src, -reduction); \
	} \

/mob/living/carbon/xenomorph/adjustBruteLoss(amount, updating_health = FALSE, passive = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_XENOMORPH_BRUTE_DAMAGE, amount, amount_mod, passive)
	for(var/i in amount_mod)
		amount -= i

	HANDLE_OVERHEAL(amount)

	bruteloss = max(bruteloss + amount, 0)

	if(updating_health)
		updatehealth()

/mob/living/carbon/xenomorph/adjustFireLoss(amount, updating_health = FALSE, passive = FALSE)
	var/list/amount_mod = list()
	SEND_SIGNAL(src, COMSIG_XENOMORPH_BURN_DAMAGE, amount, amount_mod, passive)
	for(var/i in amount_mod)
		amount -= i

	HANDLE_OVERHEAL(amount)

	fireloss = max(fireloss + amount, 0)

	if(updating_health)
		updatehealth()

#undef HANDLE_OVERHEAL

/mob/living/carbon/xenomorph/proc/check_blood_splash(damage = 0, damtype = BRUTE, chancemod = 0, radius = 1, sharp = FALSE, edge = FALSE)
	if(!damage)
		return FALSE
	var/chance = 25 //base chance
	if(damtype == BRUTE)
		chance += 5
	if(sharp)
		chancemod += 10
	if(edge) //Pierce weapons give the most bonus
		chancemod += 12
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
		var/splash_chance
		for(var/mob/living/carbon/human/victim in range(radius,src)) //Loop through all nearby victims, including the tile.
			splash_chance = (chance * 2) - (get_dist(src,victim) * 20)
			if(prob(splash_chance))
				victim.visible_message(span_danger("\The [victim] is scalded with hissing green blood!"), \
				span_danger("You are splattered with sizzling blood! IT BURNS!"))
				if(victim.stat != CONSCIOUS && !(victim.species.species_flags & NO_PAIN) && prob(60))
					victim.emote("scream")
				victim.take_overall_damage(rand(15, 30), BURN, ACID, updating_health = TRUE)
