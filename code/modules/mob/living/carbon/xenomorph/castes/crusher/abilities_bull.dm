// ***************************************
// *********** Bull's Charge
// ***************************************
/datum/action/ability/xeno_action/ready_charge/bull_charge
	action_icon_state = "bull_ready_charge"
	action_icon = 'icons/Xeno/actions/bull.dmi'
	charge_type = CHARGE_BULL
	crush_sound = SFX_ALIEN_TAIL_ATTACK
	speed_per_step = 0.2
	steps_for_charge = 7
	max_steps_buildup = 8
	crush_living_damage = 37


// ***************************************
// *********** Bull's Stomp
// ***************************************
/datum/action/ability/activable/xeno/stomp/bull
	ability_cost = 50
	cooldown_duration = 5 SECONDS

/datum/action/ability/activable/xeno/stomp/bull/use_ability(atom/A)
	succeed_activate()
	add_cooldown()
	playsound(xeno_owner.loc, 'sound/effects/bang.ogg', 25, 0)
	xeno_owner.create_stomp()
	for(var/mob/living/living_target in range(1, xeno_owner.loc))
		if(xeno_owner.issamexenohive(living_target) || living_target.stat == DEAD || !xeno_owner.Adjacent(living_target))
			continue
		var/distance = get_dist(living_target, xeno_owner)
		var/stomp_damage = XENO_STOMP_DAMAGE / max(1, distance + 1)
		if(distance == 0)
			GLOB.round_statistics.crusher_stomp_victims++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomp_victims")
			living_target.take_overall_damage(stomp_damage, BRUTE, MELEE, updating_health = TRUE, max_limbs = 2)
			living_target.Paralyze(3 SECONDS)
			shake_camera(living_target, 2, 2)
		else
			step_away(living_target, xeno_owner, 1) //Knock away
			living_target.take_overall_damage(stomp_damage, BRUTE, MELEE, updating_health = TRUE, max_limbs = 2)
			living_target.adjust_stagger(3 SECONDS)
			living_target.adjust_slowdown(3 SECONDS)


// ***************************************
// *********** Scorched Earth
// ***************************************
#define SCORCHED_EARTH_RANGE 7
#define SCORCHED_EARTH_GRACE_PERIOD 6 SECONDS
#define SCORCHED_EARTH_AOE_SIZE 1
#define SCORCHED_EARTH_TRAVEL_DAMAGE 5
#define SCORCHED_EARTH_DEBUFF_DURATION 4 SECONDS
#define SCORCHED_EARTH_TILE_DAMAGE 10

/datum/action/ability/activable/xeno/scorched_earth
	name = "Scorched Earth"
	action_icon_state = "scorched_earth"
	action_icon = 'icons/Xeno/actions/crusher.dmi'
	desc = "When activated, gain three charges of Scorched Earth. These can be used to dash towards a targeted location, leaving damaging trails of plasma behind."
	ability_cost = 250
	cooldown_duration = 3 MINUTES
	target_flags = ABILITY_TURF_TARGET
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCORCHED_EARTH,
	)
	/// The current amount of charges of this ability that we have.
	var/current_charges = 0
	/// The maximum amount of charges of this ability that we can have.
	var/maximum_charges = 3
	/// Timer that warns the player that their grace period is about to end.
	var/warning_timer
	/// Timer for the grace period that this ability allows after activation. If it expires, the ability cancels itself.
	var/grace_period_timer

/datum/action/ability/activable/xeno/scorched_earth/on_cooldown_finish()
	playsound(xeno_owner, 'sound/effects/alien/new_larva.ogg', 50, 0, 1)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")
	return ..()

/datum/action/ability/activable/xeno/scorched_earth/give_action(...)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	visual_references[VREF_MUTABLE_SCORCHED_EARTH] = counter_maptext

/datum/action/ability/activable/xeno/scorched_earth/remove_action(...)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	visual_references[VREF_MUTABLE_SCORCHED_EARTH] = null

/datum/action/ability/activable/xeno/scorched_earth/update_button_icon()
	if(!current_charges)
		return ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_SCORCHED_EARTH]
	number.maptext = MAPTEXT("[current_charges ? "[current_charges]/[maximum_charges]" : ""]")
	visual_references[VREF_MUTABLE_SCORCHED_EARTH] = number
	button.add_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	return ..()

