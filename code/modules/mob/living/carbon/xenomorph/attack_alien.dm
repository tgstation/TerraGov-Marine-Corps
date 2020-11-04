/*
* Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
* For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
* In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
*/

//#define DEBUG_ATTACK_ALIEN

/mob/living/proc/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(X == src || anchored || buckled)
		return FALSE

	if(!Adjacent(X))
		return FALSE

	X.start_pulling(src)
	return TRUE

/mob/living/carbon/human/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(check_shields(COMBAT_TOUCH_ATTACK, X.xeno_caste.tackle_damage, "melee"))
		return ..()
	X.visible_message("<span class='danger'>\The [X]'s grab is blocked by [src]'s shield!</span>",
		"<span class='danger'>Our grab was blocked by [src]'s shield!</span>", null, 5)
	playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, TRUE) //Feedback
	return FALSE


/mob/living/proc/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	if(!prob(X.melee_accuracy))
		X.do_attack_animation(src)
		playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE)
		X.visible_message("<span class='danger'>\The [X] shoves at [src], narroly missing!</span>",
		"<span class='danger'>Our tackle against [src] narroly misses!</span>")
		return FALSE
	SEND_SIGNAL(src, COMSIG_LIVING_MELEE_ALIEN_DISARMED, X)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, TRUE)
	X.visible_message("<span class='warning'>\The [X] shoves [src]!</span>",
	"<span class='warning'>We shove [src]!</span>", null, 5)
	return TRUE

/mob/living/carbon/monkey/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	. = ..()
	if(!.)
		return
	Paralyze(16 SECONDS)

/mob/living/carbon/human/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	var/tackle_pain = X.xeno_caste.tackle_damage
	if(!tackle_pain)
		return FALSE
	if(isnestedhost(src)) //No more memeing nested and infected hosts
		to_chat(X, "<span class='xenodanger'>We reconsider our mean-spirited bullying of the pregnant, secured host.</span>")
		return FALSE
	if(!prob(X.melee_accuracy))
		X.do_attack_animation(src)
		playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE)
		X.visible_message("<span class='danger'>\The [X] shoves at [src], narroly missing!</span>",
		"<span class='danger'>Our tackle against [src] narroly misses!</span>")
		return FALSE
	tackle_pain = check_shields(COMBAT_MELEE_ATTACK, tackle_pain, "melee")
	if(!tackle_pain)
		X.do_attack_animation(src)
		X.visible_message("<span class='danger'>\The [X]'s tackle is blocked by [src]'s shield!</span>", \
		"<span class='danger'>Our tackle is blocked by [src]'s shield!</span>", null, 5)
		return FALSE
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)

	if(!IsParalyzed() && !no_stun && (traumatic_shock > 100))
		Paralyze(20)
		X.visible_message("<span class='danger'>\The [X] slams [src] to the ground!</span>", \
		"<span class='danger'>We slam [src] to the ground!</span>", null, 5)

	var/armor_block = run_armor_check("chest", "melee")

	playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, TRUE)

	if(protection_aura)
		tackle_pain = tackle_pain * (1 - (0.10 + 0.05 * protection_aura))  //Stamina damage decreased by 10% + 5% per rank of protection aura

	var/list/pain_mod = list()

	SEND_SIGNAL(X, COMSIG_XENOMORPH_DISARM_HUMAN, src, tackle_pain, pain_mod)

	for(var/i in pain_mod)
		tackle_pain += i

	if(dam_bonus)
		tackle_pain += dam_bonus

	apply_damage(tackle_pain, STAMINA, "chest", armor_block)
	updateshock()
	UPDATEHEALTH(src)
	var/throttle_message = "<span class='danger'>\The [X] throttles [src]!</span>"
	var/throttle_message2 = "<span class='danger'>We throttle [src]!</span>"
	if(tackle_pain > 40)
		throttle_message = "<span class='danger'>\The [X] badly throttles [src]!</span>"
		throttle_message2 = "<span class='danger'>We badly throttle [src]!</span>"
	X.visible_message("[throttle_message]", \
	"[throttle_message2]", null, 5)
	return TRUE

/mob/living/proc/can_xeno_slash(mob/living/carbon/xenomorph/X)
	if(CHECK_BITFIELD(X.xeno_caste.caste_flags, CASTE_IS_INTELLIGENT)) // intelligent ignore restrictions
		return TRUE

	if(X.hive.slashing_allowed == XENO_SLASHING_RESTRICTED)
		if(status_flags & XENO_HOST)
			for(var/obj/item/alien_embryo/embryo in src)
				if(!embryo.issamexenohive(X))
					continue
				to_chat(X, "<span class='warning'>We try to slash [src], but find we <B>cannot</B>. There is a host inside!</span>")
				return FALSE

		if(X.health > round(2 * X.maxHealth / 3)) //Note : Under 66 % health
			to_chat(X, "<span class='warning'>We try to slash [src], but find we <B>cannot</B>. We are not yet injured enough to overcome the Queen's orders.</span>")
			return FALSE

	else if(isnestedhost(src))
		for(var/obj/item/alien_embryo/embryo in src)
			if(!embryo.issamexenohive(X))
				continue
			to_chat(X, "<span class='warning'>We should not harm this host! It has a sister inside.</span>")
			return FALSE
	return TRUE

