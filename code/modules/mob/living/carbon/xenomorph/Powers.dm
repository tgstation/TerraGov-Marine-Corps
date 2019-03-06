

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

	if(can_sneak_attack) //If we could sneak attack, add a cooldown to sneak attack
		to_chat(src, "<span class='xenodanger'>Your pounce has left you off-balance; you'll need to wait [HUNTER_POUNCE_SNEAKATTACK_DELAY*0.1] seconds before you can Sneak Attack again.</span>")
		can_sneak_attack = FALSE
		addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY)

	usedPounce = TRUE
	flags_pass = PASSTABLE
	use_plasma(20)
	throw_at(T, 7, 2, src) //Victim, distance, speed
	addtimer(CALLBACK(src, .proc/reset_flags_pass), 6)
	addtimer(CALLBACK(src, .proc/reset_pounce_delay), xeno_caste.pounce_delay)



	return TRUE

/mob/living/carbon/Xenomorph/Hunter/proc/sneak_attack_cooldown()
	if(can_sneak_attack)
		return
	can_sneak_attack = TRUE
	to_chat(src, "<span class='xenodanger'>You're ready to use Sneak Attack while stealthed.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)

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

	if (used_acid_spray || !check_plasma(200))
		return

	if(!do_after(src, 5, TRUE, 5, BUSY_ICON_HOSTILE))
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
	addtimer(CALLBACK(src, .speed_increase, 2), rand(20,30))
	addtimer(CALLBACK(src, .acid_spray_cooldown_finished), xeno_caste.acid_spray_cooldown)

/mob/living/carbon/Xenomorph/proc/speed_increase(var/amount)
	speed -= amount

/mob/living/carbon/Xenomorph/proc/acid_spray_cooldown_finished()
	used_acid_spray = FALSE
	to_chat(src, "<span class='notice'>You have produced enough acid to spray again.</span>")

/atom/proc/acid_spray_act(mob/living/carbon/Xenomorph/X)
	return TRUE

/obj/structure/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if(!is_type_in_typecache(src, GLOB.acid_spray_hit))
		return TRUE // normal density flag
	health -= rand(40,60) + (X.upgrade * SPRAY_STRUCTURE_UPGRADE_BONUS)
	update_health(TRUE)
	return TRUE // normal density flag

/obj/structure/razorwire/acid_spray_act(mob/living/carbon/Xenomorph/X)
	. = ..()
	return FALSE // not normal density flag

/obj/vehicle/multitile/root/cm_armored/acid_spray_act(mob/living/carbon/Xenomorph/X)
	take_damage_type(rand(40,60) + (X.upgrade * SPRAY_STRUCTURE_UPGRADE_BONUS), "acid", src)
	healthcheck()
	return TRUE

/mob/living/carbon/acid_spray_act(mob/living/carbon/Xenomorph/X)
	if((status_flags & XENO_HOST) && istype(buckled, /obj/structure/bed/nest))
		return

	if(isxenopraetorian(X))
		round_statistics.praetorian_spray_direct_hits++

	acid_process_cooldown = world.time //prevent the victim from being damaged by acid puddle process damage for 1 second, so there's no chance they get immediately double dipped by it.
	var/armor_block = run_armor_check("chest", "energy")
	var/damage = rand(30,40) + (X.upgrade * SPRAY_MOB_UPGRADE_BONUS)
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

// Warrior Fling
/mob/living/carbon/Xenomorph/proc/fling(atom/A)

	if (!A || !ishuman(A) || !check_state() || agility || !check_plasma(30) || !Adjacent(A))
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
	use_plasma(30)
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

	addtimer(CALLBACK(src, .fling_reset), WARRIOR_FLING_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/fling_reset()
	used_fling = FALSE
	to_chat(src, "<span class='notice'>You gather enough strength to fling something again.</span>")
	update_action_button_icons()

/mob/living/proc/punch_act(mob/living/carbon/Xenomorph/X, damage, target_zone)
	apply_damage(damage, BRUTE, target_zone, run_armor_check(target_zone))

/mob/living/carbon/human/punch_act(mob/living/carbon/Xenomorph/X, damage, target_zone)
	var/datum/limb/L = get_limb(target_zone)

	if (!L || (L.limb_status & LIMB_DESTROYED))
		return

	X.visible_message("<span class='xenowarning'>\The [X] hits [src] in the [L.display_name] with a devastatingly powerful punch!</span>", \
		"<span class='xenowarning'>You hit [src] in the [L.display_name] with a devastatingly powerful punch!</span>")

	if(L.limb_status & LIMB_SPLINTED) //If they have it splinted, the splint won't hold.
		L.limb_status &= ~LIMB_SPLINTED
		to_chat(src, "<span class='danger'>The splint on your [L.display_name] comes apart!</span>")

	L.take_damage(damage, 0, 0, 0, null, null, null, run_armor_check(target_zone))

	adjust_stagger(3)
	add_slowdown(3)

	apply_damage(damage, HALLOSS) //Armor penetrating halloss also applies.

/mob/living/carbon/Xenomorph/proc/punch(var/mob/living/M)
	if (!istype(M) || M == src)
		return

	if (!check_state() || agility)
		return

	if (!Adjacent(M))
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if (used_punch)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before punching.</span>")
		return

	if(xeno_hivenumber(M) == hivenumber)
		return M.attack_alien() //harmless nibbling.

	if (!check_plasma(20))
		return

	if(M.stat == DEAD || ((M.status_flags & XENO_HOST) && istype(M.buckled, /obj/structure/bed/nest))) //Can't bully the dead/nested hosts.
		return
	round_statistics.warrior_punches++


	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	var/target_zone = check_zone(zone_selected)
	if(!target_zone)
		target_zone = "chest"
	var/damage = rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper)
	used_punch = TRUE
	use_plasma(20)
	playsound(M, S, 50, 1)

	M.punch_act(src, damage, target_zone)

	shake_camera(M, 2, 1)
	step_away(M, src, 2)

	addtimer(CALLBACK(src, .punch_reset), WARRIOR_PUNCH_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/punch_reset()
	used_punch = FALSE
	to_chat(src, "<span class='notice'>You gather enough strength to punch again.</span>")
	update_action_button_icons()

/mob/living/carbon/Xenomorph/proc/lunge(atom/A)

	if (!A || !ishuman(A) || !check_state() || agility || !check_plasma(10))
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

	addtimer(CALLBACK(src, .lunge_reset), WARRIOR_LUNGE_COOLDOWN)

	return TRUE

/mob/living/carbon/Xenomorph/proc/lunge_reset()
	used_lunge = FALSE
	to_chat(src, "<span class='notice'>You get ready to lunge again.</span>")
	update_action_button_icons()

// Called when pulling something and attacking yourself with the pull
/mob/living/carbon/Xenomorph/proc/pull_power(var/mob/M)
	if (isxenowarrior(src) && !ripping_limb && M.stat != DEAD)
		ripping_limb = TRUE
		if(rip_limb(M))
			stop_pulling()
		ripping_limb = FALSE


// Warrior Rip Limb - called by pull_power()
/mob/living/carbon/Xenomorph/proc/rip_limb(var/mob/M)
	if (!ishuman(M))
		return FALSE

	if(action_busy) //can't stack the attempts
		return FALSE

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake up the shock!</span>")
		return

	var/mob/living/carbon/human/H = M
	var/datum/limb/L = H.get_limb(check_zone(zone_selected))

	if (!L || L.body_part == CHEST || L.body_part == GROIN || (L.limb_status & LIMB_DESTROYED) || L.body_part == HEAD) //Only limbs; no head
		to_chat(src, "<span class='xenowarning'>You can't rip off that limb.</span>")
		return FALSE
	round_statistics.warrior_limb_rips++
	var/limb_time = rand(40,60)

	visible_message("<span class='xenowarning'>\The [src] begins pulling on [M]'s [L.display_name] with incredible strength!</span>", \
	"<span class='xenowarning'>You begin to pull on [M]'s [L.display_name] with incredible strength!</span>")

	if(!do_after(src, limb_time, TRUE, 5, BUSY_ICON_HOSTILE, 1) || M.stat == DEAD)
		to_chat(src, "<span class='notice'>You stop ripping off the limb.</span>")
		return FALSE

	if(L.limb_status & LIMB_DESTROYED)
		return FALSE

	if(L.limb_status & LIMB_ROBOT)
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

	if(L.limb_status & LIMB_DESTROYED)
		return FALSE

	visible_message("<span class='xenowarning'>\The [src] rips [M]'s [L.display_name] away from [M.p_their()] body!</span>", \
	"<span class='xenowarning'>\The [M]'s [L.display_name] rips away from [M.p_their()] body!</span>")
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
		addtimer(CALLBACK(src, .agility_cooldown), WARRIOR_AGILITY_COOLDOWN)
		return

	to_chat(src, "<span class='xenowarning'>You raise yourself to stand on two feet, hard scales setting back into place.</span>")
	speed_modifier++
	armor_bonus += WARRIOR_AGILITY_ARMOR
	update_icons()
	addtimer(CALLBACK(src, .agility_cooldown), WARRIOR_AGILITY_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/agility_cooldown()
	used_toggle_agility = FALSE
	to_chat(src, "<span class='notice'>You can [agility ? "raise yourself back up" : "lower yourself back down"] again.</span>")
	update_action_button_icons()

// Defender Headbutt
/mob/living/carbon/Xenomorph/proc/headbutt(var/mob/M)
	if (!ishuman(M))
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
		if (!check_plasma(DEFENDER_HEADBUTT_COST * 2))
			return
	else if (!check_plasma(DEFENDER_HEADBUTT_COST))
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

	used_headbutt = TRUE
	if(crest_defense) //We can now use crest defense, but the plasma cost is doubled.
		use_plasma(DEFENDER_HEADBUTT_COST * 2)
	else
		use_plasma(DEFENDER_HEADBUTT_COST)

	face_atom(H) //Face towards the target so we don't look silly

	var/damage = rand(xeno_caste.melee_damage_lower,xeno_caste.melee_damage_upper)
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
	addtimer(CALLBACK(src, .headbutt_cooldown), DEFENDER_HEADBUTT_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/headbutt_cooldown()
	used_headbutt = FALSE
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
		if (!check_plasma(DEFENDER_TAILSWIPE_COST * 2))
			return
	else if (!check_plasma(DEFENDER_TAILSWIPE_COST))
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
			var/damage = rand(xeno_caste.melee_damage_lower,xeno_caste.melee_damage_upper)
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
		use_plasma(DEFENDER_TAILSWIPE_COST * 2)
	else
		use_plasma(DEFENDER_TAILSWIPE_COST)

	addtimer(CALLBACK(src, .tailswipe_cooldown), DEFENDER_TAILSWIPE_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/tailswipe_cooldown()
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
		armor_bonus += xeno_caste.crest_defense_armor
		xeno_explosion_resistance = 2
		speed_modifier += DEFENDER_CRESTDEFENSE_SLOWDOWN	// This is actually a slowdown but speed is dumb
		update_icons()
		addtimer(CALLBACK(src, .crest_defense_cooldown), DEFENDER_CREST_DEFENSE_COOLDOWN)
		return

	round_statistics.defender_crest_raises++
	to_chat(src, "<span class='xenowarning'>You raise your crest.</span>")
	armor_bonus -= xeno_caste.crest_defense_armor
	xeno_explosion_resistance = 0
	speed_modifier -= DEFENDER_CRESTDEFENSE_SLOWDOWN
	update_icons()
	addtimer(CALLBACK(src, .crest_defense_cooldown), DEFENDER_CREST_DEFENSE_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/crest_defense_cooldown()
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
		armor_bonus += xeno_caste.fortify_armor
		xeno_explosion_resistance = 3
		set_frozen(TRUE)
		anchored = TRUE
		update_canmove()
		update_icons()
		addtimer(CALLBACK(src, .fortify_cooldown), DEFENDER_FORTIFY_COOLDOWN)
		playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
		return

	fortify_off()
	addtimer(CALLBACK(src, .fortify_cooldown), DEFENDER_FORTIFY_COOLDOWN)

/mob/living/carbon/Xenomorph/proc/fortify_off()
	to_chat(src, "<span class='xenowarning'>You resume your normal stance.</span>")
	armor_bonus -= xeno_caste.fortify_armor
	xeno_explosion_resistance = 0
	fortify = FALSE
	set_frozen(FALSE)
	anchored = FALSE
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
	update_canmove()
	update_icons()

/mob/living/carbon/Xenomorph/proc/fortify_cooldown()
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



/mob/living/carbon/Xenomorph/verb/hive_status()
	set name = "Hive Status"
	set desc = "Check the status of your current hive."
	set category = "Alien"

	if(isxenoqueen(src) && anchored)
		check_hive_status(src, anchored)
	else
		check_hive_status(src)


/proc/check_hive_status(mob/living/carbon/Xenomorph/user, var/anchored = FALSE)
	if(!SSticker)
		return
	var/dat = "<html><head><title>Hive Status</title></head><body>"

	var/datum/hive_status/hive
	if(istype(user) && user.hive)
		hive = user.hive
	else
		hive = GLOB.hive_datums[XENO_HIVE_NORMAL]

	var/xenoinfo = ""
	var/can_overwatch = FALSE

	var/tier3counts = ""
	var/tier2counts = ""
	var/tier1counts = ""

	if(isxenoqueen(user))
		var/mob/living/carbon/Xenomorph/Queen/Q = user
		if(Q.ovipositor)
			can_overwatch = TRUE

	for(var/i in hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Queen])
		var/mob/living/carbon/Xenomorph/X = i
		xenoinfo += "<tr><td>[X.name] "
		if(!X.client)
			xenoinfo += " <i>(SSD)</i>"
		else if(X.client.prefs.xeno_name && X.client.prefs.xeno_name != "Undefined")
			xenoinfo += "- [X.client.prefs.xeno_name]"
		var/area/A = get_area(X)
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

	for(var/i in hive.xeno_leader_list)
		var/mob/living/carbon/Xenomorph/X = i
		if(can_overwatch)
			xenoinfo += "<tr><td><b>(-L-)</b><a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
		else
			xenoinfo += "<tr><td><b>(-L-)</b>[X.name] "
		if(!X.client)
			xenoinfo += " <i>(SSD)</i>"
		else if(X.client.prefs.xeno_name && X.client.prefs.xeno_name != "Undefined")
			xenoinfo += "- [X.client.prefs.xeno_name]"

		var/area/A = get_area(X)
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

	for(var/typepath in hive.xenos_by_typepath)
		var/mob/living/carbon/Xenomorph/T = typepath
		if(initial(T.tier) == XENO_TIER_ZERO)
			continue
		if(typepath == /mob/living/carbon/Xenomorph/Queen)
			continue
		
		switch(initial(T.tier))
			if(XENO_TIER_THREE)
				tier3counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"
			if(XENO_TIER_TWO)
				tier2counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"
			if(XENO_TIER_ONE)
				tier1counts += " | [initial(T.name)]s: [length(hive.xenos_by_typepath[typepath])]"

		for(var/i in hive.xenos_by_typepath[typepath])
			var/mob/living/carbon/Xenomorph/X = i
			if(X.queen_chosen_lead)
				continue
			if(can_overwatch)
				xenoinfo += "<tr><td><a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
			else
				xenoinfo += "<tr><td>[X.name] "
			if(!X.client)
				xenoinfo += " <i>(SSD)</i>"
			else if(X.client.prefs.xeno_name && X.client.prefs.xeno_name != "Undefined")
				xenoinfo += "- [X.client.prefs.xeno_name]"
			var/area/A = get_area(X)
			xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

	for(var/i in hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva])
		var/mob/living/carbon/Xenomorph/X = i
		if(can_overwatch)
			xenoinfo += "<tr><td><a href=?src=\ref[user];watch_xeno_number=[X.nicknumber]>[X.name]</a> "
		else
			xenoinfo += "<tr><td>[X.name] "
		if(!X.client)
			xenoinfo += " <i>(SSD)</i>"
		else if(X.client.prefs.xeno_name && X.client.prefs.xeno_name != "Undefined")
			xenoinfo += "- [X.client.prefs.xeno_name]"
		var/area/A = get_area(X)
		xenoinfo += " <b><font color=green>([A ? A.name : null])</b></td></tr>"

	dat += "<b>Total Living Sisters: [user.hive.get_total_xeno_number()]</b><BR>"
	dat += "<b>Tier 3: [length(user.hive.xenos_by_tier[XENO_TIER_THREE])] Sisters</b>[tier3counts]<BR>"
	dat += "<b>Tier 2: [length(user.hive.xenos_by_tier[XENO_TIER_TWO])] Sisters</b>[tier2counts]<BR>"
	dat += "<b>Tier 1: [length(user.hive.xenos_by_tier[XENO_TIER_ONE])] Sisters</b>[tier1counts]<BR>"
	dat += "<b>Larvas: [length(hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva])] Sisters<BR>"
	if(istype(user)) // cover calling it without parameters
		if(user.hivenumber == XENO_HIVE_NORMAL)
			dat += "<b>Burrowed Larva: [SSticker.mode.stored_larva] Sisters<BR>"
	dat += "<table cellspacing=4>"
	dat += xenoinfo
	dat += "</table></body>"
	usr << browse(dat, "window=roundstatus;size=600x600")


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
	addtimer(CALLBACK(src, .savage_cooldown), xeno_caste.savage_cooldown)

	return TRUE

/mob/living/carbon/Xenomorph/proc/savage_cooldown()
	if(!savage_used)//sanity check/safeguard
		return
	savage_used = FALSE
	to_chat(src, "<span class='xenowarning'><b>You can now savage your victims again.</b></span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()

// Crusher Horn Toss
/mob/living/carbon/Xenomorph/proc/cresttoss(var/mob/living/carbon/M)
	if(cresttoss_used)
		return

	if(!check_plasma(CRUSHER_CRESTTOSS_COST))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't maneuver your body properly with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to fling away [M] but are too disoriented!</span>")
		return

	if (!Adjacent(M) || !isliving(M)) //Sanity check
		return

	if(M.stat == DEAD || (M.status_flags & XENO_HOST && istype(M.buckled, /obj/structure/bed/nest) ) ) //no bully
		return

	if(M.mob_size >= MOB_SIZE_BIG) //We can't fling big aliens/mobs
		to_chat(src, "<span class='xenowarning'>[M] is too large to fling!</span>")
		return

	face_atom(M) //Face towards the target so we don't look silly

	var/facing = get_dir(src, M)
	var/toss_distance = rand(3,5)
	var/turf/T = loc
	var/turf/temp = loc
	if(a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for (var/x in 1 to toss_distance)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(M, src)
		if(!check_blocked_turf(get_step(T, facing) ) ) //Make sure we can actually go to the target turf
			M.loc = get_step(T, facing) //Move the target behind us before flinging
			for (var/x = 0, x < toss_distance, x++)
				temp = get_step(T, facing)
				if (!temp)
					break
				T = temp
		else
			to_chat(src, "<span class='xenowarning'>You try to fling [M] behind you, but there's no room!</span>")
			return

	//The target location deviates up to 1 tile in any direction
	var/scatter_x = rand(-1,1)
	var/scatter_y = rand(-1,1)
	var/turf/new_target = locate(T.x + round(scatter_x),T.y + round(scatter_y),T.z) //Locate an adjacent turf.
	if(new_target)
		T = new_target//Looks like we found a turf.

	icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	visible_message("<span class='xenowarning'>\The [src] flings [M] away with its crest!</span>", \
	"<span class='xenowarning'>You fling [M] away with your crest!</span>")

	cresttoss_used = TRUE
	use_plasma(CRUSHER_CRESTTOSS_COST)


	M.throw_at(T, toss_distance, 1, src)

	var/mob/living/carbon/Xenomorph/X = M
	//Handle the damage
	if(!istype(X) || hivenumber != X.hivenumber) //Friendly xenos don't take damage.
		var/damage = toss_distance * 5
		if(frenzy_aura)
			damage *= (1 + round(frenzy_aura * 0.1,0.01)) //+10% damage per level of frenzy
		var/armor_block = M.run_armor_check("chest", "melee")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.take_overall_damage(rand(damage * 0.75,damage * 1.25), null, 0, 0, 0, armor_block) //Armour functions against this.
		else
			M.take_overall_damage(rand(damage * 0.75,damage * 1.25), 0, null, armor_block) //Armour functions against this.
		M.apply_damage(damage, HALLOSS) //...But decent armour ignoring Halloss
		shake_camera(M, 2, 2)
		playsound(M,pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)
		M.KnockDown(1, 1)

	addtimer(CALLBACK(src, .cresttoss_cooldown), CRUSHER_CRESTTOSS_COOLDOWN)
	addtimer(CALLBACK(src, .reset_intent_icon_state), 3)

/mob/living/carbon/Xenomorph/proc/reset_intent_icon_state()
	if(m_intent == MOVE_INTENT_RUN)
		icon_state = "Crusher Running"
	else
		icon_state = "Crusher Walking"

/mob/living/carbon/Xenomorph/proc/cresttoss_cooldown()
	if(!cresttoss_used)//sanity check/safeguard
		return
	cresttoss_used = FALSE
	to_chat(src, "<span class='xenowarning'><b>You can now crest toss again.</b></span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()

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

	if(huggers.len >= xeno_caste.huggers_max)
		to_chat(src, "<span class='xenowarning'>You can't host any more young ones!</span>")
		return

	var/obj/item/clothing/mask/facehugger/stasis/F = new
	F.hivenumber = hivenumber
	store_hugger(F, FALSE, TRUE) //Add it to our cache
	to_chat(src, "<span class='xenowarning'>You spawn a young one via the miracle of asexual internal reproduction, adding it to your stores. Now sheltering: [length(huggers)] / [xeno_caste.huggers_max].</span>")
	playsound(src, 'sound/voice/alien_drool2.ogg', 50, 0, 1)
	last_spawn_facehugger = world.time
	used_spawn_facehugger = TRUE
	use_plasma(CARRIER_SPAWN_HUGGER_COST)
	addtimer(CALLBACK(src, .hugger_spawn_cooldown), cooldown_spawn_facehugger)

/mob/living/carbon/Xenomorph/Carrier/proc/hugger_spawn_cooldown()
	if(!used_spawn_facehugger)//sanity check/safeguard
		return
	used_spawn_facehugger = FALSE
	to_chat(src, "<span class='xenodanger'>You can now spawn another young one.</span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()



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

	if(on_fire)
		to_chat(src, "<span class='xenodanger'>You're too busy being on fire to enter Stealth!</span>")
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
			addtimer(CALLBACK(src, .stealth_cooldown), HUNTER_STEALTH_COOLDOWN)
			addtimer(CALLBACK(src, .proc/sneak_attack_cooldown), HUNTER_POUNCE_SNEAKATTACK_DELAY) //Short delay before we can sneak attack.
	else
		cancel_stealth()

/mob/living/carbon/Xenomorph/Hunter/proc/stealth_cooldown()
	if(!used_stealth)//sanity check/safeguard
		return
	used_stealth = FALSE
	to_chat(src, "<span class='xenodanger'><b>You're ready to use Stealth again.</b></span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 25, 0, 1)
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
	addtimer(CALLBACK(src, .stealth_cooldown), HUNTER_STEALTH_COOLDOWN)

/mob/living/carbon/Xenomorph/Ravager/proc/Ravage(atom/A)
	if (!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if (ravage_used)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before Ravaging. Ravage can be used in [(ravage_delay - world.time) * 0.1] seconds.</span>")
		return

	if (!check_plasma(40))
		return

	emote("roar")
	round_statistics.ravager_ravages++
	visible_message("<span class='danger'>\The [src] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>You thrash about in a murderous frenzy!</span>")

	face_atom(A)
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
			var/extra_dam = rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper) * round(RAV_RAVAGE_DAMAGE_MULITPLIER + rage * RAV_RAVAGE_RAGE_MULITPLIER, 0.01)
			H.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, INTENT_HARM)
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

	reset_movement()

	//10 second cooldown base, minus 3 seconds per victim
	addtimer(CALLBACK(src, .ravage_cooldown), CLAMP(RAV_RAVAGE_COOLDOWN - (victims * 30),10,100))

/mob/living/carbon/Xenomorph/Ravager/proc/ravage_cooldown()
	ravage_used = FALSE
	to_chat(src, "<span class='xenodanger'>You gather enough strength to Ravage again.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	update_action_button_icons()

/mob/living/carbon/Xenomorph/Ravager/proc/Second_Wind()
	if(!check_state())
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>Your limbs fail to respond as you try to shake off the shock!</span>")
		return

	if(second_wind_used)
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
	plasma_stored += CLAMP( (xeno_caste.plasma_max - plasma_stored) * (0.25 + current_rage * 0.015), 0, xeno_caste.plasma_max - plasma_stored) //Restore Plasma equal to 25% + 1.5% of the difference between min and max health per rage
	updatehealth()
	hud_set_plasma()

	round_statistics.ravager_second_winds++

	second_wind_used = TRUE

	var/cooldown = (RAV_SECOND_WIND_COOLDOWN * round((1 - (current_rage * 0.015) ),0.01) )

	second_wind_delay = world.time + cooldown

	addtimer(CALLBACK(src, .second_wind_cooldown), cooldown) //4 minute cooldown, minus 0.75 seconds per rage to minimum 60 seconds.

	rage = 0

/mob/living/carbon/Xenomorph/Ravager/proc/second_wind_cooldown()
	second_wind_used = FALSE
	to_chat(src, "<span class='xenodanger'>You gather enough strength to use Second Wind again.</span>")
	playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	update_action_button_icons()

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

/mob/living/carbon/Xenomorph/proc/acid_spray(atom/T, plasmacost = 250, acid_d = xeno_caste.acid_delay)
	if(!T)
		to_chat(src, "<span class='warning'>You see nothing to spit at!</span>")
		return

	if(!check_state())
		return

	if(!isturf(loc) || isspaceturf(loc))
		to_chat(src, "<span class='warning'>You can't do that from there.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>The shock disrupts you!</span>")
		return

	if(!check_plasma(plasmacost))
		return

	if(acid_cooldown)
		to_chat(src, "<span class='xenowarning'>You're not yet ready to spray again! You can do so in [( (last_spray_used + acid_d) - world.time) * 0.1] seconds.</span>")
		return

	if(!do_after(src, 5, TRUE, 5, BUSY_ICON_HOSTILE, TRUE, TRUE))
		return

	var/turf/target

	if(isturf(T))
		target = T
	else
		target = get_turf(T)

	if(!target || !istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(target == loc)
		to_chat(src, "<span class='warning'>That's far too close!</span>")
		return


	acid_cooldown = TRUE
	last_spray_used = world.time
	use_plasma(plasmacost)
	playsound(loc, 'sound/effects/refill.ogg', 50, 1)
	visible_message("<span class='xenowarning'>\The [src] spews forth a virulent spray of acid!</span>", \
	"<span class='xenowarning'>You spew forth a spray of acid!</span>", null, 5)
	var/turflist = getline(src, target)
	spray_turfs(turflist)

	addtimer(CALLBACK(src, .acid_cooldown_end), acid_d)

/mob/living/carbon/Xenomorph/proc/acid_cooldown_end()
	acid_cooldown = FALSE
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your acid glands refill. You can spray acid again.</span>")
	update_action_buttons()

//Defiler abilities
/mob/living/carbon/Xenomorph/Defiler/proc/emit_neurogas()

	if(!check_state())
		return

	if(world.time < last_emit_neurogas + DEFILER_GAS_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenodanger'>You are not ready to emit neurogas again. This ability will be ready in [(last_emit_neurogas + DEFILER_GAS_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return FALSE

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	if(!check_plasma(200))
		return

	//give them fair warning
	visible_message("<span class='danger'>Tufts of smoke begin to billow from [src]!</span>", \
	"<span class='xenodanger'>Your dorsal vents widen, preparing to emit neurogas. Keep still!</span>")

	emitting_gas = TRUE //We gain bump movement immunity while we're emitting gas.
	use_plasma(200)
	icon_state = "Defiler Power Up"

	if(!do_after(src, DEFILER_GAS_CHANNEL_TIME, TRUE, 5, BUSY_ICON_HOSTILE))
		smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()
		smoke_system.amount = 1
		smoke_system.set_up(1, 0, get_turf(src))
		to_chat(src, "<span class='xenodanger'>You abort emitting neurogas, your expended plasma resulting in only a feeble wisp.</span>")
		emitting_gas = FALSE
		icon_state = "Defiler Running"
		return
	emitting_gas = FALSE
	icon_state = "Defiler Running"

	addtimer(CALLBACK(src, .defiler_gas_cooldown), DEFILER_GAS_COOLDOWN)

	last_emit_neurogas = world.time

	if(stagger) //If we got staggered, return
		to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
		return

	round_statistics.defiler_neurogas_uses++

	visible_message("<span class='xenodanger'>[src] emits a noxious gas!</span>", \
	"<span class='xenodanger'>You emit neurogas!</span>")
	dispense_gas()

/mob/living/carbon/Xenomorph/Defiler/proc/defiler_gas_cooldown()
	playsound(loc, 'sound/effects/xeno_newlarva.ogg', 50, 0)
	to_chat(src, "<span class='xenodanger'>You feel your dorsal vents bristle with neurotoxic gas. You can use Emit Neurogas again.</span>")
	update_action_button_icons()

/mob/living/carbon/Xenomorph/Defiler/proc/dispense_gas(count = 3)
	set waitfor = FALSE
	while(count)
		if(stagger) //If we got staggered, return
			to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are staggered!</span>")
			return
		if(stunned || knocked_down)
			to_chat(src, "<span class='xenowarning'>You try to emit neurogas but are disabled!</span>")
			return
		playsound(loc, 'sound/effects/smoke.ogg', 25)
		var/turf/T = get_turf(src)
		smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()
		if(count > 1)
			smoke_system.amount = 2
			smoke_system.set_up(2, 0, T)
		else //last emission is larger
			smoke_system.amount = 3
			smoke_system.set_up(3, 0, T)
		smoke_system.start()
		T.visible_message("<span class='danger'>Noxious smoke billows from the hulking xenomorph!</span>")
		count = max(0,count - 1)
		sleep(DEFILER_GAS_DELAY)



/mob/living/carbon/Xenomorph/Defiler/proc/defiler_sting(mob/living/carbon/C)
	if(!check_state() || !C?.can_sting())
		return

	if(world.time < last_defiler_sting + DEFILER_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='warning'>You are not ready to Defile again. It will be ready in [(last_defiler_sting + DEFILER_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='warning'>You try to sting but are too disoriented!</span>")
		return

	if(!C.can_sting())
		to_chat(src, "<span class='warning'>Your sting won't affect this target!</span>")
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
	last_defiler_sting = world.time
	use_plasma(150)

	round_statistics.defiler_defiler_stings++

	addtimer(CALLBACK(src, .defiler_sting_cooldown), DEFILER_STING_COOLDOWN)

	larva_injection(C)
	larval_growth_sting(C)
	

/mob/living/carbon/Xenomorph/Defiler/proc/defiler_sting_cooldown()
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your toxin glands refill, another young one ready for implantation. You can use Defile again.</span>")
	update_action_button_icons()


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


/mob/living/carbon/Xenomorph/Hivelord/proc/build_tunnel()
	if(!check_state())
		return

	if(action_busy)
		to_chat(src, "<span class='warning'>You should finish up what you're doing before digging.</span>")
		return

	var/turf/T = loc
	if(!istype(T)) //logic
		to_chat(src, "<span class='warning'>You can't do that from there.</span>")
		return

	if(!T.can_dig_xeno_tunnel())
		to_chat(src, "<span class='warning'>You scrape around, but you can't seem to dig through that kind of floor.</span>")
		return

	if(locate(/obj/structure/tunnel) in loc)
		to_chat(src, "<span class='warning'>There already is a tunnel here.</span>")
		return

	if(tunnel_delay)
		to_chat(src, "<span class='warning'>You are not ready to dig a tunnel again.</span>")
		return

	if(get_active_held_item())
		to_chat(src, "<span class='warning'>You need an empty claw for this!</span>")
		return

	if(!check_plasma(200))
		return

	visible_message("<span class='xenonotice'>[src] begins digging out a tunnel entrance.</span>", \
	"<span class='xenonotice'>You begin digging out a tunnel entrance.</span>", null, 5)
	if(!do_after(src, 100, TRUE, 5, BUSY_ICON_BUILD))
		to_chat(src, "<span class='warning'>Your tunnel caves in as you stop digging it.</span>")
		return
	if(!check_plasma(200))
		return
	if(!start_dig) //Let's start a new one.
		visible_message("<span class='xenonotice'>\The [src] digs out a tunnel entrance.</span>", \
		"<span class='xenonotice'>You dig out the first entrance to your tunnel.</span>", null, 5)
		start_dig = new /obj/structure/tunnel(T)
	else
		to_chat(src, "<span class='xenonotice'>You dig your tunnel all the way to the original entrance, connecting both entrances!</span>")
		var/obj/structure/tunnel/newt = new /obj/structure/tunnel(T)
		newt.other = start_dig
		start_dig.other = newt //Link the two together
		start_dig = null //Now clear it
		tunnel_delay = TRUE
		addtimer(CALLBACK(src, .tunnel_cooldown), 2400)

		var/msg = copytext(sanitize(input("Add a description to the tunnel:", "Tunnel Description") as text|null), 1, MAX_MESSAGE_LEN)
		if(msg)
			newt.other.tunnel_desc = msg
			newt.tunnel_desc = msg

	use_plasma(200)
	playsound(loc, 'sound/weapons/pierce.ogg', 25, 1)

/mob/living/carbon/Xenomorph/Hivelord/proc/tunnel_cooldown()
	to_chat(src, "<span class='notice'>You are ready to dig a tunnel again.</span>")
	tunnel_delay = FALSE


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

/mob/living/carbon/Xenomorph/Runner/hit_and_run_bonus(damage)
	var/last_move = last_move_intent - 10
	var/bonus
	if(last_move && last_move < world.time - 5) //If we haven't moved in the last 500 ms, we lose our bonus
		hit_and_run = 1
	bonus = CLAMP(hit_and_run, 1, 2)//Runner deals +5% damage per tile moved in rapid succession to a maximum of +100%. Damage bonus is lost on attacking.
	switch(bonus)
		if(2)
			visible_message("<span class='danger'>\The [src] strikes with lethal speed!</span>", \
			"<span class='danger'>You strike with lethal speed!</span>")
		if(1.5 to 1.99)
			visible_message("<span class='danger'>\The [src] strikes with deadly speed!</span>", \
			"<span class='danger'>You strike with deadly speed!</span>")
		if(1.25 to 1.45)
			visible_message("<span class='danger'>\The [src] strikes with vicious speed!</span>", \
			"<span class='danger'>You strike with vicious speed!</span>")
	damage *= bonus
	hit_and_run = 1 //reset the hit and run bonus
	return damage
