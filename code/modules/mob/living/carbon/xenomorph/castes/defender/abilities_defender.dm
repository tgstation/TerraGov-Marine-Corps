// ***************************************
// *********** Headbutt
// ***************************************
/datum/action/xeno_action/activable/headbutt
	name = "Headbutt"
	action_icon_state = "headbutt"
	mechanics_text = "Charge a target up to 2 tiles away, knocking them away and down and disarming them."
	ability_name = "headbutt"

/datum/action/xeno_action/activable/headbutt/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.headbutt(A)

/datum/action/xeno_action/activable/headbutt/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_headbutt

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

	var/damage = rand(xeno_caste.melee_damage_lower,xeno_caste.melee_damage_upper) + FRENZY_DAMAGE_BONUS(src)
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

// ***************************************
// *********** Tail sweep
// ***************************************
/datum/action/xeno_action/activable/tail_sweep
	name = "Tail Sweep"
	action_icon_state = "tail_sweep"
	mechanics_text = "Hit all adjacent units around you, knocking them away and down."
	ability_name = "tail sweep"

/datum/action/xeno_action/activable/tail_sweep/use_ability()
	var/mob/living/carbon/Xenomorph/X = owner
	X.tail_sweep()

/datum/action/xeno_action/activable/tail_sweep/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_tail_sweep

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
			var/damage = rand(xeno_caste.melee_damage_lower,xeno_caste.melee_damage_upper) + FRENZY_DAMAGE_BONUS(src)
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

// ***************************************
// *********** Crest defense
// ***************************************
/datum/action/xeno_action/activable/toggle_crest_defense
	name = "Toggle Crest Defense"
	action_icon_state = "crest_defense"
	mechanics_text = "Increase your resistance to projectiles at the cost of move speed. Can use abilities while in Crest Defense."
	ability_name = "toggle crest defense"

/datum/action/xeno_action/activable/toggle_crest_defense/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.toggle_crest_defense()

/datum/action/xeno_action/activable/toggle_crest_defense/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_crest_defense

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

// ***************************************
// *********** Fortify
// ***************************************
/datum/action/xeno_action/activable/fortify
	name = "Fortify"
	action_icon_state = "fortify"	// TODO
	mechanics_text = "Plant yourself for a large defensive boost."
	ability_name = "fortify"

/datum/action/xeno_action/activable/fortify/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	X.fortify()

/datum/action/xeno_action/activable/fortify/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.used_fortify

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
