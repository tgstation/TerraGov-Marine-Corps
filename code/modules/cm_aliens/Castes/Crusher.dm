/mob/living/carbon/Xenomorph/Crusher
	caste = "Crusher"
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	melee_damage_lower = 15
	melee_damage_upper = 30
	tacklemin = 4
	tacklemax = 7
	tackle_chance = 60
	health = 250
	maxHealth = 250
	storedplasma = 200
	plasma_gain = 10
	maxplasma = 200
	evolution_threshold = 800
	caste_desc = "A huge tanky xenomorph."
	speed = 0.1
	evolves_to = list()
	armor_deflection = 75
	tier = 3
	upgrade = 0
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 3 //no stuns from explosions, ignore damages except devastation range.
	var/charge_dir = 0
	var/momentum = 0 //Builds up charge based on movement.
	var/charge_timer = 0 //Has a small charge window. has to keep moving to build momentum.
	var/turf/lastturf = null
	var/noise_timer = 0 // Makes a mech footstep, but only every 3 turfs.
	var/has_moved = 0
	mob_size = MOB_SIZE_BIG
	var/is_charging = 1

	pixel_x = -16
	pixel_y = -3

	actions = list(
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/stomp,
		/datum/action/xeno_action/ready_charge,
		)





/mob/living/carbon/Xenomorph/Crusher/Stat()
	. = ..()
	if(.)
		stat(null, "Momentum: [momentum]")

// This is depricated. Use handle_collision() for all future momentum changes. ~Bmc777
/mob/living/carbon/Xenomorph/Crusher/proc/stop_momentum(direction, stunned)
	if(!lastturf) r_FAL //Not charging.
	momentum = 0
	if(stunned && momentum > 24)
		visible_message(
		"<span class='danger'>[src] skids to a halt!</span>",
		"<span class='xenowarning'>You skid to a halt.</span>")
	lastturf = null
	flags_pass = 0
	speed = initial(speed) //TODO This doesn't take into account other speed upgrades, reseting after evolve.
	update_icons()

//This is called every time the crusher moves, before it moves.
/mob/living/carbon/Xenomorph/Crusher/movement_delay()
	. = ..()

	charge_timer = 2
	if(momentum == 0)
		charge_dir = dir
		handle_momentum()
	else
		if(charge_dir != dir) //Have we changed direction?
			stop_momentum() //This should disallow rapid turn bumps
		else
			handle_momentum()



/mob/living/carbon/Xenomorph/Crusher/proc/stomp()

	if(!check_state()) return

	if(world.time < has_screeched + CRUSHER_STOMP_COOLDOWN) //Sure, let's use this.
		src << "<span class='xenowarning'>You are not ready to stomp again.</span>"
		r_FAL

	if(!check_plasma(50)) return
	has_screeched = world.time
	use_plasma(50)

	playsound(loc, 'sound/effects/bang.ogg', 25, 0)
	visible_message("<span class='xenodanger'>[src] smashes into the ground!</span>", \
	"<span class='xenodanger'>You smash into the ground!</span>")
	create_shriekwave() //Adds the visual effect. Wom wom wom
	var/mob/living/L
	var/i = 5
	for(var/mob/M in loc)
		if(!i) break
		if(!isXeno(M) && isliving(M))
			L = M
			L.take_overall_damage(40) //The same as a full charge, but no more than that.
			L.KnockDown(rand(2, 3))
			L << "<span class='highdanger'>You are stomped on by [src]!</span>"
			shake_camera(L, 2, 2)
		i--



