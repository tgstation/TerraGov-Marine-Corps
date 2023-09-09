
/obj/item/alien_embryo/proc/process_growth()

	if(CHECK_BITFIELD(affected_mob.restrained_flags, RESTRAINED_XENO_NEST)) //Hosts who are nested in resin nests provide an ideal setting, larva grows faster.
		counter += 1 + max(0, (0.03 * affected_mob.health)) //Up to +300% faster, depending on the health of the host.

	if(stage <= 4)
		counter += 4 //Free burst time in ~5 min.

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/consumable/larvajelly))
		counter += 10 //Accelerates larval growth massively. Voluntarily drinking larval jelly while infected is straight-up suicide. Larva hits Stage 5 in exactly ONE minute.

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/medicine/larvaway))
		counter -= 3 //Halves larval growth progress, for some tradeoffs. Larval toxin purges this

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin))
		counter -= 1

	if(boost_timer)
		counter += 2.5 //Doubles larval growth progress. Burst time in ~3 min.
		adjust_boost_timer(-1)

	if(stage < 5 && counter >= 120)
		counter = 0
		stage++
		log_combat(affected_mob, null, "had their embryo advance to stage [stage]")
		var/mob/living/carbon/C = affected_mob
		C.med_hud_set_status()
		affected_mob.jitter(stage * 5)

	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, span_warning("[pick("Your chest hurts a little bit", "Your stomach hurts")]."))
		if(3)
			if(prob(2))
				to_chat(affected_mob, span_warning("[pick("Your throat feels sore", "Mucous runs down the back of your throat")]."))
			else if(prob(1))
				to_chat(affected_mob, span_warning("Your muscles ache."))
				if(prob(20))
					affected_mob.take_limb_damage(1)
			else if(prob(2))
				affected_mob.emote("[pick("sneeze", "cough")]")
		if(4)
			if(prob(1))
				if(!affected_mob.IsUnconscious())
					affected_mob.visible_message(span_danger("\The [affected_mob] starts shaking uncontrollably!"), \
												span_danger("You start shaking uncontrollably!"))
					affected_mob.Unconscious(20 SECONDS)
					affected_mob.jitter(105)
					affected_mob.take_limb_damage(1)
			if(prob(2))
				to_chat(affected_mob, span_warning("[pick("Your chest hurts badly", "It becomes difficult to breathe", "Your heart starts beating rapidly, and each beat is painful")]."))
		if(5)
			become_larva()
		if(6)
			larva_autoburst_countdown--
			if(!larva_autoburst_countdown)
				var/mob/living/carbon/xenomorph/larva/L = locate() in affected_mob
				L?.initiate_burst(affected_mob)
