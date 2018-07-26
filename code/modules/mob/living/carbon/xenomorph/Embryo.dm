//This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
//It functions almost identically (see code/datums/diseases/alien_embryo.dm)
/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yucky."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Larva Dead"
	var/mob/living/affected_mob
	var/stage = 0
	var/counter = 0 //How developed the embryo is, if it ages up highly enough it has a chance to burst
	var/larva_autoburst_countdown = 20 //to kick the larva out
	var/hivenumber = XENO_HIVE_NORMAL

/obj/item/alien_embryo/New()
	..()
	if(istype(loc, /mob/living))
		affected_mob = loc
		affected_mob.status_flags |= XENO_HOST
		processing_objects.Add(src)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
	else
		cdel(src)

/obj/item/alien_embryo/Dispose()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
		processing_objects.Remove(src)
		affected_mob = null
	. = ..()

/obj/item/alien_embryo/process()
	if(!affected_mob) //The mob we were gestating in is straight up gone, we shouldn't be here
		processing_objects.Remove(src)
		cdel(src)
		r_FAL

	if(loc != affected_mob) //Our location is not the host
		affected_mob.status_flags &= ~(XENO_HOST)
		processing_objects.Remove(src)
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()
		affected_mob = null
		r_FAL

	if(affected_mob.stat == DEAD)
		if(ishuman(affected_mob))
			var/mob/living/carbon/human/H = affected_mob
			if(world.time > H.timeofdeath + H.revive_grace_period) //Can't be defibbed.
				var/mob/living/carbon/Xenomorph/Larva/L = locate() in affected_mob
				if(L)
					L.chest_burst(affected_mob)
				processing_objects.Remove(src)
				r_FAL
		else
			var/mob/living/carbon/Xenomorph/Larva/L = locate() in affected_mob
			if(L)
				L.chest_burst(affected_mob)
			processing_objects.Remove(src)
			r_FAL

	if(affected_mob.in_stasis == STASIS_IN_CRYO_CELL) r_FAL //If they are in cryo, the embryo won't grow.

	process_growth()

/obj/item/alien_embryo/proc/process_growth()

	//Low temperature seriously hampers larva growth (as in, way below livable), so does stasis
	if(affected_mob.in_stasis || affected_mob.bodytemperature < 170)
		if(stage <= 4)
			counter += 0.33
		else if(stage == 4)
			counter += 0.11
	else if(istype(affected_mob.buckled, /obj/structure/bed/nest)) //Hosts who are nested in resin nests provide an ideal setting, larva grows faster
		counter += 1.5 //Currently twice as much, can be changed
	else
		if(stage <= 4)
			counter++

	if(stage < 5 && counter >= 120)
		counter = 0
		stage++
		if(iscarbon(affected_mob))
			var/mob/living/carbon/C = affected_mob
			C.med_hud_set_status()

	switch(stage)
		if(2)
			if(prob(2))
				affected_mob << "<span class='warning'>[pick("Your chest hurts a little bit", "Your stomach hurts")].</span>"
		if(3)
			if(prob(2))
				affected_mob << "<span class='warning'>[pick("Your throat feels sore", "Mucous runs down the back of your throat")].</span>"
			else if(prob(1))
				affected_mob << "<span class='warning'>Your muscles ache.</span>"
				if(prob(20))
					affected_mob.take_limb_damage(1)
			else if(prob(2))
				affected_mob.emote("[pick("sneeze", "cough")]")
		if(4)
			if(prob(1))
				if(affected_mob.knocked_out < 1)
					affected_mob.visible_message("<span class='danger'>\The [affected_mob] starts shaking uncontrollably!</span>", \
												 "<span class='danger'>You start shaking uncontrollably!</span>")
					affected_mob.KnockOut(10)
					affected_mob.make_jittery(105)
					affected_mob.take_limb_damage(1)
			if(prob(2))
				affected_mob << "<span class='warning'>[pick("Your chest hurts badly", "It becomes difficult to breathe", "Your heart starts beating rapidly, and each beat is painful")].</span>"
		if(5)
			become_larva()
		if(6)
			larva_autoburst_countdown--
			if(!larva_autoburst_countdown)
				var/mob/living/carbon/Xenomorph/Larva/L = locate() in affected_mob
				if(L)
					L.chest_burst(affected_mob)

