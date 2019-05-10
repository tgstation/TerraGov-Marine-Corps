// ***************************************
// *********** Agility
// ***************************************
/datum/action/xeno_action/activable/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
	mechanics_text = "Move an all fours for greater speed. Cannot use abilities while in this mode."
	ability_name = "toggle agility"
	cooldown_timer = WARRIOR_AGILITY_COOLDOWN
	use_state_flags = XACT_USE_AGILITY

/datum/action/xeno_action/activable/toggle_agility/on_cooldown_finish()
	var/mob/living/carbon/Xenomorph/X = owner
	to_chat(src, "<span class='notice'>You can [X.agility ? "raise yourself back up" : "lower yourself back down"] again.</span>")
	return ..()

/datum/action/xeno_action/activable/toggle_agility/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner

	X.agility = !X.agility

	round_statistics.warrior_agility_toggles++
	if (X.agility)
		to_chat(X, "<span class='xenowarning'>You lower yourself to all fours and loosen your armored scales to ease your movement.</span>")
		X.speed_modifier--
		X.armor_bonus -= WARRIOR_AGILITY_ARMOR
	else
		to_chat(X, "<span class='xenowarning'>You raise yourself to stand on two feet, hard scales setting back into place.</span>")
		X.speed_modifier++
		X.armor_bonus += WARRIOR_AGILITY_ARMOR
	X.update_icons()
	add_cooldown()
	return succeed_activate()

// ***************************************
// *********** Lunge
// ***************************************
/datum/action/xeno_action/activable/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	mechanics_text = "Pounce up to 5 tiles and grab a target, knocking them down and putting them in your grasp."
	ability_name = "lunge"
	plasma_cost = 10
	cooldown_timer = WARRIOR_LUNGE_COOLDOWN

/datum/action/xeno_action/activable/lunge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE
	if(!ishuman(A))
		return FALSE
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return FALSE

/datum/action/xeno_action/activable/lunge/on_cooldown_finish()
	var/mob/living/carbon/Xenomorph/X = owner
	X.used_lunge = FALSE
	to_chat(X, "<span class='notice'>You get ready to lunge again.</span>")
	return ..()

/datum/action/xeno_action/activable/lunge/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

	round_statistics.warrior_lunges++
	X.visible_message("<span class='xenowarning'>\The [X] lunges towards [A]!</span>", \
	"<span class='xenowarning'>You lunge at [A]!</span>")

	succeed_activate()
	X.used_lunge = TRUE // triggered by start_pulling
	X.throw_at(get_step_towards(A, X), 6, 2, X)

	if (X.Adjacent(A))
		X.start_pulling(A, TRUE)

	add_cooldown()
	return TRUE

// ***************************************
// *********** Fling
// ***************************************
/datum/action/xeno_action/activable/fling
	name = "Fling"
	action_icon_state = "fling"
	mechanics_text = "Knock a target flying up to 5 tiles."
	ability_name = "Fling"
	plasma_cost = 30
	cooldown_timer = WARRIOR_FLING_COOLDOWN

/datum/action/xeno_action/activable/fling/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>You gather enough strength to fling something again.</span>")
	return ..()

/datum/action/xeno_action/activable/fling/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE
	if(!owner.Adjacent(A))
		return FALSE
	if(!ishuman(A))
		return FALSE
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return FALSE

/datum/action/xeno_action/activable/fling/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	var/mob/living/carbon/human/H = A
	round_statistics.warrior_flings++

	X.visible_message("<span class='xenowarning'>\The [X] effortlessly flings [H] to the side!</span>", \
	"<span class='xenowarning'>You effortlessly fling [H] to the side!</span>")
	playsound(H,'sound/weapons/alien_claw_block.ogg', 75, 1)
	succeed_activate()
	H.apply_effects(1,2) 	// Stun
	shake_camera(H, 2, 1)

	var/facing = get_dir(X, H)
	var/fling_distance = 4
	var/turf/T = X.loc
	var/turf/temp = X.loc

	for (var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp
	X.animation_attack_on(H)
	X.flick_attack_overlay(H, "disarm")
	H.throw_at(T, fling_distance, 1, X, 1)

	add_cooldown()

// ***************************************
// *********** Punch
// ***************************************
/datum/action/xeno_action/activable/punch
	name = "Punch"
	action_icon_state = "punch"
	mechanics_text = "Strike a target up to 1 tile away with a chance to break bones."
	ability_name = "punch"
	plasma_cost = 20
	cooldown_timer = WARRIOR_PUNCH_COOLDOWN

/datum/action/xeno_action/activable/punch/on_cooldown_finish()
	to_chat(src, "<span class='notice'>You gather enough strength to punch again.</span>")
	return ..()

/datum/action/xeno_action/activable/punch/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(A))
		return FALSE
	var/mob/living/L = A
	if(L.stat == DEAD || (CHECK_BITFIELD(L.status_flags, XENO_HOST) && istype(L.buckled, /obj/structure/bed/nest))) //Can't bully the dead/nested hosts.
		return FALSE

/datum/action/xeno_action/activable/punch/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	var/mob/living/M = A
	if(X.issamexenohive(M))
		return M.attack_alien() //harmless nibbling.

	round_statistics.warrior_punches++

	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
	var/target_zone = check_zone(X.zone_selected)
	if(!target_zone)
		target_zone = "chest"
	var/damage = rand(X.xeno_caste.melee_damage_lower, X.xeno_caste.melee_damage_upper)
	succeed_activate()
	playsound(M, S, 50, 1)

	M.punch_act(X, damage, target_zone)
	X.animation_attack_on(M)
	X.flick_attack_overlay(M, "punch")
	shake_camera(M, 2, 1)
	step_away(M, X, 2)

	add_cooldown()

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

	if(!do_after(src, limb_time, TRUE, H, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .break_do_after_checks, null, null, zone_selected)) || M.stat == DEAD)
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

	if(!do_after(src, limb_time, TRUE, H, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .break_do_after_checks, null, null, zone_selected)) || M.stat == DEAD)
		to_chat(src, "<span class='notice'>You stop ripping off the limb.</span>")
		return FALSE

	if(L.limb_status & LIMB_DESTROYED)
		return FALSE

	visible_message("<span class='xenowarning'>\The [src] rips [M]'s [L.display_name] away from [M.p_their()] body!</span>", \
	"<span class='xenowarning'>\The [M]'s [L.display_name] rips away from [M.p_their()] body!</span>")
	log_message(src, M, "ripped the [L.display_name] off", addition="2/2 progress")

	L.droplimb()

	return TRUE