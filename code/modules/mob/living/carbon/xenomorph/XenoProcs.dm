//Xenomorph General Procs And Functions - Colonial Marines
//LAST EDIT: APOPHIS 22MAY16


//Send a message to all xenos. Mostly used in the deathgasp display
/proc/xeno_message(var/message = null, var/size = 3)
	if(!message)
		return

	if(ticker && ticker.mode.xenomorphs.len) //Send to only xenos in our gamemode list. This is faster than scanning all mobs
		for(var/datum/mind/L in ticker.mode.xenomorphs)
			var/mob/living/carbon/Xenomorph/M = L.current
			if(M && istype(M) && !M.stat && M.client) //Only living and connected xenos
				M << "<span class='xenodanger'><font size=[size]> [message]</font></span>"

//Adds stuff to your "Status" pane -- Specific castes can have their own, like carrier hugger count
//Those are dealt with in their caste files.
/mob/living/carbon/Xenomorph/Stat()
	. = ..()

	if (.) //Only update when looking at the Status panel.

		if(evolution_allowed && living_xeno_queen)
			stat(null, "Evolve Progress: [evolution_stored]/[evolution_threshold]")
		else if(!living_xeno_queen)
			stat(null, "Evolve Progress (HALTED - NO QUEEN): [evolution_stored]/[evolution_threshold]")
		else
			stat(null, "Evolve Progress (FINISHED): [evolution_stored]/[evolution_threshold]")

		if(maxplasma > 0)
			if(is_robotic)
				stat(null, "Charge: [storedplasma]/[maxplasma]")
			else
				stat(null, "Plasma: [storedplasma]/[maxplasma]")

		if(slashing_allowed == 1)
			stat(null,"Slashing of hosts is currently: PERMITTED.")
		else if(slashing_allowed == 2)
			stat(null,"Slashing of hosts is currently: ONLY WHEN NEEDED.")
		else
			stat(null,"Slashing of hosts is currently: NOT ALLOWED.")

		if(frenzy_aura)
			stat(null,"You are affected by a pheromone of FRENZY.")
		if(warding_aura)
			stat(null,"You are affected by a pheromone of WARDING.")
		if(recovery_aura)
			stat(null,"You are affected by a pheromone of RECOVERY.")

		if(hive_orders && hive_orders != "")
			stat(null,"Hive Orders: [hive_orders]")

//A simple handler for checking your state. Used in pretty much all the procs.
/mob/living/carbon/Xenomorph/proc/check_state()
	if(is_mob_incapacitated() || lying || buckled)
		src << "<span class='warning'>You cannot do this in your current state.</span>"
		return 0
	return 1

//Checks your plasma levels and gives a handy message.
/mob/living/carbon/Xenomorph/proc/check_plasma(value)
	if(stat)
		src << "<span class='warning'>You cannot do this in your current state.</span>"
		return 0

	if(value)
		if(storedplasma < value)
			if(is_robotic)
				src << "<span class='warning'>Beep. You do not have enough plasma to do this. You require [value] plasma but have only [storedplasma] stored.</span>"
			else
				src << "<span class='warning'>You do not have enough plasma to do this. You require [value] plasma but have only [storedplasma] stored.</span>"
			return 0
	return 1

/mob/living/carbon/Xenomorph/proc/use_plasma(value)
	storedplasma = max(storedplasma - value, 0)
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()

/mob/living/carbon/Xenomorph/proc/gain_plasma(value)
	storedplasma = min(storedplasma + value, maxplasma)
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()


//Check if you can plant weeds on that turf.
//Does NOT return a message, just a 0 or 1.
/turf/proc/is_weedable()
	return !density

/turf/space/is_weedable()
	return FALSE

/turf/unsimulated/floor/gm/grass/is_weedable()
	return FALSE

/turf/unsimulated/floor/gm/dirtgrassborder/is_weedable()
	return FALSE

/turf/unsimulated/floor/gm/river/is_weedable()
	return FALSE

/turf/unsimulated/floor/gm/coast/is_weedable()
	return FALSE

/turf/unsimulated/floor/snow/is_weedable()
	return !slayer

/turf/unsimulated/floor/mars/is_weedable()
	return FALSE

/turf/simulated/floor/gm/grass/is_weedable()
	return FALSE

/turf/simulated/floor/gm/dirtgrassborder/is_weedable()
	return FALSE

/turf/simulated/floor/gm/river/is_weedable()
	return FALSE

/turf/simulated/wall/is_weedable()
	return TRUE //so we can spawn weeds on the walls




//Strip all inherent xeno verbs from your caste. Used in evolution.
/mob/living/carbon/Xenomorph/proc/remove_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs -= verb_path

