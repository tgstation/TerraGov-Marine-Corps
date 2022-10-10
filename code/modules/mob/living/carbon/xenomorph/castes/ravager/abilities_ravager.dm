// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 4 tiles and viciously attack your target."
	ability_name = "charge"
	cooldown_timer = 20 SECONDS
	plasma_cost = 500 //Can't ignore pain/Charge and ravage in the same timeframe, but you can combo one of them.
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RAVAGER_CHARGE,
	)

/datum/action/xeno_action/activable/charge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/charge/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack))
		var/obj/structure/S = target
		X.visible_message(span_danger("[X] plows straight through [S]!"), null, null, 5)
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
	to_chat(owner, span_xenodanger("Our exoskeleton quivers as we get ready to use Eviscerating Charge again."))
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, .proc/charge_complete)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)

	X.visible_message(span_danger("[X] charges towards \the [A]!"), \
	span_danger("We charge towards \the [A]!") )
	X.emote("roar") //heheh
	X.usedPounce = TRUE //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	X.throw_at(A, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, X)

	add_cooldown()

/datum/action/xeno_action/activable/charge/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/charge/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 4))
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


// ***************************************
// *********** Ravage
// ***************************************
/datum/action/xeno_action/activable/ravage
	name = "Ravage"
	action_icon_state = "ravage"
	mechanics_text = "Attacks and knockbacks enemies in the direction your facing."
	ability_name = "ravage"
	plasma_cost = 200
	cooldown_timer = 6 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RAVAGE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_RAVAGE_SELECT,
	)

/datum/action/xeno_action/activable/ravage/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We gather enough strength to Ravage again."))
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message(span_danger("\The [X] thrashes about in a murderous frenzy!"), \
	span_xenowarning("We thrash about in a murderous frenzy!"))

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
			H.attack_alien_harm(X, X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier * 0.25, FALSE, TRUE, FALSE, TRUE)
			victims++
			step_away(H, X, sweep_range, 2)
			shake_camera(H, 2, 1)
			H.Paralyze(1 SECONDS)

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/activable/ravage/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/ravage/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE


// ***************************************
// *********** Endure
// ***************************************
/datum/action/xeno_action/endure
	name = "Endure"
	action_icon_state = "ignore_pain"
	mechanics_text = "For the next few moments you will not go into crit and become resistant to explosives and immune to stagger and slowdown, but you still die if you take damage exceeding your crit health."
	ability_name = "Endure"
	plasma_cost = 200
	cooldown_timer = 60 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ENDURE,
	)
	use_state_flags = XACT_USE_STAGGERED //Can use this while staggered
	///How low the Ravager's health can go while under the effects of Endure before it dies
	var/endure_threshold = RAVAGER_ENDURE_HP_LIMIT
	///Timer for Endure's duration
	var/endure_duration
	///Timer for Endure's warning
	var/endure_warning_duration

/datum/action/xeno_action/endure/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We feel able to imbue ourselves with plasma to Endure once again!"))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/endure/action_activate()
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message(span_danger("\The skin on the [X] begins to glow!"), \
	span_xenowarning("We feel the plasma coursing through our veins!"))

	X.endure = TRUE

	X.add_filter("ravager_endure_outline", 4, outline_filter(1, COLOR_PURPLE)) //Set our cool aura; also confirmation we have the buff

	endure_duration = addtimer(CALLBACK(src, .proc/endure_warning), RAVAGER_ENDURE_DURATION * RAVAGER_ENDURE_DURATION_WARNING, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE) //Warn the ravager when the duration is about to expire.
	endure_warning_duration = addtimer(CALLBACK(src, .proc/endure_deactivate), RAVAGER_ENDURE_DURATION, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE)

	X.stagger = 0 //Remove stagger
	X.set_slowdown(0) //Remove slowdown
	X.soft_armor = X.soft_armor.modifyRating(bomb = 20) //Improved explosion resistance
	ADD_TRAIT(X, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT) //Can now endure impacts/damages that would make lesser xenos flinch
	ADD_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, ENDURE_TRAIT) //Can now endure slowdown

	RegisterSignal(X, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/damage_taken) //Warns us if our health is critically low

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_endures++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_endures")