/mob/living/carbon/Xenomorph/Crusher/proc/handle_momentum()
	if(throwing) r_FAL

	if(stat || pulledby || !loc || !isturf(loc))
		stop_momentum(charge_dir)
		r_FAL

	if(!is_charging)
		stop_momentum(charge_dir)
		r_FAL

	if(lastturf && (loc == lastturf || loc.z != lastturf.z))
		stop_momentum(charge_dir)
		r_FAL

	if(dir != charge_dir || m_intent == "walk" || istype(loc, /turf/unsimulated/floor/gm/river))
		stop_momentum(charge_dir)
		r_FAL

	if(pulling && momentum > 12) stop_pulling()

	if(storedplasma > 5) storedplasma -= round(momentum * 0.1) //Eats up some plasma. max -3
	else
		stop_momentum(charge_dir)
		r_FAL

	if(speed > -2.0) speed -= 0.17 //Speed increases each step taken. At 30 tiles, maximum speed is reached. //Seems to be 13 tiles now. Would match more with observations

	switch(momentum)
		if(-INFINITY to -1) momentum = 0 //Close enough.
		if(0 to 18)
			if(momentum == 10) src << "<span class='xenonotice'>You begin churning up the ground with your charge!</span>"
			momentum += 3 //2 per turf. Max speed in 15.
		if(19 to 25)
			if(momentum == 20) src << "<span class='xenowarning'>The ground begins to shake as you run!</span>"
			momentum += 2
		if(26 to 29)
			if(momentum == 28)
				src << "<span class='xenodanger'>You have achieved maximum momentum!</span>"
				emote("roar")
			momentum++ //Increases slower at high speeds so we don't go LAZERFAST

	noise_timer = noise_timer ? --noise_timer : 3

	if(noise_timer == 3 && momentum > 10)
		playsound(loc, 'sound/mecha/mechstep.ogg', 15 + (momentum/2), 0)

	if(momentum > 6)
		for(var/mob/living/carbon/M in view(8))
			if(M && M.client && get_dist(M, src) <= round(momentum / 5) && src != M)
				if(!isXeno(M)) shake_camera(M, 1, 1)

			if(M && M.lying && M.loc == src.loc && !isXeno(M) && M.stat != DEAD)
				visible_message(
				"<span class='danger'>[src] runs [M] over!</span>",
				"<span class='danger'>You run [M] over!</span>")
				M.take_overall_damage(momentum * 2)
				animation_flash_color(M)

	lastturf = isturf(loc) && !istype(loc, /turf/space) ? loc : null//Set their turf, to make sure they're moving and not jumped in a locker or some shit

	update_icons()

// The atom collided with is passed to this proc, all types of collisions are dealt with here.
// The atom does not tell the Crusher how to handle a collision, the Crusher is an independant
// Xeno who don't need no atom. ~Bmc777
/mob/living/carbon/Xenomorph/Crusher/proc/handle_collision(atom/target)
	if (!target)
		r_FAL

	//Barricade collision
	if (istype(target, /obj/structure/barricade))
		var/obj/structure/barricade/B = target
		if (momentum > 19)
			visible_message(
			"<span class='danger'>[src] hits [B] and skids to a halt!</span>",
			"<span class='xenowarning'>You hit [B] and skid to a halt!</span>")

			flags_pass = 0
			update_icons()
			B.Bumped(src)
			momentum = 0
			speed = initial(speed)
			r_TRU

	r_FAL

proc/diagonal_step(atom/movable/A, direction, P = 75)
	if(!A || !prob(P)) r_FAL
	switch(direction)
		if(EAST, WEST) step(A, pick(NORTH,SOUTH))
		if(NORTH,SOUTH) step(A, pick(EAST,WEST))

/atom/proc/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	r_TRU

//Catch-all, basically. Bump() isn't going to catch anything non-dense, so this is fine.
/obj/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	. = ..()
	if(.)
		if(unacidable)
			if(X.momentum > 26) X.stop_momentum(X.charge_dir)
			r_FAL

		if(anchored)
			switch(X.momentum)
				if(0 to 16) r_FAL

				if(20 to INFINITY)
					X.visible_message(
					"<span class='danger'>[X] crushes [src]!</span>",
					"<span class='xenodanger'>You crush [src]!</span>")
					if(contents.len) //Hopefully won't auto-delete things inside crushed stuff.
						var/turf/T = get_turf(src)
						for(var/atom/movable/S in contents) S.loc = T
					cdel(src)
					X.momentum -= 6
		else
			if(X.momentum > 5)
				X.visible_message(
				"<span class='warning'>[X] knocks aside [src]</span>!",
				"<span class='xenowarning'>You casually knock aside [src].</span>") //Canisters, crates etc. go flying.
				playsound(loc, "punch", 25, 1)
				diagonal_step(src, X.dir) //Occasionally fling it diagonally.
				step_away(src, X, round(X.momentum * 0.1) + 1)
				X.momentum -= 3
			else r_FAL

//Beginning special object overrides.

//**READ ME**
//NO MORE SPECIAL OBJECT OVERRIDES! Do not create another crusher_act.
//For all future collisions, add to the body of handle_collision().
//We do not want to add Crusher specific procs to objects, all Crusher
//related code should be handled by Crusher code. The object collided with
//should handle it's own damage (and deletion if needed) through it's
//Bumped() proc. ~Bmc777

/obj/structure/window/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	if(unacidable)
		if(X.momentum > 26) X.stop_momentum(X.charge_dir, TRUE)
		r_FAL
	health -= X.momentum * 4 + 10 //Should generally smash it unless not moving very fast.
	healthcheck(user = X)

	if (X.momentum > 2)
		X.momentum -= 2
	else
		X.momentum = 0

	r_TRU

