//Xenomorph General Procs And Functions - Colonial Marines
//LAST EDIT: APOPHIS 22MAY16


//Send a message to all xenos. Mostly used in the deathgasp display
/proc/xeno_message(var/message = null, var/size = 3, var/hivenumber = XENO_HIVE_NORMAL)
	if(!message)
		return

	if(ticker && ticker.mode && ticker.mode.xenomorphs.len) //Send to only xenos in our gamemode list. This is faster than scanning all mobs
		for(var/datum/mind/L in ticker.mode.xenomorphs)
			var/mob/living/carbon/Xenomorph/M = L.current
			if(M && istype(M) && !M.stat && M.client && hivenumber == M.hivenumber) //Only living and connected xenos
				to_chat(M, "<span class='xenodanger'><font size=[size]> [message]</font></span>")

//Adds stuff to your "Status" pane -- Specific castes can have their own, like carrier hugger count
//Those are dealt with in their caste files.
/mob/living/carbon/Xenomorph/Stat()
	if (!..())
		return 0

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]

		if(!evolution_allowed)
			stat(null, "Evolve Progress (FINISHED)")
		else if(!hive.living_xeno_queen)
			stat(null, "Evolve Progress (HALTED - NO QUEEN)")
		else if(!hive.living_xeno_queen.ovipositor)
			stat(null, "Evolve Progress (HALTED - QUEEN HAS NO OVIPOSITOR)")
		else
			stat(null, "Evolve Progress: [evolution_stored]/[evolution_threshold]")

		if(upgrade != -1 && upgrade != 3) //upgrade possible
			stat(null, "Upgrade Progress: [upgrade_stored]/[upgrade_threshold]")
		else //Upgrade process finished or impossible
			stat(null, "Upgrade Progress (FINISHED)")

		if(plasma_max > 0)
			if(is_robotic)
				stat(null, "Charge: [plasma_stored]/[plasma_max]")
			else
				stat(null, "Plasma: [plasma_stored]/[plasma_max]")

		if(hivenumber != XENO_HIVE_CORRUPTED)
			if(hive.slashing_allowed == 1)
				stat(null,"Slashing of hosts is currently: PERMITTED.")
			else if(hive.slashing_allowed == 2)
				stat(null,"Slashing of hosts is currently: LIMITED.")
			else
				stat(null,"Slashing of hosts is currently: FORBIDDEN.")
		else
			stat(null,"Slashing of hosts is decided by your masters.")

		//Very weak <= 1.0, weak <= 2.0, no modifier 2-3, strong <= 3.5, very strong <= 4.5
		var/msg_holder = ""
		if(frenzy_aura)
			switch(frenzy_aura)
				if(-INFINITY to 1.0) msg_holder = "very weak "
				if(1.1 to 2.0) msg_holder = "weak "
				if(2.1 to 2.9) msg_holder = ""
				if(3.0 to 3.9) msg_holder = "strong "
				if(4.0 to INFINITY) msg_holder = "very strong "
			stat(null,"You are affected by a [msg_holder]FRENZY pheromone.")
		if(warding_aura)
			switch(warding_aura)
				if(-INFINITY to 1.0) msg_holder = "very weak "
				if(1.1 to 2.0) msg_holder = "weak "
				if(2.1 to 2.9) msg_holder = ""
				if(3.0 to 3.9) msg_holder = "strong "
				if(4.0 to INFINITY) msg_holder = "very strong "
			stat(null,"You are affected by a [msg_holder]WARDING pheromone.")
		if(recovery_aura)
			switch(recovery_aura)
				if(-INFINITY to 1.0) msg_holder = "very weak "
				if(1.1 to 2.0) msg_holder = "weak "
				if(2.1 to 2.9) msg_holder = ""
				if(3.0 to 3.9) msg_holder = "strong "
				if(4.0 to INFINITY) msg_holder = "very strong "
			stat(null,"You are affected by a [msg_holder]RECOVERY pheromone.")


		if(hivenumber != XENO_HIVE_CORRUPTED)
			if(hive.hive_orders && hive.hive_orders != "")
				stat(null,"Hive Orders: [hive.hive_orders]")
		else
			stat(null,"Hive Orders: Follow the instructions of your masters")

	return 1

