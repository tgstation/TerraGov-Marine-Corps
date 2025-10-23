/*
* Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
* For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
* In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
*/

//#define DEBUG_ATTACK_ALIEN

/mob/living/proc/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(X == src || anchored || buckled || X.buckled)
		return FALSE
	if(!Adjacent(X))
		return FALSE
	if(!X.start_pulling(src))
		return FALSE
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
	return TRUE

/mob/living/carbon/human/attack_alien_grab(mob/living/carbon/xenomorph/X)
	if(check_shields(COMBAT_TOUCH_ATTACK, X.xeno_caste.melee_damage, "melee"))
		return ..()
	X.visible_message(span_danger("\The [X]'s grab is blocked by [src]'s shield!"),
		span_danger("Our grab was blocked by [src]'s shield!"), null, 5)
	playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, TRUE) //Feedback
	return FALSE


/mob/living/proc/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)

	SEND_SIGNAL(src, COMSIG_LIVING_MELEE_ALIEN_DISARMED, X)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, TRUE)
	X.visible_message(span_warning("\The [X] shoves [src]!"),
	span_warning("We shove [src]!"), null, 5)
	return TRUE

/mob/living/carbon/human/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus)
	var/randn = rand(1, 100)
	var/stamina_loss = getStaminaLoss()
	var/disarmdamage = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier * 3
	var/damage_to_deal = clamp(disarmdamage, 0, maxHealth - stamina_loss)
	damage_to_deal += (disarmdamage - damage_to_deal)/12
	var/sound = 'sound/weapons/alien_knockdown.ogg'

	if (ishuman(src))
		if(IsParalyzed())
			X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
			X.visible_message(null, "<span class='info'>We keep holding [src] down.</span>", null)
			apply_damage(damage_to_deal, STAMINA, BODY_ZONE_CHEST, MELEE)
			sound = 'sound/weapons/thudswoosh.ogg'
			var/obj/item/radio/headset/mainship/headset = wear_ear
			if(istype(headset))
				headset.disable_locator(40 SECONDS)
		else
			X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
			if(pulling)
				X.visible_message("<span class='danger'>[X] has broken [src]'s grip on [pulling]!</span>",
				"<span class='danger'>We break [src]'s grip on [pulling]!</span>", null, 5)
				sound = 'sound/weapons/thudswoosh.ogg'
				stop_pulling()
			else if(prob(10) && drop_held_item())
				X.visible_message("<span class='danger'>[X] has disarmed [src]!</span>",
				"<span class='danger'>We disarm [src]!</span>", null, 5)
				sound = 'sound/weapons/thudswoosh.ogg'
			apply_damage(damage_to_deal, STAMINA, BODY_ZONE_CHEST, MELEE)
			X.visible_message("<span class='danger'>[X] wrestles [src]-!</span>",
			"<span class='danger'>We wrestle [src]!</span>", null, 5)
			Stagger(2 SECONDS)
			if(stamina_loss >= maxHealth)
				if(!IsParalyzed())
					visible_message(null, "<span class='danger'>You are too weakened to keep resisting [X], you slump to the ground!</span>")
					X.visible_message("<span class='danger'>[X] slams [src] to the ground!</span>",
					"<span class='danger'>We slam [src] to the ground!</span>", null, 5)
					Paralyze(10 SECONDS)
					var/obj/item/radio/headset/mainship/headset = wear_ear
					if(istype(headset))
						headset.disable_locator(40 SECONDS)
		SEND_SIGNAL(X, COMSIG_XENOMORPH_DISARM_HUMAN, src, damage_to_deal)
	else if(!ishuman(src))
		if(randn <= 40)
			if(!IsParalyzed())
				X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
				X.visible_message("<span class='danger'>[X] shoves and presses [src] down!</span>",
				"<span class='danger'>We shove and press [src] down!</span>", null, 5)
				visible_message(null, "<span class='danger'>You are too weakened to keep resisting [X], you slump to the ground!</span>")
				X.visible_message("<span class='danger'>[X] slams [src] to the ground!</span>",
				"<span class='danger'>We slam [src] to the ground!</span>", null, 5)
				Paralyze(8 SECONDS)
			else if(IsParalyzed())
				X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
				X.visible_message(null, "<span class='info'>We could not do much to [src], they are already down.</span>", null)
				sound = 'sound/weapons/punchmiss.ogg'
		else if(randn > 40)
			X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
			sound = 'sound/weapons/punchmiss.ogg'
			X.visible_message("<span class='danger'>[X] attempted to disarm [src] but they resist!</span>",
			"<span class='danger'>We attempt to disarm [src] but it resisted!</span>", null, 5)
			Stagger(2 SECONDS)


	log_combat(X, src, "disarmed")
	playsound(loc, sound, 25, TRUE, 7)
