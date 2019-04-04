/mob/living/carbon/Xenomorph/proc/Pounce(atom/T)

	if(!T || !check_state() || !check_plasma(10) || T.layer >= FLY_LAYER) //anything above that shouldn't be pounceable (hud stuff)
		return

	if(!isturf(loc))
		to_chat(src, "<span class='xenowarning'>You can't pounce from here!</span>")
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>You must wait before pouncing.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't pounce with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	if(layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		layer = MOB_LAYER

	if(m_intent == "walk" && isxenohunter(src)) //Hunter that is currently using its stealth ability, need to unstealth him
		m_intent = "run"
		if(hud_used && hud_used.move_intent)
			hud_used.move_intent.icon_state = "running"
		update_icons()

	visible_message("<span class='xenowarning'>\The [src] pounces at [T]!</span>", \
	"<span class='xenowarning'>You pounce at [T]!</span>")
	usedPounce = TRUE
	flags_pass = PASSTABLE
	use_plasma(10)
	throw_at(T, 6, 2, src) //Victim, distance, speed
	addtimer(CALLBACK(src, .reset_flags_pass), 6)
	addtimer(CALLBACK(src, .reset_pounce_delay), xeno_caste.pounce_delay)

	return TRUE

/mob/living/carbon/Xenomorph/proc/reset_pounce_delay()
	usedPounce = FALSE
	to_chat(src, "<span class='xenodanger'>You're ready to pounce again.</span>")
	update_action_button_icons()
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

/mob/living/carbon/Xenomorph/proc/reset_flags_pass()
	if(!xeno_caste.hardcore)
		flags_pass = initial(flags_pass) //Reset the passtable.
	else
		flags_pass = NOFLAGS //Reset the passtable.


/atom/proc/acid_spray_act(mob/living/carbon/Xenomorph/X)
	return TRUE

/obj/structure/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if(!is_type_in_typecache(src, GLOB.acid_spray_hit))
		return TRUE // normal density flag
	health -= rand(40,60) + (X.upgrade_as_number() * SPRAY_STRUCTURE_UPGRADE_BONUS)
	update_health(TRUE)
	return TRUE // normal density flag

/obj/structure/razorwire/acid_spray_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	return FALSE // not normal density flag

/obj/vehicle/multitile/root/cm_armored/acid_spray_act(mob/living/carbon/Xenomorph/X)
	take_damage_type(rand(40,60) + (X.upgrade_as_number() * SPRAY_STRUCTURE_UPGRADE_BONUS), "acid", src)
	healthcheck()
	return TRUE

/mob/living/carbon/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if((status_flags & XENO_HOST) && istype(buckled, /obj/structure/bed/nest))
		return

	if(isxenopraetorian(X))
		round_statistics.praetorian_spray_direct_hits++

	acid_process_cooldown = world.time //prevent the victim from being damaged by acid puddle process damage for 1 second, so there's no chance they get immediately double dipped by it.
	var/armor_block = run_armor_check("chest", "acid")
	var/damage = rand(30,40) + (X.upgrade_as_number() * SPRAY_MOB_UPGRADE_BONUS)
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

GLOBAL_LIST_INIT(acid_spray_hit, typecacheof(list(/obj/structure/barricade, /obj/vehicle/multitile/root/cm_armored, /obj/structure/razorwire)))

/mob/living/carbon/Xenomorph/proc/do_acid_spray_cone(var/turf/T)
	set waitfor = 0

	var/facing = get_cardinal_dir(src, T)
	setDir(facing)

	T = loc
	for (var/i = 0, i < xeno_caste.acid_spray_range, i++)

		var/turf/next_T = get_step(T, facing)

		for (var/obj/O in T)
			if(!O.CheckExit(src, next_T))
				if(is_type_in_typecache(O, GLOB.acid_spray_hit) && O.acid_spray_act(src))
					return // returned true if normal density applies

		T = next_T

		if (T.density)
			return

		for (var/obj/O in T)
			if(!O.CanPass(src, loc))
				if(is_type_in_typecache(O, GLOB.acid_spray_hit) && O.acid_spray_act(src))
					return // returned true if normal density applies

		var/obj/effect/xenomorph/spray/S = acid_splat_turf(T)
		do_acid_spray_cone_normal(T, i, facing, S)
		sleep(3)

