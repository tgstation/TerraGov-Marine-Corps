/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	if(isxenoqueen(src) && anchored)
		check_hive_status(src, anchored)
	else
		check_hive_status(src)

/proc/xeno_status_output(list/xenolist, can_overwatch = FALSE, ignore_leads = TRUE, user)
	var/xenoinfo = ""
	var/leadprefix = (ignore_leads?"":"<b>(-L-)</b>")
	for(var/i in xenolist)
		var/mob/living/carbon/Xenomorph/X = i
		if(ignore_leads && X.queen_chosen_lead)
			continue
		if(can_overwatch)
			xenoinfo += "<tr><td>[leadprefix]<a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
		else
			xenoinfo += "<tr><td>[leadprefix][X.name] "
		if(!X.client)
			xenoinfo += " <i>(SSD)</i>"
		else if(X.client.prefs.xeno_name && X.client.prefs.xeno_name != "Undefined")
			xenoinfo += "- [X.client.prefs.xeno_name]"

		var/area/A = get_area(X)
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"
	
	return xenoinfo

/proc/check_hive_status(mob/living/carbon/Xenomorph/user, var/anchored = FALSE)
	if(!SSticker)
		return
	var/dat = "<html><head><title>Hive Status</title></head><body>"

	var/datum/hive_status/hive
	if(istype(user) && user.hive)
		hive = user.hive
	else
		hive = GLOB.hive_datums[XENO_HIVE_NORMAL]

	if(!hive)
		CRASH("couldnt find a hive in check_hive_status")

	var/xenoinfo = ""
	var/can_overwatch = FALSE

	var/tier3counts = ""
	var/tier2counts = ""
	var/tier1counts = ""

	if(isxenoqueen(user))
		var/mob/living/carbon/Xenomorph/Queen/Q = user
		if(Q.ovipositor)
			can_overwatch = TRUE

	xenoinfo += xeno_status_output(hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Queen], FALSE, TRUE)

	xenoinfo += xeno_status_output(hive.xeno_leader_list, can_overwatch, FALSE, user)

	for(var/typepath in hive.xenos_by_typepath)
		if(typepath == /mob/living/carbon/Xenomorph/Queen)
			continue
		var/mob/living/carbon/Xenomorph/T = typepath
		var/datum/xeno_caste/XC = GLOB.xeno_caste_datums[typepath][XENO_UPGRADE_BASETYPE]
		if(XC.caste_flags & CASTE_HIDE_IN_STATUS)
			continue

		switch(initial(T.tier))
			if(XENO_TIER_ZERO)
				continue
			if(XENO_TIER_THREE)
				tier3counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"
			if(XENO_TIER_TWO)
				tier2counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"
			if(XENO_TIER_ONE)
				tier1counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"

		xenoinfo += xeno_status_output(hive.xenos_by_typepath[typepath], can_overwatch, TRUE, user)

	xenoinfo += xeno_status_output(hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva], can_overwatch, TRUE, user)

	dat += "<b>Total Living Sisters: [hive.get_total_xeno_number()]</b><BR>"
	dat += "<b>Tier 3: [length(hive.xenos_by_tier[XENO_TIER_THREE])] Sisters</b>[tier3counts]<BR>"
	dat += "<b>Tier 2: [length(hive.xenos_by_tier[XENO_TIER_TWO])] Sisters</b>[tier2counts]<BR>"
	dat += "<b>Tier 1: [length(hive.xenos_by_tier[XENO_TIER_ONE])] Sisters</b>[tier1counts]<BR>"
	dat += "<b>Larvas: [length(hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva])] Sisters<BR>"
	if(hive.hivenumber == XENO_HIVE_NORMAL)
		var/datum/hive_status/normal/HN = hive
		dat += "<b>Burrowed Larva: [HN.stored_larva] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += xenoinfo
	dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=600x600")