///Warns the player when Endure is about to end
/datum/action/xeno_action/endure/proc/endure_warning()
	to_chat(owner,span_highdanger("We feel the plasma draining from our veins... [ability_name] will last for only [timeleft(endure_duration) * 0.1] more seconds!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Turns off the Endure buff
/datum/action/xeno_action/endure/proc/endure_deactivate()
	var/mob/living/carbon/xenomorph/X = owner

	UnregisterSignal(X, COMSIG_XENOMORPH_TAKING_DAMAGE)

	X.do_jitter_animation(1000)
	X.endure = FALSE
	X.remove_filter("ravager_endure_outline")
	if(X.health < X.get_crit_threshold()) //If we have less health than our death threshold, but more than our Endure death threshold, set our HP to just a hair above insta dying
		var/total_damage = X.getFireLoss() + X.getBruteLoss()
		var/burn_percentile_damage = X.getFireLoss() / total_damage
		var/brute_percentile_damage = X.getBruteLoss() / total_damage
		X.setBruteLoss((X.xeno_caste.max_health - X.get_crit_threshold()-1) * brute_percentile_damage)
		X.setFireLoss((X.xeno_caste.max_health - X.get_crit_threshold()-1) * burn_percentile_damage)

	X.soft_armor = X.soft_armor.modifyRating(bomb = -20) //Remove resistances/immunities
	REMOVE_TRAIT(X, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)
	REMOVE_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, ENDURE_TRAIT)
	endure_threshold = initial(endure_threshold) //Reset the endure vars to their initial states
	endure_duration = initial(endure_duration)
	endure_warning_duration = initial(endure_warning_duration)

	to_chat(owner,span_highdanger("The last of the plasma drains from our body... We can no longer endure beyond our normal limits!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Warns us when our health is critically low and tells us exactly how much more punishment we can take
/datum/action/xeno_action/endure/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	SIGNAL_HANDLER
	if(X.health < 0)
		to_chat(X, "<span class='xenohighdanger' style='color: red;'>We are critically wounded! We can only withstand [(RAVAGER_ENDURE_HP_LIMIT-X.health) * -1] more damage before we perish!</span>")


/datum/action/xeno_action/endure/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/endure/ai_should_use(target)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > WORLD_VIEW_NUM) // If we can be seen.
		return FALSE
	if(X.health > 50)
		return FALSE
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	return TRUE

// ***************************************
// *********** Rage
// ***************************************
/datum/action/xeno_action/rage
	name = "Rage"
	action_icon_state = "rage"
	mechanics_text = "Use while at 50% health or lower to gain extra slash damage, resistances and speed in proportion to your missing hit points. This bonus is increased and you regain plasma while your HP is negative."
	ability_name = "Rage"
	plasma_cost = 0 //We're limited by cooldowns, not plasma
	cooldown_timer = 60 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_RAGE,
	)
	///Determines the power of Rage's many effects. Power scales inversely with the Ravager's HP; min 0.25 at 50% of Max HP, max 1 while in negative HP. 0.5 and above triggers especial effects.
	var/rage_power
	///Determines the Sunder to impose when Rage ends
	var/rage_sunder
	///Determines the Plasma to remove when Rage ends
	var/rage_plasma

/datum/action/xeno_action/rage/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to enter our rage once again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/rage/can_use_action(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/rager = owner

	if(rager.health > rager.maxHealth * RAVAGER_RAGE_MIN_HEALTH_THRESHOLD) //Need to be at 50% of max hp or lower to rage
		if(!silent)
			to_chat(rager, span_xenodanger("Our health isn't low enough to rage! We must take [rager.health - (rager.maxHealth * RAVAGER_RAGE_MIN_HEALTH_THRESHOLD)] more damage!"))
		return FALSE


/datum/action/xeno_action/rage/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	rage_power = (1-(X.health/X.maxHealth)) * RAVAGER_RAGE_POWER_MULTIPLIER //Calculate the power of our rage; scales with difference between current and max HP

	if(X.health < 0) //If we're at less than 0 HP, it's time to max rage.
		rage_power = 0.5

	var/rage_power_radius = CEILING(rage_power * 7, 1) //Define radius of the SFX

	X.visible_message(span_danger("\The [X] becomes frenzied, bellowing with a shuddering roar!"), \
	span_highdanger("We bellow as our fury overtakes us! RIP AND TEAR!"))
	X.do_jitter_animation(1000)


	//Roar SFX; volume scales with rage
	playsound(X.loc, 'sound/voice/alien_roar2.ogg', clamp(100 * rage_power, 25, 80), 0)

	var/bonus_duration
	if(rage_power >= RAVAGER_RAGE_SUPER_RAGE_THRESHOLD) //If we're super pissed it's time to get crazy
		var/datum/action/xeno_action/charge = X.actions_by_path[/datum/action/xeno_action/activable/charge]
		var/datum/action/xeno_action/ravage = X.actions_by_path[/datum/action/xeno_action/activable/ravage]
		var/datum/action/xeno_action/endure/endure_ability = X.actions_by_path[/datum/action/xeno_action/endure]

		if(endure_ability.endure_duration) //Check if Endure is active
			endure_ability.endure_threshold = RAVAGER_ENDURE_HP_LIMIT * (1 + rage_power) //Endure crit threshold scales with Rage Power; min -100, max -150

		if(charge)
			charge.clear_cooldown() //Reset charge cooldown
		if(ravage)
			ravage.clear_cooldown() //Reset ravage cooldown
		RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/drain_slash)

	for(var/turf/affected_tiles AS in RANGE_TURFS(rage_power_radius, X.loc))
		affected_tiles.Shake(4, 4, 1 SECONDS) //SFX

	for(var/mob/living/L AS in GLOB.mob_living_list) //Roar that applies cool SFX
		if(L.stat == DEAD || !L.hud_used || (get_dist(L, X) > rage_power_radius)) //We don't care about the dead
			continue

		shake_camera(L, 1 SECONDS, 1)
		L.Shake(4, 4, 1 SECONDS) //SFX

		if(rage_power >= RAVAGER_RAGE_SUPER_RAGE_THRESHOLD) //If we're super pissed it's time to get crazy

			var/obj/screen/plane_master/floor/OT = L.hud_used.plane_masters["[FLOOR_PLANE]"]
			var/obj/screen/plane_master/game_world/GW = L.hud_used.plane_masters["[GAME_PLANE]"]

			addtimer(CALLBACK(OT, /atom.proc/remove_filter, "rage_outcry"), 1 SECONDS)
			GW.add_filter("rage_outcry", 2, radial_blur_filter(0.07))
			animate(GW.get_filter("rage_outcry"), size = 0.12, time = 5, loop = -1)
			OT.add_filter("rage_outcry", 2, radial_blur_filter(0.07))
			animate(OT.get_filter("rage_outcry"), size = 0.12, time = 5, loop = -1)
			addtimer(CALLBACK(GW, /atom.proc/remove_filter, "rage_outcry"), 1 SECONDS)

	X.add_filter("ravager_rage_outline", 5, outline_filter(1.5, COLOR_RED)) //Set our cool aura; also confirmation we have the buff

	rage_plasma = min(X.xeno_caste.plasma_max - X.plasma_stored, X.xeno_caste.plasma_max * rage_power) //Calculate the plasma to restore (and take away later)
	X.plasma_stored += rage_plasma //Regain a % of our maximum plasma scaling with rage

	rage_sunder = min(X.sunder, rage_power * 100) //Set our temporary Sunder recovery
	X.adjust_sunder(-1 * rage_sunder) //Restores up to 50 Sunder temporarily.

	X.xeno_melee_damage_modifier += rage_power  //Set rage melee damage bonus

	X.add_movespeed_modifier(MOVESPEED_ID_RAVAGER_RAGE, TRUE, 0, NONE, TRUE, X.xeno_caste.speed * 0.5 * rage_power) //Set rage speed bonus

	//Too angry to be stunned/slowed/staggered/knocked down
	ADD_TRAIT(X, TRAIT_STUNIMMUNE, RAGE_TRAIT)
	ADD_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, RAGE_TRAIT)
	ADD_TRAIT(X, TRAIT_STAGGERIMMUNE, RAGE_TRAIT)

	addtimer(CALLBACK(src, .proc/rage_warning, bonus_duration), (RAVAGER_RAGE_DURATION + bonus_duration) * RAVAGER_RAGE_WARNING) //Warn the ravager when rage is about to expire.
	addtimer(CALLBACK(src, .proc/rage_deactivate), (RAVAGER_RAGE_DURATION + bonus_duration))

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_rages++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_rages")

