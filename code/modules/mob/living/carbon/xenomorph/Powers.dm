

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

	if(m_intent == "walk" && isXenoHunter(src)) //Hunter that is currently using its stealth ability, need to unstealth him
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
	spawn(6)
		if(!hardcore)
			flags_pass = initial(flags_pass) //Reset the passtable.
		else
			flags_pass = 0 //Reset the passtable.

	spawn(pounce_delay)
		usedPounce = 0
		to_chat(src, "<span class='notice'>You get ready to pounce again.</span>")
		update_action_button_icons()

	return TRUE



/mob/living/carbon/Xenomorph/Hunter/Pounce(atom/T)

	if(!T || !check_state() || !check_plasma(20) || T.layer >= FLY_LAYER) //anything above that shouldn't be pounceable (hud stuff)
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

	if(m_intent == "walk") //Hunter that is currently using its stealth ability, need to unstealth him
		m_intent = "run"
		if(hud_used && hud_used.move_intent)
			hud_used.move_intent.icon_state = "running"
		update_icons()

	visible_message("<span class='xenowarning'>\The [src] pounces at [T]!</span>", \
	"<span class='xenowarning'>You pounce at [T]!</span>")
	usedPounce = TRUE
	flags_pass = PASSTABLE
	use_plasma(20)
	throw_at(T, 7, 2, src) //Victim, distance, speed
	spawn(6)
		if(!hardcore)
			flags_pass = initial(flags_pass) //Reset the passtable.
		else
			flags_pass = 0 //Reset the passtable.

	spawn(pounce_delay)
		usedPounce = 0
		to_chat(src, "<span class='xenowarning'><b>You are ready to pounce again.</b></span>")
		playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
		update_action_button_icons()

	if(stealth && can_sneak_attack) //If we're stealthed and could sneak attack, add a cooldown to sneak attack
		to_chat(src, "<span class='xenodanger'>Your pounce has left you off-balance; you'll need to wait [HUNTER_POUNCE_SNEAKATTACK_DELAY*0.1] seconds before you can Sneak Attack again.</span>")
		can_sneak_attack = FALSE
		sneak_attack_cooldown()

	return TRUE


// Praetorian acid spray
/mob/living/carbon/Xenomorph/proc/acid_spray_cone(atom/A)

	if (!A || !check_state())
		return

	if (used_acid_spray)
		to_chat(src, "<span class='xenowarning'>You must wait to produce enough acid to spray.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
		return

	if (!check_plasma(200))
		to_chat(src, "<span class='xenowarning'>You must produce more plasma before doing this.</span>")
		return

	var/turf/target

	if (isturf(A))
		target = A
	else
		target = get_turf(A)

	if (target == loc || !target || action_busy)
		return

	if(!do_after(src, 12, TRUE, 5, BUSY_ICON_HOSTILE))
		return

	if (used_acid_spray || !check_plasma(200))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>The shock disrupts you!</span>")
		return

	round_statistics.praetorian_acid_sprays++

	used_acid_spray = TRUE
	use_plasma(200)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1)
	visible_message("<span class='xenowarning'>\The [src] spews forth a wide cone of acid!</span>", \
	"<span class='xenowarning'>You spew forth a cone of acid!</span>", null, 5)

	speed += 2
	do_acid_spray_cone(target)
	spawn(rand(20,30))
		speed -= 2

	spawn(acid_spray_cooldown)
		used_acid_spray = FALSE
		to_chat(src, "<span class='notice'>You have produced enough acid to spray again.</span>")

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
			to_chat(C, "<span class='xenodanger'>\The [src] showers you in corrosive acid!</span>")

			if (!isYautja(C))
				C.emote("scream")
				C.KnockDown(rand(3, 4))


// Warrior Fling
/mob/living/carbon/Xenomorph/proc/fling(atom/A)

	if (!A || !istype(A, /mob/living/carbon/human) || !check_state() || agility || !check_plasma(10) || !Adjacent(A))
		return

	if (used_fling)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before flinging something.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return
	round_statistics.warrior_flings++

	visible_message("<span class='xenowarning'>\The [src] effortlessly flings [H] to the side!</span>", \
	"<span class='xenowarning'>You effortlessly fling [H] to the side!</span>")
	playsound(H,'sound/weapons/alien_claw_block.ogg', 75, 1)
	used_fling = TRUE
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
		used_fling = FALSE
		to_chat(src, "<span class='notice'>You gather enough strength to fling something again.</span>")
		update_action_button_icons()

