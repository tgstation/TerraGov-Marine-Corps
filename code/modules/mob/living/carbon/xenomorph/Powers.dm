

/mob/living/carbon/Xenomorph/proc/Pounce(atom/T)

	if(!T) return

	if(T.layer >= FLY_LAYER)//anything above that shouldn't be pounceable (hud stuff)
		return

	if(!isturf(loc))
		src << "<span class='xenowarning'>You can't pounce from here!</span>"
		return

	if(!check_state())
		return

	if(usedPounce)
		src << "<span class='xenowarning'>You must wait before pouncing.</span>"
		return

	if(!check_plasma(10))
		return

	if(legcuffed)
		src << "<span class='xenodanger'>You can't pounce with that thing on your leg!</span>"
		return

	if(layer == XENO_HIDING_LAYER) //Xeno is currently hiding, unhide him
		layer = MOB_LAYER

	if(m_intent == "walk" && isXenoHunter(src)) //Hunter that is currently using its stealth ability, need to unstealth him
		m_intent = "run"
		if(hud_used && hud_used.move_intent)
			hud_used.move_intent.icon_state = "running"
		update_icons()

	visible_message("<span class='xenowarning'>\The [src] pounces at [T]!</span>", \
	"<span class='xenowarning'>You pounce at [T]!</span>")
	usedPounce = 1
	flags_pass = PASSTABLE
	use_plasma(10)
	throw_at(T, 6, 2, src) //Victim, distance, speed
	spawn(6)
		if(!hardcore)
			flags_pass = initial(flags_pass) //Reset the passtable.
		else
			flags_pass = 0 //Reset the passtable.

	spawn(pounce_delay)
		usedPounce = 0
		src << "<span class='notice'>You get ready to pounce again.</span>"
		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

	return 1


