/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yucky."
	icon = 'icons/Xeno/castes/larva.dmi'
	icon_state = "Embryo"
	var/grinder_datum = /datum/reagent/consumable/larvajelly //good ol cookin
	var/grinder_amount = 5
	var/mob/living/affected_mob
	///The stage of the bursts, with worsening effects.
	var/stage = 0
	///How developed the embryo is, if it ages up highly enough it has a chance to burst.
	var/counter = 0
	///How long before the larva is kicked out, * SSobj wait
	var/larva_autoburst_countdown = 20
	///How long will the embryo's growth rate be increased
	var/boost_timer = 0
	var/hivenumber = XENO_HIVE_NORMAL
	var/admin = FALSE


/obj/item/alien_embryo/Initialize(mapload)
	. = ..()
	if(!isliving(loc))
		return
	affected_mob = loc
	affected_mob.status_flags |= XENO_HOST
	log_combat(affected_mob, null, "been infected with an embryo")
	START_PROCESSING(SSobj, src)
	if(iscarbon(affected_mob))
		var/mob/living/carbon/C = affected_mob
		C.med_hud_set_status()


/obj/item/alien_embryo/Destroy()
	if(affected_mob)
		log_combat(affected_mob, null, "had their embryo removed")
		affected_mob.status_flags &= ~(XENO_HOST)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
		STOP_PROCESSING(SSobj, src)
		affected_mob = null
	return ..()


/obj/item/alien_embryo/process()
	if(!affected_mob)
		qdel(src)
		return PROCESS_KILL

	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
		affected_mob = null
		return PROCESS_KILL

	if(affected_mob.stat == DEAD)
		var/mob/living/carbon/xenomorph/larva/L = locate() in affected_mob
		L?.initiate_burst(affected_mob)
		return PROCESS_KILL

	if(HAS_TRAIT(affected_mob, TRAIT_STASIS))
		return //If they are in cryo, bag or cell, the embryo won't grow.

	process_growth()


/obj/item/alien_embryo/proc/process_growth()

	if(stage <= 4)
		counter += 2.5 //Free burst time in ~7/8 min.

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/consumable/larvajelly))
		counter += 10 //Accelerates larval growth massively. Voluntarily drinking larval jelly while infected is straight-up suicide. Larva hits Stage 5 in exactly ONE minute.

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/medicine/larvaway))
		counter -= 1 //Halves larval growth progress, for some tradeoffs. Larval toxin purges this

	if(boost_timer)
		counter += 2.5 //Doubles larval growth progress. Burst time in ~4 min.
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
				to_chat(affected_mob, span_warning("[pick("Your stomach hurts a little bit", "Your stomach hurts a bit")]."))
		if(3)
			if(prob(2))
				to_chat(affected_mob, span_warning("[pick("Your stomach feels sore", "Your belly hurts a little.")]."))
			else if(prob(1))
				to_chat(affected_mob, span_warning("Your stomach ache a bit."))
		if(4)
			if(prob(1))
				if(!affected_mob.IsUnconscious())
					affected_mob.visible_message(span_danger("\The [affected_mob] starts shaking uncontrollably!"), \
												span_danger("You start shaking uncontrollably!"))
					affected_mob.jitter(105)
			if(prob(2))
				to_chat(affected_mob, span_warning("[pick("Your stomach hurts badly", "It becomes difficult to breathe")]."))
		if(5)
			become_larva()
		if(6)
			larva_autoburst_countdown--
			if(!larva_autoburst_countdown)
				var/mob/living/carbon/xenomorph/larva/L = locate() in affected_mob
				L?.initiate_burst(affected_mob)


//We look for a candidate. If found, we spawn the candidate as a larva.
//Order of priority is bursted individual (if xeno is enabled), then random candidate, and then it's up for grabs and spawns braindead.
/obj/item/alien_embryo/proc/become_larva()
	if(!affected_mob)
		return

	if(is_centcom_level(affected_mob.z) && !admin)
		return

	var/mob/picked

	//If the bursted person themselves has Xeno enabled, they get the honor of first dibs on the new larva.
	if(affected_mob.client?.prefs && (affected_mob.client.prefs.be_special & (BE_ALIEN|BE_ALIEN_UNREVIVABLE)) && !is_banned_from(affected_mob.ckey, ROLE_XENOMORPH))
		picked = get_alien_candidate()

	//Spawn the larva.
	var/mob/living/carbon/xenomorph/larva/new_xeno

	new_xeno = new(affected_mob)

	new_xeno.transfer_to_hive(hivenumber)
	new_xeno.update_icons()

	//If we have a candidate, transfer it over.
	if(picked)
		picked.mind.transfer_to(new_xeno, TRUE)
		to_chat(new_xeno, span_xenoannounce("We are a xenomorph larva inside a host! Move to squirm out of it!"))
		new_xeno << sound('sound/effects/xeno_newlarva.ogg')

	stage = 6


/mob/living/carbon/xenomorph/larva/proc/initiate_burst(mob/living/carbon/victim)
	if(victim.chestburst || loc != victim)
		return

	victim.chestburst = 1
	to_chat(src, span_danger("We start slithering out of [victim]!"))

	victim.Unconscious(10 SECONDS)
	victim.visible_message(span_danger("\The [victim] starts shaking uncontrollably!"), \
								span_danger("You feel something wiggling out of your insides!"))
	victim.jitter(300)

	victim.emote_burstscream()

	addtimer(CALLBACK(src, PROC_REF(burst), victim), 3 SECONDS)


/mob/living/carbon/xenomorph/larva/proc/burst(mob/living/carbon/victim)
	if(QDELETED(victim))
		return

	if(loc != victim)
		victim.chestburst = 0
		return


	if(istype(victim.loc, /obj/vehicle/multitile/root))
		var/obj/vehicle/multitile/root/V = victim.loc
		V.handle_player_exit(src)
	else
		forceMove(get_turf(victim)) //moved to the turf directly so we don't get stuck inside a cryopod or another mob container.
	playsound(src, pick('sound/voice/alien_chestburst.ogg','sound/voice/alien_chestburst2.ogg'), 25)
	GLOB.round_statistics.total_larva_burst++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_larva_burst")
	var/obj/item/alien_embryo/AE = locate() in victim

	if(AE)
		qdel(AE)


	victim.chestburst = 2
	log_combat(src, null, "was born as a larva.")
	log_game("[key_name(src)] was born as a larva at [AREACOORD(src)].")
	victim.chestburst = 0

	if(((locate(/obj/structure/bed/nest) in loc) && hive.living_xeno_ruler?.z == loc.z))
		burrow()


/mob/living/proc/emote_burstscream()
	return


/mob/living/carbon/human/emote_burstscream()
	if(species.species_flags & NO_PAIN)
		return
	emote("burstscream")


///Adjusts the growth acceleration timer
/obj/item/alien_embryo/proc/adjust_boost_timer(amount, capped = 0, override_time = FALSE)
	if(override_time)
		boost_timer = max(amount, 0)
	else
		boost_timer = max(boost_timer + amount, 0)

	if(capped > 0)
		boost_timer = min(boost_timer, capped)
	return