/mob/living/carbon/Xenomorph/proc/punch(var/mob/living/M)

	if (!M)
		return

	if (!check_state() || agility)
		return

	if (used_punch)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before punching.</span>")
		return

	if (!check_plasma(20))
		return

	if (!Adjacent(M))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if(M.stat == DEAD || ((M.status_flags & XENO_HOST) && istype(M.buckled, /obj/structure/bed/nest))) //Can't bully the dead/nested hosts.
		return
	round_statistics.warrior_punches++


	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	var/target_zone = check_zone(zone_selected)
	if(!target_zone)
		target_zone = "chest"
	var/armor_block = M.run_armor_check(target_zone)
	var/damage = rand(melee_damage_lower, melee_damage_upper)
	used_punch = TRUE
	use_plasma(20)
	playsound(M, S, 50, 1)

	if(!ishuman(M))
		M.apply_damage(damage, BRUTE, target_zone, armor_block) //If we're not a humie, just apply brute.
	else
		var/mob/living/carbon/human/H = M

		var/datum/limb/L = H.get_limb(check_zone(zone_selected))

		if (!L || (L.status & LIMB_DESTROYED))
			return

		visible_message("<span class='xenowarning'>\The [src] hits [H] in the [L.display_name] with a devastatingly powerful punch!</span>", \
		"<span class='xenowarning'>You hit [H] in the [L.display_name] with a devastatingly powerful punch!</span>")


		if(L.status & LIMB_SPLINTED) //If they have it splinted, the splint won't hold.
			L.status &= ~LIMB_SPLINTED
			to_chat(H, "<span class='danger'>The splint on your [L.display_name] comes apart!</span>")

		if(isYautja(H))
			L.take_damage(damage, 0, 0, 0, null, null, null, armor_block)
		else if(L.status & LIMB_ROBOT)
			L.take_damage(damage * 2, 0, 0, 0, null, null, null, armor_block)
		else
			var/fracture_chance = 100
			switch(L.body_part)
				if(HEAD)
					fracture_chance = 50
				if(UPPER_TORSO)
					fracture_chance = 50
				if(LOWER_TORSO)
					fracture_chance = 50
			fracture_chance *= max(0,round(1 - armor_block,0.01)) //Reduce the fracture chance by a % equal to the armor.

			L.take_damage(damage, 0, 0, 0, null, null, null, armor_block)
			if(prob(fracture_chance))
				L.fracture()
		H.apply_damage(damage, HALLOSS) //Armor penetrating halloss also applies.
	shake_camera(M, 2, 1)
	step_away(M, src, 2)

	spawn(punch_cooldown)
		used_punch = FALSE
		to_chat(src, "<span class='notice'>You gather enough strength to punch again.</span>")
		update_action_button_icons()

/mob/living/carbon/Xenomorph/proc/lunge(atom/A)

	if (!A || !istype(A, /mob/living/carbon/human) || !check_state() || agility || !check_plasma(10))
		return

	if (!isturf(loc))
		to_chat(src, "<span class='xenowarning'>You can't lunge from here!</span>")
		return

	if (used_lunge)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before lunging.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return
	round_statistics.warrior_lunges++
	visible_message("<span class='xenowarning'>\The [src] lunges towards [H]!</span>", \
	"<span class='xenowarning'>You lunge at [H]!</span>")

	used_lunge = TRUE // triggered by start_pulling
	use_plasma(10)
	throw_at(get_step_towards(A, src), 6, 2, src)

	if (Adjacent(H))
		start_pulling(H,1)

	spawn(lunge_cooldown)
		used_lunge = FALSE
		to_chat(src, "<span class='notice'>You get ready to lunge again.</span>")
		update_action_button_icons()

	return TRUE

// Called when pulling something and attacking yourself with the pull
/mob/living/carbon/Xenomorph/proc/pull_power(var/mob/M)
	if (isXenoWarrior(src) && !ripping_limb && M.stat != DEAD)
		ripping_limb = TRUE
		if(rip_limb(M))
			stop_pulling()
		ripping_limb = FALSE