///Warns the user when his rage is about to end.
/datum/action/xeno_action/rage/proc/rage_warning(bonus_duration = 0)
	to_chat(owner,span_highdanger("Our rage begins to subside... [ability_name] will only last for only [(RAVAGER_RAGE_DURATION + bonus_duration) * (1-RAVAGER_RAGE_WARNING) * 0.1] more seconds!"))
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Warns the user when his rage is about to end.
/datum/action/xeno_action/rage/proc/drain_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	var/mob/living/rager = owner
	var/brute_damage = rager.getBruteLoss()
	var/burn_damage = rager.getFireLoss()
	if(!brute_damage && !burn_damage) //If we have no healable damage, don't bother proceeding
		return
	var/health_recovery = rage_power * damage //Amount of health we leech per slash
	var/health_modifier
	if(brute_damage) //First heal Brute damage, then heal Burn damage with remainder
		health_modifier = min(brute_damage, health_recovery)*-1 //Get the lower of our Brute Loss or the health we're leeching
		rager.adjustBruteLoss(health_modifier)
		health_recovery += health_modifier //Decrement the amount healed from our total healing pool
	if(burn_damage)
		health_modifier = min(burn_damage, health_recovery)*-1
		rager.adjustFireLoss(health_modifier)

	var/datum/action/xeno_action/endure/endure_ability = rager.actions_by_path[/datum/action/xeno_action/endure]
	if(endure_ability.endure_duration) //Check if Endure is active
		var/new_duration = min(RAVAGER_ENDURE_DURATION, (timeleft(endure_ability.endure_duration) + RAVAGER_RAGE_ENDURE_INCREASE_PER_SLASH)) //Increment Endure duration by 2 seconds per slash
		deltimer(endure_ability.endure_duration) //Reset timers
		deltimer(endure_ability.endure_warning_duration)
		endure_ability.endure_duration = addtimer(CALLBACK(endure_ability, /datum/action/xeno_action/endure.proc/endure_deactivate), new_duration, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE) //Reset Endure timers if active
		if(new_duration > 3 SECONDS) //Check timing
			endure_ability.endure_warning_duration = addtimer(CALLBACK(endure_ability, /datum/action/xeno_action/endure.proc/endure_warning), new_duration - 3 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_OVERRIDE) //Reset Endure timers if active