// Praetorian acid spray
/mob/living/carbon/Xenomorph/proc/acid_spray_cone(atom/A)

	if (!A || !check_state())
		return

	if (used_acid_spray)
		src << "<span class='xenowarning'>You must wait to produce enough acid to spray.</span>"
		return

	if (!check_plasma(200))
		src << "<span class='xenowarning'>You must produce more plasma before doing this.</span>"
		return

	var/turf/target

	if (isturf(A))
		target = A
	else
		target = get_turf(A)

	if (target == loc)
		return

	if(!target)
		return

	if(action_busy)
		return

	if(!do_after(src, 12, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if (used_acid_spray)
		return

	if (!check_plasma(200))
		return

	round_statistics.praetorian_acid_sprays++

	used_acid_spray = 1
	use_plasma(200)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1)
	visible_message("<span class='xenowarning'>\The [src] spews forth a wide cone of acid!</span>", \
	"<span class='xenowarning'>You spew forth a cone of acid!</span>", null, 5)

	speed += 2
	do_acid_spray_cone(target)
	spawn(rand(20,30))
		speed -= 2

	spawn(acid_spray_cooldown)
		used_acid_spray = 0
		src << "<span class='notice'>You have produced enough acid to spray again.</span>"

/mob/living/carbon/Xenomorph/proc/do_acid_spray_cone(var/turf/T)
	set waitfor = 0

	var/facing = get_cardinal_dir(src, T)
	dir = facing

	T = loc
	for (var/i = 0, i < acid_spray_range, i++)

		var/turf/next_T = get_step(T, facing)

		for (var/obj/O in T)
			if(!O.CheckExit(src, next_T))
				if(istype(O, /obj/structure/barricade))
					var/obj/structure/barricade/B = O
					B.health -= rand(20, 30)
					B.update_health(1)
				return

		T = next_T

		if (T.density)
			return

		for (var/obj/O in T)
			if(!O.CanPass(src, loc))
				if(istype(O, /obj/structure/barricade))
					var/obj/structure/barricade/B = O
					B.health -= rand(20, 30)
					B.update_health(1)
				return

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
					if(istype(O, /obj/structure/barricade))
						var/obj/structure/barricade/B = O
						B.health -= rand(20, 30)
						B.update_health(1)
					normal_density_flag = 1
					break

			normal_turf = next_normal_turf

			if(!normal_density_flag)
				normal_density_flag = normal_turf.density

			if(!normal_density_flag)
				for (var/obj/O in normal_turf)
					if(!O.CanPass(left_S, left_S.loc))
						if(istype(O, /obj/structure/barricade))
							var/obj/structure/barricade/B = O
							B.health -= rand(20, 30)
							B.update_health(1)
						normal_density_flag = 1
						break

			if (!normal_density_flag)
				left_S = acid_splat_turf(normal_turf)


		if (!inverse_normal_density_flag)

			var/next_inverse_normal_turf = get_step(inverse_normal_turf, inverse_normal_dir)

			for (var/obj/O in inverse_normal_turf)
				if(!O.CheckExit(right_S, next_inverse_normal_turf))
					if(istype(O, /obj/structure/barricade))
						var/obj/structure/barricade/B = O
						B.health -= rand(20, 30)
						B.update_health(1)
					inverse_normal_density_flag = 1
					break

			inverse_normal_turf = next_inverse_normal_turf

			if(!inverse_normal_density_flag)
				inverse_normal_density_flag = inverse_normal_turf.density

			if(!inverse_normal_density_flag)
				for (var/obj/O in inverse_normal_turf)
					if(!O.CanPass(right_S, right_S.loc))
						if(istype(O, /obj/structure/barricade))
							var/obj/structure/barricade/B = O
							B.health -= rand(20, 30)
							B.update_health(1)
						inverse_normal_density_flag = 1
						break

			if (!inverse_normal_density_flag)
				right_S = acid_splat_turf(inverse_normal_turf)



/mob/living/carbon/Xenomorph/proc/acid_splat_turf(var/turf/T)
	. = locate(/obj/effect/xenomorph/spray) in T
	if(!.)
		. = new /obj/effect/xenomorph/spray(T)

		// This should probably be moved into obj/effect/xenomorph/spray or something
		for (var/obj/structure/barricade/B in T)
			B.health -= rand(20, 30)
			B.update_health(1)

		for (var/mob/living/carbon/C in T)
			if (!ishuman(C) && !ismonkey(C))
				continue

			if ((C.status_flags & XENO_HOST) && istype(C.buckled, /obj/structure/bed/nest))
				continue

			round_statistics.praetorian_spray_direct_hits++
			C.adjustFireLoss(rand(20,30) + 5 * upgrade)
			C << "<span class='xenodanger'>\The [src] showers you in corrosive acid!</span>"

			if (!isYautja(C))
				C.emote("scream")
				C.KnockDown(rand(3, 4))


// Warrior Fling
/mob/living/carbon/Xenomorph/proc/fling(atom/A)

	if (!A || !istype(A, /mob/living/carbon/human))
		return

	if (!check_state() || agility)
		return

	if (used_fling)
		src << "<span class='xenowarning'>You must gather your strength before flinging something.</span>"
		return

	if (!check_plasma(10))
		return

	if (!Adjacent(A))
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD) return
	round_statistics.warrior_flings++

	visible_message("<span class='xenowarning'>\The [src] effortlessly flings [H] to the side!</span>", \
	"<span class='xenowarning'>You effortlessly fling [H] to the side!</span>")
	playsound(H,'sound/weapons/alien_claw_block.ogg', 75, 1)
	used_fling = 1
	use_plasma(10)
	H.apply_effects(1,2) 	// Stun
	shake_camera(H, 2, 1)

	var/facing = get_dir(src, H)
	var/fling_distance = 4
	var/turf/T = loc
	var/turf/temp = loc

	for (var/x = 0, x < fling_distance, x++)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	H.throw_at(T, fling_distance, 1, src, 1)

	spawn(fling_cooldown)
		used_fling = 0
		src << "<span class='notice'>You gather enough strength to fling something again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

/mob/living/carbon/Xenomorph/proc/punch(atom/A)

	if (!A || !ishuman(A))
		return

	if (!check_state() || agility)
		return

	if (used_punch)
		src << "<span class='xenowarning'>You must gather your strength before punching.</span>"
		return

	if (!check_plasma(10))
		return

	if (!Adjacent(A))
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD) return
	round_statistics.warrior_punches++
	var/datum/limb/L = H.get_limb(check_zone(zone_selected))

	if (!L || (L.status & LIMB_DESTROYED))
		return

	visible_message("<span class='xenowarning'>\The [src] hits [H] in the [L.display_name] with a devistatingly powerful punch!</span>", \
	"<span class='xenowarning'>You hit [H] in the [L.display_name] with a devistatingly powerful punch!</span>")
	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	playsound(H,S, 50, 1)
	used_punch = 1
	use_plasma(10)

	if(L.status & LIMB_SPLINTED) //If they have it splinted, the splint won't hold.
		L.status &= ~LIMB_SPLINTED
		H << "<span class='danger'>The splint on your [L.display_name] comes apart!</span>"

	if(isYautja(H))
		L.take_damage(rand(8,12))
	else if(L.status & LIMB_ROBOT)
		L.take_damage(rand(30,40), 0, 0) // just do more damage
	else
		var/fracture_chance = 100
		switch(L.body_part)
			if(HEAD)
				fracture_chance = 20
			if(UPPER_TORSO)
				fracture_chance = 30
			if(LOWER_TORSO)
				fracture_chance = 40

		L.take_damage(rand(15,25), 0, 0)
		if(prob(fracture_chance))
			L.fracture()
	shake_camera(H, 2, 1)
	step_away(H, src, 2)

	spawn(punch_cooldown)
		used_punch = 0
		src << "<span class='notice'>You gather enough strength to punch again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

