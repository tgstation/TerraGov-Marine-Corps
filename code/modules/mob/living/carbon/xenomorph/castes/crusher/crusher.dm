/mob/living/carbon/Xenomorph/Crusher
	caste_base_type = /mob/living/carbon/Xenomorph/Crusher
	name = "Crusher"
	desc = "A huge alien with an enormous armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Crusher Walking"
	health = 300
	maxHealth = 300
	plasma_stored = 200
	speed = 0.1
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 3 //no stuns from explosions, ignore damages except devastation range.
	mob_size = MOB_SIZE_BIG

	is_charging = 1 //Crushers start with charging enabled

	pixel_x = -16
	pixel_y = -3
	old_x = -16
	old_y = -3

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/stomp,
		/datum/action/xeno_action/ready_charge,
		/datum/action/xeno_action/activable/cresttoss,
		)

/mob/living/carbon/Xenomorph/Crusher/add_slowdown(amount)
	if(charge_speed > CHARGE_SPEED_MAX * 0.5) //If we're over half the max charge speed, we're immune to slowdown.
		return FALSE
	slowdown = adjust_slowdown(amount*XENO_SLOWDOWN_REGEN)
	return slowdown

/mob/living/carbon/Xenomorph/Crusher/adjust_stagger(amount)
	if(amount > 0 && (charge_speed > CHARGE_SPEED_MAX * 0.5) ) //If we're over half the max charge speed, we don't accumulate more stagger stacks.
		return FALSE
	stagger = max(stagger + amount,0)
	return stagger 

//The atom collided with is passed to this proc, all types of collisions are dealt with here.
//The atom does not tell the Crusher how to handle a collision, the Crusher is an independant
//Xeno who don't need no atom. ~Bmc777
/mob/living/carbon/Xenomorph/proc/handle_collision(atom/target)
	if(!target)
		return FALSE

	//Barricade collision
	if(istype(target, /obj/structure/barricade))
		var/obj/structure/barricade/B = target
		if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
			visible_message("<span class='danger'>[src] rams into [B] and skids to a halt!</span>",
			"<span class='xenowarning'>You ram into [B] and skid to a halt!</span>")
			flags_pass = 0
			update_icons()
			B.Bumped(src)
			stop_momentum(charge_dir)
			return TRUE
		else
			stop_momentum(charge_dir)
			return FALSE

	//Razorwire collision
	if(istype(target, /obj/structure/razorwire))
		var/obj/structure/razorwire/B = target
		if(charge_speed >= CHARGE_SPEED_MAX) //plows right through
			flags_pass |= PASSTABLE
			update_icons()
			return TRUE
		else if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
			visible_message("<span class='danger'>[src] rams into [B] and skids to a halt!</span>",
			"<span class='xenowarning'>You ram into [B] and skid to a halt!</span>")
			flags_pass &= ~PASSTABLE
			update_icons()
			return TRUE
		else
			stop_momentum(charge_dir)
			return FALSE

	if(istype(target, /obj/vehicle/multitile/hitbox))
		var/obj/vehicle/multitile/hitbox/H = target
		if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
			visible_message("<span class='danger'>[src] rams into [H.root] and skids to a halt!</span>",
			"<span class='xenowarning'>You ram into [H.root] and skid to a halt!</span>")
			flags_pass = 0
			update_icons()
			H.root.Bumped(src)
			stop_momentum(charge_dir)
			return TRUE
		else
			stop_momentum(charge_dir)
			return FALSE

/atom/proc/charge_act(mob/living/carbon/Xenomorph/X)
	return TRUE

