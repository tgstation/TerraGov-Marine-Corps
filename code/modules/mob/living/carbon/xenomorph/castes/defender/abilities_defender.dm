// ***************************************
// *********** Headbutt
// ***************************************
/datum/action/xeno_action/activable/headbutt
	name = "Headbutt"
	action_icon_state = "headbutt"
	mechanics_text = "Charge a target up to 2 tiles away, knocking them away and down and disarming them."
	ability_name = "headbutt"
	plasma_cost = 25
	use_state_flags = XACT_USE_CRESTED
	cooldown_timer = 6 SECONDS
	keybind_signal = COMSIG_XENOABILITY_HEADBUTT

/datum/action/xeno_action/activable/headbutt/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(A))
		return FALSE
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD || isnestedhost(H) )
		return FALSE
	var/mob/living/carbon/xenomorph/defender/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>We don't have enough plasma, we need [(plasma_cost * 2) - X.plasma_stored] more plasma!</span>")
		return FALSE
	if(get_dist(X, H) > 2)
		if(!silent && world.time > (X.recent_notice + X.notice_delay)) //anti-notice spam
			to_chat(X, "<span class='xenowarning'>Our target is too far away!</span>")
			X.recent_notice = world.time //anti-notice spam
		return FALSE

/datum/action/xeno_action/activable/headbutt/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>We gather enough strength to headbutt again.</span>")
	return ..()

/datum/action/xeno_action/activable/headbutt/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	var/mob/living/carbon/human/H = A

	var/distance = get_dist(X, H)

	if(X.cadecheck())
		return fail_activate()

	if (distance > 1)
		step_towards(X, H, 1)

	if (!X.Adjacent(H))
		return fail_activate()

	GLOB.round_statistics.defender_headbutts++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_headbutts")

	X.visible_message("<span class='xenowarning'>\The [X] rams [H] with its armored crest!</span>", \
	"<span class='xenowarning'>We ram [H] with our armored crest!</span>")

	succeed_activate()
	if(X.crest_defense)
		X.use_plasma(plasma_cost)
	add_cooldown()

	X.face_atom(H) //Face towards the target so we don't look silly

	var/damage = X.xeno_caste.melee_damage
	damage *= (1 + distance * 0.25) //More distance = more momentum = stronger Headbutt.
	var/affecting = H.get_limb(ran_zone(null, 0))
	if(!affecting) //Still nothing??
		affecting = H.get_limb("chest") //Gotta have a torso?!
	var/armor_block = H.run_armor_check(affecting, "melee")
	H.apply_damage(damage, BRUTE, affecting, armor_block) //We deal crap brute damage after armor...
	H.apply_damage(damage, STAMINA) //...But some sweet armour ignoring Stamina
	UPDATEHEALTH(H)
	shake_camera(H, 2, 1)

	var/facing = get_dir(X, H)
	var/headbutt_distance = 3
	var/turf/T = X.loc
	var/turf/temp = X.loc

	for (var/x in 1 to headbutt_distance)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	H.throw_at(T, headbutt_distance, 1, src)
	H.Paralyze(20)
	playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)

// ***************************************
// *********** Tail sweep
// ***************************************
/datum/action/xeno_action/activable/tail_sweep
	name = "Tail Sweep"
	action_icon_state = "tail_sweep"
	mechanics_text = "Hit all adjacent units around you, knocking them away and down."
	ability_name = "tail sweep"
	plasma_cost = 35
	use_state_flags = XACT_USE_CRESTED
	cooldown_timer = 12 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_TAIL_SWEEP

/datum/action/xeno_action/activable/tail_sweep/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>We don't have enough plasma, we need [(plasma_cost * 2) - X.plasma_stored] more plasma!</span>")
		return FALSE

/datum/action/xeno_action/activable/tail_sweep/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We gather enough strength to tail sweep again.</span>")
	return ..()