/mob/living/carbon/Xenomorph/proc/lunge(atom/A)

	if (!A || !istype(A, /mob/living/carbon/human))
		return

	if (!isturf(loc))
		src << "<span class='xenowarning'>You can't lunge from here!</span>"
		return

	if (!check_state() || agility)
		return

	if (used_lunge)
		src << "<span class='xenowarning'>You must gather your strength before lunging.</span>"
		return

	if (!check_plasma(10))
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD) return
	round_statistics.warrior_lunges++
	visible_message("<span class='xenowarning'>\The [src] lunges towards [H]!</span>", \
	"<span class='xenowarning'>You lunge at [H]!</span>")

	used_lunge = 1 // triggered by start_pulling
	use_plasma(10)
	throw_at(get_step_towards(A, src), 6, 2, src)

	if (Adjacent(H))
		start_pulling(H,1)

	spawn(lunge_cooldown)
		used_lunge = 0
		src << "<span class='notice'>You get ready to lunge again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

	return 1

// Called when pulling something and attacking yourself with the pull
/mob/living/carbon/Xenomorph/proc/pull_power(var/mob/M)
	if (isXenoWarrior(src) && !ripping_limb && M.stat != DEAD)
		ripping_limb = 1
		if(rip_limb(M))
			stop_pulling()
		ripping_limb = 0


// Warrior Rip Limb - called by pull_power()
/mob/living/carbon/Xenomorph/proc/rip_limb(var/mob/M)
	if (!istype(M, /mob/living/carbon/human))
		return 0

	if(action_busy) //can't stack the attempts
		return 0

	var/mob/living/carbon/human/H = M
	var/datum/limb/L = H.get_limb(check_zone(zone_selected))

	if (!L || L.body_part == UPPER_TORSO || L.body_part == LOWER_TORSO || (L.status & LIMB_DESTROYED)) //Only limbs and head.
		src << "<span class='xenowarning'>You can't rip off that limb.</span>"
		return 0
	round_statistics.warrior_limb_rips++
	var/limb_time = rand(40,60)

	if (L.body_part == HEAD)
		limb_time = rand(90,110)

	visible_message("<span class='xenowarning'>\The [src] begins pulling on [M]'s [L.display_name] with incredible strength!</span>", \
	"<span class='xenowarning'>You begin to pull on [M]'s [L.display_name] with incredible strength!</span>")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE, 1) || M.stat == DEAD)
		src << "<span class='notice'>You stop ripping off the limb.</span>"
		return 0

	if(L.status & LIMB_DESTROYED)
		return 0

	if(L.status & LIMB_ROBOT)
		L.take_damage(rand(30,40), 0, 0) // just do more damage
		visible_message("<span class='xenowarning'>You hear [M]'s [L.display_name] being pulled beyond its load limits!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] begins to tear apart!</span>")
	else
		visible_message("<span class='xenowarning'>You hear the bones in [M]'s [L.display_name] snap with a sickening crunch!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] bones snap with a satisfying crunch!</span>")
		L.take_damage(rand(15,25), 0, 0)
		L.fracture()
	src.attack_log += text("\[[time_stamp()]\] <font color='red'>ripped the [L.display_name] off of [M.name] ([M.ckey]) 1/2 progress</font>")
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>had their [L.display_name] ripped off by [src.name] ([src.ckey]) 1/2 progress</font>")
	log_attack("[src.name] ([src.ckey]) ripped the [L.display_name] off of [M.name] ([M.ckey]) 1/2 progress")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE)  || M.stat == DEAD)
		src << "<span class='notice'>You stop ripping off the limb.</span>"
		return 0

	if(L.status & LIMB_DESTROYED)
		return 0

	visible_message("<span class='xenowarning'>\The [src] rips [M]'s [L.display_name] away from \his body!</span>", \
	"<span class='xenowarning'>\The [M]'s [L.display_name] rips away from \his body!</span>")
	src.attack_log += text("\[[time_stamp()]\] <font color='red'>ripped the [L.display_name] off of [M.name] ([M.ckey]) 2/2 progress</font>")
	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>had their [L.display_name] ripped off by [src.name] ([src.ckey]) 2/2 progress</font>")
	log_attack("[src.name] ([src.ckey]) ripped the [L.display_name] off of [M.name] ([M.ckey]) 2/2 progress")

	L.droplimb()

	return 1


