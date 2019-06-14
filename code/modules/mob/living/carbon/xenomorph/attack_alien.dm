/*
 * Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
 * For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
 * In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
 */

//#define DEBUG_ATTACK_ALIEN

/mob/living/carbon/xenomorph/proc/reset_critical_hit()
	critical_proc = FALSE

/mob/living/carbon/xenomorph/proc/process_rage_attack()
	return FALSE

/mob/living/proc/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(X == src || anchored || buckled)
		return FALSE

	if(!Adjacent(X))
		return FALSE

	X.start_pulling(src)
	return TRUE

/mob/living/carbon/human/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(check_shields(0, X.name) && prob(66)) //Bit of a bonus
		X.visible_message("<span class='danger'>\The [X]'s grab is blocked by [src]'s shield!</span>", \
		"<span class='danger'>Your grab was blocked by [src]'s shield!</span>", null, 5)
		playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, 1) //Feedback
		return FALSE
	return ..()

/mob/living/proc/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
	X.visible_message("<span class='warning'>\The [X] shoves [src]!</span>", \
	"<span class='warning'>You shove [src]!</span>", null, 5)
	return TRUE

/mob/living/carbon/monkey/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	. = ..()
	KnockDown(8)

/mob/living/carbon/human/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	if(isnestedhost(src)) //No more memeing nested and infected hosts
		to_chat(X, "<span class='xenodanger'>You reconsider your mean-spirited bullying of the pregnant, secured host.</span>")
		return FALSE
	X.animation_attack_on(src)
	if(check_shields(0, X.name) && prob(66)) //Bit of a bonus
		X.visible_message("<span class='danger'>\The [X]'s tackle is blocked by [src]'s shield!</span>", \
		"<span class='danger'>Your tackle is blocked by [src]'s shield!</span>", null, 5)
		return FALSE
	X.flick_attack_overlay(src, "disarm")

	if(!knocked_down && !no_stun && (traumatic_shock > 100))
		KnockDown(1)
		X.visible_message("<span class='danger'>\The [X] slams [src] to the ground!</span>", \
		"<span class='danger'>You slam [src] to the ground!</span>", null, 5)

	var/armor_block = run_armor_check("chest", "melee")

	playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)

	var/tackle_pain = X.xeno_caste.tackle_damage
	if(X.frenzy_aura)
		tackle_pain = tackle_pain * (1 + (0.05 * X.frenzy_aura))  //Halloss damage increased by 5% per rank of frenzy aura
	if(protection_aura)
		tackle_pain = tackle_pain * (1 - (0.10 + 0.05 * protection_aura))  //Halloss damage decreased by 10% + 5% per rank of protection aura
	if(X.stealth_router(HANDLE_STEALTH_CHECK))
		if(X.stealth_router(HANDLE_SNEAK_ATTACK_CHECK))
			#ifdef DEBUG_ATTACK_ALIEN
			to_chat(world, "DEBUG_ALIEN_ATTACK SNEAK ATTACK: target: [src] last_move_intent: [X.last_move_intent] world.time minus run delay: [world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY]")
			#endif
			var/staggerslow_stacks = 2
			var/knockout_stacks = 1
			if(m_intent == MOVE_INTENT_RUN && ( X.last_move_intent > (world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY) ) ) //Allows us to slash while running... but only if we've been stationary for awhile
				tackle_pain *= 1.75 //Half the multiplier if running.
				X.visible_message("<span class='danger'>\The [X] strikes [src] with vicious precision!</span>", \
				"<span class='danger'>You strike [src] with vicious precision!</span>")
			else
				armor_block *= HUNTER_SNEAK_TACKLE_ARMOR_PEN //Tackle armor penetration heightened.
				tackle_pain *= 3.5 //Massive damage on the sneak attack... hope you have armour.
				staggerslow_stacks *= 2
				knockout_stacks *= 2
				X.visible_message("<span class='danger'>\The [X] strikes [src] with deadly precision!</span>", \
				"<span class='danger'>You strike [src] with deadly precision!</span>")
			KnockOut(knockout_stacks)
			adjust_stagger(staggerslow_stacks)
			add_slowdown(staggerslow_stacks)

	SEND_SIGNAL(X, COMSIG_XENOMORPH_DISARM_HUMAN, src)

	X.neuroclaw_router(src) //if we have neuroclaws...
	if(dam_bonus)
		tackle_pain += dam_bonus

	tackle_pain = X.hit_and_run_bonus(tackle_pain) //Apply Runner hit and run bonus damage if applicable

	apply_damage(tackle_pain, HALLOSS, "chest", armor_block * XENO_TACKLE_ARMOR_PEN) //Only half armour applies vs tackle
	updatehealth()
	updateshock()
	var/throttle_message = "<span class='danger'>\The [X] throttles [src]!</span>"
	var/throttle_message2 = "<span class='danger'>You throttle [src]!</span>"
	if(tackle_pain > 40)
		throttle_message = "<span class='danger'>\The [X] badly throttles [src]!</span>"
		throttle_message2 = "<span class='danger'>You badly throttle [src]!</span>"
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
				to_chat(X, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is a host inside!</span>")
				return FALSE

		if(X.health > round(2 * X.maxHealth / 3)) //Note : Under 66 % health
			to_chat(X, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>")
			return FALSE

	else if(isnestedhost(src))
		for(var/obj/item/alien_embryo/embryo in src)
			if(!embryo.issamexenohive(X))
				continue
			to_chat(X, "<span class='warning'>You should not harm this host! It has a sister inside.</span>")
			return FALSE
	return TRUE

/mob/living/carbon/human/can_xeno_slash(mob/living/carbon/xenomorph/X)
	. = ..()
	if(!.)
		return FALSE
	if(!X.hive.slashing_allowed && !(X.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
		to_chat(X, "<span class='warning'>Slashing is currently <b>forbidden</b> by the Queen. You refuse to slash [src].</span>")
		return FALSE

/mob/living/proc/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE)
	return

/mob/living/carbon/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE)
	var/datum/limb/affecting
	if(set_location)
		affecting = get_limb(set_location)
	else if(X.stealth_router(HANDLE_STEALTH_CHECK) && X.stealth_router(HANDLE_SNEAK_ATTACK_CHECK)) //We always get the limb we're aiming for if we're sneak attacking
		affecting = get_limb(X.zone_selected)
	else
		affecting = get_limb(ran_zone(X.zone_selected, 70))
	if(!affecting || (random_location && !set_location)) //No organ, just get a random one
		affecting = get_limb(ran_zone(null, 0))
	if(no_head && affecting == get_limb("chest"))
		affecting = get_limb("chest")
	if(!affecting) //Still nothing??
		affecting = get_limb("chest") //Gotta have a torso?!
	return affecting

/mob/living/proc/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(!can_xeno_slash(X))
		return FALSE

	// copypasted from attack_alien.dm
	//From this point, we are certain a full attack will go out. Calculate damage and modifiers
	var/damage = rand(X.xeno_caste.melee_damage_lower, X.xeno_caste.melee_damage_upper) + FRENZY_DAMAGE_BONUS(X)

	X.animation_attack_on(src)

	var/attack_flick =  "slash"
	var/attack_sound = "alien_claw_flesh"
	var/attack_message1 = "<span class='danger'>\The [X] slashes [src]!</span>"
	var/attack_message2 = "<span class='danger'>You slash [src]!</span>"
	var/log = "slashed"
	//Check for a special bite attack
	if(prob(X.xeno_caste.bite_chance) && !X.critical_proc && !no_crit && !X.stealth_router(HANDLE_STEALTH_CHECK)) //Can't crit if we already crit in the past 3 seconds; stealthed ironically can't crit because weeoo das a lotta damage
		damage *= 1.5
		attack_sound = "alien_bite"
		attack_message1 = "<span class='danger'>\The [src] is viciously shredded by \the [X]'s sharp teeth!</span>"
		attack_message2 = "<span class='danger'>You viciously rend \the [src] with your teeth!</span>"
		log = "bit"
		X.critical_proc = TRUE
		addtimer(CALLBACK(X, /mob/living/carbon/xenomorph/proc/reset_critical_hit), X.xeno_caste.rng_min_interval)

	//Check for a special bite attack
	if(prob(X.xeno_caste.tail_chance) && !X.critical_proc && !no_crit && !X.stealth_router(HANDLE_STEALTH_CHECK)) //Can't crit if we already crit in the past 3 seconds; stealthed ironically can't crit because weeoo das a lotta damage
		damage *= 1.25
		attack_flick = "tail"
		attack_sound = 'sound/weapons/alien_tail_attack.ogg'
		attack_message1 = "<span class='danger'>\The [src] is suddenly impaled by \the [X]'s sharp tail!</span>"
		attack_message2 = "<span class='danger'>You violently impale \the [src] with your tail!</span>"
		log = "tail-stabbed"
		X.critical_proc = TRUE
		addtimer(CALLBACK(X, /mob/living/carbon/xenomorph/proc/reset_critical_hit), X.xeno_caste.rng_min_interval)

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(X.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		X.animation_attack_on(src)
		X.visible_message("<span class='danger'>\The [X] lunges at [src]!</span>", \
		"<span class='danger'>You lunge at [src]!</span>", null, 5)
		return FALSE

	X.flick_attack_overlay(src, attack_flick)

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

	if(X.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
		if(X.stealth_router(HANDLE_SNEAK_ATTACK_CHECK)) //Pouncing prevents us from making a sneak attack for 4 seconds
			#ifdef DEBUG_ATTACK_ALIEN
			to_chat(world, "DEBUG_ALIEN_ATTACK SNEAK ATTACK: target: [src] last_move_intent: [M.last_move_intent] world.time minus run delay: [world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY]")
			#endif
			var/staggerslow_stacks = 2
			var/knockout_stacks = 1
			damage *= X.sneak_bonus //Massive damage on the sneak attack... hope you have armour.
			if(m_intent == MOVE_INTENT_RUN && ( X.last_move_intent > (world.time - HUNTER_SNEAK_ATTACK_RUN_DELAY) ) ) //Allows us to slash while running... but only if we've been stationary for awhile
			//...And we knock them out
				X.visible_message("<span class='danger'>\The [X] strikes [src] with vicious precision!</span>", \
				"<span class='danger'>You strike [src] with vicious precision!</span>")
			else
				armor_block *= HUNTER_SNEAK_SLASH_ARMOR_PEN //20% armor penetration
				staggerslow_stacks *= 2
				knockout_stacks *= 2
				X.visible_message("<span class='danger'>\The [X] strikes [src] with deadly precision!</span>", \
				"<span class='danger'>You strike [src] with deadly precision!</span>")
			KnockOut(knockout_stacks) //...And we knock 
			adjust_stagger(staggerslow_stacks)
			add_slowdown(staggerslow_stacks)

	if(dam_bonus)
		damage += dam_bonus
	else //We avoid stacking, like hit-and-run and savage.
		damage = X.hit_and_run_bonus(damage) //Apply Runner hit and run bonus damage if applicable

	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_LIVING, src)

	apply_damage(damage, BRUTE, affecting, armor_block, sharp = TRUE, edge = TRUE) //This should slicey dicey
	updatehealth()

/mob/living/silicon/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(stat != DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
		var/datum/effect_system/spark_spread/spark_system
		spark_system = new /datum/effect_system/spark_spread()
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)
		playsound(loc, "alien_claw_metal", 25, 1)
	return ..()

/mob/living/carbon/xenomorph/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(issamexenohive(X))
		X.visible_message("<span class='warning'>\The [X] nibbles [src].</span>", \
		"<span class='warning'>You nibble [src].</span>", null, 5)
		return TRUE
	return ..()

/mob/living/carbon/human/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(stat == DEAD)
		if(luminosity > 0)
			playsound(loc, "alien_claw_metal", 25, 1)
			X.flick_attack_overlay(src, "slash")
			disable_lights(sparks = TRUE)
			to_chat(X, "<span class='warning'>You disable whatever annoying lights the dead creature possesses.</span>")
		else
			to_chat(X, "<span class='warning'>[src] is dead, why would you want to touch it?</span>")
		return FALSE

	if(check_shields(0, X.name) && prob(66)) //Bit of a bonus
		X.visible_message("<span class='danger'>\The [X]'s slash is blocked by [src]'s shield!</span>", \
		"<span class='danger'>Your slash is blocked by [src]'s shield!</span>", null, 5)
		return FALSE

	. = ..()
	if(!.)
		return FALSE
	
	X.neuroclaw_router(src) //if we have neuroclaws...
	X.process_rage_attack() //Process Ravager rage gains on attack

//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if (X.fortify)
		return FALSE

	var/intent = force_intent ? force_intent : X.a_intent

	switch(intent)
		if(INTENT_HELP)
			X.visible_message("<span class='notice'>\The [X] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)
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
	"<span class='danger'>You nudge your head against [src].</span>", null, 5)

/obj/attack_larva(mob/living/carbon/xenomorph/larva/M)
	return //larva can't do anything by default
