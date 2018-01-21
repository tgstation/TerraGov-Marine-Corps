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
		if(!living_xeno_queen)
			stat(null, "Evolve Progress (HALTED - NO QUEEN)")
		else if(!living_xeno_queen.ovipositor)
			stat(null, "Evolve Progress (HALTED - QUEEN HAS NO OVIPOSITOR)")
		else if(!evolution_allowed)
			stat(null, "Evolve Progress (FINISHED)")
		else
			stat(null, "Evolve Progress: [evolution_stored]/[evolution_threshold]")

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

/turf/simulated/floor/is_weedable()
	var/area/A = get_area(src)
	return A.is_weedable

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

	if(is_charging)
		. -= charge_speed
		charge_timer = 2
		if(charge_speed == 0)
			charge_dir = dir
			handle_momentum()
		else
			if(charge_dir != dir) //Have we changed direction?
				stop_momentum() //This should disallow rapid turn bumps
			else
				handle_momentum()

/mob/living/carbon/Xenomorph/proc/update_progression()
	if(upgrade != -1 && upgrade != 3) //upgrade possible
		if(upgrade_stored >= upgrade_threshold)
			if(health == maxHealth && !is_mob_incapacitated() && !handcuffed && !legcuffed)
				upgrade_xeno(upgrade+1)
		else
			upgrade_stored = min(upgrade_stored + 1, upgrade_threshold)

/mob/living/carbon/Xenomorph/show_inv(mob/user)
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
					spawn(charge_type == 1 ? 5 : 15)
						frozen = FALSE
						update_canmove()

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
/mob/living/carbon/Xenomorph/proc/bite_attack(var/mob/living/carbon/human/M, var/damage)

	damage += 20

	if(mob_size == MOB_SIZE_BIG)
		damage += 10

	var/datum/limb/affecting
	affecting = M.get_limb(ran_zone("head", 50))
	if(!affecting) //No head? Just get a random one
		affecting = M.get_limb(ran_zone(null, 0))
	if(!affecting) //Still nothing??
		affecting = M.get_limb("chest") //Gotta have a torso?!
	var/armor_block = M.run_armor_check(affecting, "melee")

	flick_attack_overlay(M, "slash") //TODO: Special bite attack overlay ?
	playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
	visible_message("<span class='danger'>\The [M] is viciously shredded by \the [src]'s sharp teeth!</span>", \
	"<span class='danger'>You viciously rend \the [M] with your teeth!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>bit [src.name] ([src.ckey])</font>")
	attack_log += text("\[[time_stamp()]\] <font color='orange'>was bitten by [M.name] ([M.ckey])</font>")

	M.apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1) //This should slicey dicey
	M.updatehealth()

//Tail stab. Checked during a slash, after the above.
//Deals a monstrous amount of damage based on how long it's been charging, but charging it drains plasma.
//Toggle is in XenoPowers.dm.
/mob/living/carbon/Xenomorph/proc/tail_attack(mob/living/carbon/human/M, var/damage)

	damage += 20

	if(mob_size == MOB_SIZE_BIG)
		damage += 10

	var/datum/limb/affecting
	affecting = M.get_limb(ran_zone(zone_selected, 75))
	if(!affecting) //No organ, just get a random one
		affecting = M.get_limb(ran_zone(null, 0))
	if(!affecting) //Still nothing??
		affecting = M.get_limb("chest") // Gotta have a torso?!
	var/armor_block = M.run_armor_check(affecting, "melee")

	flick_attack_overlay(M, "tail")
	playsound(loc, 'sound/weapons/wristblades_hit.ogg', 25, 1) //Stolen from Yautja! Owned!
	visible_message("<span class='danger'>\The [M] is suddenly impaled by \the [src]'s sharp tail!</span>", \
	"<span class='danger'>You violently impale \the [M] with your tail!</span>")
	M.attack_log += text("\[[time_stamp()]\] <font color='red'>tail-stabbed [M.name] ([M.ckey])</font>")
	attack_log += text("\[[time_stamp()]\] <font color='orange'>was tail-stabbed by [src.name] ([src.ckey])</font>")

	M.apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
	M.updatehealth()

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
	client.view = world.view
	client.pixel_x = 0
	client.pixel_y = 0
	is_zoomed = 0
	zoom_turf = null