// Warrior Agility
/mob/living/carbon/Xenomorph/proc/toggle_agility()
	if (!check_state())
		return

	if (used_toggle_agility)
		return

	agility = !agility

	round_statistics.warrior_agility_toggles++
	if (agility)
		src << "<span class='xenowarning'>You lower yourself to all fours.</span>"
		speed -= 0.7
		update_icons()
		do_agility_cooldown()
		return

	src << "<span class='xenowarning'>You raise yourself to stand on two feet.</span>"
	speed += 0.7
	update_icons()
	do_agility_cooldown()

/mob/living/carbon/Xenomorph/proc/do_agility_cooldown()
	spawn(toggle_agility_cooldown)
		used_toggle_agility = 0
		src << "<span class='notice'>You can [agility ? "raise yourself back up" : "lower yourself back down"] again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Headbutt
/mob/living/carbon/Xenomorph/proc/headbutt(var/mob/M)
	if (!M || !istype(M, /mob/living/carbon/human))
		return

	if (fortify)
		src << "<span class='xenowarning'>You cannot use abilities while fortified.</span>"
		return

	if (crest_defense)
		src << "<span class='xenowarning'>You cannot use abilities with your crest lowered.</span>"
		return

	if (!check_state())
		return

	if (used_headbutt)
		src << "<span class='xenowarning'>You must gather your strength before headbutting.</span>"
		return

	if (!check_plasma(10))
		return

	var/mob/living/carbon/human/H = M

	var/distance = get_dist(src, H)

	if (distance > 2)
		return

	if (distance > 1)
		step_towards(src, H, 1)

	if (!Adjacent(H))
		return

	round_statistics.defender_headbutts++

	visible_message("<span class='xenowarning'>\The [src] rams [H] with it's armored crest!</span>", \
	"<span class='xenowarning'>You ram [H] with your armored crest!</span>")

	used_headbutt = 1
	use_plasma(10)

	if(H.stat != DEAD && (!(H.status_flags & XENO_HOST) || !istype(H.buckled, /obj/structure/bed/nest)) )
		H.apply_damage(20)
		shake_camera(H, 2, 1)

	var/facing = get_dir(src, H)
	var/headbutt_distance = 3
	var/turf/T = loc
	var/turf/temp = loc

	for (var/x = 0, x < headbutt_distance, x++)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	H.throw_at(T, headbutt_distance, 1, src)
	playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	spawn(headbutt_cooldown)
		used_headbutt = 0
		src << "<span class='notice'>You gather enough strength to headbutt again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Tail Sweep
/mob/living/carbon/Xenomorph/proc/tail_sweep()
	if (fortify)
		src << "<span class='xenowarning'>You cannot use abilities while fortified.</span>"
		return

	if (crest_defense)
		src << "<span class='xenowarning'>You cannot use abilities with your crest lowered.</span>"
		return

	if (!check_state())
		return

	if (used_tail_sweep)
		src << "<span class='xenowarning'>You must gather your strength before tail sweeping.</span>"
		return

	if (!check_plasma(10))
		return

	round_statistics.defender_tail_sweeps++
	visible_message("<span class='xenowarning'>\The [src] sweeps it's tail in a wide circle!</span>", \
	"<span class='xenowarning'>You sweep your tail in a wide circle!</span>")

	spin_circle()

	var/sweep_range = 1
	var/list/L = orange(sweep_range)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		H.apply_damage(10)
		round_statistics.defender_tail_sweep_hits++
		shake_camera(H, 2, 1)

		if (prob(50))
			H.KnockDown(2, 1)

		H << "<span class='xenowarning'>You are struck by \the [src]'s tail sweep!</span>"
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	used_tail_sweep = 1
	use_plasma(10)

	spawn(tail_sweep_cooldown)
		used_tail_sweep = 0
		src << "<span class='notice'>You gather enough strength to tail sweep again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Crest Defense
/mob/living/carbon/Xenomorph/proc/toggle_crest_defense()

	if (fortify)
		src << "<span class='xenowarning'>You cannot use abilities while fortified.</span>"
		return

	if (!check_state())
		return

	if (used_crest_defense)
		return

	crest_defense = !crest_defense
	used_crest_defense = 1

	if (crest_defense)
		round_statistics.defender_crest_lowerings++
		src << "<span class='xenowarning'>You lower your crest.</span>"
		armor_deflection += 15
		speed += 0.8	// This is actually a slowdown but speed is dumb
		update_icons()
		do_crest_defense_cooldown()
		return

	round_statistics.defender_crest_raises++
	src << "<span class='xenowarning'>You raise your crest.</span>"
	armor_deflection -= 15
	speed -= 0.8
	update_icons()
	do_crest_defense_cooldown()