// Normal refers to the mathematical normal
/mob/living/carbon/Xenomorph/proc/do_acid_spray_cone_normal(turf/T, distance, facing, obj/effect/xenomorph/spray/source_spray)
	if (!distance)
		return

	var/obj/effect/xenomorph/spray/left_S = source_spray
	var/obj/effect/xenomorph/spray/right_S = source_spray

	var/normal_dir = turn(facing, 90)
	var/inverse_normal_dir = turn(facing, -90)

	var/turf/normal_turf = T
	var/turf/inverse_normal_turf = T

	var/normal_density_flag = 0
	var/inverse_normal_density_flag = 0

	for (var/i = 0, i < distance, i++)
		if (normal_density_flag && inverse_normal_density_flag)
			return

		if (!normal_density_flag)
			var/next_normal_turf = get_step(normal_turf, normal_dir)

			for (var/obj/O in normal_turf)
				if(!O.CheckExit(left_S, next_normal_turf))
					normal_density_flag = TRUE
					if(is_type_in_typecache(O, GLOB.acid_spray_hit))
						normal_density_flag = O.acid_spray_act(src)
					break

			normal_turf = next_normal_turf

			if(!normal_density_flag)
				normal_density_flag = normal_turf.density

			if(!normal_density_flag)
				for (var/obj/O in normal_turf)
					if(!O.CanPass(left_S, left_S.loc))
						normal_density_flag = TRUE
						if(is_type_in_typecache(O, GLOB.acid_spray_hit))
							normal_density_flag = O.acid_spray_act(src)
						break

			if (!normal_density_flag)
				left_S = acid_splat_turf(normal_turf)


		if (!inverse_normal_density_flag)

			var/next_inverse_normal_turf = get_step(inverse_normal_turf, inverse_normal_dir)

			for (var/obj/O in inverse_normal_turf)
				if(!O.CheckExit(right_S, next_inverse_normal_turf))
					inverse_normal_density_flag = TRUE
					if(is_type_in_typecache(O, GLOB.acid_spray_hit))
						inverse_normal_density_flag = O.acid_spray_act(src)
					break

			inverse_normal_turf = next_inverse_normal_turf

			if(!inverse_normal_density_flag)
				inverse_normal_density_flag = inverse_normal_turf.density

			if(!inverse_normal_density_flag)
				for (var/obj/O in inverse_normal_turf)
					if(!O.CanPass(right_S, right_S.loc))
						inverse_normal_density_flag = TRUE //passable for acid spray
						if(is_type_in_typecache(O, GLOB.acid_spray_hit))
							inverse_normal_density_flag = O.acid_spray_act(src)
						break

			if (!inverse_normal_density_flag)
				right_S = acid_splat_turf(inverse_normal_turf)



/mob/living/carbon/Xenomorph/proc/acid_splat_turf(var/turf/T)
	. = locate(/obj/effect/xenomorph/spray) in T
	if(!.)
		. = new /obj/effect/xenomorph/spray(T)

		for(var/i in T)
			var/atom/A = i
			if(!A)
				continue
			A.acid_spray_act(src)