//Catch-all, basically. Bump() isn't going to catch anything non-dense, so this is fine.
/obj/charge_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(.)
		if(CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			X.stop_momentum(X.charge_dir)
			return FALSE

		if(anchored)
			if(X.charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
				X.stop_momentum(X.charge_dir)
				return FALSE
			else
				X.visible_message("<span class='danger'>[X] crushes [src]!</span>",
				"<span class='xenodanger'>You crush [src]!</span>")
				if(contents.len) //Hopefully won't auto-delete things inside crushed stuff.
					var/turf/T = get_turf(src)
					for(var/atom/movable/S in contents) S.loc = T
				qdel(src)
				X.charge_speed -= CHARGE_SPEED_BUILDUP * 3 //Lose three turfs worth of speed
		else
			if(X.charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
				if(buckled_mob)
					unbuckle()
				X.visible_message("<span class='warning'>[X] knocks [src] aside.</span>!",
				"<span class='xenowarning'>You knock [src] aside.</span>") //Canisters, crates etc. go flying.
				playsound(loc, "punch", 25, 1)
				X.diagonal_step(src, X.dir) //Occasionally fling it diagonally.
				step_away(src, X, min(round(X.charge_speed) + 1, 3))
				X.charge_speed -= CHARGE_SPEED_BUILDUP * 2 //Lose two turfs worth of speed
			else
				X.stop_momentum(X.charge_dir)
				return FALSE


//Beginning special object overrides.

//**READ ME**
//NO MORE SPECIAL OBJECT OVERRIDES! Do not create another charge_act.
//For all future collisions, add to the body of handle_collision().
//We do not want to add Crusher specific procs to objects, all Crusher
//related code should be handled by Crusher code. The object collided with
//should handle it's own damage (and deletion if needed) through it's
//Bumped() proc. ~Bmc777

/obj/structure/window/charge_act(mob/living/carbon/Xenomorph/X)
	if(CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		X.stop_momentum(X.charge_dir)
		return FALSE
	if(X.charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		X.stop_momentum(X.charge_dir)
		return FALSE
	health -= X.charge_speed * 80 //Should generally smash it unless not moving very fast.
	healthcheck(user = X)

	X.charge_speed -= CHARGE_SPEED_BUILDUP * 2 //Lose two turfs worth of speed

	return TRUE

/obj/structure/grille/charge_act(mob/living/carbon/Xenomorph/X)
	if(CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		X.stop_momentum(X.charge_dir)
		return FALSE
	if(X.charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		X.stop_momentum(X.charge_dir)
		return FALSE
	health -= X.charge_speed * 40 //Usually knocks it down.
	healthcheck()

	X.charge_speed -= CHARGE_SPEED_BUILDUP //Lose one turf worth of speed

	return TRUE

/obj/machinery/vending/charge_act(mob/living/carbon/Xenomorph/X)
	if(X.charge_speed > CHARGE_SPEED_MAX/2) //Halfway to full speed or more
		if(CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			X.stop_momentum(X.charge_dir, TRUE)
			return FALSE
		X.visible_message("<span class='danger'>[X] smashes straight into [src]!</span>",
		"<span class='xenodanger'>You smash straight into [src]!</span>")
		playsound(loc, "punch", 25, 1)
		tip_over()
		X.diagonal_step(src, X.dir, 50) //Occasionally fling it diagonally.
		step_away(src, X)
		step_away(src, X)
		X.charge_speed -= CHARGE_SPEED_BUILDUP * 2 //Lose two turfs worth of speed
		return TRUE
	else
		X.stop_momentum(X.charge_dir)
		return FALSE

/obj/mecha/charge_act(mob/living/carbon/Xenomorph/X)
	if(CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		X.stop_momentum(X.charge_dir, TRUE)
		return FALSE
	if(X.charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		X.stop_momentum(X.charge_dir)
		return FALSE
	take_damage(X.charge_speed * 80)
	X.visible_message("<span class='danger'>[X] rams [src]!</span>",
	"<span class='xenodanger'>You ram [src]!</span>")
	playsound(loc, "punch", 25, 1)
	if(X.charge_speed > CHARGE_SPEED_MAX/2) //Halfway to full speed or more
		X.diagonal_step(src, X.dir, 50) //Occasionally fling it diagonally.
		step_away(src, X)
		X.charge_speed -= CHARGE_SPEED_BUILDUP * 3 //Lose three turfs worth of speed
	return TRUE

/obj/machinery/marine_turret/charge_act(mob/living/carbon/Xenomorph/X)
	if(CHECK_BITFIELD(resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
		X.stop_momentum(X.charge_dir, TRUE)
		return FALSE
	if(X.charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		X.stop_momentum(X.charge_dir)
		return FALSE
	X.visible_message("<span class='danger'>[X] rams [src]!</span>",
	"<span class='xenodanger'>You ram [src]!</span>")
	playsound(loc, "punch", 25, 1)
	machine_stat = 1
	on = 0
	update_icon()
	update_health(X.charge_speed * 20)
	X.charge_speed -= CHARGE_SPEED_BUILDUP * 3 //Lose three turfs worth of speed
	return TRUE

/obj/structure/mineral_door/resin/charge_act(mob/living/carbon/Xenomorph/X)
	TryToSwitchState(X)

	if(X.charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		X.stop_momentum(X.charge_dir)
		return FALSE
	else
		X.charge_speed -= CHARGE_SPEED_BUILDUP * 2 //Lose two turfs worth of speed
		return TRUE

/obj/structure/table/charge_act(mob/living/carbon/Xenomorph/X)
	Crossed(X)
	return TRUE

/mob/living/carbon/charge_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(. && X.charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		playsound(loc, "punch", 25, 1)
		if(stat == DEAD)
			var/count = 0
			var/turf/TU = get_turf(src)
			for(var/mob/living/carbon/C in TU)
				if(C.stat == DEAD)
					count++
			if(count)
				X.charge_speed -= CHARGE_SPEED_BUILDUP / (count * 2) // half normal slowdown regardless of number of corpses.
		else if(!(status_flags & XENO_HOST) && !istype(buckled, /obj/structure/bed/nest))
			log_combat(X, src, "xeno charged")
			apply_damage(X.charge_speed * 40, BRUTE)
			X.visible_message("<span class='danger'>[X] rams [src]!</span>",
			"<span class='xenodanger'>You ram [src]!</span>")
		KnockDown(X.charge_speed * 4)
		animation_flash_color(src)
		X.diagonal_step(src, X.dir) //Occasionally fling it diagonally.
		step_away(src, X, round(X.charge_speed))
		X.charge_speed -= CHARGE_SPEED_BUILDUP //Lose one turf worth of speed
		return TRUE

//Special override case.
/mob/living/carbon/Xenomorph/charge_act(mob/living/carbon/Xenomorph/X)
	if(X.charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE)
		playsound(loc, "punch", 25, 1)
		if(!issamexenohive(X))
			log_combat(X, src, "xeno charged")
			apply_damage(X.charge_speed * 20, BRUTE) // half damage to avoid sillyness
		if(anchored) //Ovipositor queen can't be pushed
			X.stop_momentum(X.charge_dir, TRUE)
			return TRUE
		diagonal_step(src, X.dir, 100)
		step_away(src, X)
		X.charge_speed -= CHARGE_SPEED_BUILDUP * 2 //Lose two turfs worth of speed
		return TRUE
	else
		X.stop_momentum(X.charge_dir)
		return FALSE

/turf/charge_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(. && density) //We don't care if it's non dense.
		if(X.charge_speed < CHARGE_SPEED_MAX)
			X.stop_momentum(X.charge_dir)
			return FALSE
		else
			ex_act(2) //Should dismantle, or at least heavily damage it.
			X.stop_momentum(X.charge_dir)
			return TRUE

//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Crusher/Bump(atom/A, yes)
	set waitfor = 0

	if(charge_speed < CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE || !is_charging) return ..()

	if(stat || !A || !istype(A) || A == src || !yes) return FALSE

	if(now_pushing) return FALSE //Just a plain ol turf, let's return.

	if(dir != charge_dir) //We aren't facing the way we're charging.
		stop_momentum()
		return ..()

	if(!handle_collision(A))
		if(!A.charge_act(src)) //charge_act is depricated and only here to handle cases that have not been refactored as of yet.
			return ..()

	var/turf/T = get_step(src, dir)
	if(!T || !get_step_to(src, T)) //If it still exists, try to push it.
		return ..()

	lastturf = null //Reset this so we can properly continue with momentum.
	return TRUE

/mob/living/carbon/Xenomorph/Crusher/ex_act(severity)

	flash_eyes()

	if(severity == 1)
		adjustBruteLoss(rand(200, 300))
		updatehealth()

/mob/living/carbon/Xenomorph/Crusher/update_icons()
	if(stat == DEAD)
		icon_state = "Crusher Dead"
	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "Crusher Sleeping"
		else
			icon_state = "Crusher Knocked Down"
	else
		if(m_intent == MOVE_INTENT_RUN)
			if(charge_speed > CHARGE_SPEED_BUILDUP * CHARGE_TURFS_TO_CHARGE) //Let it build up a bit so we're not changing icons every single turf
				icon_state = "Crusher Charging"
			else
				icon_state = "Crusher Running"

		else
			icon_state = "Crusher Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()