// Warrior Rip Limb - called by pull_power()
/mob/living/carbon/Xenomorph/proc/rip_limb(var/mob/M)
	if (!istype(M, /mob/living/carbon/human))
		return FALSE

	if(action_busy) //can't stack the attempts
		return FALSE

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	var/mob/living/carbon/human/H = M
	var/datum/limb/L = H.get_limb(check_zone(zone_selected))

	if (!L || L.body_part == UPPER_TORSO || L.body_part == LOWER_TORSO || (L.status & LIMB_DESTROYED) || L.body_part == HEAD) //Only limbs; no head
		to_chat(src, "<span class='xenowarning'>You can't rip off that limb.</span>")
		return FALSE
	round_statistics.warrior_limb_rips++
	var/limb_time = rand(40,60)

	visible_message("<span class='xenowarning'>\The [src] begins pulling on [M]'s [L.display_name] with incredible strength!</span>", \
	"<span class='xenowarning'>You begin to pull on [M]'s [L.display_name] with incredible strength!</span>")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE, 1) || M.stat == DEAD)
		to_chat(src, "<span class='notice'>You stop ripping off the limb.</span>")
		return FALSE

	if(L.status & LIMB_DESTROYED)
		return FALSE

	if(L.status & LIMB_ROBOT)
		L.take_damage(rand(30,40), 0, 0) // just do more damage
		visible_message("<span class='xenowarning'>You hear [M]'s [L.display_name] being pulled beyond its load limits!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] begins to tear apart!</span>")
	else
		visible_message("<span class='xenowarning'>You hear the bones in [M]'s [L.display_name] snap with a sickening crunch!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] bones snap with a satisfying crunch!</span>")
		L.take_damage(rand(15,25), 0, 0)
		L.fracture()
	log_message(src, M, "ripped the [L.display_name] off", addition="1/2 progress")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE)  || M.stat == DEAD)
		to_chat(src, "<span class='notice'>You stop ripping off the limb.</span>")
		return FALSE

	if(L.status & LIMB_DESTROYED)
		return FALSE

	visible_message("<span class='xenowarning'>\The [src] rips [M]'s [L.display_name] away from \his body!</span>", \
	"<span class='xenowarning'>\The [M]'s [L.display_name] rips away from \his body!</span>")
	log_message(src, M, "ripped the [L.display_name] off", addition="2/2 progress")

	L.droplimb()

	return TRUE


// Warrior Agility
/mob/living/carbon/Xenomorph/proc/toggle_agility()
	if (!check_state())
		return

	if (used_toggle_agility)
		return

	agility = !agility

	round_statistics.warrior_agility_toggles++
	if (agility)
		to_chat(src, "<span class='xenowarning'>You lower yourself to all fours and loosen your armored scales to ease your movement.</span>")
		speed_modifier--
		armor_bonus -= WARRIOR_AGILITY_ARMOR

		update_icons()
		do_agility_cooldown()
		return

	to_chat(src, "<span class='xenowarning'>You raise yourself to stand on two feet, hard scales setting back into place.</span>")
	speed_modifier++
	armor_bonus += WARRIOR_AGILITY_ARMOR
	update_icons()
	do_agility_cooldown()

/mob/living/carbon/Xenomorph/proc/do_agility_cooldown()
	spawn(toggle_agility_cooldown)
		used_toggle_agility = FALSE
		to_chat(src, "<span class='notice'>You can [agility ? "raise yourself back up" : "lower yourself back down"] again.</span>")
		update_action_button_icons()


// Defender Headbutt
/mob/living/carbon/Xenomorph/proc/headbutt(var/mob/M)
	if (!M || !istype(M, /mob/living/carbon/human))
		return

	if(M.stat == DEAD || (istype(M.buckled, /obj/structure/bed/nest) && M.status_flags & XENO_HOST) ) //No bullying the dead/secured hosts
		return

	if (fortify)
		to_chat(src, "<span class='xenowarning'>You cannot use abilities while fortified.</span>")
		return

	if (!check_state())
		return

	if (used_headbutt)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before headbutting.</span>")
		return

	if (crest_defense) //We can now use crest defense, but the plasma cost is doubled.
		if (!check_plasma(20))
			return
	else if (!check_plasma(10))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	var/mob/living/carbon/human/H = M

	var/distance = get_dist(src, H)

	if (distance > 2)
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='xenowarning'>Your target is too far away!</span>")

			recent_notice = world.time //anti-notice spam
		return


	if (distance > 1)
		step_towards(src, H, 1)

	if (!Adjacent(H))
		return

	round_statistics.defender_headbutts++

	visible_message("<span class='xenowarning'>\The [src] rams [H] with it's armored crest!</span>", \
	"<span class='xenowarning'>You ram [H] with your armored crest!</span>")

	used_headbutt = 1
	if(crest_defense) //We can now use crest defense, but the plasma cost is doubled.
		use_plasma(20)
	else
		use_plasma(10)

	face_atom(H) //Face towards the target so we don't look silly

	var/damage = rand(melee_damage_lower,melee_damage_upper)
	if(frenzy_aura > 0)
		damage += (frenzy_aura * 2)
	damage *= (1 + distance * 0.25) //More distance = more momentum = stronger Headbutt.
	var/affecting = H.get_limb(ran_zone(null, 0))
	if(!affecting) //Still nothing??
		affecting = H.get_limb("chest") //Gotta have a torso?!
	var/armor_block = H.run_armor_check(affecting, "melee")
	H.apply_damage(damage, BRUTE, affecting, armor_block) //We deal crap brute damage after armor...
	H.apply_damage(damage, HALLOSS) //...But some sweet armour ignoring Halloss
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
	H.KnockDown(1, 1)
	playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	spawn(headbutt_cooldown)
		used_headbutt = 0
		to_chat(src, "<span class='notice'>You gather enough strength to headbutt again.</span>")
		update_action_button_icons()