/* WIP Burrower stuff
/mob/living/carbon/Xenomorph/proc/burrow()
	if (!check_state())
		return

	if (used_burrow)
		return

	burrow = !burrow
	used_burrow = 1

	if (burrow)
		// TODO Make immune to all damage here.
		to_chat(src, "<span class='xenowarning'>You burrow yourself into the ground.</span>")
		set_frozen(TRUE)
		invisibility = INVISIBILITY_MAXIMUM
		anchored = TRUE
		density = FALSE
		update_canmove()
		update_icons()
		do_burrow_cooldown()
		burrow_timer = world.timeofday + 90		// How long we can be burrowed
		process_burrow()
		return

	burrow_off()
	do_burrow_cooldown()

/mob/living/carbon/Xenomorph/proc/process_burrow()
	set background = 1

	spawn while (burrow)
		if (world.timeofday > burrow_timer && !tunnel)
			burrow = 0
			burrow_off()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/burrow_off()

	to_chat(src, "<span class='notice'>You resurface.</span>")
	set_frozen(FALSE)
	invisibility = 0
	anchored = 0
	density = 1
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_burrow_cooldown()
	spawn(burrow_cooldown)
		used_burrow = 0
		to_chat(src, "<span class='notice'>You can now surface or tunnel.</span>")
		update_action_button_icons()


/mob/living/carbon/Xenomorph/proc/tunnel(var/turf/T)
	if (!burrow)
		to_chat(src, "<span class='notice'>You must be burrowed to do this.</span>")
		return

	if (used_burrow || used_tunnel)
		to_chat(src, "<span class='notice'>You must wait some time to do this.</span>")
		return

	if (tunnel)
		tunnel = 0
		to_chat(src, "<span class='notice'>You stop tunneling.</span>")
		used_tunnel = 1
		do_tunnel_cooldown()
		return

	if (!T || T.density)
		to_chat(src, "<span class='notice'>You cannot tunnel to there!</span>")

	tunnel = 1
	process_tunnel(T)


/mob/living/carbon/Xenomorph/proc/process_tunnel(var/turf/T)
	set background = 1

	spawn while (tunnel && T)
		if (world.timeofday > tunnel_timer)
			tunnel = 0
			do_tunnel()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/do_tunnel(var/turf/T)
	to_chat(src, "<span class='notice'>You tunnel to your destination.</span>")
	M.forceMove(T)
	burrow = 0
	burrow_off()

/mob/living/carbon/Xenomorph/proc/do_tunnel_cooldown()
	spawn(tunnel_cooldown)
		used_tunnel = 0
		to_chat(src, "<span class='notice'>You can now tunnel while burrowed.</span>")
		update_action_button_icons()
*/

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


