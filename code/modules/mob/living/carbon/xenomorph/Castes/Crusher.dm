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
	health = 300
	maxHealth = 300
	plasma_stored = 200
	plasma_gain = 10
	plasma_max = 200
	upgrade_threshold = 800
	evolution_allowed = FALSE
	caste_desc = "A huge tanky xenomorph."
	speed = 0.1
	tail_chance = 0 //Inherited from old code. Tail's too big
	armor_deflection = 75
	tier = 3
	upgrade = 0
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
		)

/mob/living/carbon/Xenomorph/Crusher/proc/stomp()

	if(!check_state()) return

	if(world.time < has_screeched + CRUSHER_STOMP_COOLDOWN) //Sure, let's use this.
		src << "<span class='xenowarning'>You are not ready to stomp again.</span>"
		r_FAL

	if(legcuffed)
		src << "<span class='xenodanger'>You can't rear up to stomp with that thing on your leg!</span>"
		return

	if(!check_plasma(50)) return
	has_screeched = world.time
	use_plasma(50)

	round_statistics.crusher_stomps++

	playsound(loc, 'sound/effects/bang.ogg', 25, 0)
	visible_message("<span class='xenodanger'>[src] smashes into the ground!</span>", \
	"<span class='xenodanger'>You smash into the ground!</span>")
	create_stomp() //Adds the visual effect. Wom wom wom

	var/i = 5
	for(var/mob/living/M in range(1,loc))
		if(!i) break
		if(!isXeno(M))
			if(M.loc == loc)
				if(M.stat == DEAD)
					continue
				if(!(M.status_flags & XENO_HOST) && !istype(M.buckled, /obj/structure/bed/nest))
					round_statistics.crusher_stomp_victims++
					M.take_overall_damage(40) //The same as a full charge, but no more than that.
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>was xeno stomped by [src] ([ckey])</font>")
					attack_log += text("\[[time_stamp()]\] <font color='red'>xeno stomped [M.name] ([M.ckey])</font>")
					log_attack("[src] ([ckey]) xeno stomped [M.name] ([M.ckey])")
				M.KnockDown(rand(2, 3))
				M << "<span class='highdanger'>You are stomped on by [src]!</span>"
			shake_camera(M, 2, 2)
		i--

//The atom collided with is passed to this proc, all types of collisions are dealt with here.
//The atom does not tell the Crusher how to handle a collision, the Crusher is an independant
//Xeno who don't need no atom. ~Bmc777
/mob/living/carbon/Xenomorph/proc/handle_collision(atom/target)
	if(!target)
		r_FAL

	//Barricade collision
	if(istype(target, /obj/structure/barricade))
		var/obj/structure/barricade/B = target
		if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)
			visible_message("<span class='danger'>[src] rams into [B] and skids to a halt!</span>",
			"<span class='xenowarning'>You ram into [B] and skid to a halt!</span>")
			flags_pass = 0
			update_icons()
			B.Bumped(src)
			stop_momentum(charge_dir)
			r_TRU
		else
			stop_momentum(charge_dir)
			r_FAL

	if(istype(target, /obj/vehicle/multitile/hitbox))
		var/obj/vehicle/multitile/hitbox/H = target
		if(charge_speed > charge_speed_buildup * charge_turfs_to_charge)
			visible_message("<span class='danger'>[src] rams into [H.root] and skids to a halt!</span>",
			"<span class='xenowarning'>You ram into [H.root] and skid to a halt!</span>")
			flags_pass = 0
			update_icons()
			H.root.Bumped(src)
			stop_momentum(charge_dir)
			r_TRU
		else
			stop_momentum(charge_dir)
			r_FAL

/atom/proc/charge_act(mob/living/carbon/Xenomorph/X)
	r_TRU