//Send a message to all xenos.
/proc/xeno_message(message = null, size = 3, hivenumber = XENO_HIVE_NORMAL)
	if(!message)
		return

	if(!GLOB.hive_datums[hivenumber])
		CRASH("xeno_message called with invalid hivenumber")

	var/datum/hive_status/HS = GLOB.hive_datums[hivenumber]
	HS.xeno_message(message, size)

/mob/living/carbon/Xenomorph/proc/upgrade_possible()
	return (upgrade != XENO_UPGRADE_INVALID && upgrade != XENO_UPGRADE_THREE)

//Adds stuff to your "Status" pane -- Specific castes can have their own, like carrier hugger count
//Those are dealt with in their caste files.
/mob/living/carbon/Xenomorph/Stat()
	. = ..()

	if(!statpanel("Stats"))
		return

	if(!(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED))
		stat(null, "Evolve Progress (FINISHED)")
	else if(!hive.living_xeno_queen)
		stat(null, "Evolve Progress (HALTED - NO QUEEN)")
	else
		stat(null, "Evolve Progress: [evolution_stored]/[xeno_caste.evolution_threshold]")

	if(upgrade_possible()) 
		stat(null, "Upgrade Progress: [upgrade_stored]/[xeno_caste.upgrade_threshold]")
	else //Upgrade process finished or impossible
		stat(null, "Upgrade Progress (FINISHED)")

	if(xeno_caste.plasma_max > 0)
		stat(null, "Plasma: [plasma_stored]/[xeno_caste.plasma_max]")

	if(hivenumber != XENO_HIVE_CORRUPTED)
		if(hive.slashing_allowed == XENO_SLASHING_ALLOWED)
			stat(null,"Slashing of hosts is currently: PERMITTED.")
		else if(hive.slashing_allowed == XENO_SLASHING_RESTRICTED)
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


//A simple handler for checking your state. Used in pretty much all the procs.
/mob/living/carbon/Xenomorph/proc/check_state()
	if(incapacitated() || lying || buckled)
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
			to_chat(src, "<span class='warning'>You do not have enough plasma to do this. You require [value] plasma but have only [plasma_stored] stored.</span>")
			return 0
	return 1

/mob/living/carbon/Xenomorph/proc/use_plasma(value)
	plasma_stored = max(plasma_stored - value, 0)
	update_action_button_icons()

/mob/living/carbon/Xenomorph/proc/gain_plasma(value)
	plasma_stored = min(plasma_stored + value, xeno_caste.plasma_max)
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

	if(hit_and_run) //We need to have the hit and run ability before we do anything
		hit_and_run = min(2, hit_and_run + 0.05) //increment the damage of our next attack by +5% up to 200%

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



/mob/living/carbon/Xenomorph/proc/update_progression()
	if(upgrade_possible()) //upgrade possible
		if(client && ckey) // pause for ssd/ghosted
			if(!hive?.living_xeno_queen || hive.living_xeno_queen.loc.z == loc.z)
				if(upgrade_stored >= xeno_caste.upgrade_threshold)
					if(health == maxHealth && !incapacitated() && !handcuffed && !legcuffed)
						upgrade_xeno(upgrade_next())
				else
					upgrade_stored = min(upgrade_stored + 1, xeno_caste.upgrade_threshold)

/mob/living/carbon/Xenomorph/proc/update_evolving()
	if(!client || !ckey) // stop evolve progress for ssd/ghosted xenos
		return
	if(evolution_stored >= xeno_caste.evolution_threshold || !(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED))
		return
	if(hive?.living_xeno_queen)
		evolution_stored++
		if(evolution_stored == xeno_caste.evolution_threshold - 1)
			to_chat(src, "<span class='xenodanger'>Your carapace crackles and your tendons strengthen. You are ready to evolve!</span>")
			src << sound('sound/effects/xeno_evolveready.ogg')

/mob/living/carbon/Xenomorph/show_inv(mob/user)
	return