//We look for a candidate. If found, we spawn the candidate as a larva
//Order of priority is bursted individual (if xeno is enabled), then random candidate, and then it's up for grabs and spawns braindead
/obj/item/alien_embryo/proc/become_larva()
	// We do not allow chest bursts on the Centcomm Z-level, to prevent
	// stranded players from admin experiments and other issues
	if (!affected_mob || affected_mob.z == 2)
		return

	var/picked

	// If the bursted person themselves has Xeno enabled, they get the honor of first dibs on the new larva
	if (affected_mob.client && affected_mob.client.prefs && (affected_mob.client.prefs.be_special & BE_ALIEN) && !jobban_isbanned(affected_mob, "Alien"))
		picked = affected_mob.key
	else
		// Get a candidate from observers
		var/list/candidates = get_alien_candidates()

		if (candidates.len)
			picked = pick(candidates)

	// Spawn the larva
	var/mob/living/carbon/Xenomorph/Larva/new_xeno

	if(isYautja(affected_mob))
		new_xeno = new /mob/living/carbon/Xenomorph/Larva/predalien(affected_mob)
	else
		new_xeno = new(affected_mob)

	new_xeno.hivenumber = hivenumber
	new_xeno.update_icons()

	// If we have a candidate, transfer it over
	if(picked)
		new_xeno.key = picked

		if(new_xeno.client)
			new_xeno.client.change_view(world.view)

		new_xeno << "<span class='xenoannounce'>You are a xenomorph larva inside a host! Move to burst out of it!</span>"
		new_xeno << sound('sound/effects/xeno_newlarva.ogg')

	stage = 6

/mob/living/carbon/Xenomorph/Larva/proc/chest_burst(mob/living/carbon/victim)
	set waitfor = 0
	if(victim.chestburst || loc != victim) return
	victim.chestburst = 1
	src << "<span class='danger'>You start bursting out of [victim]'s chest!</span>"
	if(victim.knocked_out < 1)
		victim.KnockOut(20)
	victim.visible_message("<span class='danger'>\The [victim] starts shaking uncontrollably!</span>", \
								 "<span class='danger'>You feel something ripping up your insides!</span>")
	victim.make_jittery(300)
	sleep(30)
	if(!victim || !victim.loc) return//host could've been deleted, or we could've been removed from host.
	if(loc != victim)
		victim.chestburst = 0
		return
	victim.update_burst()
	sleep(6) //Sprite delay
	if(!victim || !victim.loc) return
	if(loc != victim)
		victim.chestburst = 0 //if a doc removes the larva during the sleep(6), we must remove the 'bursting' overlay on the human
		victim.update_burst()
		return

	if(isYautja(victim)) victim.emote("roar")
	else victim.emote("scream")
	forceMove(get_turf(victim)) //moved to the turf directly so we don't get stuck inside a cryopod or another mob container.
	playsound(src, pick('sound/voice/alien_chestburst.ogg','sound/voice/alien_chestburst2.ogg'), 25)
	round_statistics.total_larva_burst++
	var/obj/item/alien_embryo/AE = locate() in victim
	if(AE)
		cdel(AE)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/datum/internal_organ/O
		var/i
		for(i in list("heart","lungs")) //This removes (and later garbage collects) both organs. No heart means instant death.
			O = H.internal_organs_by_name[i]
			H.internal_organs_by_name -= i
			H.internal_organs -= O
	victim.death() // Certain species were still surviving bursting (predators), DEFINITELY kill them this time.
	victim.chestburst = 2
	victim.update_burst()

	var/datum/hive_status/hive = hive_datum[XENO_HIVE_NORMAL]
	if((!key || !client) && loc.z == 1 && (locate(/obj/structure/bed/nest) in loc) && hivenumber == XENO_HIVE_NORMAL && hive.living_xeno_queen && hive.living_xeno_queen.z == src.loc.z)
		visible_message("<span class='xenodanger'>[src] quickly buries into the ground.</span>")
		round_statistics.total_xenos_created-- // keep stats sane
		ticker.mode.stored_larva++
		cdel(src)