/datum/action/xeno_action/activable/tail_sweep/use_ability()
	var/mob/living/carbon/xenomorph/X = owner

	GLOB.round_statistics.defender_tail_sweeps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_tail_sweeps")
	X.visible_message("<span class='xenowarning'>\The [X] sweeps its tail in a wide circle!</span>", \
	"<span class='xenowarning'>We sweep our tail in a wide circle!</span>")

	X.spin(4, 1)

	var/sweep_range = 1
	var/list/L = orange(sweep_range, X)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		if(H.stat != DEAD && !isnestedhost(H) ) //No bully
			var/damage = X.xeno_caste.melee_damage
			var/affecting = H.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			var/armor_block = H.run_armor_check(affecting, "melee")
			H.apply_damage(damage, BRUTE, affecting, armor_block) //Crap base damage after armour...
			H.apply_damage(damage, STAMINA) //...But some sweet armour ignoring Stamina
			UPDATEHEALTH(H)
			H.Paralyze(20)
		GLOB.round_statistics.defender_tail_sweep_hits++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_tail_sweep_hits")
		shake_camera(H, 2, 1)

		to_chat(H, "<span class='xenowarning'>We are struck by \the [X]'s tail sweep!</span>")
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)

	succeed_activate()
	if(X.crest_defense)
		X.use_plasma(plasma_cost)
	add_cooldown()

/datum/action/xeno_action/activable/tail_sweep/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/tail_sweep/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

// ***************************************
// *********** Forward Charge
// ***************************************
/datum/action/xeno_action/activable/forward_charge
	name = "Forward Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 4 tiles and knockdown any targets in our way."
	ability_name = "charge"
	cooldown_timer = 15 SECONDS
	plasma_cost = 80
	use_state_flags = XACT_USE_CRESTED
	keybind_signal = COMSIG_XENOABILITY_FORWARD_CHARGE

/datum/action/xeno_action/activable/forward_charge/proc/charge_complete()
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT, COMSIG_XENO_NONE_THROW_HIT))

/datum/action/xeno_action/activable/forward_charge/proc/mob_hit(datum/source, mob/M)
	if(M.stat || isxeno(M))
		return
	return COMPONENT_KEEP_THROWING

/datum/action/xeno_action/activable/forward_charge/proc/obj_hit(datum/source, obj/target, speed)
	var/mob/living/carbon/xenomorph/X = owner
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack))
		var/obj/structure/S = target
		X.visible_message("<span class='danger'>[X] plows straight through [S]!</span>", null, null, 5)
		S.deconstruct(FALSE) //We want to continue moving, so we do not reset throwing.
		return // stay registered
	else
		target.hitby(X, speed) //This resets throwing.
	charge_complete()

/datum/action/xeno_action/activable/forward_charge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/xeno_action/activable/forward_charge/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>Our exoskeleton quivers as we get ready to use Forward Charge again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/forward_charge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(X, COMSIG_XENO_NONE_THROW_HIT, .proc/charge_complete)

	if(!do_after(X, 0.5 SECONDS, FALSE, X, BUSY_ICON_GENERIC, extra_checks = CALLBACK(src, .proc/can_use_ability, A, FALSE, XACT_USE_BUSY)))
		return fail_activate()

	X.visible_message("<span class='danger'>[X] charges towards \the [A]!</span>", \
	"<span class='danger'>We charge towards \the [A]!</span>" )
	X.emote("roar")
	succeed_activate()

	X.throw_at(A, 4, 70, X)

	add_cooldown()

// ***************************************
// *********** Crest defense
// ***************************************
/datum/action/xeno_action/toggle_crest_defense
	name = "Toggle Crest Defense"
	action_icon_state = "crest_defense"
	mechanics_text = "Increase your resistance to projectiles at the cost of move speed. Can use abilities while in Crest Defense."
	ability_name = "toggle crest defense"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED // duh
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_CREST_DEFENSE

/datum/action/xeno_action/toggle_crest_defense/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/defender/X = owner
	to_chat(X, "<span class='notice'>We can [X.crest_defense ? "raise" : "lower"] our crest.</span>")
	return ..()

