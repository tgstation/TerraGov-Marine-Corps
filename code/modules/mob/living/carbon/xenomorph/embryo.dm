/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yucky."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Larva Dead"
	var/grinder_datum = /datum/reagent/consumable/larvajelly //good ol cookin
	var/grinder_amount = 5
	var/mob/living/affected_mob
	///The stage of the bursts, with worsening effects.
	var/stage = 0
	///How developed the embryo is, if it ages up highly enough it has a chance to burst.
	var/counter = 0
	///How long before the larva is kicked out, * SSobj wait
	var/larva_autoburst_countdown = 20
	var/hivenumber = XENO_HIVE_NORMAL
	var/admin = FALSE


/obj/item/alien_embryo/Initialize()
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
		counter += 3.3 //Free burst time in ~6/7 min.

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/consumable/larvajelly))
		counter += 10 //Accelerates larval growth massively. Voluntarily drinking larval jelly while infected is straight-up suicide. Larva hits Stage 5 in exactly ONE minute.

	if(affected_mob.reagents.get_reagent_amount(/datum/reagent/medicine/larvaway))
		counter -= 1 //Halves larval growth progress, for some tradeoffs. Larval toxin purges this


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
		picked = affected_mob
	else //Get a candidate from observers.
		picked = get_alien_candidate()

	//Spawn the larva.
	var/mob/living/carbon/xenomorph/larva/new_xeno

	new_xeno = new(affected_mob)

	new_xeno.hivenumber = hivenumber
	new_xeno.update_icons()

	//If we have a candidate, transfer it over.
	if(picked)
		picked.mind.transfer_to(new_xeno, TRUE)
		to_chat(new_xeno, span_xenoannounce("We are a xenomorph larva inside a host! Move to burst out of it!"))
		new_xeno << sound('sound/effects/xeno_newlarva.ogg')

	stage = 6


/mob/living/carbon/xenomorph/larva/proc/initiate_burst(mob/living/carbon/victim)
	if(victim.chestburst || loc != victim)
		return

	victim.chestburst = 1
	ADD_TRAIT(victim, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	to_chat(src, span_danger("We start bursting out of [victim]'s chest!"))

	victim.Unconscious(40 SECONDS)
	victim.visible_message(span_danger("\The [victim] starts shaking uncontrollably!"), \
								span_danger("You feel something ripping up your insides!"))
	victim.jitter(300)

	victim.emote_burstscream()

	addtimer(CALLBACK(src, .proc/burst, victim), 3 SECONDS)


/mob/living/carbon/xenomorph/larva/proc/burst(mob/living/carbon/victim)
	if(QDELETED(victim))
		return

	if(loc != victim)
		victim.chestburst = 0
		return

	victim.update_burst()

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

	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		H.apply_damage(200, BRUTE, H.get_limb("chest"), updating_health = TRUE) //lethal armor ignoring brute damage
		var/datum/internal_organ/O
		for(var/i in list("heart", "lungs", "liver", "kidneys", "appendix")) //Bruise all torso internal organs
			O = H.internal_organs_by_name[i]

			if(!H.mind && !H.client) //If we have no client or mind, permadeath time; remove the organs. Mainly for the NPC colonist bodies
				H.internal_organs_by_name -= i
				H.internal_organs -= O
			else
				O.take_damage(O.min_bruised_damage, TRUE)

		var/datum/limb/chest = H.get_limb("chest")
		new /datum/wound/internal_bleeding(15, chest) //Apply internal bleeding to chest
		chest.fracture()


	victim.chestburst = 2
	victim.update_burst()
	log_combat(src, null, "chestbursted as a larva.")
	log_game("[key_name(src)] chestbursted as a larva at [AREACOORD(src)].")

	if((locate(/obj/structure/bed/nest) in loc) && hive.living_xeno_queen?.z == loc.z)
		burrow()

	victim.death()


/mob/living/proc/emote_burstscream()
	return


/mob/living/carbon/human/emote_burstscream()
	if(species.species_flags & NO_PAIN)
		return
	emote("burstscream")