///Called when we want to end the Rage effect
/datum/action/xeno_action/rage/proc/rage_deactivate()

	var/mob/living/carbon/xenomorph/X = owner

	X.do_jitter_animation(1000)

	X.remove_filter("ravager_rage_outline")
	X.visible_message(span_warning("[X] seems to calm down."), \
	span_highdanger("Our rage subsides and its power leaves our body, leaving us exhausted."))

	X.xeno_melee_damage_modifier = initial(X.xeno_melee_damage_modifier) //Reset rage melee damage bonus
	X.remove_movespeed_modifier(MOVESPEED_ID_RAVAGER_RAGE) //Reset speed
	X.adjust_sunder(rage_sunder) //Remove the temporary Sunder restoration
	X.use_plasma(rage_plasma) //Remove the temporary Plasma

	REMOVE_TRAIT(X, TRAIT_STUNIMMUNE, RAGE_TRAIT)
	REMOVE_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, RAGE_TRAIT)
	REMOVE_TRAIT(X, TRAIT_STAGGERIMMUNE, RAGE_TRAIT)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING)

	rage_sunder = 0
	rage_power = 0
	rage_plasma = 0
	X.playsound_local(X, 'sound/voice/hiss5.ogg', 50) //Audio cue


// ***************************************
// *********** Vampirism
// ***************************************
/datum/action/xeno_action/vampirism
	name = "Toggle vampirism"
	action_icon_state = "rage"
	mechanics_text = "Toggle on to enable boosting on "
	ability_name = "Vampirism"
	plasma_cost = 0 //We're limited by cooldowns, not plasma
	cooldown_timer = 0.5 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_VAMPIRISM,
	)
	///timer hash for timer to clear last attacked
	var/clear_timer
	///int of how stacked we are on leeching
	var/leech_count
	///list of mob = timer_key of mobs we are actively leeching
	var/mob/living/last_leeched

