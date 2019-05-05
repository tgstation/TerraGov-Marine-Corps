// ***************************************
// *********** Agility
// ***************************************
/datum/action/xeno_action/activable/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
	mechanics_text = "Move an all fours for greater speed. Cannot use abilities while in this mode."
	ability_name = "toggle agility"

/datum/action/xeno_action/activable/toggle_agility/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.toggle_agility()

/datum/action/xeno_action/activable/toggle_agility/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_toggle_agility

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

// ***************************************
// *********** Lunge
// ***************************************
/datum/action/xeno_action/activable/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	mechanics_text = "Pounce up to 5 tiles and grab a target, knocking them down and putting them in your grasp."
	ability_name = "lunge"

/datum/action/xeno_action/activable/lunge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.lunge(A)

/datum/action/xeno_action/activable/lunge/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_lunge

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

// ***************************************
// *********** Fling
// ***************************************
/datum/action/xeno_action/activable/fling
	name = "Fling"
	action_icon_state = "fling"
	mechanics_text = "Knock a target flying up to 5 tiles."
	ability_name = "Fling"

/datum/action/xeno_action/activable/fling/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.fling(A)

/datum/action/xeno_action/activable/fling/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_fling

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

// ***************************************
// *********** Punch
// ***************************************
/datum/action/xeno_action/activable/punch
	name = "Punch"
	action_icon_state = "punch"
	mechanics_text = "Strike a target up to 1 tile away with a chance to break bones."
	ability_name = "punch"

/datum/action/xeno_action/activable/punch/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.punch(A)

/datum/action/xeno_action/activable/punch/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_punch

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

	L.take_damage_limb(damage, 0, FALSE, FALSE, run_armor_check(target_zone))

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

	if(issamexenohive(M))
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

// ***************************************
// *********** Rip limb
// ***************************************

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
		L.take_damage_limb(rand(30, 40)) // just do more damage
		visible_message("<span class='xenowarning'>You hear [M]'s [L.display_name] being pulled beyond its load limits!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] begins to tear apart!</span>")
	else
		visible_message("<span class='xenowarning'>You hear the bones in [M]'s [L.display_name] snap with a sickening crunch!</span>", \
		"<span class='xenowarning'>\The [M]'s [L.display_name] bones snap with a satisfying crunch!</span>")
		L.take_damage_limb(rand(15, 25))
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