// Defender Tail Sweep
/mob/living/carbon/Xenomorph/proc/tail_sweep()
	if (fortify)
		to_chat(src, "<span class='xenowarning'>You cannot use abilities while fortified.</span>")
		return

	if (!check_state())
		return

	if (used_tail_sweep)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before tail sweeping.</span>")
		return

	if (crest_defense) //We can now use crest defense, but the plasma cost is doubled.
		if (!check_plasma(30))
			return
	else if (!check_plasma(15))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	round_statistics.defender_tail_sweeps++
	visible_message("<span class='xenowarning'>\The [src] sweeps it's tail in a wide circle!</span>", \
	"<span class='xenowarning'>You sweep your tail in a wide circle!</span>")

	spin_circle()

	var/sweep_range = 1
	var/list/L = orange(sweep_range)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		if(H.stat != DEAD && !(istype(H.buckled, /obj/structure/bed/nest) && H.status_flags & XENO_HOST) ) //No bully
			var/damage = rand(melee_damage_lower,melee_damage_upper)
			if(frenzy_aura > 0)
				damage += (frenzy_aura * 2)
			var/affecting = H.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			var/armor_block = H.run_armor_check(affecting, "melee")
			H.apply_damage(damage, BRUTE, affecting, armor_block) //Crap base damage after armour...
			H.apply_damage(damage, HALLOSS) //...But some sweet armour ignoring Halloss
			H.KnockDown(1, 1)
		round_statistics.defender_tail_sweep_hits++
		shake_camera(H, 2, 1)



		to_chat(H, "<span class='xenowarning'>You are struck by \the [src]'s tail sweep!</span>")
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)
	used_tail_sweep = TRUE
	if(crest_defense) //We can now use crest defense, but the plasma cost is doubled.
		use_plasma(30)
	else
		use_plasma(15)

	spawn(tail_sweep_cooldown)
		used_tail_sweep = FALSE
		to_chat(src, "<span class='notice'>You gather enough strength to tail sweep again.</span>")
		update_action_button_icons()


// Defender Crest Defense
/mob/living/carbon/Xenomorph/proc/toggle_crest_defense()

	if (!check_state())
		return

	if (used_crest_defense)
		return

	crest_defense = !crest_defense
	used_crest_defense = TRUE

	if (crest_defense)
		if(fortify)
			if(!used_fortify)
				toggle_crest_defense()
				to_chat(src, "<span class='xenowarning'>You carefully untuck, keeping your crest lowered.</span>")
				fortify = FALSE
				fortify_off()
			else
				to_chat(src, "<span class='xenowarning'>You cannot yet untuck yourself!</span>")
				crest_defense = !crest_defense
				used_crest_defense = FALSE
				return
		else
			to_chat(src, "<span class='xenowarning'>You tuck yourself into a defensive stance.</span>")
		round_statistics.defender_crest_lowerings++
		armor_bonus += crest_defense_armor
		xeno_explosion_resistance = 2
		speed_modifier += DEFENDER_CRESTDEFENSE_SLOWDOWN	// This is actually a slowdown but speed is dumb
		update_icons()
		do_crest_defense_cooldown()
		return

	round_statistics.defender_crest_raises++
	to_chat(src, "<span class='xenowarning'>You raise your crest.</span>")
	armor_bonus -= crest_defense_armor
	xeno_explosion_resistance = 0
	speed_modifier -= DEFENDER_CRESTDEFENSE_SLOWDOWN
	update_icons()
	do_crest_defense_cooldown()