//This deals with "throwing" xenos -- ravagers, hunters, and runners in particular. Everyone else defaults to normal
//Pounce, charge both use throw_at, so we need extra code to do stuff rather than just push people aside.
/mob/living/carbon/Xenomorph/throw_impact(atom/hit_atom, speed)
	set waitfor = 0

	if(!xeno_caste.charge_type || stat || (!throwing && usedPounce)) //No charge type, unconscious or dead, or not throwing but used pounce.
		..() //Do the parent instead.
		return FALSE

	if(isobj(hit_atom)) //Deal with smacking into dense objects. This overwrites normal throw code.
		var/obj/O = hit_atom
		if(!O.density) return FALSE//Not a dense object? Doesn't matter then, pass over it.
		if(!O.anchored) step(O, dir) //Not anchored? Knock the object back a bit. Ie. canisters.

		switch(xeno_caste.charge_type) //Determine how to handle it depending on charge type.
			if(1 to 2)
				if(!istype(O, /obj/structure/table) && !istype(O, /obj/structure/rack))
					O.hitby(src, speed) //This resets throwing.
			if(3 to 4)
				if(istype(O, /obj/structure/table) || istype(O, /obj/structure/rack))
					var/obj/structure/S = O
					visible_message("<span class='danger'>[src] plows straight through [S]!</span>", null, null, 5)
					S.destroy_structure() //We want to continue moving, so we do not reset throwing.
				else O.hitby(src, speed) //This resets throwing.
		return TRUE

	if(ismob(hit_atom)) //Hit a mob! This overwrites normal throw code.
		var/mob/living/carbon/M = hit_atom
		if(!M.stat && !isxeno(M))
			switch(xeno_caste.charge_type)
				if(1 to 2)
					if(ishuman(M) && M.dir in reverse_nearby_direction(dir))
						var/mob/living/carbon/human/H = M
						if(H.check_shields(15, "the pounce")) //Human shield block.
							KnockDown(3)
							throwing = FALSE //Reset throwing manually.
							return FALSE

					visible_message("<span class='danger'>[src] pounces on [M]!</span>",
									"<span class='xenodanger'>You pounce on [M]!</span>", null, 5)
					M.KnockDown(1)
					step_to(src, M)
					stop_movement()
					if(savage) //If Runner Savage is toggled on, attempt to use it.
						if(!savage_used)
							if(plasma_stored >= 10)
								Savage(M)
							else
								to_chat(src, "<span class='xenodanger'>You attempt to savage your victim, but you need [10-plasma_stored] more plasma.</span>")
						else
							to_chat(src, "<span class='xenodanger'>You attempt to savage your victim, but you aren't yet ready.</span>")

					if(xeno_caste.charge_type == 2)
						if(stealth_router(HANDLE_STEALTH_CHECK))
							M.adjust_stagger(3)
							M.add_slowdown(1)
							to_chat(src, "<span class='xenodanger'>Pouncing from the shadows, you stagger your victim.</span>")
					playsound(loc, rand(0, 100) < 95 ? 'sound/voice/alien_pounce.ogg' : 'sound/voice/alien_pounce2.ogg', 25, 1)
					addtimer(CALLBACK(src, .proc/reset_movement), xeno_caste.charge_type == 1 ? 5 : 15)
					stealth_router(HANDLE_STEALTH_CODE_CANCEL)

				if(RAV_CHARGE_TYPE) //Ravagers plow straight through humans; we only stop on hitting a dense turf
					return FALSE

		throwing = FALSE //Resert throwing since something was hit.
		reset_movement()
		return TRUE
	throwing = FALSE //Resert throwing since something was hit.
	reset_movement()
	return ..() //Do the parent otherwise, for turfs.

/mob/living/carbon/Xenomorph/proc/reset_movement()
	set_frozen(FALSE)
	update_canmove()

/mob/living/carbon/Xenomorph/proc/stop_movement()
	set_frozen(TRUE)
	update_canmove()

/mob/living/carbon/Xenomorph/set_frozen(freeze = TRUE)
	if(fortify && !freeze)
		return FALSE
	return ..()