/mob/living/carbon/Xenomorph/proc/xeno_transfer_plasma(atom/A, amount = 50, transfer_delay = 20, max_range = 2)
	if(!isxeno(A) || !check_state() || A == src)
		return

	var/mob/living/carbon/Xenomorph/target = A
	var/energy = isxenosilicon(src) ? "charge" : "plasma"

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't transfer [energy] from here!</span>")
		return

	if(isxenosilicon(src) != isxenosilicon(A))
		to_chat(src, "<span class='warning'>[target]'s source of energy is incompatible with ours.</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
		return

	to_chat(src, "<span class='notice'>You start focusing your [energy] towards [target].</span>")
	if(!do_after(src, transfer_delay, TRUE, 5, BUSY_ICON_FRIENDLY))
		return

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't transfer [energy] from here!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
		return

	if(plasma_stored < amount)
		amount = plasma_stored //Just use all of it

	if(target.plasma_stored >= target.xeno_caste.plasma_max)
		to_chat(src, "<span class='xenowarning'>[target] already has full plasma.</span>")
		return

	use_plasma(amount)
	target.gain_plasma(amount)
	to_chat(target, "<span class='xenowarning'>[src] has transfered [amount] units of [energy] to you. You now have [target.plasma_stored]/[target.xeno_caste.plasma_max].</span>")
	to_chat(src, "<span class='xenowarning'>You have transferred [amount] units of [energy] to [target]. You now have [plasma_stored]/[xeno_caste.plasma_max].</span>")
	playsound(src, "alien_drool", 25)

/mob/living/carbon/Xenomorph/proc/xeno_salvage_plasma(atom/A, amount, salvage_delay, max_range)
	if(!isxeno(A) || !check_state() || A == src)
		return

	var/mob/living/carbon/Xenomorph/target = A
	var/energy = isxenosilicon(src) ? "charge" : "plasma"

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't salvage [energy] from here!</span>")
		return

	if(isxenosilicon(src) != isxenosilicon(A))
		to_chat(src, "<span class='warning'>[target]'s source of energy is incompatible with ours.</span>")
		return

	if(plasma_stored >= xeno_caste.plasma_max)
		to_chat(src, "<span class='notice'>Your [energy] reserves are already at full capacity and can't hold any more.</span>")
		return

	if(target.stat != DEAD)
		to_chat(src, "<span class='warning'>You can't steal [energy] from living sisters, ask for some to a drone or a hivelord instead!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
		return

	if(!(target.plasma_stored))
		to_chat(src, "<span class='notice'>[target] doesn't have any [energy] left to salvage.</span>")
		return

	to_chat(src, "<span class='notice'>You start salvaging [energy] from [target].</span>")

	while(target.plasma_stored && plasma_stored >= xeno_caste.plasma_max)
		if(!do_after(src, salvage_delay, TRUE, 5, BUSY_ICON_HOSTILE) || !check_state())
			break

		if(!isturf(loc))
			to_chat(src, "<span class='warning'>You can't absorb [energy] from here!</span>")
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
		to_chat(src, "<span class='xenowarning'>You salvage [absorbed_amount] units of [energy] from [target]. You have [plasma_stored]/[xeno_caste.plasma_max] stored now.</span>")
		if(prob(50))
			playsound(src, "alien_drool", 25)

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/xeno_spit(atom/T)

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't spit from here!</span>")
		return

	if(has_spat > world.time)
		to_chat(src, "<span class='warning'>You must wait for your spit glands to refill.</span>")
		return

	if(!check_plasma(ammo.spit_cost))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
		return

	var/turf/current_turf = get_turf(src)

	if(!current_turf)
		return

	visible_message("<span class='xenowarning'>\The [src] spits at \the [T]!</span>", \
	"<span class='xenowarning'>You spit at \the [T]!</span>" )
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
	playsound(src.loc, sound_to_play, 25, 1)

	var/obj/item/projectile/A = new /obj/item/projectile(current_turf)
	A.generate_bullet(ammo, ammo.damage * SPIT_UPGRADE_BONUS) 
	A.permutated += src
	A.def_zone = get_limbzone_target()

	A.fire_at(T, src, src, ammo.max_range, ammo.shell_speed)
	has_spat = world.time + xeno_caste.spit_delay + ammo.added_spit_delay
	use_plasma(ammo.spit_cost)
	cooldown_notification(xeno_caste.spit_delay + ammo.added_spit_delay, "spit")

	return TRUE

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit")
			to_chat(src, "<span class='notice'>You feel your neurotoxin glands swell with ichor. You can spit again.</span>")
	update_action_button_icons()



/mob/living/carbon/Xenomorph/proc/build_resin(atom/A, resin_plasma_cost)
	if(action_busy)
		return
	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return
	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your dexterous limbs fail to properly respond as you try to shake up the shock!</span>")
		return
	var/turf/current_turf = loc
	if (isxenohivelord(src)) //hivelords can thicken existing resin structures.
		if(get_dist(src,A) <= 1)
			if(istype(A, /turf/closed/wall/resin))
				var/turf/closed/wall/resin/WR = A
				if(WR.walltype == "resin")
					visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and thickens [WR].</span>", \
					"<span class='xenonotice'>You regurgitate some resin and thicken [WR].</span>", null, 5)
					var/prev_oldturf = WR.oldTurf
					WR.ChangeTurf(/turf/closed/wall/resin/thick)
					WR.oldTurf = prev_oldturf
					use_plasma(resin_plasma_cost)
					playsound(loc, "alien_resin_build", 25)
				else if(WR.walltype == "membrane")
					var/prev_oldturf = WR.oldTurf
					WR.ChangeTurf(/turf/closed/wall/resin/membrane/thick)
					WR.oldTurf = prev_oldturf
					use_plasma(resin_plasma_cost)
					playsound(loc, "alien_resin_build", 25)
				else
					to_chat(src, "<span class='xenowarning'>[WR] can't be made thicker.</span>")
				return

			else if(istype(A, /obj/structure/mineral_door/resin))
				var/obj/structure/mineral_door/resin/DR = A
				if(DR.hardness == 1.5) //non thickened
					var/oldloc = DR.loc
					visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and thickens [DR].</span>", \
						"<span class='xenonotice'>You regurgitate some resin and thicken [DR].</span>", null, 5)
					qdel(DR)
					new /obj/structure/mineral_door/resin/thick (oldloc)
					playsound(loc, "alien_resin_build", 25)
					use_plasma(resin_plasma_cost)
				else
					to_chat(src, "<span class='xenowarning'>[DR] can't be made thicker.</span>")
				return

			else
				current_turf = get_turf(A) //Hivelords can secrete resin on adjacent turfs.



	var/mob/living/carbon/Xenomorph/blocker = locate() in current_turf
	if(blocker && blocker != src && blocker.stat != DEAD)
		to_chat(src, "<span class='warning'>Can't do that with [blocker] in the way!</span>")
		return

	if(!istype(current_turf) || !current_turf.is_weedable())
		to_chat(src, "<span class='warning'>You can't do that here.</span>")
		return

	var/area/AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1) || istype(AR,/area/shuttle/drop2/lz2) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		to_chat(src, "<span class='warning'>You sense this is not a suitable area for expanding the hive.</span>")
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		to_chat(src, "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>")
		return

	if(!check_alien_construction(current_turf))
		return

	if(selected_resin == "resin door")
		var/wall_support = FALSE
		for(var/D in cardinal)
			var/turf/T = get_step(current_turf,D)
			if(T)
				if(T.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in T)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(src, "<span class='warning'>Resin doors need a wall or resin door next to them to stand up.</span>")
			return

	var/wait_time = 10 + 30 - max(0,(30*health/maxHealth)) //Between 1 and 4 seconds, depending on health.

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_BUILD))
		return

	blocker = locate() in current_turf
	if(blocker && blocker != src && blocker.stat != DEAD)
		return

	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return

	if(!istype(current_turf) || !current_turf.is_weedable())
		return

	AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1 || istype(AR,/area/shuttle/drop2/lz2)) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		return

	alien_weeds = locate() in current_turf
	if(!alien_weeds)
		return

	if(!check_alien_construction(current_turf))
		return

	if(selected_resin == "resin door")
		var/wall_support = FALSE
		for(var/D in cardinal)
			var/turf/T = get_step(current_turf,D)
			if(T)
				if(T.density)
					wall_support = TRUE
					break
				else if(locate(/obj/structure/mineral_door/resin) in T)
					wall_support = TRUE
					break
		if(!wall_support)
			to_chat(src, "<span class='warning'>Resin doors need a wall or resin door next to them to stand up.</span>")
			return

	use_plasma(resin_plasma_cost)
	visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and shapes it into \a [selected_resin]!</span>", \
	"<span class='xenonotice'>You regurgitate some resin and shape it into \a [selected_resin].</span>", null, 5)
	playsound(loc, "alien_resin_build", 25)

	var/atom/new_resin

	switch(selected_resin)
		if("resin door")
			if (isxenohivelord(src))
				new_resin = new /obj/structure/mineral_door/resin/thick(current_turf)
			else
				new_resin = new /obj/structure/mineral_door/resin(current_turf)
		if("resin wall")
			if (isxenohivelord(src))
				current_turf.ChangeTurf(/turf/closed/wall/resin/thick)
			else
				current_turf.ChangeTurf(/turf/closed/wall/resin)
			new_resin = current_turf
		if("resin nest")
			new_resin = new /obj/structure/bed/nest(current_turf)
		if("sticky resin")
			new_resin = new /obj/effect/alien/resin/sticky(current_turf)

	new_resin.add_hiddenprint(src) //so admins know who placed it