//A simple handler for checking your state. Used in pretty much all the procs.
/mob/living/carbon/Xenomorph/proc/check_state()
	if(is_mob_incapacitated() || lying || buckled)
		to_chat(src, "<span class='warning'>You cannot do this in your current state.</span>")
		return 0
	return 1

//Checks your plasma levels and gives a handy message.
/mob/living/carbon/Xenomorph/proc/check_plasma(value)
	if(stat)
		to_chat(src, "<span class='warning'>You cannot do this in your current state.</span>")
		return 0

	if(value)
		if(plasma_stored < value)
			if(is_robotic)
				to_chat(src, "<span class='warning'>Beep. You do not have enough plasma to do this. You require [value] plasma but have only [plasma_stored] stored.</span>")
			else
				to_chat(src, "<span class='warning'>You do not have enough plasma to do this. You require [value] plasma but have only [plasma_stored] stored.</span>")
			return 0
	return 1

/mob/living/carbon/Xenomorph/proc/use_plasma(value)
	plasma_stored = max(plasma_stored - value, 0)
	update_action_button_icons()

/mob/living/carbon/Xenomorph/proc/gain_plasma(value)
	plasma_stored = min(plasma_stored + value, plasma_max)
	update_action_button_icons()




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
	. = ..()

	. += speed + slowdown + speed_modifier

	if(frenzy_aura)
		. -= (frenzy_aura * 0.05)

	if(is_charging)
		if(legcuffed)
			is_charging = 0
			stop_momentum()
			to_chat(src, "<span class='xenodanger'>You can't charge with that thing on your leg!</span>")
		else
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

//Stealth handling
/mob/living/carbon/Xenomorph/Hunter/movement_delay()
	. = ..()
	if(stealth)
		handle_stealth_movement()



/mob/living/carbon/Xenomorph/Hunter/proc/handle_stealth_movement()
	//Initial stealth
	if(last_stealth > world.time - HUNTER_STEALTH_INITIAL_DELAY) //We don't start out at max invisibility
		alpha = HUNTER_STEALTH_RUN_ALPHA //50% invisible
		return
	//Stationary stealth
	else if(last_move_intent < world.time - HUNTER_STEALTH_STEALTH_DELAY) //If we're standing still for 3 seconds we become almost completely invisible
		alpha = HUNTER_STEALTH_STILL_ALPHA //95% invisible
	//Walking stealth
	else if(m_intent == MOVE_INTENT_WALK)
		alpha = HUNTER_STEALTH_WALK_ALPHA //80% invisible
		use_plasma(HUNTER_STEALTH_WALK_PLASMADRAIN * 0.5)
	//Running stealth
	else
		alpha = HUNTER_STEALTH_RUN_ALPHA //50% invisible
		use_plasma(HUNTER_STEALTH_RUN_PLASMADRAIN * 0.5)
	if(!plasma_stored)
		to_chat(src, "<span class='xenodanger'>You lack sufficient plasma to remain camouflaged.</span>")
		cancel_stealth()

/mob/living/carbon/Xenomorph/proc/update_progression()
	if(upgrade != -1 && upgrade != 3) //upgrade possible
		if(client && ckey) // pause for ssd/ghosted
			var/datum/hive_status/hive = hive_datum[hivenumber]
			if(!hive.living_xeno_queen || hive.living_xeno_queen.loc.z == loc.z)
				if(upgrade_stored >= upgrade_threshold)
					if(health == maxHealth && !is_mob_incapacitated() && !handcuffed && !legcuffed)
						upgrade_xeno(upgrade+1)
				else
					upgrade_stored = min(upgrade_stored + 1, upgrade_threshold)

/mob/living/carbon/Xenomorph/proc/update_evolving()
	if(!client || !ckey) // stop evolve progress for ssd/ghosted xenos
		return
	if(evolution_stored >= evolution_threshold || !evolution_allowed)
		return
	if(!hivenumber || hivenumber > hive_datum.len) //something broke
		return
	var/datum/hive_status/hive = hive_datum[hivenumber]
	if(hive.living_xeno_queen)
		evolution_stored++
		if(evolution_stored == evolution_threshold - 1)
			to_chat(src, "<span class='xenodanger'>Your carapace crackles and your tendons strengthen. You are ready to evolve!</span>")
			src << sound('sound/effects/xeno_evolveready.ogg')