//Bleuugh
/mob/living/carbon/Xenomorph/proc/empty_gut()
	if(stomach_contents.len)
		for(var/atom/movable/S in stomach_contents)
			stomach_contents.Remove(S)
			S.forceMove(get_turf(src))
			if(isliving(S))
				var/mob/living/M = S
				M.SetKnockeddown(1)
				M.adjust_blindness(-1)

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

/mob/living/carbon/Xenomorph/drop_held_item()
	var/obj/item/clothing/mask/facehugger/F = get_active_held_item()
	if(istype(F))
		if(locate(/turf/closed/wall/resin) in loc)
			to_chat(src, "<span class='warning'>You decide not to drop [F] after all.</span>")
			return

	. = ..()


//This is depricated. Use handle_collision() for all future speed changes. ~Bmc777
/mob/living/carbon/Xenomorph/proc/stop_momentum(direction, stunned)
	if(!lastturf) return FALSE //Not charging.
	if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE) //Message now happens without a stun condition
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

	if(dir != charge_dir || m_intent == MOVE_INTENT_WALK || istype(loc, /turf/open/ground/river))
		stop_momentum(charge_dir)
		return FALSE

	if(pulling && charge_speed > CHARGE_SPEED_BUILDUP) stop_pulling()

	if(plasma_stored > 5) plasma_stored -= round(charge_speed) //Eats up plasma the faster you go, up to 0.5 per tile at max speed
	else
		stop_momentum(charge_dir)
		return FALSE

	last_charge_move = world.time //Index the world time to the last charge move

	if(charge_speed < CHARGE_SPEED_MAX)
		charge_speed += CHARGE_SPEED_BUILDUP //Speed increases each step taken. Caps out at 14 tiles
		if(charge_speed == CHARGE_SPEED_MAX) //Should only fire once due to above instruction
			if(!charge_roar)
				emote("roar")
				charge_roar = 1

	noise_timer = noise_timer ? --noise_timer : 3

	if(noise_timer == 3 && charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		playsound(loc, "alien_charge", 50)

	if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)

		for(var/mob/living/carbon/M in loc)
			if(M.lying && !isxeno(M) && M.stat != DEAD && !(M.status_flags & XENO_HOST && istype(M.buckled, /obj/structure/bed/nest)))
				visible_message("<span class='danger'>[src] runs [M] over!</span>",
				"<span class='danger'>You run [M] over!</span>", null, 5)

				M.take_overall_damage(charge_speed * 10) //Yes, times fourty. Maxes out at a sweet, square 84 damage for 2.1 max speed
				animation_flash_color(M)

		var/shake_dist = min(round(charge_speed * 5), 8)
		for(var/mob/living/carbon/M in range(shake_dist))
			if(M.client && !isxeno(M))
				shake_camera(M, 1, 1)

	lastturf = isturf(loc) && !isspaceturf(loc) ? loc : null//Set their turf, to make sure they're moving and not jumped in a locker or some shit

	update_icons()

//When the Queen's pheromones are updated, or we add/remove a leader, update leader pheromones
/mob/living/carbon/Xenomorph/proc/handle_xeno_leader_pheromones(var/mob/living/carbon/Xenomorph/Queen/Q)

	if(!Q || !Q.ovipositor || !queen_chosen_lead || !Q.current_aura || Q.loc.z != loc.z) //We are no longer a leader, or the Queen attached to us has dropped from her ovi, disabled her pheromones or even died
		leader_aura_strength = 0
		leader_current_aura = ""
		to_chat(src, "<span class='xenowarning'>Your pheromones wane. The Queen is no longer granting you her pheromones.</span>")
	else
		leader_aura_strength = Q.xeno_caste.aura_strength
		leader_current_aura = Q.current_aura
		to_chat(src, "<span class='xenowarning'>Your pheromones have changed. The Queen has new plans for the Hive.</span>")


/mob/living/carbon/Xenomorph/proc/update_spits()
	if(!ammo || !xeno_caste.spit_types || !xeno_caste.spit_types.len) //Only update xenos with ammo and spit types.
		return
	for(var/i in 1 to xeno_caste.spit_types.len)
		if(ammo.icon_state == GLOB.ammo_list[xeno_caste.spit_types[i]].icon_state)
			ammo = GLOB.ammo_list[xeno_caste.spit_types[i]]
			return
	ammo = GLOB.ammo_list[xeno_caste.spit_types[1]] //No matching projectile time; default to first spit type
	return

