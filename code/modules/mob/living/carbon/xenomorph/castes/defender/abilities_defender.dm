// ***************************************
// *********** Headbutt
// ***************************************
/datum/action/xeno_action/activable/headbutt
	name = "Headbutt"
	action_icon_state = "headbutt"
	mechanics_text = "Charge a target up to 2 tiles away, knocking them away and down and disarming them."
	ability_name = "headbutt"
	plasma_cost = DEFENDER_HEADBUTT_COST
	use_state_flags = XACT_USE_CRESTED
	cooldown_timer = DEFENDER_HEADBUTT_COOLDOWN

/datum/action/xeno_action/activable/headbutt/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(A))
		return FALSE
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD || (istype(H.buckled, /obj/structure/bed/nest) && CHECK_BITFIELD(H.status_flags, XENO_HOST)) )
		return FALSE
	var/mob/living/carbon/Xenomorph/Defender/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>You don't have enough plasma, you need [(plasma_cost * 2) - X.plasma_stored] more plasma!</span>")
		return FALSE
	if(get_dist(X, H) > 2)
		if(!silent && world.time > (X.recent_notice + X.notice_delay)) //anti-notice spam
			to_chat(X, "<span class='xenowarning'>Your target is too far away!</span>")
			X.recent_notice = world.time //anti-notice spam
		return FALSE

/datum/action/xeno_action/activable/headbutt/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>You gather enough strength to headbutt again.</span>")
	return ..()

/datum/action/xeno_action/activable/headbutt/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner

	var/mob/living/carbon/human/H = A

	var/distance = get_dist(X, H)

	if (distance > 1)
		step_towards(X, H, 1)

	if (!X.Adjacent(H))
		return fail_activate()

	round_statistics.defender_headbutts++

	X.visible_message("<span class='xenowarning'>\The [X] rams [H] with it's armored crest!</span>", \
	"<span class='xenowarning'>You ram [H] with your armored crest!</span>")

	succeed_activate()
	if(X.crest_defense)
		X.use_plasma(plasma_cost)
	add_cooldown()

	X.face_atom(H) //Face towards the target so we don't look silly

	var/damage = rand(X.xeno_caste.melee_damage_lower,X.xeno_caste.melee_damage_upper) + FRENZY_DAMAGE_BONUS(X)
	damage *= (1 + distance * 0.25) //More distance = more momentum = stronger Headbutt.
	var/affecting = H.get_limb(ran_zone(null, 0))
	if(!affecting) //Still nothing??
		affecting = H.get_limb("chest") //Gotta have a torso?!
	var/armor_block = H.run_armor_check(affecting, "melee")
	H.apply_damage(damage, BRUTE, affecting, armor_block) //We deal crap brute damage after armor...
	H.apply_damage(damage, HALLOSS) //...But some sweet armour ignoring Halloss
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
	H.KnockDown(1, 1)
	playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)

// ***************************************
// *********** Tail sweep
// ***************************************
/datum/action/xeno_action/activable/tail_sweep
	name = "Tail Sweep"
	action_icon_state = "tail_sweep"
	mechanics_text = "Hit all adjacent units around you, knocking them away and down."
	ability_name = "tail sweep"
	plasma_cost = DEFENDER_TAILSWIPE_COST
	use_state_flags = XACT_USE_CRESTED
	cooldown_timer = DEFENDER_TAILSWIPE_COOLDOWN

/datum/action/xeno_action/activable/tail_sweep/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/Xenomorph/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>You don't have enough plasma, you need [(plasma_cost * 2) - X.plasma_stored] more plasma!</span>")
		return FALSE

/datum/action/xeno_action/activable/tail_sweep/on_cooldown_finish()
	to_chat(src, "<span class='notice'>You gather enough strength to tail sweep again.</span>")
	return ..()

/datum/action/xeno_action/activable/tail_sweep/use_ability()
	var/mob/living/carbon/Xenomorph/X = owner

	round_statistics.defender_tail_sweeps++
	X.visible_message("<span class='xenowarning'>\The [X] sweeps it's tail in a wide circle!</span>", \
	"<span class='xenowarning'>You sweep your tail in a wide circle!</span>")

	X.spin(4, 1)

	var/sweep_range = 1
	var/list/L = orange(sweep_range, X)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		if(H.stat != DEAD && !(istype(H.buckled, /obj/structure/bed/nest) && CHECK_BITFIELD(H.status_flags, XENO_HOST)) ) //No bully
			var/damage = rand(X.xeno_caste.melee_damage_lower,X.xeno_caste.melee_damage_upper) + FRENZY_DAMAGE_BONUS(X)
			var/affecting = H.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			var/armor_block = H.run_armor_check(affecting, "melee")
			H.apply_damage(damage, BRUTE, affecting, armor_block) //Crap base damage after armour...
			H.apply_damage(damage, HALLOSS) //...But some sweet armour ignoring Halloss
			H.KnockDown(1, 1)
		round_statistics.defender_tail_sweep_hits++
		shake_camera(H, 2, 1)

		to_chat(H, "<span class='xenowarning'>You are struck by \the [X]'s tail sweep!</span>")
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)

	succeed_activate()
	if(X.crest_defense)
		X.use_plasma(plasma_cost)
	add_cooldown()