/mob/living/carbon/Xenomorph/show_inv(mob/user)
	return


//This deals with "throwing" xenos -- ravagers, hunters, and runners in particular. Everyone else defaults to normal
//Pounce, charge both use throw_at, so we need extra code to do stuff rather than just push people aside.
/mob/living/carbon/Xenomorph/throw_impact(atom/hit_atom, speed)
	set waitfor = 0

	if(!charge_type || stat || (!throwing && usedPounce)) //No charge type, unconscious or dead, or not throwing but used pounce.
		..() //Do the parent instead.
		return FALSE

	if(isobj(hit_atom)) //Deal with smacking into dense objects. This overwrites normal throw code.
		var/obj/O = hit_atom
		if(!O.density) return FALSE//Not a dense object? Doesn't matter then, pass over it.
		if(!O.anchored) step(O, dir) //Not anchored? Knock the object back a bit. Ie. canisters.

		switch(charge_type) //Determine how to handle it depending on charge type.
			if(1 to 2)
				if(!istype(O, /obj/structure/table) && !istype(O, /obj/structure/rack))
					O.hitby(src, speed) //This resets throwing.
			if(3 to 4)
				if(istype(O, /obj/structure/table) || istype(O, /obj/structure/rack))
					var/obj/structure/S = O
					visible_message("<span class='danger'>[src] plows straight through [S]!</span>", null, null, 5)
					S.destroy() //We want to continue moving, so we do not reset throwing.
				else O.hitby(src, speed) //This resets throwing.
		return TRUE

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
							return FALSE

						if(isYautja(H))
							if(H.check_shields(0, "the pounce", 1))
								visible_message("<span class='danger'>[H] blocks the pounce of [src] with the combistick!</span>",
												"<span class='xenodanger'>[H] blocks your pouncing form with the combistick!</span>", null, 5)
								KnockDown(5)
								throwing = FALSE
								return FALSE
							else if(prob(75)) //Body slam the fuck out of xenos jumping at your front.
								visible_message("<span class='danger'>[H] body slams [src]!</span>",
												"<span class='xenodanger'>[H] body slams you!</span>", null, 5)
								KnockDown(4)
								throwing = FALSE
								return FALSE

					visible_message("<span class='danger'>[src] pounces on [M]!</span>",
									"<span class='xenodanger'>You pounce on [M]!</span>", null, 5)
					M.KnockDown(1)
					step_to(src, M)
					canmove = FALSE
					if(savage) //If Runner Savage is toggled on, attempt to use it.
						if(!savage_used)
							if(plasma_stored >= 10)
								Savage(M)
							else
								to_chat(src, "<span class='xenodanger'>You attempt to savage your victim, but you need [10-plasma_stored] more plasma.</span>")
						else
							to_chat(src, "<span class='xenodanger'>You attempt to savage your victim, but you aren't yet ready.</span>")
					frozen = TRUE
					if(charge_type == 2)
						M.attack_alien(src, null, "disarm") //Hunters get a free throttle in exchange for lower initial stun.
					if(!is_robotic) playsound(loc, rand(0, 100) < 95 ? 'sound/voice/alien_pounce.ogg' : 'sound/voice/alien_pounce2.ogg', 25, 1)
					spawn(charge_type == 1 ? 5 : 15)
						frozen = FALSE
						update_canmove()
					stealth_router(HANDLE_STEALTH_CODE_CANCEL)

				if(3) //Ravagers get a free attack if they charge into someone. This will tackle if disarm is set instead.
					var/extra_dam = min(melee_damage_lower, rand(melee_damage_lower, melee_damage_upper) * (0.3 + 0.3 * upgrade)) //About 15 to 84 extra damage depending on upgrade level.
					M.attack_alien(src,  extra_dam) //Ancients deal about twice as much damage on a charge as a regular slash.
					M.KnockDown(1)

				if(4) //Predalien.
					M.attack_alien(src) //Free hit/grab/tackle. Does not weaken, and it's just a regular slash if they choose to do that.

		throwing = FALSE //Resert throwing since something was hit.
		return TRUE

	..() //Do the parent otherwise, for turfs.