/datum/action/xeno_action/vampirism/New(Target)
	..()
	var/mutable_appearance/leech_appeareace = mutable_appearance()
	leech_appeareace.layer = ABOVE_HUD_LAYER
	visual_references[VREF_MUTABLE_RAV_LEECH] = leech_appeareace

/datum/action/xeno_action/vampirism/update_button_icon()
	var/mob/living/carbon/xenomorph/xeno = owner
	action_icon_state = xeno.vampirism ? "neuroclaws_on" : "neuroclaws_off"
	button.cut_overlay(visual_references[VREF_MUTABLE_RAV_LEECH])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_RAV_LEECH]
	number.maptext = MAPTEXT("[leech_count]")
	visual_references[VREF_MUTABLE_RAV_LEECH] = number
	button.add_overlay(visual_references[VREF_MUTABLE_RAV_LEECH])
	return ..()

/datum/action/xeno_action/vampirism/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno = L
	xeno.vampirism = TRUE
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/on_slash)
	RegisterSignal(L, COMSIG_XENOMORPH_HEALTH_REGEN, .proc/on_regen)

/datum/action/xeno_action/vampirism/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING)

/datum/action/xeno_action/vampirism/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.vampirism = !xeno.vampirism
	if(xeno.vampirism)
		RegisterSignal(xeno, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/on_slash)
	else
		UnregisterSignal(xeno, COMSIG_XENOMORPH_ATTACK_LIVING)
	to_chat(xeno, span_xenonotice("You will now[xeno.vampirism ? "" : " no longer"] heal from attacking"))

///called on regen, handles regen rate reduction
/datum/action/xeno_action/vampirism/proc/on_regen(mob/living/carbon/xenomorph/dracula, list/heal_data)
	SIGNAL_HANDLER
	if(!leech_count)
		return
	//heals 10% extra per leeched
	var/heal_mod = 1 + (leech_count/10)

	heal_data[1] = (heal_data[1] * heal_mod)

///Adds the slashed mob to tracked damage mobs
/datum/action/xeno_action/vampirism/proc/on_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	if(target.stat == DEAD)
		return
	if(!ishuman(target)) // no farming on animals/dead
		return
	if(last_leeched == target)
		return
	addtimer(CALLBACK(src, .proc/end_leech), VAMPIRISM_MOB_DURATION)
	leech_count++
	last_leeched = target
	deltimer(clear_timer)
	clear_timer = addtimer(CALLBACK(src, .proc/clear_leeched), VAMPIRISM_MOB_DURATION, TIMER_STOPPABLE)
	update_button_icon()

///Called when the leech effect is supposed to end
/datum/action/xeno_action/vampirism/proc/end_leech()
	leech_count--
	update_button_icon()

///Called when last_leeched mob is deleted
/datum/action/xeno_action/vampirism/proc/clear_leeched()
	SIGNAL_HANDLER
	last_leeched = null