//Add all your inherent caste verbs and procs. Used in evolution.
/mob/living/carbon/Xenomorph/proc/add_inherent_verbs()
	if(inherent_verbs)
		for(var/verb_path in inherent_verbs)
			verbs |= verb_path


//Adds or removes a delay to movement based on your caste. If speed = 0 then it shouldn't do much.
//Runners are -2, -4 is BLINDLINGLY FAST, +2 is fat-level
/mob/living/carbon/Xenomorph/movement_delay()

	if(istype(loc, /turf/space))
		return -1 //It's hard to be slowed down in space by... anything

	. = ..()

	. += speed

	if(frenzy_aura)
		. -= (frenzy_aura * 0.1)



//These don't do much currently. Or anything? Only around for legacy code.
/mob/living/carbon/Xenomorph/is_mob_restrained()
	return 0

/mob/living/carbon/Xenomorph/proc/update_progression()
	return

/mob/living/carbon/Xenomorph/show_inv(mob/user as mob)
	return


//This deals with "throwing" xenos -- ravagers, hunters, and runners in particular. Everyone else defaults to normal
//Pounce, charge both use throw_at, so we need extra code to do stuff rather than just push people aside.
/mob/living/carbon/Xenomorph/throw_impact(atom/hit_atom, speed)
	set waitfor = 0

	if(!charge_type || stat || (!throwing && usedPounce)) //No charge type, unconscious or dead, or not throwing but used pounce.
		..() //Do the parent instead.
		r_FAL

	if(isobj(hit_atom)) //Deal with smacking into dense objects. This overwrites normal throw code.
		var/obj/O = hit_atom
		if(!O.density) r_FAL//Not a dense object? Doesn't matter then, pass over it.
		if(!O.anchored) step(O, dir) //Not anchored? Knock the object back a bit. Ie. canisters.

		switch(charge_type) //Determine how to handle it depending on charge type.
			if(1 to 2)
				if(!istype(O, /obj/structure/table) && !istype(O, /obj/structure/rack))
					O.hitby(src, speed) //This resets throwing.
			if(3 to 4)
				if(istype(O, /obj/structure/table) || istype(O, /obj/structure/rack))
					var/obj/structure/S = O
					visible_message("<span class='danger'>[src] plows straight through [S]!</span>")
					S.destroy() //We want to continue moving, so we do not reset throwing.
				else O.hitby(src, speed) //This resets throwing.
		r_TRU

	if(ismob(hit_atom)) //Hit a mob! This overwrites normal throw code.
		var/mob/living/carbon/M = hit_atom
		if(!M.stat && !isXeno(M))
			switch(charge_type)
				if(1 to 2)
					if(ishuman(M) && M.dir in reverse_nearby_direction(dir))
						var/mob/living/carbon/human/H = M
						if(H.check_shields(15, "the pounce")) //Human shield block.
							KnockDown(3)
							throwing = FALSE //Reset throwing manually.
							r_FAL

						if(isYautja(H) && prob(40)) //Another chance for the predator to block the pounce.
							visible_message("<span class='danger'>[H] body slams [src]!</span>",
											"<span class='xenodanger'>[H] body slams you!</span>")
							KnockDown(4)
							throwing = FALSE
							r_FAL

					visible_message("<span class='danger'>[src] pounces on [M]!</span>",
									"<span class='xenodanger'>You pounce on [M]!</span>")
					M.KnockDown(charge_type == 1 ? 1 : 3)
					step_to(src, M)
					canmove = FALSE
					frozen = TRUE
					if(!is_robotic) playsound(loc, rand(0, 100) < 95 ? 'sound/voice/alien_pounce.ogg' : 'sound/voice/alien_pounce2.ogg', 25, 1)
					spawn(charge_type == 1 ? 1 : 15) frozen = FALSE

				if(3) //Ravagers get a free attack if they charge into someone. This will tackle if disarm is set instead.
					var/extra_dam = min(melee_damage_lower, rand(melee_damage_lower, melee_damage_upper) / (4 - upgrade)) //About 12.5 to 80 extra damage depending on upgrade level.
					M.attack_alien(src,  extra_dam) //Ancients deal about twice as much damage on a charge as a regular slash.
					M.KnockDown(2)

				if(4) //Predalien.
					M.attack_alien(src) //Free hit/grab/tackle. Does not weaken, and it's just a regular slash if they choose to do that.

		throwing = FALSE //Resert throwing since something was hit.
		r_TRU

	..() //Do the parent otherwise, for turfs.

//Bleuugh
/mob/living/carbon/Xenomorph/proc/empty_gut()
	if(stomach_contents.len)
		for(var/atom/movable/S in stomach_contents)
			if(S)
				stomach_contents.Remove(S)
				S.acid_damage = 0 //Reset the acid damage
				S.loc = get_turf(src)

	if(contents.len) //Get rid of anything that may be stuck inside us as well
		for(var/atom/movable/A in contents)
			if(A)
				contents.Remove(A)
				A.loc = get_turf(src)

