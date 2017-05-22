//This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
//It functions almost identically (see code/datums/diseases/alien_embryo.dm)
/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yucky."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Normal Larva Dead"
	var/mob/living/affected_mob
	var/stage = 0
	var/counter = 0 //How developed the embryo is, if it ages up highly enough it has a chance to burst
	var/larva_autoburst_countdown = 20 //to kick the larva out

/obj/item/alien_embryo/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		affected_mob.status_flags |= XENO_HOST
		processing_objects.Add(src)
		spawn()
			AddInfectionImages(affected_mob)
	else
		cdel(src)

/obj/item/alien_embryo/Del()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		spawn()
			RemoveInfectionImages(affected_mob)
		processing_objects.Remove(src)
	..()

/obj/item/alien_embryo/process()
	if(!affected_mob) //The mob we were gestating in is straight up gone, we shouldn't be here
		processing_objects.Remove(src)
		cdel(src)
		r_FAL

	if(loc != affected_mob) //Our location is not the host
		affected_mob.status_flags &= ~(XENO_HOST)
		processing_objects.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
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
	else if(istype(affected_mob.buckled, /obj/structure/stool/bed/nest)) //Hosts who are nested in resin nests provide an ideal setting, larva grows faster
		counter += 1.5 //Currently twice as much, can be changed
	else
		if(stage <= 4)
			counter++

	if(stage < 5 && counter >= 120)
		counter = 0
		stage++
		spawn()
			RefreshInfectionImage()

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
					affected_mob.take_organ_damage(1)
			else if(prob(2))
				affected_mob.emote("[pick("sneeze", "cough")]")
		if(4)
			if(prob(1))
				if(affected_mob.paralysis < 1)
					affected_mob.visible_message("<span class='danger'>\The [affected_mob] starts shaking uncontrollably!</span>", \
												 "<span class='danger'>You start shaking uncontrollably!</span>")
					affected_mob.Paralyse(10)
					affected_mob.make_jittery(105)
					affected_mob.take_organ_damage(1)
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
	var/list/candidates = get_alien_candidates()
	var/picked

	if(!affected_mob || affected_mob.z == 2) return //We do not allow chest bursts on the Centcomm Z-level, to prevent stranded players from admin experiments and other issues

	//If the bursted person themselves has xeno enabled, they get the honor of first dibs on the new larva
	if(isYautja(affected_mob))
		if(affected_mob.client && !jobban_isbanned(affected_mob, "Alien")) picked = affected_mob.key//If they are in a predator body, put them into the alien. Doesn't matter if they have alien selected.
		else if(candidates.len) picked = pick(candidates)
	else
		if(affected_mob.client && affected_mob.client.holder && (affected_mob.client.prefs.be_special & BE_ALIEN) && !jobban_isbanned(affected_mob, "Alien"))
			picked = affected_mob.key
		//Host doesn't want to be it, so we try and pull observers into the role
		else if(candidates.len) picked = pick(candidates)

	var/mob/living/carbon/Xenomorph/Larva/new_xeno
	if(isYautja(affected_mob)) new_xeno = new /mob/living/carbon/Xenomorph/Larva/predalien(affected_mob)
	else new_xeno = new(affected_mob)
	if(picked) //found a candidate
		new_xeno.key = picked
		new_xeno << "<span class='xenoannounce'>You are a xenomorph larva inside a host! Move to burst out of it!</span>"
	stage = 6



/mob/living/carbon/Xenomorph/Larva/proc/chest_burst(mob/living/carbon/victim)
	set waitfor = 0
	if(victim.chestburst || loc != victim) return
	victim.chestburst = 1
	src << "<span class='danger'>You start bursting out of [victim]'s chest!</span>"
	if(victim.paralysis < 1)
		victim.Paralyse(20)
	victim.visible_message("<span class='danger'>\The [victim] starts shaking uncontrollably!</span>", \
								 "<span class='danger'>You feel something ripping up your insides!</span>")
	victim.make_jittery(300)
	sleep(30)
	if(!victim || !victim.loc || loc != victim) return//host could've been deleted, or we could've been removed from host.
	victim.update_burst()
	sleep(6) //Sprite delay
	if(!victim || !victim.loc || loc != victim) return

	if(isYautja(victim)) victim.emote("roar")
	else victim.emote("scream")
	forceMove(get_turf(victim)) //moved to the turf directly so we don't get stuck inside a cryopod or another mob container.
	playsound(src, pick('sound/voice/alien_chestburst.ogg','sound/voice/alien_chestburst2.ogg'), 25)
	var/obj/item/alien_embryo/AE = locate() in victim
	if(AE)
		del(AE)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/datum/organ/internal/O
		var/i
		for(i in list("heart","lungs")) //This removes (and later garbage collects) both organs. No heart means instant death.
			O = H.internal_organs_by_name[i]
			H.internal_organs_by_name -= i
			H.internal_organs -= O
	else
		victim.adjustToxLoss(300) //This should kill without gibbing da body
		victim.updatehealth()
	victim.chestburst = 2
	victim.update_burst()

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes or adds the relevant icon of the larva in the infected mob
----------------------------------------*/
/obj/item/alien_embryo/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Adds the infection image to all aliens for this embryo
----------------------------------------*/
/obj/item/alien_embryo/proc/AddInfectionImages()
	for(var/mob/living/carbon/Xenomorph/alien in player_list)
		if(alien.client)
			var/I = image('icons/Xeno/Effects.dmi', loc = affected_mob, icon_state = "infected[stage]")
			alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes all images from the mob infected by this embryo
----------------------------------------*/
/obj/item/alien_embryo/proc/RemoveInfectionImages()
	for(var/mob/living/carbon/Xenomorph/alien in player_list)
		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected") && I.loc == affected_mob)
					cdel(I)
