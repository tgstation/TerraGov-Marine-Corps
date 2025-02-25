// ***************************************
// *********** Bull's Charge
// ***************************************
/datum/action/ability/xeno_action/ready_charge/bull_charge
	action_icon_state = "bull_ready_charge"
	action_icon = 'icons/Xeno/actions/bull.dmi'
	charge_type = CHARGE_BULL
	crush_sound = SFX_ALIEN_TAIL_ATTACK
	speed_per_step = 0.15
	steps_for_charge = 5
	max_steps_buildup = 10
	crush_living_damage = 37
	plasma_use_multiplier = 2


// ***************************************
// *********** Bull's Stomp
// ***************************************
#define BULL_STOMP_DEBUFF_DURATION 3 //SECONDS

/datum/action/ability/activable/xeno/stomp/bull
	name = "Bull's Stomp"
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
			living_target.Paralyze(BULL_STOMP_DEBUFF_DURATION SECONDS)
			shake_camera(living_target, 2, 2)
		else
			step_away(living_target, xeno_owner, 1) //Knock away
			living_target.take_overall_damage(stomp_damage, BRUTE, MELEE, updating_health = TRUE, max_limbs = 2)
			living_target.adjust_stagger(BULL_STOMP_DEBUFF_DURATION)
			living_target.adjust_slowdown(BULL_STOMP_DEBUFF_DURATION)


// ***************************************
// *********** Scorched Earth
// ***************************************
#define SCORCHED_EARTH_RANGE 7
#define SCORCHED_EARTH_RESET_TIME 6 SECONDS
#define SCORCHED_EARTH_AOE_SIZE 1
#define SCORCHED_EARTH_TRAVEL_DAMAGE 5
#define SCORCHED_EARTH_TRAVEL_DEBUFF 4
#define SCORCHED_EARTH_TILE_DAMAGE 15
#define SCORCHED_EARTH_TILE_DEBUFF 1

/datum/action/ability/activable/xeno/scorched_earth
	name = "Scorched Earth"
	action_icon_state = "scorched_earth"
	action_icon = 'icons/Xeno/actions/crusher.dmi'
	desc = "When activated, gain three charges of Scorched Earth. These can be used to dash towards a targeted location, leaving damaging trails of plasma behind."
	ability_cost = 250
	cooldown_duration = 3 MINUTES
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCORCHED_EARTH,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// Whether this ability is active or not.
	var/ability_active = FALSE
	/// The current amount of charges of this ability that we have. Initial value is assumed to be the maximum.
	var/ability_charges = 3
	/// Timer ID. Warns the player that the ability's duration is about to end.
	var/warning_timer
	/// Timer ID. Grace period that this ability allows after activation. If it expires, the ability resets.
	var/reset_timer

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
	if(!ability_active)
		return ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_SCORCHED_EARTH]
	number.maptext = MAPTEXT("[ability_charges]/[initial(ability_charges)]")
	visual_references[VREF_MUTABLE_SCORCHED_EARTH] = number
	button.add_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	return ..()

/datum/action/ability/activable/xeno/scorched_earth/action_activate()
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	if(!ability_active && can_use_action())
		ability_active = TRUE
		xeno_owner.emote("roar6")
		ability_charges = initial(ability_charges)
		use_state_flags |= ABILITY_IGNORE_PLASMA
		warning_timer = addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, playsound_local), xeno_owner.loc, 'sound/voice/hiss4.ogg', 40, TRUE), SCORCHED_EARTH_RESET_TIME * 0.7, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		reset_timer = addtimer(CALLBACK(src, PROC_REF(end_ability)), SCORCHED_EARTH_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		particle_holder = new(xeno_owner, /particles/bull_glow)
		particle_holder.particles.icon = xeno_owner.icon
		adjust_particles(new_dir = xeno_owner.dir)
		RegisterSignals(xeno_owner, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DO_RESIST, COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST), PROC_REF(adjust_particles))
		RegisterSignals(xeno_owner, list(COMSIG_QDELETING, COMSIG_MOB_DEATH), PROC_REF(end_ability))
		add_cooldown(1.5 SECONDS)
		succeed_activate()
	if(xeno_owner.selected_ability == src)
		return
	if(xeno_owner.selected_ability)
		xeno_owner.selected_ability.deselect()
	select()

/datum/action/ability/activable/xeno/scorched_earth/use_ability(turf/turf_target)
	. = ..()
	xeno_owner.set_canmove(FALSE)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_enhanced_charge.ogg', 30, TRUE)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(check_turf))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(end_throw))
	xeno_owner.throw_at(turf_target, SCORCHED_EARTH_RANGE, 3, xeno_owner, flying = TRUE)
	ability_charges--
	if(!ability_charges)
		end_ability()
		return
	add_cooldown(1.5 SECONDS)
	warning_timer = addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, playsound_local), xeno_owner.loc, 'sound/voice/hiss4.ogg', 40, TRUE), SCORCHED_EARTH_RESET_TIME * 0.7, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	reset_timer = addtimer(CALLBACK(src, PROC_REF(end_ability)), SCORCHED_EARTH_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

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
			affected_living.adjust_stagger(SCORCHED_EARTH_TRAVEL_DEBUFF)
			affected_living.adjust_slowdown(SCORCHED_EARTH_TRAVEL_DEBUFF)

/// Adjusts particles to match the user. Alignments are hand picked, and should be remade if the King's icon ever changes.
/datum/action/ability/activable/xeno/scorched_earth/proc/adjust_particles(datum/source, unused, new_dir)
	SIGNAL_HANDLER
	if(!particle_holder)
		return
	if(!(new_dir in GLOB.alldirs))
		new_dir = xeno_owner.dir
	particle_holder.particles.icon_state = "[xeno_owner.xeno_caste.caste_name] Glow [closest_cardinal_dir(new_dir)]" // This intentionally misses some states, for the record.
	particle_holder.layer = xeno_owner.layer + 0.01
	particle_holder.pixel_x = xeno_owner.pixel_x + 32
	particle_holder.pixel_y = xeno_owner.pixel_y + 19

/// Ends the ability.
/datum/action/ability/activable/xeno/scorched_earth/proc/end_ability()
	SIGNAL_HANDLER
	ability_active = FALSE
	use_state_flags &= ~ABILITY_IGNORE_PLASMA
	deltimer(warning_timer)
	deltimer(reset_timer)
	QDEL_NULL(particle_holder)
	UnregisterSignal(xeno_owner, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DO_RESIST, COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST, COMSIG_QDELETING, COMSIG_MOB_DEATH))
	update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_SCORCHED_EARTH])
	xeno_owner.playsound_local(xeno_owner.loc, 'sound/voice/hiss5.ogg', 40, TRUE)
	add_cooldown()

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
	affected_living.adjust_blurriness(SCORCHED_EARTH_TRAVEL_DEBUFF)
	affected_living.adjust_stagger(SCORCHED_EARTH_TRAVEL_DEBUFF)
	affected_living.adjust_slowdown(SCORCHED_EARTH_TRAVEL_DEBUFF)

/particles/bull_glow
	icon_state = "Bull Glow 2"
	width = 96
	height = 96
	count = 1
	spawning = 1
	lifespan = 8
	fadein = 4
	fade = 4
