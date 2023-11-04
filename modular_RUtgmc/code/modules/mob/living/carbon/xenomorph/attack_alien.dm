/mob/living/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, damage_amount = F.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(F.status_flags & INCORPOREAL)
		return FALSE
	switch(F.a_intent)
		if(INTENT_HELP, INTENT_GRAB) //Try to hug target if this is a human
			if(ishuman(src))
				F.visible_message(null, span_notice("We're starting to climb on [src]"), null, 5)
				if(!do_after(F, 2 SECONDS, TRUE, F, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE, extra_checks = CALLBACK(F, TYPE_PROC_REF(/datum, Adjacent), src)))
					F.balloon_alert(F, "Climbing interrupted")
					return FALSE
				F.try_attach(src)
			else if(on_fire)
				F.visible_message(span_danger("[F] stares at [src]."), \
				span_notice("We stare at the roasting [src], toasty."), null, 5)
			else
				F.visible_message(span_notice("[F] stares at [src]."), \
				span_notice("We stare at [src]."), null, 5)
			return FALSE
		if(INTENT_HARM, INTENT_DISARM)
			return attack_alien_harm(F)
	return FALSE

/mob/living/carbon/human/attack_alien_harm(mob/living/carbon/xenomorph/X, dam_bonus, set_location, random_location, no_head, no_crit, force_intent)
	if(isnestedhost(src) && stat != DEAD) //No more memeing nested and infected hosts
		to_chat(X, span_xenodanger("We reconsider our mean-spirited bullying of the pregnant, secured host."))
		return FALSE

	return ..()