//Bleuugh
/mob/living/carbon/Xenomorph/proc/empty_gut()
	if(stomach_contents.len)
		for(var/atom/movable/S in stomach_contents)
			stomach_contents.Remove(S)
			S.forceMove(get_turf(src))

	if(contents.len) //Get rid of anything that may be stuck inside us as well
		for(var/atom/movable/A in contents)
			A.forceMove(get_turf(src))

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
	playsound(loc, "alien_bite", 25)
	visible_message("<span class='danger'>\The [M] is viciously shredded by \the [src]'s sharp teeth!</span>", \
	"<span class='danger'>You viciously rend \the [M] with your teeth!</span>", null, 5)
	log_combat(M, src, "bitten")

	M.apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1) //This should slicey dicey
	M.updatehealth()
	critical_proc = TRUE
	spawn(critical_delay) //Delay before we have a chance of another crit
		critical_proc = FALSE

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
	playsound(M.loc, 'sound/weapons/alien_tail_attack.ogg', 25, 1) //Stolen from Yautja! Owned!
	visible_message("<span class='danger'>\The [M] is suddenly impaled by \the [src]'s sharp tail!</span>", \
	"<span class='danger'>You violently impale \the [M] with your tail!</span>", null, 5)
	log_combat(src, M, "tail-stabbed")

	M.apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
	M.updatehealth()
	critical_proc = TRUE
	spawn(critical_delay) //Delay before we have a chance of another crit
		critical_proc = FALSE

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
	client.change_view(viewsize)
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
	is_zoomed = 0
	zoom_turf = null
	if(!client)
		return
	client.change_view(world.view)
	client.pixel_x = 0
	client.pixel_y = 0

/mob/living/carbon/Xenomorph/proc/check_alien_construction(var/turf/current_turf)
	var/has_obstacle
	for(var/obj/O in current_turf)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			to_chat(src, "<span class='warning'>There is a little one here already. Best move it.</span>")
			return
		if(istype(O, /obj/effect/alien/egg))
			to_chat(src, "<span class='warning'>There's already an egg.</span>")
			return
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/effect/alien/resin))
			has_obstacle = TRUE
			break
		if(istype(O, /obj/structure/ladder))
			has_obstacle = TRUE
			break
		if(istype(O, /obj/structure/bed))
			if(istype(O, /obj/structure/bed/chair/dropship/passenger))
				var/obj/structure/bed/chair/dropship/passenger/P = O
				if(P.chair_state != DROPSHIP_CHAIR_BROKEN)
					has_obstacle = TRUE
					break
			else
				has_obstacle = TRUE
				break

		if(O.density && !(O.flags_atom & ON_BORDER))
			has_obstacle = TRUE
			break

	if(current_turf.density || has_obstacle)
		to_chat(src, "<span class='warning'>There's something built here already.</span>")
		return

	return 1

/mob/living/carbon/Xenomorph/drop_held_item()
	var/obj/item/clothing/mask/facehugger/F = get_active_hand()
	if(istype(F))
		if(locate(/turf/closed/wall/resin) in loc)
			to_chat(src, "<span class='warning'>You decide not to drop [F] after all.</span>")
			return

	. = ..()


//This is depricated. Use handle_collision() for all future speed changes. ~Bmc777
/mob/living/carbon/Xenomorph/proc/stop_momentum(direction, stunned)
	if(!lastturf) return FALSE //Not charging.
	if(charge_speed > charge_speed_buildup * charge_turfs_to_charge) //Message now happens without a stun condition
		visible_message("<span class='danger'>[src] skids to a halt!</span>",
		"<span class='xenowarning'>You skid to a halt.</span>", null, 5)
	last_charge_move = 0 //Always reset last charge tally
	charge_speed = 0
	charge_roar = 0
	lastturf = null
	flags_pass = 0
	update_icons()

//Why the elerloving fuck was this a Crusher only proc ? AND WHY IS IT NOT CAST ON THE RECEIVING ATOM ? AAAAAAA
/mob/living/carbon/Xenomorph/proc/diagonal_step(atom/movable/A, direction)
	if(!A) return FALSE
	switch(direction)
		if(EAST, WEST) step(A, pick(NORTH,SOUTH))
		if(NORTH,SOUTH) step(A, pick(EAST,WEST))