/mob/living/carbon/Xenomorph/proc/do_crest_defense_cooldown()
	spawn(crest_defense_cooldown)
		used_crest_defense = 0
		src << "<span class='notice'>You can [crest_defense ? "raise" : "lower"] your crest.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Defender Fortify
/mob/living/carbon/Xenomorph/proc/fortify()
	if (crest_defense)
		src << "<span class='xenowarning'>You cannot use abilities with your crest lowered.</span>"
		return

	if (!check_state())
		return

	if (used_fortify)
		return

	round_statistics.defender_fortifiy_toggles++

	fortify = !fortify
	used_fortify = 1

	if (fortify)
		src << "<span class='xenowarning'>You tuck yourself into a defensive stance.</span>"
		armor_deflection += 30
		xeno_explosion_resistance++
		frozen = 1
		anchored = 1
		update_canmove()
		update_icons()
		do_fortify_cooldown()
		fortify_timer = world.timeofday + 90		// How long we can be fortified
		process_fortify()
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
		return

	fortify_off()
	do_fortify_cooldown()

/mob/living/carbon/Xenomorph/proc/process_fortify()
	set background = 1

	spawn while (fortify)
		if (world.timeofday > fortify_timer)
			fortify = 0
			fortify_off()
		sleep(10)	// Process every second.

/mob/living/carbon/Xenomorph/proc/fortify_off()
	src << "<span class='xenowarning'>You resume your normal stance.</span>"
	armor_deflection -= 30
	xeno_explosion_resistance--
	frozen = 0
	anchored = 0
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_fortify_cooldown()
	spawn(fortify_cooldown)
		used_fortify = 0
		src << "<span class='notice'>You can [fortify ? "stand up" : "fortify"] again.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


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
		src << "<span class='xenowarning'>You burrow yourself into the ground.</span>"
		frozen = 1
		invisibility = 101
		anchored = 1
		density = 0
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

	src << "<span class='notice'>You resurface.</span>"
	frozen = 0
	invisibility = 0
	anchored = 0
	density = 1
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_burrow_cooldown()
	spawn(burrow_cooldown)
		used_burrow = 0
		src << "<span class='notice'>You can now surface or tunnel.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


/mob/living/carbon/Xenomorph/proc/tunnel(var/turf/T)
	if (!burrow)
		src << "<span class='notice'>You must be burrowed to do this.</span>"
		return

	if (used_burrow || used_tunnel)
		src << "<span class='notice'>You must wait some time to do this.</span>"
		return

	if (tunnel)
		tunnel = 0
		src << "<span class='notice'>You stop tunneling.</span>"
		used_tunnel = 1
		do_tunnel_cooldown()
		return

	if (!T || T.density)
		src << "<span class='notice'>You cannot tunnel to there!</span>"

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
	src << "<span class='notice'>You tunnel to your destination.</span>"
	M.forceMove(T)
	burrow = 0
	burrow_off()

/mob/living/carbon/Xenomorph/proc/do_tunnel_cooldown()
	spawn(tunnel_cooldown)
		used_tunnel = 0
		src << "<span class='notice'>You can now tunnel while burrowed.</span>"
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()
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
	if(!istype(A, /mob/living/carbon/Xenomorph))
		return
	var/mob/living/carbon/Xenomorph/target = A

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't transfer plasma from here!</span>"
		return

	if(get_dist(src, target) > max_range)
		src << "<span class='warning'>You need to be closer to [target].</span>"
		return

	src << "<span class='notice'>You start focusing your plasma towards [target].</span>"
	if(!do_after(src, transfer_delay, TRUE, 5, BUSY_ICON_FRIENDLY))
		return

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't transfer plasma from here!</span>"
		return

	if(get_dist(src, target) > max_range)
		src << "<span class='warning'>You need to be closer to [target].</span>"
		return

	if(plasma_stored < amount)
		amount = plasma_stored //Just use all of it
	use_plasma(amount)
	target.gain_plasma(amount)
	target << "<span class='xenowarning'>\The [src] has transfered [amount] plasma to you. You now have [target.plasma_stored].</span>"
	src << "<span class='xenowarning'>You have transferred [amount] plasma to \the [target]. You now have [plasma_stored].</span>"
	playsound(src, "alien_drool", 25)