//	else;
//		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, 7)
//		X.visible_message("<span class='danger'>[X] attempted to disarm [src]!</span>",
//		"<span class='danger'>We attempt to disarm [src]!</span>", null, 5)
//		return


/mob/living/proc/can_xeno_slash(mob/living/carbon/xenomorph/X)
	return !(status_flags & INCORPOREAL)

/mob/living/proc/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE)
	return

/mob/living/carbon/get_xeno_slash_zone(mob/living/carbon/xenomorph/X, set_location = FALSE, random_location = FALSE, no_head = FALSE, ignore_destroyed = TRUE)
	var/datum/limb/affecting
	if(set_location)
		affecting = get_limb(set_location)
	else if(SEND_SIGNAL(X, COMSIG_XENOMORPH_ZONE_SELECT) & COMSIG_ACCURATE_ZONE)
		affecting = get_limb(X.zone_selected)
	else
		affecting = get_limb(ran_zone(X.zone_selected, XENO_DEFAULT_ACCURACY - X.xeno_caste.accuracy_malus))
	if(!affecting || (random_location && !set_location) || (ignore_destroyed && !affecting.is_usable())) //No organ or it's destroyed, just get a random one
		affecting = get_limb(ran_zone(null, 0))
	if(!affecting || (no_head && affecting == get_limb("head")) || (ignore_destroyed && !affecting.is_usable()))
		affecting = get_limb("chest")
	return affecting

