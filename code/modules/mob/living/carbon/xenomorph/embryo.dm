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
	RegisterSignal(affected_mob, COMSIG_HUMAN_SET_UNDEFIBBABLE, PROC_REF(on_host_dnr))

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

///Kills larva when host goes DNR
/obj/item/alien_embryo/proc/on_host_dnr(datum/source)
	SIGNAL_HANDLER
	qdel(src)

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

	var/area/mob_area = get_area(affected_mob)
	if(is_centcom_level(affected_mob.z) && !istype(mob_area, /area/deathmatch) && !admin)
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

	new_xeno.transfer_to_hive(hivenumber)
	new_xeno.update_icons()

	//If we have a candidate, transfer it over.
	if(picked)
		picked.mind.transfer_to(new_xeno, TRUE)
		to_chat(new_xeno, span_xenoannounce("We are a xenomorph larva inside a host! Move to burst out of it!"))
		new_xeno << sound('sound/effects/alien/new_larva.ogg')

	stage = 6


/mob/living/carbon/xenomorph/larva/proc/initiate_burst(mob/living/carbon/human/victim)
	if(victim.chestburst || loc != victim)
		return

	victim.chestburst = CARBON_IS_CHEST_BURSTING
	ADD_TRAIT(victim, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	to_chat(src, span_danger("We start bursting out of [victim]'s chest!"))

	victim.Unconscious(40 SECONDS)
	victim.visible_message(span_danger("\The [victim] starts shaking uncontrollably!"), \
								span_danger("You feel something ripping up your insides!"))
	victim.jitter(300)

	victim.emote_burstscream()

	addtimer(CALLBACK(src, PROC_REF(burst), victim), 3 SECONDS)


/mob/living/carbon/xenomorph/larva/proc/burst(mob/living/carbon/human/victim)
	if(QDELETED(victim))
		return

	if(loc != victim)
		victim.chestburst = CARBON_NO_CHEST_BURST
		return

	victim.update_burst()

	if(istype(victim.loc, /obj/vehicle/sealed))
		var/obj/vehicle/sealed/armored/veh = victim.loc
		forceMove(veh.exit_location(src))
	else
		forceMove(get_turf(victim)) //moved to the turf directly so we don't get stuck inside a cryopod or another mob container.
	playsound(src, pick('sound/voice/alien/chestburst.ogg','sound/voice/alien/chestburst2.ogg'), 25)
	GLOB.round_statistics.total_larva_burst++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_larva_burst")
	var/obj/item/alien_embryo/AE = locate() in victim

	if(AE)
		qdel(AE)

	victim.apply_damage(200, BRUTE, victim.get_limb("chest"), updating_health = TRUE) //lethal armor ignoring brute damage
	var/datum/internal_organ/O
	for(var/i in list(ORGAN_SLOT_HEART, ORGAN_SLOT_LUNGS, ORGAN_SLOT_LIVER, ORGAN_SLOT_KIDNEYS, ORGAN_SLOT_APPENDIX)) //Bruise all torso internal organs
		O = victim.get_organ_slot(i)

		if(!victim.mind && !victim.client) //If we have no client or mind, permadeath time; remove the organs. Mainly for the NPC colonist bodies
			victim.remove_organ_slot(i)
		else
			O.take_damage(O.min_bruised_damage, TRUE)

	var/datum/limb/chest = victim.get_limb("chest")
	new /datum/wound/internal_bleeding(15, chest) //Apply internal bleeding to chest
	chest.fracture()


	victim.chestburst = CARBON_CHEST_BURSTED
	victim.update_burst()
	log_combat(src, null, "chestbursted as a larva.")
	log_game("[key_name(src)] chestbursted as a larva at [AREACOORD(src)].")

	if(((locate(/obj/structure/bed/nest) in loc) && hive.living_xeno_ruler?.z == loc.z) || (!mind))
		burrow()

	victim.death()


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