//Note: All the neurotoxin projectile items are stored in XenoProcs.dm
/mob/living/carbon/Xenomorph/proc/xeno_spit(atom/T)

	if(!check_state())
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't spit from here!</span>"
		return

	if(has_spat > world.time)
		src << "<span class='warning'>You must wait for your spit glands to refill.</span>"
		return

	if(!check_plasma(ammo.spit_cost))
		return

	var/turf/current_turf = get_turf(src)

	if(!current_turf)
		return

	visible_message("<span class='xenowarning'>\The [src] spits at \the [T]!</span>", \
	"<span class='xenowarning'>You spit at \the [T]!</span>" )
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien_spitacid.ogg' : 'sound/voice/alien_spitacid2.ogg'
	playsound(src.loc, sound_to_play, 25, 1)

	var/obj/item/projectile/A = rnew(/obj/item/projectile, current_turf)
	A.generate_bullet(ammo)
	A.permutated += src
	A.def_zone = get_limbzone_target()
	A.fire_at(T, src, null, ammo.max_range, ammo.shell_speed)
	has_spat = world.time + spit_delay + ammo.added_spit_delay
	use_plasma(ammo.spit_cost)
	cooldown_notification(spit_delay + ammo.added_spit_delay, "spit")

	return TRUE

/mob/living/carbon/Xenomorph/proc/cooldown_notification(cooldown, message)
	set waitfor = 0
	sleep(cooldown)
	switch(message)
		if("spit")
			src << "<span class='notice'>You feel your neurotoxin glands swell with ichor. You can spit again.</span>"
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()