/mob/living/carbon/Xenomorph/proc/do_crest_defense_cooldown()
	spawn(crest_defense_cooldown)
		used_crest_defense = FALSE
		to_chat(src, "<span class='notice'>You can [crest_defense ? "raise" : "lower"] your crest.</span>")
		update_action_button_icons()


// Defender Fortify
/mob/living/carbon/Xenomorph/proc/fortify()
	if (!check_state())
		return

	if (used_fortify)
		return

	round_statistics.defender_fortifiy_toggles++

	fortify = !fortify
	used_fortify = TRUE

	if (fortify)
		if (crest_defense)
			if(!used_crest_defense)
				toggle_crest_defense()
				to_chat(src, "<span class='xenowarning'>You tuck your lowered crest into yourself.</span>")
			else
				to_chat(src, "<span class='xenowarning'>You cannot yet transition to a defensive stance!</span>")
				fortify = !fortify
				used_fortify = FALSE
				return
		else
			to_chat(src, "<span class='xenowarning'>You tuck yourself into a defensive stance.</span>")
		armor_bonus += fortify_armor
		xeno_explosion_resistance = 3
		frozen = TRUE
		anchored = TRUE
		update_canmove()
		update_icons()
		do_fortify_cooldown()
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
		return

	fortify_off()
	do_fortify_cooldown()