//Catch-all, basically. Bump() isn't going to catch anything non-dense, so this is fine.
/obj/charge_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(.)
		if(unacidable)
			X.stop_momentum(X.charge_dir)
			r_FAL

		if(anchored)
			if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
				X.stop_momentum(X.charge_dir)
				r_FAL
			else
				X.visible_message("<span class='danger'>[X] crushes [src]!</span>",
				"<span class='xenodanger'>You crush [src]!</span>")
				if(contents.len) //Hopefully won't auto-delete things inside crushed stuff.
					var/turf/T = get_turf(src)
					for(var/atom/movable/S in contents) S.loc = T
				cdel(src)
				X.charge_speed -= X.charge_speed_buildup * 3 //Lose three turfs worth of speed
		else
			if(X.charge_speed > X.charge_speed_buildup * X.charge_turfs_to_charge)
				if(buckled_mob)
					unbuckle()
				X.visible_message("<span class='warning'>[X] knocks [src] aside.</span>!",
				"<span class='xenowarning'>You knock [src] aside.</span>") //Canisters, crates etc. go flying.
				playsound(loc, "punch", 25, 1)
				X.diagonal_step(src, X.dir) //Occasionally fling it diagonally.
				step_away(src, X, min(round(X.charge_speed) + 1, 3))
				X.charge_speed -= X.charge_speed_buildup * 2 //Lose two turfs worth of speed
			else
				X.stop_momentum(X.charge_dir)
				r_FAL

//Beginning special object overrides.

//**READ ME**
//NO MORE SPECIAL OBJECT OVERRIDES! Do not create another charge_act.
//For all future collisions, add to the body of handle_collision().
//We do not want to add Crusher specific procs to objects, all Crusher
//related code should be handled by Crusher code. The object collided with
//should handle it's own damage (and deletion if needed) through it's
//Bumped() proc. ~Bmc777

/obj/structure/window/charge_act(mob/living/carbon/Xenomorph/X)
	if(unacidable)
		X.stop_momentum(X.charge_dir)
		r_FAL
	if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
		X.stop_momentum(X.charge_dir)
		r_FAL
	health -= X.charge_speed * 80 //Should generally smash it unless not moving very fast.
	healthcheck(user = X)

	X.charge_speed -= X.charge_speed_buildup * 2 //Lose two turfs worth of speed

	r_TRU

/obj/structure/grille/charge_act(mob/living/carbon/Xenomorph/X)
	if(unacidable)
		X.stop_momentum(X.charge_dir)
		r_FAL
	if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
		X.stop_momentum(X.charge_dir)
		r_FAL
	health -= X.charge_speed * 40 //Usually knocks it down.
	healthcheck()

	X.charge_speed -= X.charge_speed_buildup //Lose one turf worth of speed

	r_TRU

/obj/machinery/vending/charge_act(mob/living/carbon/Xenomorph/X)
	if(X.charge_speed > X.charge_speed_max/2) //Halfway to full speed or more
		if(unacidable)
			X.stop_momentum(X.charge_dir, TRUE)
			r_FAL
		X.visible_message("<span class='danger'>[X] smashes straight into [src]!</span>",
		"<span class='xenodanger'>You smash straight into [src]!</span>")
		playsound(loc, "punch", 25, 1)
		tip_over()
		X.diagonal_step(src, X.dir, 50) //Occasionally fling it diagonally.
		step_away(src, X)
		step_away(src, X)
		X.charge_speed -= X.charge_speed_buildup * 2 //Lose two turfs worth of speed
		r_TRU
	else
		X.stop_momentum(X.charge_dir)
		r_FAL

/obj/mecha/charge_act(mob/living/carbon/Xenomorph/X)
	if(unacidable)
		X.stop_momentum(X.charge_dir, TRUE)
		r_FAL
	if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
		X.stop_momentum(X.charge_dir)
		r_FAL
	take_damage(X.charge_speed * 80)
	X.visible_message("<span class='danger'>[X] rams [src]!</span>",
	"<span class='xenodanger'>You ram [src]!</span>")
	playsound(loc, "punch", 25, 1)
	if(X.charge_speed > X.charge_speed_max/2) //Halfway to full speed or more
		X.diagonal_step(src, X.dir, 50) //Occasionally fling it diagonally.
		step_away(src, X)
		X.charge_speed -= X.charge_speed_buildup * 3 //Lose three turfs worth of speed
	r_TRU

/obj/machinery/marine_turret/charge_act(mob/living/carbon/Xenomorph/X)
	if(unacidable)
		X.stop_momentum(X.charge_dir, TRUE)
		r_FAL
	if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
		X.stop_momentum(X.charge_dir)
		r_FAL
	X.visible_message("<span class='danger'>[X] rams [src]!</span>",
	"<span class='xenodanger'>You ram [src]!</span>")
	playsound(loc, "punch", 25, 1)
	stat = 1
	on = 0
	update_icon()
	update_health(X.charge_speed * 20)
	X.charge_speed -= X.charge_speed_buildup * 3 //Lose three turfs worth of speed
	r_TRU