/mob/living/carbon/Xenomorph/proc/stealth_router(code = 0)
	return FALSE

/mob/living/carbon/Xenomorph/proc/neuroclaw_router()
	return

/mob/living/carbon/Xenomorph/proc/process_ravager_charge(hit = TRUE, mob/living/carbon/M = null)
	return FALSE

/mob/living/carbon/Xenomorph/proc/handle_decay()
	if(prob(7+(3*tier)+(3*upgrade_as_number()))) // higher level xenos decay faster, higher plasma storage.
		use_plasma(min(rand(1,2), plasma_stored))



// this mess will be fixed by obj damage refactor
/atom/proc/acid_spray_act(mob/living/carbon/Xenomorph/X)
	return TRUE

/obj/structure/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if(!is_type_in_typecache(src, GLOB.acid_spray_hit))
		return TRUE // normal density flag
	obj_integrity -= rand(40,60) + SPRAY_STRUCTURE_UPGRADE_BONUS(X)
	update_health(TRUE)
	return TRUE // normal density flag

/obj/structure/razorwire/acid_spray_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	return FALSE // not normal density flag

/obj/vehicle/multitile/root/cm_armored/acid_spray_act(mob/living/carbon/Xenomorph/X)
	take_damage_type(rand(40,60) + SPRAY_STRUCTURE_UPGRADE_BONUS(X), "acid", src)
	healthcheck()
	return TRUE

/mob/living/carbon/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if((status_flags & XENO_HOST) && istype(buckled, /obj/structure/bed/nest))
		return

	if(isxenopraetorian(X))
		round_statistics.praetorian_spray_direct_hits++

	acid_process_cooldown = world.time //prevent the victim from being damaged by acid puddle process damage for 1 second, so there's no chance they get immediately double dipped by it.
	var/armor_block = run_armor_check("chest", "acid")
	var/damage = rand(30,40) + SPRAY_MOB_UPGRADE_BONUS(X)
	apply_acid_spray_damage(damage, armor_block)
	to_chat(src, "<span class='xenodanger'>\The [X] showers you in corrosive acid!</span>")

/mob/living/carbon/proc/apply_acid_spray_damage(damage, armor_block)
	apply_damage(damage, BURN, null, armor_block)

/mob/living/carbon/human/apply_acid_spray_damage(damage, armor_block)
	take_overall_damage(null, damage, null, null, null, armor_block)
	emote("scream")
	KnockDown(1)

/mob/living/carbon/Xenomorph/acid_spray_act(mob/living/carbon/Xenomorph/X)
	return


// Vent Crawl
/mob/living/carbon/Xenomorph/proc/vent_crawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Alien"
	if(!check_state())
		return
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)