/obj/structure/grille/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	if(unacidable)
		if(X.momentum > 26) X.stop_momentum(X.charge_dir, TRUE)
		r_FAL
	health -= X.momentum * 3 //Usually knocks it down.
	healthcheck()
	r_TRU

/obj/machinery/vending/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	if(X.momentum > 20)
		if(unacidable)
			if(X.momentum > 26) X.stop_momentum(X.charge_dir, TRUE)
			r_FAL
		X.visible_message(
		"<span class='danger'>[X] smashes straight into [src]!</span>",
		"<span class='xenodanger'>You smash straight into [src]!</span>")
		playsound(loc, "punch", 25, 1)
		tip_over()
		diagonal_step(src, X.dir, 50) //Occasionally fling it diagonally.
		step_away(src, X)
		step_away(src, X)
		X.momentum -= 6
		r_TRU

/obj/mecha/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	if(unacidable)
		if(X.momentum > 26) X.stop_momentum(X.charge_dir, TRUE)
		r_FAL
	take_damage(X.momentum * 8)
	X.visible_message(
	"<span class='danger'>[X] rams [src]!</span>",
	"<span class='xenodanger'>You ram [src]!</span>")
	playsound(loc, "punch", 25, 1)
	if(X.momentum > 25)
		diagonal_step(src, X.dir, 50) //Occasionally fling it diagonally.
		step_away(src, X)
		X.momentum -= 9
	r_TRU

/obj/machinery/marine_turret/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	if(unacidable)
		if(X.momentum > 26) X.stop_momentum(X.charge_dir, TRUE)
		r_FAL
	X.visible_message(
	"<span class='danger'>[X] rams [src]!</span>", \
	"<span class='xenodanger'>You ram [src]!</span>")
	playsound(loc, "punch", 25, 1)
	if(X.momentum > 10 && prob(70 + X.momentum))
		stat = 1
		on = 0
		update_icon()
	update_health(X.momentum * 2)
	X.stop_momentum(X.charge_dir, TRUE)
	r_TRU

/obj/structure/mineral_door/resin/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	TryToSwitchState(X)

	//No flying through doors for free --MadSnailDisease
	if (X.momentum > 5)
		X.momentum -= 5
	else if (X.momentum > 2)
		X.momentum = 0


/obj/structure/table/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	Crossed(X)
	r_TRU

/mob/living/carbon/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	. = ..()
	if(. && X.momentum > 7)
		playsound(loc, "punch", 25, 1)
		switch(X.momentum)
			if(8 to 11) KnockDown(2)
			if(12 to 19)
				KnockDown(6)
				apply_damage(X.momentum, BRUTE)
			if(20 to INFINITY)
				KnockDown(8)
				take_overall_damage(X.momentum * 2)
		animation_flash_color(src)
		diagonal_step(src, X.dir) //Occasionally fling it diagonally.
		step_away(src, X, round(X.momentum * 0.1))
		X.visible_message(
		"<span class='danger'>[X] rams [src]!</span>",
		"<span class='xenodanger'>You ram [src]!</span>")
		X.momentum -= 3
		r_TRU

//Special override case.
/mob/living/carbon/Xenomorph/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	if(X.momentum > 6)
		playsound(loc, "punch", 25, 1)
		diagonal_step(src, X.dir, 100)
		step_away(src, X)

		if (X.momentum > 9)
			X.momentum -= 9
		else
			X.momentum = 0

		r_TRU

/turf/crusher_act(mob/living/carbon/Xenomorph/Crusher/X)
	. = ..()
	if(. && density) //We don't care if it's non dense.
		switch(X.momentum)
			if(15 to 25) X.stop_momentum(X.charge_dir, TRUE)
			if(26 to INFINITY) ex_act(2) //Should dismantle, or at least heavily damage it.
		r_TRU

//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Crusher/Bump(atom/A, yes)
	set waitfor = 0

	if(!is_charging) return ..()

	if(stat || momentum < 3 || !A || !istype(A) || A == src || !yes) r_FAL

	if(now_pushing) r_FAL//Just a plain ol turf, let's return.

	if(dir != charge_dir) //We aren't facing the way we're charging.
		stop_momentum()
		return ..()

	if (!handle_collision(A))
		if(!A.crusher_act(src)) //crusher_act is depricated and only here to handle cases that have not been refactored as of yet.
			return ..()

	var/turf/T = get_step(src, dir)
	if(!T || !get_step_to(src, T)) //If it still exists, try to push it.
		return ..()

	lastturf = null //Reset this so we can properly continue with momentum.
	r_TRU





/mob/living/carbon/Xenomorph/Crusher/ex_act(severity)

	if(!blinded && hud_used)
		flick("flash", hud_used.flash_icon)

	if(severity == 1)
		adjustBruteLoss(rand(200, 300))
		updatehealth()