/mob/living/proc/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

	if(!can_xeno_slash(X))
		return FALSE

	var/damage = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier
	if(!damage)
		return FALSE

	var/datum/limb/affecting = get_xeno_slash_zone(X, set_location, random_location, no_head)
	var/armor_block = 0

	var/list/damage_mod = list()
	var/list/armor_mod = list()

	var/signal_return = SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_LIVING, src, damage, damage_mod, armor_mod)

	// if we don't get any non-stacking bonuses dont apply dam_bonus
	if(!(signal_return & COMSIG_XENOMORPH_BONUS_APPLIED))
		damage_mod += dam_bonus
		//locate() subtypes aswell, whichever the mob has.
		var/datum/action/ability/xeno_action/stealth/stealth_skill = locate() in X.actions
		if(stealth_skill)
			if(stealth_skill.can_sneak_attack)
				var/datum/action/ability/activable/xeno/hunter_mark/assassin/mark = X.actions_by_path[/datum/action/ability/activable/xeno/hunter_mark/assassin]
				if(mark?.marked_target == src) //assassin death mark
					damage *= 2

	var/armor_pen = X.xeno_caste.melee_ap

	if(!(signal_return & COMPONENT_BYPASS_ARMOR))
		armor_block = X.xeno_caste.melee_damage_armor

	for(var/i in damage_mod)
		damage += i

	for(var/i in armor_mod)
		armor_pen += i

	if(!(signal_return & COMPONENT_BYPASS_SHIELDS))
		damage = check_shields(COMBAT_MELEE_ATTACK, damage, "melee")

	if(!damage)
		X.visible_message(span_danger("\The [X]'s slash is blocked by [src]'s shield!"),
			span_danger("Our slash is blocked by [src]'s shield!"), null, COMBAT_MESSAGE_RANGE)
		return FALSE

	var/attack_message1 = span_danger("\The [X] slashes [src]!")
	var/attack_message2 = span_danger("We slash [src]!")
	var/log = "slashed"

	//Somehow we will deal no damage on this attack
	if(!damage)
		playsound(X.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
		X.do_attack_animation(src)
		X.visible_message(span_danger("\The [X] lunges at [src]!"), \
		span_danger("We lunge at [src]!"), null, 5)
		return FALSE

	var/attack_effect = islist(X.attack_effect) ? pick(X.attack_effect) : X.attack_effect
	X.do_attack_animation(src, attack_effect)

	//The normal attack proceeds
	playsound(loc, X.attack_sound, 25, 1)
	X.visible_message("[attack_message1]", \
	"[attack_message2]")

	if(status_flags & XENO_HOST && stat != DEAD)
		log_combat(X, src, log, addition = "while they were infected")
	else //Normal xenomorph friendship with benefits
		log_combat(X, src, log)

	record_melee_damage(X, damage)
	var/damage_done = apply_damage(damage, X.xeno_caste.melee_damage_type, affecting, armor_block, TRUE, TRUE, TRUE, armor_pen, X) //This should slicey dicey
	new /obj/effect/temp_visual/dir_setting/bloodsplatter(loc, Get_Angle(X, src), get_blood_color())
	SEND_SIGNAL(X, COMSIG_XENOMORPH_POSTATTACK_LIVING, src, damage_done, damage_mod)

	return TRUE

/mob/living/silicon/attack_alien_disarm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

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
	playsound(loc, SFX_ALIEN_CLAW_METAL, 25, TRUE)

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
	playsound(loc, SFX_ALIEN_CLAW_METAL, 25, TRUE)


/mob/living/carbon/xenomorph/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if(issamexenohive(X))
		X.visible_message(span_warning("\The [X] nibbles [src]."),
		span_warning("We nibble [src]."), null, 5)
		X.do_attack_animation(src)
		return FALSE
	return ..()


/mob/living/carbon/human/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)

	if(stat == DEAD)
		if(istype(wear_ear, /obj/item/radio/headset/mainship))
			var/obj/item/radio/headset/mainship/cam_headset = wear_ear
			if(cam_headset?.camera?.status)
				cam_headset.camera.toggle_cam(null, FALSE)
				playsound(loc, SFX_ALIEN_CLAW_METAL, 25, 1)
				X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
				to_chat(X, span_warning("We disable the creatures hivemind sight apparatus."))
				return FALSE

		if(length(static_light_sources) || length(hybrid_light_sources) || length(affected_movable_lights))
			playsound(loc, SFX_ALIEN_CLAW_METAL, 25, 1)
			X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
			disable_lights(sparks = TRUE)
			to_chat(X, span_warning("We disable whatever annoying lights the dead creature possesses."))
		else
			to_chat(X, span_warning("[src] is dead, why would we want to touch it?"))
		return FALSE

	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_HUMAN, src)

	. = ..()
	if(!.)
		return FALSE

//Every other type of nonhuman mob //MARKER OVERRIDE
/mob/living/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if (xeno_attacker.fortify || xeno_attacker.behemoth_charging || xeno_attacker.endurance_active)
		return FALSE

	switch(xeno_attacker.a_intent)
		if(INTENT_HELP)
			if(on_fire)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				xeno_attacker.visible_message(span_danger("[xeno_attacker] tries to put out the fire on [src]!"), \
					span_warning("We try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					xeno_attacker.visible_message(span_danger("[xeno_attacker] has successfully extinguished the fire on [src]!"), \
						span_notice("We extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE
			xeno_attacker.visible_message(span_notice("\The [xeno_attacker] caresses \the [src] with [xeno_attacker.p_their()] scythe-like arm."), \
			span_notice("We caress \the [src] with our scythe-like arm."), null, 5)
			return FALSE

		if(INTENT_GRAB)
			return attack_alien_grab(xeno_attacker)

		if(INTENT_HARM)
			SEND_SIGNAL(xeno_attacker, COMSIG_XENOMORPH_PRE_ATTACK_ALIEN_HARM, src, isrightclick)
			return attack_alien_harm(xeno_attacker)

		if(INTENT_DISARM)
			return attack_alien_disarm(xeno_attacker)
	return FALSE

/mob/living/attack_larva(mob/living/carbon/xenomorph/larva/M)
	M.visible_message(span_danger("[M] nudges [M.p_their()] head against [src]."), \
	span_danger("We nudge our head against [src]."), null, 5)