/mob/living/carbon/Xenomorph/proc/handle_momentum()
	if(throwing)
		return FALSE

	if(last_charge_move && last_charge_move < world.time - 5) //If we haven't moved in the last 500 ms, break charge on next move
		stop_momentum(charge_dir)

	if(stat || pulledby || !loc || !isturf(loc))
		stop_momentum(charge_dir)
		return FALSE

	if(!is_charging)
		stop_momentum(charge_dir)
		return FALSE

	if(lastturf && (loc == lastturf || loc.z != lastturf.z)) //Check if the Crusher didn't move from his last turf, aka stopped
		stop_momentum(charge_dir)
		return FALSE

	if(dir != charge_dir || m_intent == MOVE_INTENT_WALK || istype(loc, /turf/open/gm/river))
		stop_momentum(charge_dir)
		return FALSE

	if(pulling && charge_speed > charge_speed_buildup) stop_pulling()

	if(plasma_stored > 5) plasma_stored -= round(charge_speed) //Eats up plasma the faster you go, up to 0.5 per tile at max speed
	else
		stop_momentum(charge_dir)
		return FALSE

	last_charge_move = world.time //Index the world time to the last charge move

	if(charge_speed < charge_speed_max)
		charge_speed += charge_speed_buildup //Speed increases each step taken. Caps out at 14 tiles
		if(charge_speed == charge_speed_max) //Should only fire once due to above instruction
			if(!charge_roar)
				emote("roar")
				charge_roar = 1

	noise_timer = noise_timer ? --noise_timer : 3

	if(noise_timer == 3 && charge_speed > charge_speed_buildup * charge_turfs_to_charge)
		playsound(loc, "alien_charge", 50)

	if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)

		for(var/mob/living/carbon/M in loc)
			if(M.lying && !isXeno(M) && M.stat != DEAD && !(M.status_flags & XENO_HOST && istype(M.buckled, /obj/structure/bed/nest)))
				visible_message("<span class='danger'>[src] runs [M] over!</span>",
				"<span class='danger'>You run [M] over!</span>", null, 5)

				M.take_overall_damage(charge_speed * 10) //Yes, times fourty. Maxes out at a sweet, square 84 damage for 2.1 max speed
				animation_flash_color(M)

		var/shake_dist = min(round(charge_speed * 5), 8)
		for(var/mob/living/carbon/M in range(shake_dist))
			if(M.client && !isXeno(M))
				shake_camera(M, 1, 1)

	lastturf = isturf(loc) && !istype(loc, /turf/open/space) ? loc : null//Set their turf, to make sure they're moving and not jumped in a locker or some shit

	update_icons()

//When the Queen's pheromones are updated, or we add/remove a leader, update leader pheromones
/mob/living/carbon/Xenomorph/proc/handle_xeno_leader_pheromones(var/mob/living/carbon/Xenomorph/Queen/Q)

	if(!Q || !Q.anchored || !queen_chosen_lead || !Q.current_aura || Q.loc.z != loc.z) //We are no longer a leader, or the Queen attached to us has dropped from her ovi, disabled her pheromones or even died
		leader_aura_strength = 0
		leader_current_aura = ""
		to_chat(src, "<span class='xenowarning'>Your pheromones wane. The Queen is no longer granting you her pheromones.</span>")
	else
		leader_aura_strength = Q.aura_strength
		leader_current_aura = Q.current_aura
		to_chat(src, "<span class='xenowarning'>Your pheromones have changed. The Queen has new plans for the Hive.</span>")


/mob/living/carbon/Xenomorph/proc/update_spits()
	if(!ammo || !spit_types.len) //Only update xenos with ammo and spit types.
		return
	for(var/i in 1 to spit_types.len)
		if(ammo.icon_state == ammo_list[spit_types[i]].icon_state)
			ammo = ammo_list[spit_types[i]]
			return
	ammo = ammo_list[spit_types[1]] //No matching projectile time; default to first spit type
	return

/mob/living/carbon/Xenomorph/proc/stealth_router(code = 0)
	return FALSE

/mob/living/carbon/Xenomorph/Hunter/stealth_router(code = 0)
	switch(code)
		if(HANDLE_STEALTH_CHECK)
			if(stealth)
				return TRUE
			else
				return FALSE
		if(HANDLE_STEALTH_CODE_CANCEL)
			cancel_stealth()
		if(HANDLE_SNEAK_ATTACK_CHECK)
			if(can_sneak_attack)
				return TRUE
			else
				return FALSE