//Corrosive acid is consolidated -- it checks for specific castes for strength now, but works identically to each other.
//The acid items are stored in XenoProcs.
/mob/living/carbon/Xenomorph/proc/corrosive_acid(atom/O, acid_type, plasma_cost)

	if(!O.Adjacent(src))
		to_chat(src, "<span class='warning'>\The [O] is too far away.</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't melt [O] from here!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your attempt to melt [O] but are too staggered!</span>")
		return

	face_atom(O)

	var/wait_time = 10

	//OBJ CHECK
	var/obj/effect/xenomorph/acid/new_acid = new acid_type
	var/obj/effect/xenomorph/acid/current_acid
	var/turf/T
	var/obj/I

	if(isobj(O))
		I = O
		current_acid = I.current_acid

		if(current_acid && !acid_check(new_acid, current_acid) )
			return

		if(I.unacidable || istype(I, /obj/machinery/computer) || istype(I, /obj/effect)) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			to_chat(src, "<span class='warning'>You cannot dissolve \the [I].</span>")
			return
		if(istype(O, /obj/structure/window_frame))
			var/obj/structure/window_frame/WF = O
			if(WF.reinforced && acid_type != /obj/effect/xenomorph/acid/strong)
				to_chat(src, "<span class='warning'>This [O.name] is too tough to be melted by your weak acid.</span>")
			return

		if(O.density || istype(O, /obj/structure))
			wait_time = 40 //dense objects are big, so takes longer to melt.

	//TURF CHECK

	else if(isturf(O))
		T = O
		current_acid = T.current_acid

		if(current_acid && !acid_check(new_acid, current_acid) )
			return

		if(iswallturf(O))
			var/turf/closed/wall/wall_target = O
			if (wall_target.acided_hole)
				to_chat(src, "<span class='warning'>[O] is already weakened.</span>")
				return

		var/dissolvability = T.can_be_dissolved()
		switch(dissolvability)
			if(0)
				to_chat(src, "<span class='warning'>You cannot dissolve \the [T].</span>")
				return
			if(1)
				wait_time = 50
			if(2)
				if(acid_type != /obj/effect/xenomorph/acid/strong)
					to_chat(src, "<span class='warning'>This [T.name] is too tough to be melted by your weak acid.</span>")
					return
				wait_time = 100
			else
				return
		to_chat(src, "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>")
	else
		to_chat(src, "<span class='warning'>You cannot dissolve \the [O].</span>")
		return

	if(!do_after(src, wait_time, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if(!check_state())
		return

	if(!O || !get_turf(O)) //Some logic.
		return

	if(!check_plasma(plasma_cost))
		return

	if(!O.Adjacent(src))
		return

	var/obj/effect/xenomorph/acid/A = new acid_type(get_turf(O), O)

	use_plasma(plasma_cost)


	if(istype(O, /obj/vehicle/multitile/root/cm_armored))
		var/obj/vehicle/multitile/root/cm_armored/R = O
		R.take_damage_type( (1 / A.acid_strength) * 20, "acid", src)
		visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff at \the [O]. It sizzles under the bubbling mess of acid!</span>", \
			"<span class='xenowarning'>You vomit globs of vile stuff at \the [O]. It sizzles under the bubbling mess of acid!</span>", null, 5)
		playsound(loc, "sound/bullets/acid_impact1.ogg", 25)
		sleep(20)
		qdel(A)
		return

	if(isturf(O))
		A.icon_state += "_wall"
		if(T.current_acid)
			acid_progress_transfer(A, null, T)
		T.current_acid = A

	if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
		A.layer = O.layer + 0.1
		if(I.current_acid)
			acid_progress_transfer(A, O)
		I.current_acid = A

	else if(istype(I)) //If not, appear on the floor or on an item
		if(I.current_acid)
			acid_progress_transfer(A, O)
		A.layer = LOWER_ITEM_LAYER //below any item, above BELOW_OBJ_LAYER (smartfridge)
		I.current_acid = A
	else
		return

	A.name = A.name + " (on [O.name])" //Identify what the acid is on
	A.add_hiddenprint(src)

	if(!isturf(O))
		log_combat(src, O, "spat on", addition="with corrosive acid")
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
	visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>You vomit globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", null, 5)
	playsound(loc, "sound/bullets/acid_impact1.ogg", 25)


/mob/living/carbon/Xenomorph/proc/acid_check(obj/effect/xenomorph/acid/new_acid, obj/effect/xenomorph/acid/current_acid)
	if(!new_acid || !current_acid)
		return

	if(new_acid.acid_strength >= current_acid.acid_strength)
		to_chat(src, "<span class='warning'>This object is already subject to a more or equally powerful acid.</span>")
		return FALSE
	return TRUE



/mob/living/carbon/Xenomorph/proc/acid_progress_transfer(acid_type, obj/O, turf/T)
	if(!O && !T)
		return

	var/obj/effect/xenomorph/acid/new_acid = acid_type

	var/obj/effect/xenomorph/acid/current_acid

	if(T)
		current_acid = T.current_acid

	else if(O)
		current_acid = O.current_acid

	if(!current_acid) //Sanity check. No acid
		return
	new_acid.ticks = current_acid.ticks //Inherit the old acid's progress
	qdel(current_acid)




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

/mob/living/carbon/Xenomorph/proc/spray_turfs(list/turflist)
	set waitfor = 0

	if(isnull(turflist))
		return

	var/turf/prev_turf
	var/distance = 0

	for(var/X in turflist)
		var/turf/T = X

		if(!prev_turf && turflist.len > 1)
			prev_turf = get_turf(src)
			continue //So we don't burn the tile we be standin on

		for(var/obj/structure/barricade/B in prev_turf)
			if(get_dir(prev_turf, T) & B.dir)
				B.acid_spray_act(src)

		if(T.density || isspaceturf(T))
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && !O.throwpass && !(O.flags_atom & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_turf.Adjacent(T) && (T.x != prev_turf.x || T.y != prev_turf.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_turf.x, T.y, prev_turf.z)
			var/turf/Tx = locate(T.x, prev_turf.y, prev_turf.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_turf.Adjacent(TB) && !TB.density && !isspaceturf(TB))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		for(var/obj/structure/barricade/B in TF)
			if(get_dir(TF, prev_turf) & B.dir)
				B.acid_spray_act(src)

		splat_turf(TF)

		distance++
		if(distance > 7 || blocked)
			break

		prev_turf = T
		sleep(2)


/mob/living/carbon/Xenomorph/proc/splat_turf(var/turf/target)
	if(!istype(target) || istype(target,/turf/open/space))
		return

	for(var/obj/effect/xenomorph/spray/S in target) //No stacking spray!
		qdel(S)
	new /obj/effect/xenomorph/spray(target)
	for(var/mob/living/carbon/M in target)
		if( isxeno(M) ) //Xenos immune to acid
			continue
		if((M.status_flags & XENO_HOST) && istype(M.buckled, /obj/structure/bed/nest)) //nested infected hosts are not hurt by acid spray
			continue
		M.acid_spray_act(src)


/mob/living/carbon/Xenomorph/proc/larva_injection(mob/living/carbon/C)
	if(!C?.can_sting())
		return FALSE
	if(!do_after(src, DEFILER_STING_CHANNEL_TIME, TRUE, 5, BUSY_ICON_HOSTILE))
		return FALSE
	if(stagger)
		return FALSE
	if(locate(/obj/item/alien_embryo) in C) // already got one, stops doubling up
		to_chat(src, "<span class='warning'>There is already a little one in this vessel!</span>")
		return FALSE
	face_atom(C)
	animation_attack_on(C)
	playsound(C, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	var/obj/item/alien_embryo/embryo = new(C)
	embryo.hivenumber = hivenumber
	round_statistics.now_pregnant++
	to_chat(src, "<span class='xenodanger'>Your stinger successfully implants a larva into the host.</span>")
	to_chat(C, "<span class='danger'>You feel horrible pain as something large is forcefully implanted in your thorax.</span>")
	C.apply_damage(100, HALLOSS)
	C.apply_damage(10, BRUTE, "chest")
	C.emote("scream")
	return TRUE

/mob/living/carbon/Xenomorph/proc/recurring_injection(mob/living/carbon/C, toxin = "xeno_toxin", channel_time = XENO_NEURO_CHANNEL_TIME, transfer_amount = XENO_NEURO_AMOUNT_RECURRING, count = 3)
	if(!C?.can_sting() || !toxin)
		return FALSE
	var/datum/reagent/body_tox
	var/i = 1
	do
		face_atom(C)
		if(stagger)
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


/mob/living/carbon/Xenomorph/proc/neurotoxin_sting(mob/living/carbon/C)

	if(!check_state())
		return

	if(!C?.can_sting())
		to_chat(src, "<span class='warning'>Your sting won't affect this target!</span>")
		return

	if(world.time < last_neurotoxin_sting + XENO_NEURO_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='warning'>You are not ready to use the sting again. It will be ready in [(last_neurotoxin_sting + XENO_NEURO_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='warning'>You try to sting but are too disoriented!</span>")
		return

	if(!Adjacent(C))
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='warning'>You can't reach this target!</span>")
			recent_notice = world.time //anti-notice spam
		return

	if ((C.status_flags & XENO_HOST) && istype(C.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='warning'>Ashamed, you reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_neurotoxin_sting = world.time
	use_plasma(150)

	round_statistics.sentinel_neurotoxin_stings++

	addtimer(CALLBACK(src, .neurotoxin_sting_cooldown), XENO_NEURO_STING_COOLDOWN)
	recurring_injection(C, "xeno_toxin", XENO_NEURO_CHANNEL_TIME, XENO_NEURO_AMOUNT_RECURRING)


/mob/living/carbon/Xenomorph/proc/neurotoxin_sting_cooldown()
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your neurotoxin glands refill. You can use your Neurotoxin Sting again.</span>")
	update_action_button_icons()


/mob/living/carbon/Xenomorph/proc/larval_growth_sting(mob/living/carbon/C)

	if(!check_state())
		return

	if(!C?.can_sting())
		to_chat(src, "<span class='warning'>Your sting won't affect this target!</span>")
		return

	if(world.time < last_larva_growth_used + XENO_LARVAL_GROWTH_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='warning'>You are not ready to sting again. Your sting will be ready in [(last_larva_growth_used + XENO_LARVAL_GROWTH_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='warning'>You try to sting but are too disoriented!</span>")
		return

	if(!Adjacent(C))
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='warning'>You can't reach this target!</span>")
			recent_notice = world.time //anti-notice spam
		return

	if ((C.status_flags & XENO_HOST) && istype(C.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='warning'>Ashamed, you reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_larva_growth_used = world.time
	use_plasma(150)

	round_statistics.larval_growth_stings++

	addtimer(CALLBACK(src, .larval_growth_sting_cooldown), XENO_LARVAL_GROWTH_COOLDOWN)
	recurring_injection(C, "xeno_growthtoxin", XENO_LARVAL_CHANNEL_TIME, XENO_LARVAL_AMOUNT_RECURRING)


/mob/living/carbon/Xenomorph/proc/larval_growth_sting_cooldown()
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your growth toxin glands refill. You can use Growth Sting again.</span>")
	update_action_button_icons()


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