/datum/action/xeno_action/toggle_crest_defense/action_activate()
	var/mob/living/carbon/xenomorph/defender/X = owner

	if(X.crest_defense)
		X.set_crest_defense(FALSE)
		add_cooldown()
		return succeed_activate()

	var/was_fortified = X.fortify
	if(X.fortify)
		var/datum/action/xeno_action/FT = X.actions_by_path[/datum/action/xeno_action/fortify]
		if(FT.cooldown_id)
			to_chat(X, "<span class='xenowarning'>We cannot yet untuck ourselves!</span>")
			return fail_activate()
		X.set_fortify(FALSE, TRUE)
		FT.add_cooldown()
		to_chat(X, "<span class='xenowarning'>We carefully untuck, keeping our crest lowered.</span>")

	X.set_crest_defense(TRUE, was_fortified)
	add_cooldown()
	return succeed_activate()

/mob/living/carbon/xenomorph/defender/proc/set_crest_defense(on, silent = FALSE)
	crest_defense = on
	if(on)
		if(!silent)
			to_chat(src, "<span class='xenowarning'>We tuck ourselves into a defensive stance.</span>")
		GLOB.round_statistics.defender_crest_lowerings++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_crest_lowerings")
		soft_armor = soft_armor.setRating(bomb = XENO_BOMB_RESIST_2)
		armor_bonus += xeno_caste.crest_defense_armor
		add_movespeed_modifier(MOVESPEED_ID_CRESTDEFENSE, TRUE, 0, NONE, TRUE, DEFENDER_CRESTDEFENSE_SLOWDOWN)
	else
		if(!silent)
			to_chat(src, "<span class='xenowarning'>We raise our crest.</span>")
		GLOB.round_statistics.defender_crest_raises++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_crest_raises")
		soft_armor = soft_armor.setRating(bomb = XENO_BOMB_RESIST_0)
		armor_bonus -= xeno_caste.crest_defense_armor
		remove_movespeed_modifier(MOVESPEED_ID_CRESTDEFENSE)
	update_icons()

// ***************************************
// *********** Fortify
// ***************************************
/datum/action/xeno_action/fortify
	name = "Fortify"
	action_icon_state = "fortify"	// TODO
	mechanics_text = "Plant yourself for a large defensive boost."
	ability_name = "fortify"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED // duh
	cooldown_timer = 1 SECONDS
	keybind_signal = COMSIG_XENOABILITY_FORTIFY

/datum/action/xeno_action/fortify/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We can [X.fortify ? "stand up" : "fortify"] again.</span>")
	return ..()

/datum/action/xeno_action/fortify/action_activate()
	var/mob/living/carbon/xenomorph/defender/X = owner

	if(X.fortify)
		X.set_fortify(FALSE)
		add_cooldown()
		return succeed_activate()

	var/was_crested = X.crest_defense
	if(X.crest_defense)
		var/datum/action/xeno_action/CD = X.actions_by_path[/datum/action/xeno_action/toggle_crest_defense]
		if(CD.cooldown_id)
			to_chat(X, "<span class='xenowarning'>We cannot yet transition to a defensive stance!</span>")
			return fail_activate()
		X.set_crest_defense(FALSE, TRUE)
		CD.add_cooldown()
		to_chat(X, "<span class='xenowarning'>We tuck our lowered crest into ourselves.</span>")

	X.set_fortify(TRUE, was_crested)
	add_cooldown()
	return succeed_activate()

/mob/living/carbon/xenomorph/defender/proc/set_fortify(on, silent = FALSE)
	GLOB.round_statistics.defender_fortifiy_toggles++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_fortifiy_toggles")
	if(on)
		ADD_TRAIT(src, TRAIT_IMMOBILE, FORTIFY_TRAIT)
		if(!silent)
			to_chat(src, "<span class='xenowarning'>We tuck ourselves into a defensive stance.</span>")
		armor_bonus += xeno_caste.fortify_armor
		soft_armor = soft_armor.setRating(bomb = XENO_BOMB_RESIST_3)
	else
		if(!silent)
			to_chat(src, "<span class='xenowarning'>We resume our normal stance.</span>")
		armor_bonus -= xeno_caste.fortify_armor
		soft_armor = soft_armor.setRating(bomb = XENO_BOMB_RESIST_0)
		REMOVE_TRAIT(src, TRAIT_IMMOBILE, FORTIFY_TRAIT)
	fortify = on
	anchored = on
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)
	update_icons()