/mob/living/carbon/Xenomorph/proc/build_resin(atom/A, resin_plasma_cost)
	if(action_busy) return
	if(!check_state())
		return
	if(!check_plasma(resin_plasma_cost))
		return
	var/turf/current_turf = loc
	if (caste == "Hivelord") //hivelords can thicken existing resin structures.
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
					src << "<span class='xenowarning'>[WR] can't be made thicker.</span>"
				return

			else if(istype(A, /obj/structure/mineral_door/resin))
				var/obj/structure/mineral_door/resin/DR = A
				if(DR.hardness == 1.5) //non thickened
					var/oldloc = DR.loc
					visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and thickens [DR].</span>", \
						"<span class='xenonotice'>You regurgitate some resin and thicken [DR].</span>", null, 5)
					cdel(DR)
					new /obj/structure/mineral_door/resin/thick (oldloc)
					playsound(loc, "alien_resin_build", 25)
					use_plasma(resin_plasma_cost)
				else
					src << "<span class='xenowarning'>[DR] can't be made thicker.</span>"
				return

			else
				current_turf = get_turf(A) //Hivelords can secrete resin on adjacent turfs.



	var/mob/living/carbon/Xenomorph/blocker = locate() in current_turf
	if(blocker && blocker != src && blocker.stat != DEAD)
		src << "<span class='warning'>Can't do that with [blocker] in the way!</span>"
		return

	if(!istype(current_turf) || !current_turf.is_weedable())
		src << "<span class='warning'>You can't do that here.</span>"
		return

	var/area/AR = get_area(current_turf)
	if(istype(AR,/area/shuttle/drop1/lz1) || istype(AR,/area/shuttle/drop2/lz2) || istype(AR,/area/sulaco/hangar)) //Bandaid for atmospherics bug when Xenos build around the shuttles
		src << "<span class='warning'>You sense this is not a suitable area for expanding the hive.</span>"
		return

	var/obj/effect/alien/weeds/alien_weeds = locate() in current_turf

	if(!alien_weeds)
		src << "<span class='warning'>You can only shape on weeds. Find some resin before you start building!</span>"
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
			src << "<span class='warning'>Resin doors need a wall or resin door next to them to stand up.</span>"
			return

	var/wait_time = 5
	if(caste == "Drone")
		wait_time = 10

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
			src << "<span class='warning'>Resin doors need a wall or resin door next to them to stand up.</span>"
			return

	use_plasma(resin_plasma_cost)
	visible_message("<span class='xenonotice'>\The [src] regurgitates a thick substance and shapes it into \a [selected_resin]!</span>", \
	"<span class='xenonotice'>You regurgitate some resin and shape it into \a [selected_resin].</span>", null, 5)
	playsound(loc, "alien_resin_build", 25)

	var/atom/new_resin

	switch(selected_resin)
		if("resin door")
			if (caste == "Hivelord")
				new_resin = new /obj/structure/mineral_door/resin/thick(current_turf)
			else
				new_resin = new /obj/structure/mineral_door/resin(current_turf)
		if("resin wall")
			if (caste == "Hivelord")
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
		src << "<span class='warning'>\The [O] is too far away.</span>"
		return

	if(!isturf(loc))
		src << "<span class='warning'>You can't melt [O] from here!</span>"
		return

	face_atom(O)

	var/wait_time = 10

	//OBJ CHECK
	if(isobj(O))
		var/obj/I = O

		if(I.unacidable || istype(I, /obj/machinery/computer) || istype(I, /obj/effect)) //So the aliens don't destroy energy fields/singularies/other aliens/etc with their acid.
			src << "<span class='warning'>You cannot dissolve \the [I].</span>" // ^^ Note for obj/effect.. this might check for unwanted stuff. Oh well
			return
		if(istype(O, /obj/structure/window_frame))
			var/obj/structure/window_frame/WF = O
			if(WF.reinforced && acid_type != /obj/effect/xenomorph/acid/strong)
				src << "<span class='warning'>This [O.name] is too tough to be melted by your weak acid.</span>"
			return

		if(O.density || istype(O, /obj/structure))
			wait_time = 40 //dense objects are big, so takes longer to melt.

	//TURF CHECK
	else if(isturf(O))
		var/turf/T = O

		if(istype(O, /turf/closed/wall))
			var/turf/closed/wall/wall_target = O
			if (wall_target.acided_hole)
				src << "<span class='warning'>[O] is already weakened.</span>"
				return

		var/dissolvability = T.can_be_dissolved()
		switch(dissolvability)
			if(0)
				src << "<span class='warning'>You cannot dissolve \the [T].</span>"
				return
			if(1)
				wait_time = 50
			if(2)
				if(acid_type != /obj/effect/xenomorph/acid/strong)
					src << "<span class='warning'>This [T.name] is too tough to be melted by your weak acid.</span>"
					return
				wait_time = 100
			else
				return
		src << "<span class='xenowarning'>You begin generating enough acid to melt through \the [T].</span>"
	else
		src << "<span class='warning'>You cannot dissolve \the [O].</span>"
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

	use_plasma(plasma_cost)

	var/obj/effect/xenomorph/acid/A = new acid_type(get_turf(O), O)

	if(istype(O, /obj/vehicle/multitile/root/cm_armored))
		var/obj/vehicle/multitile/root/cm_armored/R = O
		R.take_damage_type( (1 / A.acid_strength) * 20, "acid", src)
		visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff at \the [O]. It sizzles under the bubbling mess of acid!</span>", \
			"<span class='xenowarning'>You vomit globs of vile stuff at \the [O]. It sizzles under the bubbling mess of acid!</span>", null, 5)
		playsound(loc, "sound/bullets/acid_impact1.ogg", 25)
		sleep(20)
		cdel(A)
		return

	if(isturf(O))
		A.icon_state += "_wall"

	if(istype(O, /obj/structure) || istype(O, /obj/machinery)) //Always appears above machinery
		A.layer = O.layer + 0.1
	else //If not, appear on the floor or on an item
		A.layer = LOWER_ITEM_LAYER //below any item, above BELOW_OBJ_LAYER (smartfridge)

	A.add_hiddenprint(src)

	if(!isturf(O))
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
		attack_log += text("\[[time_stamp()]\] <font color='green'>Spat acid on [O]</font>")
	visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>You vomit globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", null, 5)
	playsound(loc, "sound/bullets/acid_impact1.ogg", 25)





/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else return
	if(!hive.living_xeno_queen)
		src << "<span class='warning'>There is no Queen. You are alone.</span>"
		return

	if(caste == "Queen" && anchored)
		check_hive_status(src, anchored)
	else
		check_hive_status(src)