// ***************************************
// *********** Crest defense
// ***************************************
/datum/action/xeno_action/activable/toggle_crest_defense
	name = "Toggle Crest Defense"
	action_icon_state = "crest_defense"
	mechanics_text = "Increase your resistance to projectiles at the cost of move speed. Can use abilities while in Crest Defense."
	ability_name = "toggle crest defense"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED // duh
	cooldown_timer = DEFENDER_CREST_DEFENSE_COOLDOWN

/datum/action/xeno_action/activable/toggle_crest_defense/on_cooldown_finish()
	var/mob/living/carbon/Xenomorph/Defender/X = owner
	to_chat(X, "<span class='notice'>You can [X.crest_defense ? "raise" : "lower"] your crest.</span>")
	return ..()

/datum/action/xeno_action/activable/toggle_crest_defense/action_activate()
	var/mob/living/carbon/Xenomorph/Defender/X = owner

	if(X.crest_defense)
		X.set_crest_defense(FALSE)
		add_cooldown()
		return succeed_activate()

	var/was_fortified = X.fortify
	if(X.fortify)
		var/datum/action/xeno_action/FT = X.actions_by_path[/datum/action/xeno_action/activable/fortify]
		if(FT.on_cooldown)
			to_chat(src, "<span class='xenowarning'>You cannot yet untuck yourself!</span>")
			return fail_activate()
		X.set_fortify(FALSE, TRUE)
		FT.add_cooldown()
		to_chat(X, "<span class='xenowarning'>You carefully untuck, keeping your crest lowered.</span>")

	X.set_crest_defense(TRUE, was_fortified)
	add_cooldown()
	return succeed_activate()

/mob/living/carbon/Xenomorph/Defender/proc/set_crest_defense(on, silent = FALSE)
	crest_defense = on
	if(on)
		if(!silent)
			to_chat(src, "<span class='xenowarning'>You tuck yourself into a defensive stance.</span>")
		round_statistics.defender_crest_lowerings++
		xeno_explosion_resistance = 2
		armor_bonus += xeno_caste.crest_defense_armor
		speed_modifier += DEFENDER_CRESTDEFENSE_SLOWDOWN
	else
		if(!silent)
			to_chat(src, "<span class='xenowarning'>You raise your crest.</span>")
		round_statistics.defender_crest_raises++
		xeno_explosion_resistance = 0
		armor_bonus -= xeno_caste.crest_defense_armor
		speed_modifier -= DEFENDER_CRESTDEFENSE_SLOWDOWN
	update_icons()

// ***************************************
// *********** Fortify
// ***************************************
/datum/action/xeno_action/activable/fortify
	name = "Fortify"
	action_icon_state = "fortify"	// TODO
	mechanics_text = "Plant yourself for a large defensive boost."
	ability_name = "fortify"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED // duh
	cooldown_timer = DEFENDER_FORTIFY_COOLDOWN

/datum/action/xeno_action/activable/fortify/on_cooldown_finish()
	var/mob/living/carbon/Xenomorph/X = owner
	to_chat(X, "<span class='notice'>You can [X.fortify ? "stand up" : "fortify"] again.</span>")
	return ..()

/datum/action/xeno_action/activable/fortify/action_activate()
	var/mob/living/carbon/Xenomorph/Defender/X = owner

	if(X.fortify)
		X.set_fortify(FALSE)
		add_cooldown()
		return succeed_activate()

	var/was_crested = X.crest_defense
	if(X.crest_defense)
		var/datum/action/xeno_action/CD = X.actions_by_path[/datum/action/xeno_action/activable/toggle_crest_defense]
		if(CD.on_cooldown)
			to_chat(X, "<span class='xenowarning'>You cannot yet transition to a defensive stance!</span>")
			return fail_activate()
		X.set_crest_defense(FALSE, TRUE)
		CD.add_cooldown()
		to_chat(X, "<span class='xenowarning'>You tuck your lowered crest into yourself.</span>")
	
	X.set_fortify(TRUE, was_crested)
	add_cooldown()
	return succeed_activate()

/mob/living/carbon/Xenomorph/Defender/proc/set_fortify(on, silent = FALSE)
	round_statistics.defender_fortifiy_toggles++
	if(on)
		if(!silent)
			to_chat(src, "<span class='xenowarning'>You tuck yourself into a defensive stance.</span>")
		armor_bonus += xeno_caste.fortify_armor
		xeno_explosion_resistance = 3
	else
		if(!silent)
			to_chat(src, "<span class='xenowarning'>You resume your normal stance.</span>")
		armor_bonus -= xeno_caste.fortify_armor
		xeno_explosion_resistance = 0
	fortify = on
	set_frozen(on)
	anchored = on
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 30, 1)
	update_canmove()
	update_icons()