/mob/living/carbon/Xenomorph/proc/check_alien_construction(var/turf/current_turf)
	var/has_obstacle
	for(var/obj/O in current_turf)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			src << "<span class='warning'>There is a little one here already. Best move it.</span>"
			return
		if(istype(O, /obj/effect/alien/egg))
			src << "<span class='warning'>There's already an egg.</span>"
			return
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/effect/alien/resin) || istype(O, /obj/structure/bed))
			has_obstacle = TRUE
			break
		if(O.density && !(O.flags_atom & ON_BORDER))
			has_obstacle = TRUE
			break

	if(current_turf.density || has_obstacle)
		src << "<span class='warning'>There's something built here already.</span>"
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

//This is depricated. Use handle_collision() for all future speed changes. ~Bmc777
/mob/living/carbon/Xenomorph/proc/stop_momentum(direction, stunned)
	if(!lastturf) r_FAL //Not charging.
	if(charge_speed > charge_speed_buildup * charge_turfs_to_charge) //Message now happens without a stun condition
		visible_message("<span class='danger'>[src] skids to a halt!</span>",
		"<span class='xenowarning'>You skid to a halt.</span>")
	last_charge_move = 0 //Always reset last charge tally
	charge_speed = 0
	charge_roar = 0
	lastturf = null
	flags_pass = 0
	update_icons()

//Why the elerloving fuck was this a Crusher only proc ? AND WHY IS IT NOT CAST ON THE RECEIVING ATOM ? AAAAAAA
/mob/living/carbon/Xenomorph/proc/diagonal_step(atom/movable/A, direction)
	if(!A) r_FAL
	switch(direction)
		if(EAST, WEST) step(A, pick(NORTH,SOUTH))
		if(NORTH,SOUTH) step(A, pick(EAST,WEST))

/mob/living/carbon/Xenomorph/proc/handle_momentum()
	if(throwing)
		r_FAL

	if(last_charge_move && last_charge_move < world.time - 10) //If we haven't moved in the last second, break charge on next move
		stop_momentum(charge_dir)

	if(stat || pulledby || !loc || !isturf(loc))
		stop_momentum(charge_dir)
		r_FAL

	if(!is_charging)
		stop_momentum(charge_dir)
		r_FAL

	if(lastturf && (loc == lastturf || loc.z != lastturf.z)) //Check if the Crusher didn't move from his last turf, aka stopped
		stop_momentum(charge_dir)
		r_FAL

	if(dir != charge_dir || m_intent == "walk" || istype(loc, /turf/unsimulated/floor/gm/river))
		stop_momentum(charge_dir)
		r_FAL

	if(pulling && charge_speed > charge_speed_buildup) stop_pulling()

	if(storedplasma > 5) storedplasma -= round(charge_speed) //Eats up plasma the faster you go, up to 0.5 per tile at max speed
	else
		stop_momentum(charge_dir)
		r_FAL

	last_charge_move = world.time //Index the world time to the last charge move

	if(charge_speed < charge_speed_max)
		charge_speed += charge_speed_buildup //Speed increases each step taken. Caps out at 14 tiles
		if(charge_speed == charge_speed_max) //Should only fire once due to above instruction
			if(!charge_roar)
				emote("roar")
				charge_roar = 1

	noise_timer = noise_timer ? --noise_timer : 3

	if(noise_timer == 3 && charge_speed > charge_speed_buildup * charge_turfs_to_charge)
		playsound(loc, 'sound/mecha/mechstep.ogg', min(15 + (charge_speed * 20), 50), 0)

	if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)

		for(var/mob/living/carbon/M in loc)
			if(M.lying && !isXeno(M) && M.stat != DEAD)
				visible_message("<span class='danger'>[src] runs [M] over!</span>",
				"<span class='danger'>You run [M] over!</span>")
				M.take_overall_damage(charge_speed * 40) //Yes, times fourty. Maxes out at a sweet, square 84 damage for 2.1 max speed
				animation_flash_color(M)

		var/shake_dist = min(round(charge_speed * 5), 8)
		for(var/mob/living/carbon/M in range(shake_dist))
			if(M.client && !isXeno(M))
				shake_camera(M, 1, 1)

	lastturf = isturf(loc) && !istype(loc, /turf/space) ? loc : null//Set their turf, to make sure they're moving and not jumped in a locker or some shit

	update_icons()