/proc/check_hive_status(mob/living/carbon/Xenomorph/user, var/anchored = 0)
	var/dat = "<html><head><title>Hive Status</title></head><body>"

	var/count = 0
	var/queen_list = ""
	//var/exotic_list = ""
	//var/exotic_count = 0
	var/boiler_list = ""
	var/boiler_count = 0
	var/crusher_list = ""
	var/crusher_count = 0
	var/praetorian_list = ""
	var/praetorian_count = 0
	var/ravager_list = ""
	var/ravager_count = 0
	var/carrier_list = ""
	var/carrier_count = 0
	var/hivelord_list = ""
	var/hivelord_count = 0
	var/warrior_list = ""
	var/warrior_count = 0
	var/hunter_list = ""
	var/hunter_count = 0
	var/spitter_list = ""
	var/spitter_count = 0
	var/drone_list = ""
	var/drone_count = 0
	var/runner_list = ""
	var/runner_count = 0
	var/sentinel_list = ""
	var/sentinel_count = 0
	var/defender_list = ""
	var/defender_count = 0
	var/larva_list = ""
	var/larva_count = 0
	var/stored_larva_count = ticker.mode.stored_larva
	var/leader_list = ""

	for(var/mob/living/carbon/Xenomorph/X in living_mob_list)
		if(X.z == ADMIN_Z_LEVEL) continue //don't show xenos in the thunderdome when admins test stuff.
		if(istype(user)) // cover calling it without parameters
			if(X.hivenumber != user.hivenumber)
				continue // not our hive
		var/area/A = get_area(X)

		var/datum/hive_status/hive
		if(X.hivenumber && X.hivenumber <= hive_datum.len)
			hive = hive_datum[X.hivenumber]
		else
			X.hivenumber = XENO_HIVE_NORMAL
			hive = hive_datum[X.hivenumber]

		var/leader = ""

		if(X in hive.xeno_leader_list)
			leader = "<b>(-L-)</b>"

		var/xenoinfo
		if(user && anchored && X != user)
			xenoinfo = "<tr><td>[leader]<a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
		else
			xenoinfo = "<tr><td>[leader][X.name] "
		if(!X.client) xenoinfo += " <i>(SSD)</i>"

		count++ //Dead players shouldn't be on this list
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

		if(leader != "")
			leader_list += xenoinfo

		switch(X.caste)
			if("Queen")
				queen_list += xenoinfo
			if("Boiler")
				if(leader == "") boiler_list += xenoinfo
				boiler_count++
			if("Crusher")
				if(leader == "") crusher_list += xenoinfo
				crusher_count++
			if("Praetorian")
				if(leader == "") praetorian_list += xenoinfo
				praetorian_count++
			if("Ravager")
				if(leader == "") ravager_list += xenoinfo
				ravager_count++
			if("Carrier")
				if(leader == "") carrier_list += xenoinfo
				carrier_count++
			if("Hivelord")
				if(leader == "") hivelord_list += xenoinfo
				hivelord_count++
			if ("Warrior")
				if (leader == "")
					warrior_list += xenoinfo
				warrior_count++
			if("Lurker")
				if(leader == "") hunter_list += xenoinfo
				hunter_count++
			if("Spitter")
				if(leader == "") spitter_list += xenoinfo
				spitter_count++
			if("Drone")
				if(leader == "") drone_list += xenoinfo
				drone_count++
			if("Runner")
				if(leader == "") runner_list += xenoinfo
				runner_count++
			if("Sentinel")
				if(leader == "") sentinel_list += xenoinfo
				sentinel_count++
			if ("Defender")
				if (leader == "")
					defender_list += xenoinfo
				defender_count++
			if("Bloody Larva") // all larva are caste = blood larva
				if(leader == "") larva_list += xenoinfo
				larva_count++

	dat += "<b>Total Living Sisters: [count]</b><BR>"
	//if(exotic_count != 0) //Exotic Xenos in the Hive like Predalien or Xenoborg
		//dat += "<b>Ultimate Tier:</b> [exotic_count] Sisters</b><BR>"
	dat += "<b>Tier 3: [boiler_count + crusher_count + praetorian_count + ravager_count] Sisters</b> | Boilers: [boiler_count] | Crushers: [crusher_count] | Praetorians: [praetorian_count] | Ravagers: [ravager_count]<BR>"
	dat += "<b>Tier 2: [carrier_count + hivelord_count + hunter_count + spitter_count + warrior_count] Sisters</b> | Carriers: [carrier_count] | Hivelords: [hivelord_count] | Warriors: [warrior_count] | Lurkers: [hunter_count] | Spitters: [spitter_count]<BR>"
	dat += "<b>Tier 1: [drone_count + runner_count + sentinel_count + defender_count] Sisters</b> | Drones: [drone_count] | Runners: [runner_count] | Sentinels: [sentinel_count] | Defenders: [defender_count]<BR>"
	dat += "<b>Larvas: [larva_count] Sisters<BR>"
	if(istype(user)) // cover calling it without parameters
		if(user.hivenumber == XENO_HIVE_NORMAL)
			dat += "<b>Burrowed Larva: [stored_larva_count] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += queen_list + leader_list + boiler_list + crusher_list + praetorian_list + ravager_list + carrier_list + hivelord_list + warrior_list + hunter_list + spitter_list + drone_list + runner_list + sentinel_list + defender_list + larva_list
	dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=500x500")


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
		src << "<span class='notice'>The selected xeno ability will now be activated with shift clicking.</span>"
	else
		src << "<span class='notice'>The selected xeno ability will now be activated with middle mouse clicking.</span>"