/obj/structure/mineral_door/resin/charge_act(mob/living/carbon/Xenomorph/X)
	TryToSwitchState(X)

	if(X.charge_speed < X.charge_speed_buildup * X.charge_turfs_to_charge)
		X.stop_momentum(X.charge_dir)
		r_FAL
	else
		X.charge_speed -= X.charge_speed_buildup * 2 //Lose two turfs worth of speed
		r_TRU

/obj/structure/table/charge_act(mob/living/carbon/Xenomorph/X)
	Crossed(X)
	r_TRU

/mob/living/carbon/charge_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(. && X.charge_speed > X.charge_speed_buildup * X.charge_turfs_to_charge)
		playsound(loc, "punch", 25, 1)
		if(stat == DEAD)
			var/count = 0
			var/turf/TU = get_turf(src)
			for(var/mob/living/carbon/C in TU)
				if(C.stat == DEAD)
					count++
			if(count)
				X.charge_speed -= X.charge_speed_buildup / (count * 2) // half normal slowdown regardless of number of corpses.
		else if(!(status_flags & XENO_HOST) && !istype(buckled, /obj/structure/bed/nest))
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was xeno charged by [X.name] ([X.ckey])</font>")
			X.attack_log += text("\[[time_stamp()]\] <font color='red'>xeno charged [src.name] ([src.ckey])</font>")
			log_attack("[X.name] ([X.ckey]) xeno charged [src.name] ([src.ckey])")
			apply_damage(X.charge_speed * 40, BRUTE)
			X.visible_message("<span class='danger'>[X] rams [src]!</span>",
			"<span class='xenodanger'>You ram [src]!</span>")
		KnockDown(X.charge_speed * 4)
		animation_flash_color(src)
		X.diagonal_step(src, X.dir) //Occasionally fling it diagonally.
		step_away(src, X, round(X.charge_speed))
		X.charge_speed -= X.charge_speed_buildup //Lose one turf worth of speed
		r_TRU

//Special override case.
/mob/living/carbon/Xenomorph/charge_act(mob/living/carbon/Xenomorph/X)
	if(X.charge_speed > X.charge_speed_buildup * X.charge_turfs_to_charge)
		playsound(loc, "punch", 25, 1)
		if(hivenumber != X.hivenumber)
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was xeno charged by [X.name] ([X.ckey])</font>")
			X.attack_log += text("\[[time_stamp()]\] <font color='red'>xeno charged [src.name] ([src.ckey])</font>")
			log_attack("[X.name] ([X.ckey]) xeno charged [src.name] ([src.ckey])")
			apply_damage(X.charge_speed * 20, BRUTE) // half damage to avoid sillyness
		if(anchored) //Ovipositor queen can't be pushed
			X.stop_momentum(X.charge_dir, TRUE)
			r_TRU
		diagonal_step(src, X.dir, 100)
		step_away(src, X)
		X.charge_speed -= X.charge_speed_buildup * 2 //Lose two turfs worth of speed
		r_TRU
	else
		X.stop_momentum(X.charge_dir)
		r_FAL

/turf/charge_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	if(. && density) //We don't care if it's non dense.
		if(X.charge_speed < X.charge_speed_max)
			X.stop_momentum(X.charge_dir)
			r_FAL
		else
			ex_act(2) //Should dismantle, or at least heavily damage it.
			X.stop_momentum(X.charge_dir)
			r_TRU

//Custom bump for crushers. This overwrites normal bumpcode from carbon.dm
/mob/living/carbon/Xenomorph/Crusher/Bump(atom/A, yes)
	set waitfor = 0

	if(charge_speed < charge_speed_buildup * charge_turfs_to_charge || !is_charging) return ..()

	if(stat || !A || !istype(A) || A == src || !yes) r_FAL

	if(now_pushing) r_FAL //Just a plain ol turf, let's return.

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
	r_TRU

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
			if(charge_speed > charge_speed_buildup * charge_turfs_to_charge) //Let it build up a bit so we're not changing icons every single turf
				icon_state = "Crusher Charging"
			else
				icon_state = "Crusher Running"

		else
			icon_state = "Crusher Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
