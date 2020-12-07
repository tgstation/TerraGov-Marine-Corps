// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 4 tiles and viciously attack your target."
	ability_name = "charge"
	cooldown_timer = 20 SECONDS
	plasma_cost = 450 //Can't ignore pain/Charge and ravage in the same timeframe, but you can combo one of them.
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

/datum/action/xeno_action/activable/charge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_NONE_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/charge/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack))
		var/obj/structure/S = target
		X.visible_message("<span class='danger'>[X] plows straight through [S]!</span>", null, null, 5)
		S.deconstruct(FALSE) //We want to continue moving, so we do not reset throwing.
		return //stay registered
	else
		target.hitby(X, speed) //This resets throwing.
	charge_complete()

/datum/action/xeno_action/activable/charge/proc/mob_hit(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	return COMPONENT_KEEP_THROWING //Ravagers plow straight through humans; we only stop on hitting a dense turf

/datum/action/xeno_action/activable/charge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/xeno_action/activable/charge/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>Our exoskeleton quivers as we get ready to use Eviscerating Charge again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_XENO_NONE_THROW_HIT, .proc/charge_complete)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)

	X.visible_message("<span class='danger'>[X] charges towards \the [A]!</span>", \
	"<span class='danger'>We charge towards \the [A]!</span>" )
	X.emote("roar") //heheh
	X.usedPounce = TRUE //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	X.throw_at(A, RAVAGER_CHARGEDISTANCE, RAVAGER_CHARGESPEED, X)

	GLOB.round_statistics.ravager_charges++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_charges")

	add_cooldown()

/datum/action/xeno_action/activable/charge/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/charge/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 4)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


// ***************************************
// *********** Ravage
// ***************************************
/datum/action/xeno_action/activable/ravage
	name = "Ravage"
	action_icon_state = "ravage"
	mechanics_text = "Attacks and knockbacks enemies in the direction you're facing."
	ability_name = "ravage"
	plasma_cost = 200
	cooldown_timer = 6 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGE

/datum/action/xeno_action/activable/ravage/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to Ravage again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message("<span class='danger'>\The [X] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>We thrash about in a murderous frenzy!</span>")

	X.face_atom(A)
	var/sweep_range = 1
	var/list/L = orange(sweep_range, X) // Not actually the fruit
	var/victims = 0
	var/target_facing
	for(var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(X, H)
		if(target_facing != X.dir && target_facing != turn(X.dir,45) && target_facing != turn(X.dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !isnestedhost(H)) //No bully
			H.attack_alien(X, X.xeno_caste.melee_damage * 0.25, FALSE, TRUE, FALSE, TRUE, INTENT_HARM)
			victims++
			step_away(H, X, sweep_range, 2)
			shake_camera(H, 2, 1)
			H.Paralyze(1 SECONDS)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_ravages++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_ravages")


/datum/action/xeno_action/activable/ravage/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/ravage/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


// ***************************************
// *********** Endure
// ***************************************
/datum/action/xeno_action/activable/endure
	name = "Endure"
	action_icon_state = "ignore_pain"
	mechanics_text = "For the next few moments you will not go into crit, but you still die."
	ability_name = "Endure"
	plasma_cost = 200
	cooldown_timer = 60 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_IGNORE_PAIN

/datum/action/xeno_action/activable/endure/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We feel able to imbue ourselves with plasma to ignore pain once again!</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/endure/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message("<span class='danger'>\The skin on the [X] begins to glow!</span>", \
	"<span class='xenowarning'>We feel the plasma flowing through our veins!</span>")

	X.endure = TRUE
	X.endure_state = 0

	X.add_filter("ravager_endure_outline", 4, list("type" = "outline", "size" = 1, "color" = COLOR_PURPLE)) //Set our cool aura; also confirmation we have the buff

	addtimer(CALLBACK(src, .proc/endure_warning), RAVAGER_ENDURE_DURATION * RAVAGER_ENDURE_WARNING) //Warn the runner when the duration is about to expire.
	addtimer(CALLBACK(src, .proc/endure_deactivate), RAVAGER_ENDURE_DURATION)

	ADD_TRAIT(X, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT) //Can now endure impacts/damages that would make lesser xenos flinch

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_endures++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_endures")


/datum/action/xeno_action/activable/endure/proc/endure_warning()

	to_chat(owner,"<span class='highdanger'>We feel the plasma draining from our veins... [ability_name] will last for only [RAVAGER_ENDURE_DURATION * (1-RAVAGER_ENDURE_WARNING) * 0.1] more seconds!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

/datum/action/xeno_action/activable/endure/proc/endure_deactivate()
	var/mob/living/carbon/xenomorph/ravager/R = owner

	R.do_jitter_animation(1000)
	R.endure = FALSE
	R.remove_filter("ravager_endure_outline")

	REMOVE_TRAIT(R, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)

	to_chat(owner,"<span class='highdanger'>The last of the plasma drains from our body... We can no longer endure beyond our normal limits!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

/datum/action/xeno_action/activable/endure/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/endure/ai_should_use(target)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > WORLD_VIEW_NUM) // If we can be seen.
		return ..()
	if(X.health > 50)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE



// ***************************************
// *********** Rage
// ***************************************
/datum/action/xeno_action/activable/rage
	name = "Rage"
	action_icon_state = "rage"
	mechanics_text = "Use while at 50% health or lower to gain extra slash damage, resistances and speed in proportion to your missing hit points. This bonus is increased and you regain plasma while your HP is negative."
	ability_name = "Rage"
	plasma_cost = 0 //We're limited by cooldowns, not plasma
	cooldown_timer = 120 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAGE
	var/rage_power

/datum/action/xeno_action/activable/rage/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We are able to enter our rage once again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/rage/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()

	if(!.)
		return

	var/mob/living/carbon/xenomorph/ravager/rager = owner

	var/rage_health_threshold = rager.maxHealth * 0.5 //Need to be at 50% of max hp or lower to rage
	if(rager.health > rage_health_threshold)
		if(!silent)
			to_chat(rager, "<span class='xenodanger'>Our health isn't low enough to rage! We must take [rager.health - rage_health_threshold] more damage!</span>")
		return FALSE


/datum/action/xeno_action/activable/rage/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	rage_power = (1-(X.health/X.maxHealth)) * 0.5 //Calculate the power of our rage; scales with difference between current and max HP

	if(X.health < 0) //Double dip on the negative HP; gain + 0.005 rage power per point of negative HP
		rage_power += X.health * -0.005

	rage_power = min(1, rage_power) //Cap rage power so that we don't get way too insane.

	var/rage_power_radius = CEILING(rage_power * 6, 1) //Define radius of the SFX

	X.visible_message("<span class='danger'>\The [X] becomes frenzied, bellowing with a shuddering roar!</span>", \
	"<span class='highdanger'>We bellow as our fury overtakes us! RIP AND TEAR!</span>")
	X.do_jitter_animation(1000)


	//Roar SFX; volume scales with rage
	playsound(X.loc, 'sound/voice/alien_roar2.ogg', clamp(100 * rage_power, 25, 80), 0)

	var/bonus_duration
	if(rage_power > 0.5) //If we're super pissed it's time to get crazy
		for(var/mob/living/witness in hearers(rage_power_radius, X)) //Roar that applies cool SFX and some soft CC

			if(!witness.hud_used)
				continue

			var/obj/screen/plane_master/floor/OT = witness.hud_used.plane_masters["[FLOOR_PLANE]"]
			var/obj/screen/plane_master/game_world/GW = witness.hud_used.plane_masters["[GAME_PLANE]"]

			addtimer(CALLBACK(OT, /atom.proc/remove_filter, "rage_outcry"), 1 SECONDS)
			GW.add_filter("rage_outcry", 2, list("type" = "radial_blur", "size" = 0.07))
			animate(GW.get_filter("rage_outcry"), size = 0.12, time = 5, loop = -1)
			OT.add_filter("rage_outcry", 2, list("type" = "radial_blur", "size" = 0.07))
			animate(OT.get_filter("rage_outcry"), size = 0.12, time = 5, loop = -1)
			addtimer(CALLBACK(GW, /atom.proc/remove_filter, "rage_outcry"), 1 SECONDS)

	for(var/turf/affected_tiles as() in RANGE_TURFS(rage_power_radius, X.loc))
		affected_tiles.Shake(4, 4, 1 SECONDS) //SFX

	for(var/mob/living/L in hearers(rage_power_radius, X)) //Roar that applies cool SFX and some soft CC
		shake_camera(L, 1 SECONDS, 1)
		L.Shake(4, 4, 1 SECONDS) //SFX

		if(L.stat == DEAD) //We don't care about the dead
			continue

		if(isxeno(L))
			var/mob/living/carbon/xenomorph/friendly_check = L
			if(friendly_check.issamexenohive(X)) //No friendly fire
				continue

		L.adjust_stagger(rage_power_radius * 0.5) //Apply soft CC debuffs
		L.add_slowdown(rage_power_radius * 0.5)
		to_chat(L, "<span class='xenohighdanger'>The [X]'s terrible roar penetrates your senses, leaving you staggered.</span>")

	X.add_filter("ravager_rage_outline", 5, list("type" = "outline", "size" = 1.5, "color" = COLOR_RED)) //Set our cool aura; also confirmation we have the buff

	X.plasma_stored += X.xeno_caste.plasma_max * rage_power //Regain a % of our maximum plasma scaling with rage

	X.soft_armor = X.soft_armor.modifyAllRatings(CEILING(rage_power * 40,1)) //Set rage armor bonus
	switch(rage_power) //Set rage explosive resist bonus
		if(0.25 to 0.50)
			X.soft_armor = X.soft_armor.setRating(bomb = XENO_BOMB_RESIST_2)
		if(0.5 to INFINITY)
			X.soft_armor = X.soft_armor.setRating(bomb = XENO_BOMB_RESIST_3)

	X.xeno_melee_damage_modifier += rage_power  //Set rage melee damage bonus

	X.add_movespeed_modifier(MOVESPEED_ID_RAVAGER_RAGE, TRUE, 0, NONE, TRUE, X.xeno_caste.speed * 0.5 * rage_power) //Set rage speed bonus

	//Too angry to be stunned/slowed/staggered/knocked down
	ADD_TRAIT(X, TRAIT_STUNIMMUNE, RAGE_TRAIT)
	ADD_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, RAGE_TRAIT)
	ADD_TRAIT(X, TRAIT_STAGGERIMMUNE, RAGE_TRAIT)

	addtimer(CALLBACK(src, .proc/rage_warning, bonus_duration), (RAVAGER_RAGE_DURATION + bonus_duration) * RAVAGER_RAGE_WARNING) //Warn the ravager when rage is about to expire.
	addtimer(CALLBACK(src, .proc/rage_deactivate), (RAVAGER_RAGE_DURATION + bonus_duration) )

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_rages++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_rages")


/datum/action/xeno_action/activable/rage/proc/rage_warning(bonus_duration = 0)

	to_chat(owner,"<span class='highdanger'>Our rage begins to subside... [ability_name] will only last for only [(RAVAGER_RAGE_DURATION + bonus_duration) * (1-RAVAGER_RAGE_WARNING) * 0.1] more seconds!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)


/datum/action/xeno_action/activable/rage/proc/rage_deactivate()

	var/mob/living/carbon/xenomorph/ravager/R = owner

	R.do_jitter_animation(1000)

	R.remove_filter("ravager_rage_outline")
	R.visible_message("<span class='warning'>[R] seems to calm down.</span>", \
	"<span class='highdanger'>Our rage subsides and its power leaves our body.</span>")

	R.soft_armor = R.soft_armor.modifyAllRatings(-CEILING(rage_power * 40,1)) //Reset rage armor bonus
	R.soft_armor = R.soft_armor.setRating(bomb = XENO_BOMB_RESIST_1) //Reset blast resistance
	R.xeno_melee_damage_modifier -= rage_power //Reset rage melee damage bonus
	R.remove_movespeed_modifier(MOVESPEED_ID_RAVAGER_RAGE) //Reset speed

	REMOVE_TRAIT(R, TRAIT_STUNIMMUNE, RAGE_TRAIT)
	REMOVE_TRAIT(R, TRAIT_SLOWDOWNIMMUNE, RAGE_TRAIT)
	REMOVE_TRAIT(R, TRAIT_STAGGERIMMUNE, RAGE_TRAIT)

	R.playsound_local(R, 'sound/voice/hiss5.ogg', 50) //Audio cue
