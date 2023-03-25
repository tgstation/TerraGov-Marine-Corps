/mob/living/carbon/xenomorph/slime
	caste_base_type = /mob/living/carbon/xenomorph/slime
	name = "Slime"
	desc = "A viscous, squishy and oozy substance. It quivers every now and then, as if it were alive."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Slime Walking"
	speak_emote = list("blurbs", "blorbs")
	attacktext = "burns"
	bubble_icon = "alienleft"
	alpha = 200
	health = 225
	maxHealth = 225
	plasma_stored = 125
	pixel_x = 0
	old_x = 0
	pull_speed = -2
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	flags_pass = PASSTABLE
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

// ***************************************
// *********** Overrides
// ***************************************
/mob/living/carbon/xenomorph/slime/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/slime/attack_animal(mob/living/M as mob)
	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(!S.melee_damage)
			M.do_attack_animation(src)
			S.emote("me", EMOTE_VISIBLE, "[S.friendly] [src]")
		else
			M.do_attack_animation(src, ATTACK_EFFECT_SLIME_ATTACK)
			visible_message(span_danger("[S] [S.attacktext] [src]!"), null, null, 5)
			var/damage = S.melee_damage
			apply_damage(damage, BURN, blocked = ACID)
			UPDATEHEALTH(src)
			log_combat(S, src, "attacked")

/mob/living/carbon/xenomorph/slime/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(lying_angle)
		return FALSE
	if(isclosedturf(get_turf(src)) && !iswallturf(A))	//If we are on a closed turf (e.g. in a wall) we can't attack anything, except walls (or well, resin walls really) so we can't make ourselves be stuck.
		balloon_alert(src, "Cannot reach")
		return FALSE
	if(!(isopenturf(A) || istype(A, /obj/alien/weeds))) //We don't care about open turfs; they don't trigger our melee click cooldown
		changeNext_move(xeno_caste ? xeno_caste.attack_delay : CLICK_CD_MELEE)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src, xeno_caste.melee_damage * xeno_melee_damage_modifier, BURN, isrightclick = islist(modifiers) ? modifiers["right"] : FALSE)
	GLOB.round_statistics.xeno_unarmed_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_unarmed_attacks")

/mob/living/carbon/xenomorph/slime/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BURN, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(status_flags & INCORPOREAL || X.status_flags & INCORPOREAL)
		return
	if(src == X)
		return TRUE
	switch(X.a_intent)
		if(INTENT_HELP)
			if(on_fire)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				X.visible_message(span_danger("[X] tries to put out the fire on [src]!"), \
					span_warning("We try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					X.visible_message(span_danger("[X] has successfully extinguished the fire on [src]!"), \
						span_notice("We extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE
			X.visible_message(span_notice("\The [X] caresses \the [src] with a slimy tendril."), \
			span_notice("We caress \the [src] with a slimy tendril."), null, 5)
		if(INTENT_GRAB)
			if(anchored)
				return FALSE
			if(!X.start_pulling(src))
				return FALSE
			X.visible_message(span_warning("[X] grabs \the [src]!"), \
			span_warning("We grab \the [src]!"), null, 5)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
		if(INTENT_HARM, INTENT_DISARM)
			if(issamexenohive(X))
				X.do_attack_animation(src)
				X.visible_message(span_warning("\The [X] nuzzle \the [src]."), \
				span_warning("We nuzzle \the [src]."), null, 5)
				return TRUE
			var/damage = X.xeno_caste.melee_damage
			if(!damage)
				X.do_attack_animation(src)
				playsound(X.loc, 'sound/effects/attackblob.ogg', 25, 1)
				X.visible_message(span_danger("\The [X] lunges at [src]!"), \
				span_danger("We lunge at [src]!"), null, 5)
				return FALSE
			X.visible_message(span_danger("\The [X] burns [src]!"), \
			span_danger("We burn [src]!"), null, 5)
			log_combat(X, src, "burned")
			X.do_attack_animation(src, ATTACK_EFFECT_SLIME_ATTACK)
			playsound(loc, 'sound/effects/attackblob.ogg', 25, 1)
			apply_damage(damage, damage_type, blocked = ACID, updating_health = TRUE)
			if(isliving(src))
				if(!HAS_TRAIT(src, TRAIT_INTOXICATION_IMMUNE))
					if(has_status_effect(STATUS_EFFECT_INTOXICATED))
						var/datum/status_effect/stacking/intoxicated/debuff = has_status_effect(STATUS_EFFECT_INTOXICATED)
						debuff.add_stacks(SLIME_ATTACK_INTOXICATION_STACKS + X.xeno_caste.additional_stacks)
						return TRUE
					apply_status_effect(STATUS_EFFECT_INTOXICATED, SLIME_ATTACK_INTOXICATION_STACKS + X.xeno_caste.additional_stacks)