/mob/living/carbon/Xenomorph/proc/fortify_off()
	to_chat(src, "<span class='xenowarning'>You resume your normal stance.</span>")
	armor_bonus -= fortify_armor
	xeno_explosion_resistance = 0
	frozen = FALSE
	anchored = FALSE
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/do_fortify_cooldown()
	spawn(fortify_cooldown)
		used_fortify = FALSE
		to_chat(src, "<span class='notice'>You can [fortify ? "stand up" : "fortify"] again.</span>")
		update_action_button_icons()


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

	to_chat(src, "<span class='notice'>You resurface.</span>")
	frozen = 0
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
	if(!isXeno(A))
		return
	var/mob/living/carbon/Xenomorph/target = A

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't transfer plasma from here!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
		return

	to_chat(src, "<span class='notice'>You start focusing your plasma towards [target].</span>")
	if(!do_after(src, transfer_delay, TRUE, 5, BUSY_ICON_FRIENDLY))
		return

	if(!check_state())
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't transfer plasma from here!</span>")
		return

	if(get_dist(src, target) > max_range)
		to_chat(src, "<span class='warning'>You need to be closer to [target].</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
		return

	if(plasma_stored < amount)
		amount = plasma_stored //Just use all of it
	use_plasma(amount)
	target.gain_plasma(amount)
	to_chat(target, "<span class='xenowarning'>\The [src] has transfered [amount] plasma to you. You now have [target.plasma_stored].</span>")
	to_chat(src, "<span class='xenowarning'>You have transferred [amount] plasma to \the [target]. You now have [plasma_stored].</span>")
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
					to_chat(src, "<span class='xenowarning'>[WR] can't be made thicker.</span>")
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
		to_chat(src, "<span class='warning'>\The [O] is too far away.</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't melt [O] from here!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your muscles fail to respond as you try to shake up the shock!</span>")
		return

	face_atom(O)

	var/wait_time = 10

	//OBJ CHECK
	if(isobj(O))
		var/obj/I = O

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
		var/turf/T = O

		if(istype(O, /turf/closed/wall))
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
		log_combat(src, O, "spat on", addition="with corrosive acid")
		msg_admin_attack("[src.name] ([src.ckey]) spat acid on [O].")
	visible_message("<span class='xenowarning'>\The [src] vomits globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", \
	"<span class='xenowarning'>You vomit globs of vile stuff all over \the [O]. It begins to sizzle and melt under the bubbling mess of acid!</span>", null, 5)
	playsound(loc, "sound/bullets/acid_impact1.ogg", 25)





/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	if(caste == "Queen" && anchored)
		check_hive_status(src, anchored)
	else
		check_hive_status(src)


/proc/check_hive_status(mob/living/carbon/Xenomorph/user, var/anchored = FALSE)
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
		if(X.z == ADMIN_Z_LEVEL)
			continue //don't show xenos in the thunderdome when admins test stuff.
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
			if("Hunter")
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
	dat += "<b>Tier 2: [carrier_count + hivelord_count + hunter_count + spitter_count + warrior_count] Sisters</b> | Carriers: [carrier_count] | Hivelords: [hivelord_count] | Warriors: [warrior_count] | Hunters: [hunter_count] | Spitters: [spitter_count]<BR>"
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
		to_chat(src, "<span class='notice'>The selected xeno ability will now be activated with shift clicking.</span>")
	else
		to_chat(src, "<span class='notice'>The selected xeno ability will now be activated with middle mouse clicking.</span>")


// Runner Savage
/mob/living/carbon/Xenomorph/proc/Savage(var/mob/living/carbon/M)

	if(!check_state())
		return

	if(savage_used)
		to_chat(src, "<span class='xenowarning'>You're too tired to savage right now.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't savage with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenodanger'>You're too disoriented from the shock to savage!</span>")
		return

	var/alien_roar = "alien_roar[rand(1,6)]"
	playsound(src, alien_roar, 50)
	use_plasma(10) //Base cost of the Savage
	src.visible_message("<span class='danger'>\ [src] savages [M]!</span>", \
	"<span class='xenodanger'>You savage [M]!</span>", null, 5)
	var/extra_dam = min(15, plasma_stored * 0.2)
	round_statistics.runner_savage_attacks++
	M.attack_alien(src,  extra_dam, FALSE, TRUE, TRUE, TRUE) //Inflict a free attack on pounce that deals +1 extra damage per 4 plasma stored, up to 35 or twice the max damage of an Ancient Runner attack.
	use_plasma(extra_dam * 5) //Expend plasma equal to 4 times the extra damage.
	savage_used = TRUE
	do_savage_cooldown()

	return TRUE

/mob/living/carbon/Xenomorph/proc/do_savage_cooldown()
	if(!savage_used)//sanity check/safeguard
		return
	spawn(savage_cooldown)
		savage_used = FALSE
		to_chat(src, "<span class='xenowarning'><b>You can now savage your victims again.</b></span>")
		playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()

// Crusher Horn Toss
/mob/living/carbon/Xenomorph/proc/cresttoss(var/mob/living/carbon/M)
	if(cresttoss_used)
		return

	if(!check_plasma(40))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't maneuver your body properly with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to fling away [M] but are unable as you fail to shake off the shock!</span>")
		return

	if (!Adjacent(M) || !istype(M, /mob/living)) //Sanity check
		return

	if(M.stat == DEAD || (M.status_flags & XENO_HOST && istype(M.buckled, /obj/structure/bed/nest) ) ) //no bully
		return

	if(M.mob_size >= MOB_SIZE_BIG) //We can't fling big aliens/mobs
		to_chat(src, "<span class='xenowarning'>[M] is too large to fling!</span>")
		return

	icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect
	visible_message("<span class='xenowarning'>\The [src] flings [M] away with its crest!</span>", \
	"<span class='xenowarning'>You fling [M] away with your crest!</span>")

	cresttoss_used = 1
	use_plasma(40)

	face_atom(M) //Face towards the target so we don't look silly

	var/facing = get_dir(src, M)
	var/toss_distance = rand(3,5)
	var/turf/T = loc
	var/turf/temp = loc
	if(a_intent == "hurt") //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for (var/x = 0, x < toss_distance, x++)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(M, src)
		M.loc = get_step(T, facing) //Move the target behind us before flinging
		for (var/x = 0, x < toss_distance, x++)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	//The target location deviates up to 1 tile in any direction
	var/scatter_x = rand(-1,1)
	var/scatter_y = rand(-1,1)
	var/turf/new_target = locate(T.x + round(scatter_x),T.y + round(scatter_y),T.z) //Locate an adjacent turf.
	if(new_target)
		T = new_target//Looks like we found a turf.

	M.throw_at(T, toss_distance, 1, src)

	//Handle the damage
	if(!isXeno(M)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 5
		if(frenzy_aura)
			damage *= (1 + round(frenzy_aura * 0.1,0.01)) //+10% damage per level of frenzy
		var/armor_block = M.run_armor_check("chest", "melee")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.take_overall_damage(rand(damage * 0.75,damage * 1.25) * 0.5, armor_block) //Armour functions against this.
		else
			M.take_overall_damage(rand(damage * 0.75,damage * 1.25) * 0.5, armor_block) //Armour functions against this.
		M.apply_damage(damage, HALLOSS) //...But decent armour ignoring Halloss
		shake_camera(M, 2, 2)
		playsound(M,pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)
		M.KnockDown(1, 1)

	cresttoss_cooldown()
	spawn(3) //Revert to our prior icon state.
		if(m_intent == MOVE_INTENT_RUN)
			icon_state = "Crusher Running"
		else
			icon_state = "Crusher Walking"

/mob/living/carbon/Xenomorph/proc/cresttoss_cooldown()
	if(!cresttoss_used)//sanity check/safeguard
		return
	spawn(cresttoss_cooldown)
		cresttoss_used = FALSE
		to_chat(src, "<span class='xenowarning'><b>You can now crest toss again.</b></span>")
		playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()


// Carrier Spawn Hugger
/mob/living/carbon/Xenomorph/Carrier/proc/Spawn_Hugger(var/mob/living/carbon/M)
	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to spawn a young one but are unable to shake off the shock!</span>")
		return

	if(used_spawn_facehugger)
		to_chat(src, "<span class='xenowarning'>You're not yet ready to spawn another young one; you must wait [(last_spawn_facehugger + cooldown_spawn_facehugger - world.time) * 0.1] more seconds.</span>")
		return

	if(!check_plasma(CARRIER_SPAWN_HUGGER_COST))
		return

	if(huggers_cur >= huggers_max)
		to_chat(src, "<span class='xenowarning'>You can't host any more young ones!</span>")
		return

	huggers_cur = min(huggers_max, huggers_cur + 1) //Add it to our cache
	to_chat(src, "<span class='xenowarning'>You spawn a young one via the miracle of asexual internal reproduction, adding it to your stores. Now sheltering: [huggers_cur] / [huggers_max].</span>")
	playsound(src, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
	last_spawn_facehugger = world.time
	used_spawn_facehugger = TRUE
	use_plasma(CARRIER_SPAWN_HUGGER_COST)
	hugger_spawn_cooldown()

/mob/living/carbon/Xenomorph/Carrier/proc/hugger_spawn_cooldown()
	if(!used_spawn_facehugger)//sanity check/safeguard
		return
	spawn(cooldown_spawn_facehugger)
		used_spawn_facehugger = FALSE
		to_chat(src, "<span class='xenowarning'><b>You can now spawn another young one.</b></span>")
		playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
		for(var/X in actions)
			var/datum/action/act = X
			act.update_button_icon()



// Hunter Stealth
/mob/living/carbon/Xenomorph/Hunter/proc/Stealth()

	if(!check_state())
		return

	if(world.time < stealth_delay)
		to_chat(src, "<span class='xenodanger'><b>You're not yet ready to Stealth again. You'll be ready in [(stealth_delay - world.time)*0.1] seconds.</span>")
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't enter Stealth with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenodanger'>You're too disoriented from the shock to enter Stealth!</span>")
		return

	if(!stealth)
		if (!check_plasma(10))
			return
		else
			use_plasma(10)
			to_chat(src, "<span class='xenodanger'>You vanish into the shadows...</span>")
			last_stealth = world.time
			stealth = TRUE
			handle_stealth()
			sneak_attack_cooldown()
	else
		cancel_stealth()

/mob/living/carbon/Xenomorph/Hunter/proc/stealth_cooldown_notice()
	if(!used_stealth)//sanity check/safeguard
		return
	spawn(HUNTER_STEALTH_COOLDOWN)
		used_stealth = FALSE
		to_chat(src, "<span class='notice'><b>You're ready to use Stealth again.</b></span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()

/mob/living/carbon/Xenomorph/Hunter/proc/cancel_stealth() //This happens if we take damage, attack, pounce, toggle stealth off, and do other such exciting stealth breaking activities.
	if(!stealth)//sanity check/safeguard
		return
	to_chat(src, "<span class='xenodanger'>You emerge from the shadows.</span>")
	stealth = FALSE
	used_stealth = TRUE
	can_sneak_attack = FALSE
	alpha = 255 //no transparency/translucency
	stealth_delay = world.time + HUNTER_STEALTH_COOLDOWN
	stealth_cooldown_notice()

/mob/living/carbon/Xenomorph/Hunter/proc/sneak_attack_cooldown()
	if(can_sneak_attack)
		return
	spawn(HUNTER_POUNCE_SNEAKATTACK_DELAY)
		can_sneak_attack = TRUE
		to_chat(src, "<span class='xenodanger'>You're ready to use Sneak Attack while stealthed.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)


/mob/living/carbon/Xenomorph/Ravager/proc/Ravage(atom/A)
	if (!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if (ravage_used)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before Ravaging. Ravage can be used in [(ravage_delay - world.time) * 0.1] seconds.</span>")
		return

	var/dist = get_dist(src,A)
	if (dist > 2)
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='xenowarning'>Your target is too far away!</span>")

			recent_notice = world.time //anti-notice spam
		return

	if (!check_plasma(40))
		return

	emote("roar")
	round_statistics.ravager_ravages++
	visible_message("<span class='danger'>\The [src] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>You thrash about in a murderous frenzy!</span>")

	face_atom(A)
	if(dist > 1) //Lunge towards the target turf
		step_towards(src,A,2)

	var/sweep_range = 1
	var/list/L = orange(sweep_range)		// Not actually the fruit
	var/victims
	var/target_facing
	for (var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(src, H)
		if(target_facing != dir && target_facing != turn(dir,45) && target_facing != turn(dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !(istype(H.buckled, /obj/structure/bed/nest) && H.status_flags & XENO_HOST) ) //No bully
			var/extra_dam = rand(melee_damage_lower, melee_damage_upper) * (1 + round(rage * 0.01) ) //+1% bonus damage per point of Rage.relative to base melee damage.
			H.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, "hurt")
			victims++
			round_statistics.ravager_ravage_victims++
		step_away(H, src, sweep_range, 2)
		shake_camera(H, 2, 1)
		H.KnockDown(1, 1)

	victims = CLAMP(victims,0,3) //Just to be sure
	rage = (0 + 10 * victims) //rage resets to 0, though we regain 10 rage per victim.

	ravage_used = TRUE
	use_plasma(40)

	ravage_delay = world.time + (RAV_RAVAGE_COOLDOWN - (victims * 30))

	spawn(CLAMP(RAV_RAVAGE_COOLDOWN - (victims * 30),10,100)) //10 second cooldown base, minus 2 per victim
		ravage_used = FALSE
		to_chat(src, "<span class='xenodanger'>You gather enough strength to Ravage again.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()

/mob/living/carbon/Xenomorph/Ravager/proc/Second_Wind()
	if (!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if (second_wind_used)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before using Second Wind. Second Wind can be used in [(second_wind_delay - world.time) * 0.1] seconds.</span>")
		return

	to_chat(src, "<span class='xenodanger'>Your coursing adrenaline stimulates tissues into a spat of rapid regeneration...</span>")
	var/current_rage = CLAMP(rage,0,RAVAGER_MAX_RAGE) //lock in the value at the time we use it; min 0, max 50.
	do_jitter_animation(1000)
	if(!do_after(src, 50, TRUE, 5, BUSY_ICON_FRIENDLY))
		return
	do_jitter_animation(1000)
	playsound(src, "sound/effects/alien_drool2.ogg", 50, 0)
	to_chat(src, "<span class='xenodanger'>You recoup your health, your tapped rage restoring your body, flesh and chitin reknitting themselves...</span>")
	adjustFireLoss(-CLAMP( (getFireLoss()) * (0.25 + current_rage * 0.015), 0, getFireLoss()) )//Restore HP equal to 25% + 1.5% of the difference between min and max health per rage
	adjustBruteLoss(-CLAMP( (getBruteLoss()) * (0.25 + current_rage * 0.015), 0, getBruteLoss()) )//Restore HP equal to 25% + 1.5% of the difference between min and max health per rage
	plasma_stored += CLAMP( (plasma_max - plasma_stored) * (0.25 + current_rage * 0.015), 0, plasma_max - plasma_stored) //Restore Plasma equal to 25% + 1.5% of the difference between min and max health per rage
	updatehealth()
	hud_set_plasma()

	round_statistics.ravager_second_winds++

	second_wind_used = TRUE

	second_wind_delay = world.time + (RAV_SECOND_WIND_COOLDOWN * round(1 - current_rage * 0.01) )

	spawn(RAV_SECOND_WIND_COOLDOWN * round(1 - current_rage * 0.01) ) //1 minute cooldown, minus 0.5 seconds per rage to minimum 30 seconds.
		second_wind_used = FALSE
		to_chat(src, "<span class='xenodanger'>You gather enough strength to use Second Wind again.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()

	rage = 0