/datum/action/ability/activable/xeno/scorched_earth/can_use_ability(atom/atom_target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(toggled && !current_charges)
		return FALSE

/datum/action/ability/activable/xeno/scorched_earth/use_ability(atom/atom_target)
	. = ..()
	if(!toggled && !current_charges)
		set_toggle(TRUE)
		xeno_owner.emote("roar6")
		current_charges = maximum_charges
		use_state_flags = ABILITY_IGNORE_PLASMA
		keybind_flags = null
		action_activate()
		add_cooldown(1.5 SECONDS)
		succeed_activate()
		warning_timer = addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, playsound_local), xeno_owner.loc, 'sound/voice/hiss4.ogg', 40, TRUE), SCORCHED_EARTH_GRACE_PERIOD - 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		grace_period_timer = addtimer(CALLBACK(src, PROC_REF(end_ability)), SCORCHED_EARTH_GRACE_PERIOD, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return
	if(!isturf(atom_target))
		atom_target = get_turf(atom_target)
	xeno_owner.set_canmove(FALSE)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_enhanced_charge.ogg', 30, TRUE)
	RegisterSignal(atom_target, COMSIG_QDELETING, PROC_REF(end_throw))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_turf))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(end_throw))
	xeno_owner.throw_at(atom_target, SCORCHED_EARTH_RANGE, 3, xeno_owner, flying = TRUE, impact_bounce = FALSE)
	current_charges--
	if(!current_charges)
		end_ability()
		return
	add_cooldown(1.5 SECONDS)
	warning_timer = addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, playsound_local), xeno_owner.loc, 'sound/voice/hiss4.ogg', 40, TRUE), SCORCHED_EARTH_GRACE_PERIOD - 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	grace_period_timer = addtimer(CALLBACK(src, PROC_REF(end_ability)), SCORCHED_EARTH_GRACE_PERIOD, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/// Ends the throw, removing signals and allowing movement.
/datum/action/ability/activable/xeno/scorched_earth/proc/end_throw()
	SIGNAL_HANDLER
	xeno_owner.set_canmove(TRUE)
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_POST_THROW))
	if(xeno_owner.throwing)
		xeno_owner.stop_throw()

/// Checks affected turfs and applies various effects to eligible contents.
/datum/action/ability/activable/xeno/scorched_earth/proc/check_turf(datum/source, atom/old_loc, movement_dir)
	SIGNAL_HANDLER
	for(var/turf/affected_turf AS in RANGE_TURFS(SCORCHED_EARTH_AOE_SIZE, xeno_owner.loc))
		if(isclosedturf(affected_turf))
			continue
		var/obj/fire/scorched_earth/bull_fire = locate(/obj/fire/scorched_earth) in affected_turf
		if(!bull_fire)
			new /obj/fire/scorched_earth(affected_turf, max(900, rand(0, 1100)), 0, "red", 0, 0, xeno_owner.hivenumber)
		for(var/mob/living/affected_living in affected_turf)
			if(affected_living.issamexenohive(xeno_owner) || affected_living.stat == DEAD)
				continue
			affected_living.take_overall_damage(SCORCHED_EARTH_TRAVEL_DAMAGE, BRUTE, MELEE, penetration = 100, max_limbs = SCORCHED_EARTH_TRAVEL_DAMAGE)
			affected_living.adjust_stagger(SCORCHED_EARTH_DEBUFF_DURATION)
			affected_living.adjust_slowdown(SCORCHED_EARTH_DEBUFF_DURATION)

/// Ends the ability.
/datum/action/ability/activable/xeno/scorched_earth/proc/end_ability()
	set_toggle(FALSE)
	use_state_flags = initial(use_state_flags)
	keybind_flags = initial(keybind_flags)
	xeno_owner.playsound_local(xeno_owner.loc, 'sound/voice/hiss5.ogg', 40, TRUE)
	add_cooldown()
	deltimer(warning_timer)
	deltimer(grace_period_timer)
	if(current_charges)
		current_charges = 0
	button.cut_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	update_button_icon()

/obj/fire/scorched_earth
	name = "Scorched Earth"
	icon = 'icons/effects/fire.dmi'
	icon_state = "bull"
	light_range = 1
	light_power = 1
	burn_decay = 80
	/// The hive this belongs to.
	var/hivenumber

/obj/fire/scorched_earth/Initialize(mapload, new_burn_ticks = burn_ticks, new_burn_level = burn_level, f_color, fire_stacks = 0, fire_damage = 0, _hivenumber)
	. = ..()
	hivenumber = _hivenumber

/obj/fire/scorched_earth/update_icon_state()
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/fire/scorched_earth/effect_smoke(...)
	return

/obj/fire/scorched_earth/set_fire(new_burn_ticks, new_burn_level, new_flame_color, fire_stacks = 0, fire_damage = 0)
	if(new_burn_ticks <= 0)
		qdel(src)
		return
	if(new_burn_ticks)
		burn_ticks = new_burn_ticks
	if(new_burn_level)
		burn_level = new_burn_level
	update_appearance(UPDATE_ICON)
	if((fire_stacks + fire_damage) <= 0)
		return

/obj/fire/scorched_earth/affect_atom(atom/affected)
	if(!isliving(affected))
		return
	var/mob/living/affected_living = affected
	if(affected_living.stat == DEAD)
		return
	if(isxeno(affected_living))
		var/mob/living/carbon/xenomorph/affected_xeno = affected_living
		if(affected_xeno.hivenumber == hivenumber)
			return
	if(affected_living.status_flags & (INCORPOREAL|GODMODE))
		return FALSE
	if(affected_living.pass_flags & PASS_FIRE)
		return FALSE
	affected_living.take_overall_damage(SCORCHED_EARTH_TILE_DAMAGE, BRUTE, MELEE, penetration = 100, max_limbs = 2)
	affected_living.adjust_blurriness(1)
	affected_living.adjust_stagger(1 SECONDS)
	affected_living.adjust_slowdown(1 SECONDS)