/mob/living/carbon/human/can_xeno_slash(mob/living/carbon/xenomorph/X)
	. = ..()
	if(!.)
		return FALSE
	if(!X.hive.slashing_allowed && !(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		to_chat(X, "<span class='warning'>Slashing is currently <b>forbidden</b> by the Queen. We refuse to slash [src].</span>")
		return FALSE

/mob/living/proc/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE)
	return

/mob/living/carbon/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE, ignore_destroyed = TRUE)
	var/datum/limb/affecting
	if(set_location)
		affecting = get_limb(set_location)
	else if(SEND_SIGNAL(X, COMSIG_XENOMORPH_ZONE_SELECT) & COMSIG_ACCURATE_ZONE)
		affecting = get_limb(X.zone_selected)
	else
		affecting = get_limb(ran_zone(X.zone_selected, 70))
	if(!affecting || (random_location && !set_location) || (ignore_destroyed && !affecting.is_usable())) //No organ or it's destroyed, just get a random one
		affecting = get_limb(ran_zone(null, 0))
	if(!affecting || (no_head && affecting == get_limb("head")) || (ignore_destroyed && !affecting.is_usable()))
		affecting = get_limb("chest")
	return affecting

/mob/living/proc/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(!can_xeno_slash(X))
		return FALSE

	if(!prob(X.melee_accuracy))
		playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE)
		X.visible_message("<span class='danger'>\The [X] slashes at [src], narroly missing!</span>",
		"<span class='danger'>Our slash against [src] narroly misses!</span>")
		return FALSE

	var/damage = X.xeno_caste.melee_damage
	if(!damage)
		return FALSE

	damage = check_shields(COMBAT_MELEE_ATTACK, damage, "melee")
	if(!damage)
		X.visible_message("<span class='danger'>\The [X]'s slash is blocked by [src]'s shield!</span>",
			"<span class='danger'>Our slash is blocked by [src]'s shield!</span>", null, COMBAT_MESSAGE_RANGE)
		return FALSE

	var/attack_sound = "alien_claw_flesh"
	var/attack_message1 = "<span class='danger'>\The [X] slashes [src]!</span>"
	var/attack_message2 = "<span class='danger'>We slash [src]!</span>"
	var/log = "slashed"

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(X.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		X.do_attack_animation(src)
		X.visible_message("<span class='danger'>\The [X] lunges at [src]!</span>", \
		"<span class='danger'>We lunge at [src]!</span>", null, 5)
		return FALSE

	X.do_attack_animation(src, ATTACK_EFFECT_REDSLASH)

	//The normal attack proceeds
	playsound(loc, attack_sound, 25, 1)
	X.visible_message("[attack_message1]", \
	"[attack_message2]")

	if(status_flags & XENO_HOST && stat != DEAD)
		log_combat(X, src, log, addition = "while they were infected")
	else //Normal xenomorph friendship with benefits
		log_combat(X, src, log)

	var/datum/limb/affecting = get_xeno_slash_zone(X, set_location, random_location, no_head)
	var/armor_block = run_armor_check(affecting, "melee")

	var/list/damage_mod = list()
	var/list/armor_mod = list()

	// if we don't get any non-stacking bonuses dont apply dam_bonus
	if(!( SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_LIVING, src, damage, damage_mod, armor_mod) & COMSIG_XENOMORPH_BONUS_APPLIED ))
		damage_mod += dam_bonus

	for(var/i in damage_mod)
		damage += i

	for(var/i in armor_mod)
		armor_block *= i

	apply_damage(damage, BRUTE, affecting, armor_block, TRUE, TRUE) //This should slicey dicey
	UPDATEHEALTH(src)


	return TRUE


/mob/living/silicon/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(stat == DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
		return FALSE
	. = ..()
	if(!.)
		return
	var/datum/effect_system/spark_spread/spark_system
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	spark_system.start(src)
	playsound(loc, "alien_claw_metal", 25, TRUE)


/mob/living/carbon/xenomorph/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(issamexenohive(X))
		X.visible_message("<span class='warning'>\The [X] nibbles [src].</span>",
		"<span class='warning'>We nibble [src].</span>", null, 5)
		return FALSE
	return ..()


/mob/living/carbon/human/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(stat == DEAD)
		if(length(light_sources))
			playsound(loc, "alien_claw_metal", 25, 1)
			X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
			disable_lights(sparks = TRUE)
			to_chat(X, "<span class='warning'>We disable whatever annoying lights the dead creature possesses.</span>")
		else
			to_chat(X, "<span class='warning'>[src] is dead, why would we want to touch it?</span>")
		return FALSE

	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_HUMAN, src)

	. = ..()
	if(!.)
		return FALSE

//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if (X.fortify)
		return FALSE

	var/intent = force_intent ? force_intent : X.a_intent

	switch(intent)
		if(INTENT_HELP)
			if(on_fire)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)
				ExtinguishMob()
				X.visible_message("<span class='danger'>[X] effortlessly extinguishes the fire on [src]!</span>",
					"<span class='notice'>We extinguished the fire on [src].</span>", null, 5)
				return TRUE
			X.visible_message("<span class='notice'>\The [X] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>We caress [src] with our scythe-like arm.</span>", null, 5)
			return FALSE

		if(INTENT_GRAB)
			return attack_alien_grab(X)

		if(INTENT_HARM)
			return attack_alien_harm(X, dam_bonus, set_location, random_location, no_head, no_crit, force_intent)

		if(INTENT_DISARM)
			return attack_alien_disarm(X, dam_bonus)
	return FALSE

/mob/living/attack_larva(mob/living/carbon/xenomorph/larva/M)
	M.visible_message("<span class='danger'>[M] nudges its head against [src].</span>", \
	"<span class='danger'>We nudge our head against [src].</span>", null, 5)