/mob/living/carbon/Xenomorph/proc/toggle_nightvision()
	if(see_invisible == SEE_INVISIBLE_MINIMUM)
		see_invisible = SEE_INVISIBLE_LEVEL_TWO //Turn it off.
		see_in_dark = 4
		sight |= SEE_MOBS
		sight &= ~SEE_TURFS
		sight &= ~SEE_OBJS
	else
		see_invisible = SEE_INVISIBLE_MINIMUM
		see_in_dark = 8
		sight |= SEE_MOBS

//Random bite attack. Procs more often on downed people. Returns 0 if the check fails.
//Does a LOT of damage.
/mob/living/carbon/Xenomorph/proc/check_bite(var/mob/living/carbon/human/M)
	if(!M || !istype(M))
		return 0
	if(!bite_chance)
		return 0 //Does not have a bite attack

	var/chance = bite_chance
	var/dmg = rand(melee_damage_lower,melee_damage_upper) + 20

	if(M.lying)
		chance += 10
	if(M.head)
		chance -= 5 //Helmet? Less likely to bite, even if not all bites target head.

	if(rand(0, 100) > chance)
		return 0 //Failed the check, get out

	var/datum/limb/affecting
	affecting = M.get_limb(ran_zone("head", 50))
	if(!affecting) //No head? Just get a random one
		affecting = M.get_limb(ran_zone(null,0))
	if(!affecting) //Still nothing??
		affecting = M.get_limb("chest") //Gotta have a torso?!
	var/armor_block = M.run_armor_check(affecting, "melee")

	playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
	visible_message("<span class='danger'>\The [M] is viciously shredded by \the [src]'s sharp teeth!</span>", \
	"<span class='danger'>You viciously rend \the [M] with your teeth!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>bit [src.name] ([src.ckey])</font>")
	src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was bitten by [M.name] ([M.ckey])</font>")

	M.apply_damage(dmg, BRUTE, affecting, armor_block, sharp = 1) //This should slicey dicey
	M.updatehealth()

	return 1


/mob/living/carbon/Xenomorph/proc/zoom_in(var/tileoffset = 5, var/viewsize = 12)
	if(stat || resting)
		if(is_zoomed)
			is_zoomed = 0
			zoom_out()
			return
		return
	if(is_zoomed)
		return
	if(!client)
		return
	if(hud_used)
		hud_used.show_hud(HUD_STYLE_REDUCED)
	zoom_turf = get_turf(src)
	is_zoomed = 1
	client.view = viewsize
	var/viewoffset = 32 * tileoffset
	switch(dir)
		if(NORTH)
			client.pixel_x = 0
			client.pixel_y = viewoffset
		if(SOUTH)
			client.pixel_x = 0
			client.pixel_y = -viewoffset
		if(EAST)
			client.pixel_x = viewoffset
			client.pixel_y = 0
		if(WEST)
			client.pixel_x = -viewoffset
			client.pixel_y = 0

/mob/living/carbon/Xenomorph/proc/zoom_out()
	if(!client)
		return
	if(hud_used)
		hud_used.show_hud(HUD_STYLE_STANDARD)
	client.view = world.view
	client.pixel_x = 0
	client.pixel_y = 0
	is_zoomed = 0
	zoom_turf = null

/mob/living/carbon/Xenomorph/proc/check_alien_construction(var/turf/current_turf)
	var/obj/structure/mineral_door/alien_door = locate() in current_turf
	var/obj/effect/alien/resin/alien_construct = locate() in current_turf
	var/obj/structure/bed/stool/chair = locate() in current_turf

	if(alien_door || alien_construct || chair || istype(current_turf, /turf/simulated/wall/resin))
		src << "<span class='warning'>There's something built here already.</span>"
		return

	var/obj/effect/alien/egg/alien_egg = locate() in current_turf

	if(alien_egg)
		src << "<span class='warning'>There's already an egg.</span>"
		return

	var/obj/item/clothing/mask/facehugger/alien_hugger = locate() in current_turf
	if(alien_hugger)
		src << "<span class='warning'>There is a little one here already. Best move it.</span>"
		return

	return 1

/mob/living/carbon/Xenomorph/drop_held_item()
	var/obj/item/clothing/mask/facehugger/F = get_active_hand()
	if(istype(F))
		if(locate(/turf/simulated/wall/resin) in loc)
			src << "<span class='warning'>You decide not to drop [F] after all.</span>"
			return

	. = ..()


/mob/living/carbon/Xenomorph/start_pulling(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.buckled) return //to stop xeno from pulling marines on roller beds.
	..()