/mob/living/carbon/Xenomorph/proc/xeno_salvage_plasma(atom/A, amount, salvage_delay, max_range)
	if(!isxeno(A) || !check_state() || A == src)
		return

	var/mob/living/carbon/Xenomorph/target = A

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't salvage plasma from here!</span>")
		return

	if(plasma_stored >= xeno_caste.plasma_max)
		to_chat(src, "<span class='notice'>Your plasma reserves are already at full capacity and can't hold any more.</span>")
		return

	if(target.stat != DEAD)
		to_chat(src, "<span class='warning'>You can't steal plasma from living sisters, ask for some to a drone or a hivelord instead!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
		return

	if(!(target.plasma_stored))
		to_chat(src, "<span class='notice'>[target] doesn't have any plasma left to salvage.</span>")
		return

	to_chat(src, "<span class='notice'>You start salvaging plasma from [target].</span>")

	while(target.plasma_stored && plasma_stored >= xeno_caste.plasma_max)
		if(!do_after(src, salvage_delay, TRUE, 5, BUSY_ICON_HOSTILE) || !check_state())
			break

		if(!isturf(loc))
			to_chat(src, "<span class='warning'>You can't absorb plasma from here!</span>")
			break

		if(get_dist(src, target) > max_range)
			to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
			break

		if(stagger)
			to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
			break

		if(target.plasma_stored < amount)
			amount = target.plasma_stored //Just take it all.

		var/absorbed_amount = round(amount * PLASMA_SALVAGE_MULTIPLIER)
		target.use_plasma(amount)
		gain_plasma(absorbed_amount)
		to_chat(src, "<span class='xenowarning'>You salvage [absorbed_amount] units of plasma from [target]. You have [plasma_stored]/[xeno_caste.plasma_max] stored now.</span>")
		if(prob(50))
			playsound(src, "alien_drool", 25)



/mob/living/carbon/Xenomorph/verb/toggle_xeno_mobhud()
	set name = "Toggle Xeno Status HUD"
	set desc = "Toggles the health and plasma hud appearing above Xenomorphs."
	set category = "Alien"

	xeno_mobhud = !xeno_mobhud
	var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
	if(xeno_mobhud)
		H.add_hud_to(usr)
	else
		H.remove_hud_from(usr)


/mob/living/carbon/Xenomorph/verb/middle_mousetoggle()
	set name = "Toggle Middle/Shift Clicking"
	set desc = "Toggles between using middle mouse click and shift click for selected abilitiy use."
	set category = "Alien"

	middle_mouse_toggle = !middle_mouse_toggle
	if(!middle_mouse_toggle)
		to_chat(src, "<span class='notice'>The selected xeno ability will now be activated with shift clicking.</span>")
	else
		to_chat(src, "<span class='notice'>The selected xeno ability will now be activated with middle mouse clicking.</span>")


/mob/living/carbon/Xenomorph/proc/recurring_injection(mob/living/carbon/C, toxin = "xeno_toxin", channel_time = XENO_NEURO_CHANNEL_TIME, transfer_amount = XENO_NEURO_AMOUNT_RECURRING, count = 3)
	if(!C?.can_sting() || !toxin)
		return FALSE
	var/datum/reagent/body_tox
	var/i = 1
	do
		face_atom(C)
		if(stagger)
			return FALSE
		body_tox = C.reagents.get_reagent(toxin)
		if(CHECK_BITFIELD(C.status_flags, XENO_HOST) && body_tox && body_tox.volume > body_tox.overdose_threshold)
			to_chat(src, "<span class='warning'>You sense the infected host is saturated with [body_tox.name] and cease your attempt to inoculate it further to preserve the little one inside.</span>")
			return FALSE
		animation_attack_on(C)
		playsound(C, 'sound/effects/spray3.ogg', 15, 1)
		playsound(C, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
		C.reagents.add_reagent(toxin, transfer_amount)
		if(!body_tox) //Let's check this each time because depending on the metabolization rate it can disappear between stings.
			body_tox = C.reagents.get_reagent(toxin)
		to_chat(C, "<span class='danger'>You feel a tiny prick.</span>")
		to_chat(src, "<span class='xenowarning'>Your stinger injects your victim with [body_tox.name]!</span>")
		if(body_tox.volume > body_tox.overdose_threshold)
			to_chat(src, "<span class='danger'>You sense the host is saturated with [body_tox.name].</span>")
	while(i++ < count && do_after(src, channel_time, TRUE, 5, BUSY_ICON_HOSTILE))
	return TRUE


/atom/proc/can_sting()
	return FALSE

/mob/living/carbon/monkey/can_sting()
	if(stat != DEAD)
		return TRUE
	return FALSE

/mob/living/carbon/human/can_sting()
	if(stat != DEAD)
		return TRUE
	return FALSE

/mob/living/carbon/human/species/machine/can_sting()
	return FALSE

/mob/living/carbon/human/species/synthetic/can_sting()
	return FALSE

/mob/living/carbon/Xenomorph/proc/hit_and_run_bonus(damage)
	return damage
