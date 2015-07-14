// This is to replace the previous datum/disease/alien_embryo for slightly improved handling and maintainability
// It functions almost identically (see code/datums/diseases/alien_embryo.dm)

/obj/item/alien_embryo
	name = "alien embryo"
	desc = "All slimy and yuck."
	icon = 'icons/mob/alien.dmi'
	icon_state = "larva0_dead"
	var/mob/living/affected_mob
	var/stage = 0

/obj/item/alien_embryo/New()
	if(istype(loc, /mob/living))
		affected_mob = loc
		processing_objects.Add(src)
		spawn(0)
			AddInfectionImages(affected_mob)
	else
		del(src)

/obj/item/alien_embryo/Del()
	if(affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		spawn(0)
			RemoveInfectionImages(affected_mob)
	..()

/obj/item/alien_embryo/process()
	if(!affected_mob)
		processing_objects.Remove(src)
		return

	if(loc != affected_mob)
		affected_mob.status_flags &= ~(XENO_HOST)
		processing_objects.Remove(src)
		spawn(0)
			RemoveInfectionImages(affected_mob)
			affected_mob = null
		return

	if(affected_mob.stat == DEAD) //Stop. just stop it.
		return 0

	if(stage < 5 && prob(1))
		stage++
		spawn(0)
			RefreshInfectionImage(affected_mob)

	switch(stage)
		if(2)
			if(prob(1))
				affected_mob << "Your chest hurts a little bit."
		if(3)
			if(prob(1))
				affected_mob << "\red Your throat feels sore."
			if(prob(1))
				affected_mob << "\red Mucous runs down the back of your throat."
		if(4)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				affected_mob << "\red Your muscles ache."
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				affected_mob << "\red Your stomach hurts."
		if(5)
			affected_mob << "\red You feel something tearing its way out of your stomach..."
			affected_mob.emote("scream")
			affected_mob.adjustToxLoss(5)
			affected_mob.updatehealth()
//			if(prob(50))
			AttemptGrow()



/obj/item/alien_embryo/proc/AttemptGrow(var/gib_on_success = 1)
	var/list/candidates = get_alien_candidates()
	var/picked = null

	// To stop clientless larva, we will check that our host has a client
	// if we find no ghosts to become the alien. If the host has a client
	// he will become the alien but if he doesn't then we will set the stage
	// to 2, so we don't do a process heavy check everytime.

	if(!affected_mob)
		return 0

	if(candidates.len)
		picked = pick(candidates)
	else if(affected_mob.client)
		if(affected_mob.client.holder && istype(affected_mob.client.holder,/datum/admins) && !(affected_mob.client.prefs.be_special & BE_ALIEN))
			affected_mob << "You were about to burst, but admins are immune to forced xenos. Lucky you!"
			stage = 4
			return 0
		else
			picked = affected_mob.key
	else
		stage = 4 // Let's try again later.
		return 0

	if(!picked)
		stage = 4
		return 0

	var/image/overlay_l = new()
	overlay_l.icon = 'icons/Xeno/Misc.dmi'
	overlay_l.icon_state = "burst_lie"

	var/image/overlay_s = new()
	overlay_s.icon = 'icons/Xeno/Misc.dmi'
	overlay_s.icon_state = "burst_stand"

	if(affected_mob.lying)
		affected_mob.overlays += overlay_l
	else
		affected_mob.overlays += overlay_s
	spawn(6)
		if(!affected_mob || !src) return //Might have died or something in that half second
		var/mob/living/carbon/Xenomorph/Larva/new_xeno = new(get_turf(affected_mob.loc))
		new_xeno.key = picked
		new_xeno << sound('sound/voice/hiss5.ogg',0,0,0,100)	//To get the player's attention
		affected_mob.adjustToxLoss(200) //This should kill without gibbing da body
		affected_mob.updatehealth()

		affected_mob.overlays -= overlay_l
		affected_mob.overlays -= overlay_s

		var/image/overlay_l_b = new()
		overlay_l_b.icon = 'icons/Xeno/Misc.dmi'
		overlay_l_b.icon_state = "bursted_lie"

		var/image/overlay_s_b = new()
		overlay_s_b.icon = 'icons/Xeno/Misc.dmi'
		overlay_s_b.icon_state = "bursted_stand"

		if(affected_mob.lying)
			affected_mob.overlays += overlay_l_b
		else
			affected_mob.overlays += overlay_s_b
//		if(gib_on_success)
//			affected_mob.gib()
		processing_objects.Remove(src)
		affected_mob.update_icons()
		del(src)

/*----------------------------------------
Proc: RefreshInfectionImage()
Des: Removes all infection images from aliens and places an infection image on all infected mobs for aliens.
----------------------------------------*/
/obj/item/alien_embryo/proc/RefreshInfectionImage()

	for(var/mob/living/carbon/Xenomorph/alien in player_list)

		if(!istype(alien,/mob/living/carbon/Xenomorph))
			continue //Shouldn't be possible, just to be safe

		if(alien.client)
			for(var/image/I in alien.client.images)
				if(dd_hasprefix_case(I.icon_state, "infected"))
					del(I)
			for(var/mob/living/L in mob_list)
				if(iscorgi(L) || iscarbon(L))
					if(L.status_flags & XENO_HOST)
						var/I = image('icons/Xeno/Misc.dmi', loc = L, icon_state = "infected[stage]")
						alien.client.images += I

/*----------------------------------------
Proc: AddInfectionImages(C)
Des: Checks if the passed mob (C) is infected with the alien egg, then gives each alien client an infected image at C.
----------------------------------------*/
/obj/item/alien_embryo/proc/AddInfectionImages(var/mob/living/C)
	if(C)

		for(var/mob/living/carbon/Xenomorph/alien in player_list)

			if(!istype(alien,/mob/living/carbon/Xenomorph))
				continue //Shouldn't be possible, just to be safe

			if(alien.client)
				if(C.status_flags & XENO_HOST)
					var/I = image('icons/Xeno/Misc.dmi', loc = C, icon_state = "infected[stage]")
					alien.client.images += I

/*----------------------------------------
Proc: RemoveInfectionImage(C)
Des: Removes the alien infection image from all aliens in the world located in passed mob (C).
----------------------------------------*/

/obj/item/alien_embryo/proc/RemoveInfectionImages(var/mob/living/C)

	if(C)

		for(var/mob/living/carbon/Xenomorph/alien in player_list)

			if(!istype(alien,/mob/living/carbon/Xenomorph))
				continue //Shouldn't be possible, just to be safe

			if(alien.client)
				for(var/image/I in alien.client.images)
					if(I.loc == C)
						if(dd_hasprefix_case(I.icon_state, "infected"))
							del(I)
