/obj/effect/temp_visual/conqueror
	layer = ABOVE_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE


// ***************************************
// *********** Conqueror's Dash
// ***************************************
#define CONQUEROR_DASH_RANGE 2 // How far we can go with this ability.

/datum/action/ability/xeno_action/conqueror_dash
	name = "Dash"
	desc = "Move in a burst of speed. Double tap any movement direction to dash towards it."
	action_type = ACTION_TOGGLE
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "rewind"
	ability_cost = 15
	cooldown_duration = 4.5 SECONDS
	use_state_flags = ABILITY_USE_FORTIFIED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_DASH,
	)
	/// Stores the time at which we last moved.
	var/last_move_time
	/// Stores the direction of the last movement made.
	var/last_move_dir
	/// The timing for activating a dash by double tapping a movement key.
	var/double_tap_timing = 0.18 SECONDS
	/// If this ability is in its alternative form, the amount of charges that Dash has. Otherwise, does nothing.
	var/charges
	/// The maximum amount of charges that can be restored. Do not set this directly. Use `set_maximum_charges` instead.
	var/maximum_charges
	/// The amount of deciseconds until a charge is restored.
	var/charge_restoration_length
	/// The timer ID of the charge restoration.
	var/charge_restoration_timer

/datum/action/ability/xeno_action/conqueror_dash/give_action(mob/living/L)
	. = ..()
	toggled = TRUE
	set_toggle(TRUE)
	enable_ability()
	add_button_visuals()
	restore_charge(0)
	if(charge_restoration_timer)
		START_PROCESSING(SSprocessing, src)

/datum/action/ability/xeno_action/conqueror_dash/remove_action(mob/living/L)
	toggled = FALSE
	set_toggle(FALSE)
	disable_ability()
	remove_button_visuals()
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSprocessing, src)
	if(charge_restoration_timer)
		deltimer(charge_restoration_timer)
		charge_restoration_timer = null
	return ..()

/datum/action/ability/xeno_action/conqueror_dash/update_button_icon()
	if(isnull(charges) || isnull(maximum_charges))
		return ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES]
	number.maptext = MAPTEXT("[charges]/[maximum_charges]")
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES] = number
	button.add_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES])

	button.cut_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER])
	var/mutable_appearance/time = visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER]
	time.maptext = MAPTEXT("[timeleft(charge_restoration_timer) ? "[round(timeleft(charge_restoration_timer) / 10)]s" : ""]")
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER] = time
	button.add_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER])
	return ..()

/datum/action/ability/xeno_action/conqueror_dash/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!xeno_owner.canmove)
		return FALSE
	if(xeno_owner.endurance_active)
		return FALSE
	if(maximum_charges && !charges)
		return FALSE
	return TRUE

/datum/action/ability/xeno_action/conqueror_dash/process()
	if(!charge_restoration_timer)
		STOP_PROCESSING(SSprocessing, src)
		button.cut_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER])
		return
	button.cut_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER])
	var/mutable_appearance/time = visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER]
	time.maptext = MAPTEXT("[timeleft(charge_restoration_timer) ? "[round(timeleft(charge_restoration_timer) / 10)]s" : ""]")
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER] = time
	button.add_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER])

/datum/action/ability/xeno_action/conqueror_dash/action_activate()
	toggled = !toggled
	set_toggle(toggled)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] [toggled ? "enabled" : "disabled"]")
	if(!toggled)
		disable_ability()
		return
	enable_ability()

/datum/action/ability/xeno_action/conqueror_dash/alternate_action_activate()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(set_timing))

/datum/action/ability/xeno_action/conqueror_dash/clean_action()
	disable_ability()
	return ..()

/// Enables the ability.
/datum/action/ability/xeno_action/conqueror_dash/proc/enable_ability()
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_EAST_DOWN, PROC_REF(dash_east))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_NORTH_DOWN, PROC_REF(dash_north))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_SOUTH_DOWN, PROC_REF(dash_south))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_WEST_DOWN, PROC_REF(dash_west))

/// Disables the ability.
/datum/action/ability/xeno_action/conqueror_dash/proc/disable_ability()
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_KB_MOVEMENT_EAST_DOWN, COMSIG_KB_MOVEMENT_NORTH_DOWN, COMSIG_KB_MOVEMENT_SOUTH_DOWN, COMSIG_KB_MOVEMENT_WEST_DOWN))

/// On death, disables the ability and stops charges from being restored. Registers a signal to deal with the owner's revival, if it were to happen.
/datum/action/ability/xeno_action/conqueror_dash/proc/on_death()
	SIGNAL_HANDLER
	disable_ability()
	RegisterSignal(xeno_owner, COMSIG_MOB_REVIVE, PROC_REF(on_revive))
	if(charge_restoration_timer)
		deltimer(charge_restoration_timer)
		charge_restoration_timer = null

/// On revival, enables the ability. If it was using the charge system, start the timer to restore charges.
/datum/action/ability/xeno_action/conqueror_dash/proc/on_revive()
	SIGNAL_HANDLER
	enable_ability()
	UnregisterSignal(xeno_owner, COMSIG_MOB_REVIVE)
	if(maximum_charges && !charge_restoration_timer)
		restore_charge(0)
		START_PROCESSING(SSprocessing, src)

/// Checks if we can dash to the east.
/datum/action/ability/xeno_action/conqueror_dash/proc/dash_east()
	SIGNAL_HANDLER
	check_dash(EAST)

/// Checks if we can dash to the north.
/datum/action/ability/xeno_action/conqueror_dash/proc/dash_north()
	SIGNAL_HANDLER
	check_dash(NORTH)

/// Checks if we can dash to the south.
/datum/action/ability/xeno_action/conqueror_dash/proc/dash_south()
	SIGNAL_HANDLER
	check_dash(SOUTH)

/// Checks if we can dash to the west.
/datum/action/ability/xeno_action/conqueror_dash/proc/dash_west()
	SIGNAL_HANDLER
	check_dash(WEST)

/// Checks if we can dash in the specified direction, and activates the ability if so.
/datum/action/ability/xeno_action/conqueror_dash/proc/check_dash(direction)
	if(!can_use_action(TRUE))
		return
	if(last_move_dir == direction && last_move_time + double_tap_timing > world.time)
		activate_dash(direction)
		return
	last_move_time = world.time
	last_move_dir = direction

/// Does a dash in the specified direction.
/datum/action/ability/xeno_action/conqueror_dash/proc/activate_dash(direction)
	xeno_owner.add_pass_flags(PASS_LOW_STRUCTURE|PASS_MOB|PASS_FIRE|PASS_XENO|PASS_THROW|PASS_WALKOVER, CONQUEROR_ABILITY_TRAIT)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(end_dash))
	playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_enhanced_charge.ogg', 8, TRUE)
	var/turf/turf_target = get_ranged_target_turf(xeno_owner, direction, CONQUEROR_DASH_RANGE)
	for(var/turf/turf_to_check AS in get_line(xeno_owner.loc, turf_target) - xeno_owner.loc)
		for(var/atom/atom_to_check AS in turf_to_check)
			if(atom_to_check.CanPass(xeno_owner, turf_to_check))
				new /obj/effect/temp_visual/conqueror/dash_trail(turf_to_check, direction)
	xeno_owner.throw_at(turf_target, CONQUEROR_DASH_RANGE, CONQUEROR_DASH_RANGE, targetted_throw = FALSE)
	last_move_time = 0
	last_move_dir = null
	add_cooldown()
	succeed_activate()
	if(charges)
		restore_charge(-1)
		START_PROCESSING(SSprocessing, src)
	disable_ability() // Ability usage is disabled until the cooldown has concluded. This prevents signals from firing, for the purposes of performance efficiency.
	addtimer(CALLBACK(src, PROC_REF(enable_ability)), cooldown_duration)

/// Gets rid of dash bonuses, if any.
/datum/action/ability/xeno_action/conqueror_dash/proc/end_dash()
	SIGNAL_HANDLER
	xeno_owner.remove_pass_flags(PASS_LOW_STRUCTURE|PASS_MOB|PASS_FIRE|PASS_XENO|PASS_THROW|PASS_PROJECTILE|PASS_WALKOVER, CONQUEROR_ABILITY_TRAIT)
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW)

/// Opens an input window to allow customization of the double tap timing.
/datum/action/ability/xeno_action/conqueror_dash/proc/set_timing()
	var/timing = input(xeno_owner, "Specify the double tap timing IN SECONDS. This is 0.18s by default.", "Set Double Tap Timing", double_tap_timing * 0.1) as num
	if(timing)
		double_tap_timing = timing SECONDS
	return COMSIG_KB_ACTIVATED

/// Sets the maximum charges and how long it takes to restore charges. Will switch the ability away or to a charge-based system based on maximum charges.
/datum/action/ability/xeno_action/conqueror_dash/proc/set_maximum_charges(new_maximum_charges = 0, restoration_length)
	if(!charge_restoration_length && !restoration_length)
		restoration_length = cooldown_duration
	charge_restoration_length = restoration_length
	if(maximum_charges == new_maximum_charges)
		return
	// We only support maximum charges that are two or higher. If it is changed to be under, it means we're no longer using the charge-system anymore.
	if(new_maximum_charges < 2)
		if(maximum_charges)
			if(charges >= 1)
				clear_cooldown()
			charges = null
			maximum_charges = null
			charge_restoration_length = null
			if(charge_restoration_timer)
				deltimer(charge_restoration_timer)
				charge_restoration_timer = null
			remove_button_visuals()
		return
	// Switching from non-charges to charges.
	if(!maximum_charges)
		maximum_charges = new_maximum_charges
		restore_charge(action_cooldown_finished() ? 1 : 0)
		add_button_visuals()
		return
	maximum_charges = new_maximum_charges
	restore_charge(0)

/// Restores a certain amount of charges. If under the maximum charges, restart the timer.
/datum/action/ability/xeno_action/conqueror_dash/proc/restore_charge(amount = 1)
	charges = clamp(charges + amount, 0, maximum_charges)
	update_button_icon()
	if(charges >= maximum_charges)
		deltimer(charge_restoration_timer)
		charge_restoration_timer = null
		return
	if(!charge_restoration_timer || amount >= 1)
		charge_restoration_timer = addtimer(CALLBACK(src, PROC_REF(restore_charge)), charge_restoration_length, TIMER_UNIQUE|TIMER_STOPPABLE)

/// If the ability is using the charge system, adds various visuals to indicate current, maximum, and recharge time for charges.
/datum/action/ability/xeno_action/conqueror_dash/proc/add_button_visuals()
	if(isnull(charges) || isnull(maximum_charges))
		return
	var/mutable_appearance/counter_maptext = mutable_appearance(layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[charges]/[maximum_charges]")
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES] = counter_maptext

	var/mutable_appearance/timer_maptext = mutable_appearance(layer = ACTION_LAYER_MAPTEXT)
	timer_maptext.pixel_x = 16
	timer_maptext.pixel_y = 24
	timer_maptext.maptext = MAPTEXT("[timeleft(charge_restoration_timer) ? "[round(timeleft(charge_restoration_timer) / 10)]s" : ""]")
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER] = timer_maptext

/// If the ability is not using the charge system, removes visuals used for charges.
/datum/action/ability/xeno_action/conqueror_dash/proc/remove_button_visuals()
	if(!isnull(charges) || !isnull(maximum_charges))
		return
	button.cut_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES])
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGES] = null

	button.cut_overlay(visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER])
	visual_references[VREF_MUTABLE_CONQ_DASH_CHARGETIMER] = null

/obj/effect/temp_visual/conqueror/dash_trail
	icon = 'icons/effects/particles/conqueror.dmi'
	icon_state = "Conqueror Trail"
	pixel_x = -16
	alpha = 200
	color = COLOR_VIOLET
	layer = BELOW_MOB_LAYER
	duration = 5
	anchored = FALSE
	animate_movement = SLIDE_STEPS
	randomdir = FALSE

/obj/effect/temp_visual/conqueror/dash_trail/Initialize(mapload, new_dir)
	. = ..()
	animate(src, alpha = 0, time = duration)
	if(new_dir)
		dir = new_dir


// ***************************************
// *********** Conqueror's Will
// ***************************************
#define CONQUEROR_WILL_DASH_RANGE 2 // The range for most of this ability's bonuses (in tiles).
#define CONQUEROR_WILL_MAX_COMBO 3 // The maximum amount of hits that a combo can have.
#define CONQUEROR_WILL_RESET_TIME 6 SECONDS // The time before the ability's combo is reset.
#define CONQUEROR_WILL_COMBO_DEBUFF 1.5 SECONDS // The duration of this ability's combo debuffs.
#define CONQUEROR_WILL_JAB_MULTIPLIER 0.2 // The damage multiplier for this ability's Jab combo, as a percentage (0.2 = 20%)
#define CONQUEROR_WILL_JAB_PENETRATION 100 // The penetration bonus for this ability's Jab combo.
#define CONQUEROR_WILL_KICK_PUSH 2 // How far the kick combo will fling victims away.

// Combo defines. L represents left click, and R represents right click.
#define COMBO_LEFT_RIGHT "LR"
#define COMBO_RIGHT_LEFT "RL"
#define COMBO_LEFT_LEFT "LL"
#define COMBO_RIGHT_RIGHT "RR"

/datum/action/ability/activable/xeno/conqueror_will
	name = "Conqueror's Will"
	desc = "Imbue your punches with charged plasma. Upgrades attacks, and allows you to execute powerful combos while this ability is selected."
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	action_icon_state = "punch"
	cooldown_duration = 10 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_IGNORE_COOLDOWN|ABILITY_DO_AFTER_ATTACK
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_WILL,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// If enabled, a meter will be displayed on the HUD for the current combo streak.
	var/display_combos = TRUE
	/// The streak of attacks the user has performed.
	var/combo_streak = ""
	/// Timer ID. Length of time until combo streaks are automatically reset.
	var/reset_timer
	/// Timer ID. Length of time after which the ability will warn the user of an impending reset.
	var/warning_timer
	/// On Jab's usage, the percentage of maximum health to heal.
	var/jab_heal_percentage = 0
	/// On Jab's usage, the multiplier of damage to deal.
	var/jab_damage_multiplier = CONQUEROR_WILL_JAB_MULTIPLIER

/datum/action/ability/activable/xeno/conqueror_will/give_action(mob/living/L)
	. = ..()
	xeno_owner.attack_sound = null
	xeno_owner.attack_effect = null
	enable_ability()

/datum/action/ability/activable/xeno/conqueror_will/remove_action(mob/living/L)
	xeno_owner.attack_sound = initial(xeno_owner.attack_sound)
	xeno_owner.attack_effect = initial(xeno_owner.attack_effect)
	disable_ability()
	return ..()

/datum/action/ability/activable/xeno/conqueror_will/on_cooldown_finish()
	. = ..()
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 30, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

/// Toggles the combo display.
/datum/action/ability/activable/xeno/conqueror_will/alternate_action_activate()
	. = ..()
	display_combos = !display_combos
	xeno_owner.balloon_alert(xeno_owner, "Combo display [display_combos ? "enabled" : "disabled"]")
	if(!display_combos)
		xeno_owner.hud_used?.combo_display.reset_icons()

/datum/action/ability/activable/xeno/conqueror_will/clean_action()
	disable_ability()
	return ..()

/// Enables the ability.
/datum/action/ability/activable/xeno/conqueror_will/proc/enable_ability()
	if(!particle_holder)
		particle_holder = new(xeno_owner, /particles/conqueror_will)
	adjust_particles(new_dir = xeno_owner.dir)
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignals(xeno_owner, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DO_RESIST, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST), PROC_REF(adjust_particles))
	RegisterSignal(xeno_owner, COMSIG_MOB_CLICKON, PROC_REF(check_range)) // Happens before the xeno actually attacks.
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_PRE_ATTACK_ALIEN_HARM, PROC_REF(add_to_attack))

/// Disables the ability.
/datum/action/ability/activable/xeno/conqueror_will/proc/disable_ability()
	SIGNAL_HANDLER
	reset_combo(TRUE)
	QDEL_NULL(particle_holder)
	UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DO_RESIST, COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST, COMSIG_MOB_CLICKON, COMSIG_XENOMORPH_PRE_ATTACK_ALIEN_HARM))

/// If the user dies, a check will be added in the case of revival, to reenable the ability.
/datum/action/ability/activable/xeno/conqueror_will/proc/on_death()
	SIGNAL_HANDLER
	disable_ability()
	RegisterSignal(xeno_owner, COMSIG_MOB_REVIVE, PROC_REF(enable_ability))

/// Adjusts particles to match the user. Alignments are hand picked, and may have to be remade if the Conqueror's icon ever changes.
/datum/action/ability/activable/xeno/conqueror_will/proc/adjust_particles(datum/source, unused, new_dir)
	SIGNAL_HANDLER
	if(!particle_holder)
		return
	if(!(new_dir in GLOB.alldirs))
		new_dir = xeno_owner.dir
	particle_holder.particles.icon_state = "[xeno_owner.icon_state][closest_cardinal_dir(new_dir)]" // This intentionally misses some states, for the record.
	particle_holder.layer = xeno_owner.layer - 0.01
	particle_holder.pixel_y = xeno_owner.pixel_y + 19
	switch(new_dir)
		if(WEST)
			particle_holder.pixel_x = xeno_owner.pixel_x + 34
		if(EAST)
			particle_holder.pixel_x = xeno_owner.pixel_x + 30
		else
			particle_holder.pixel_x = xeno_owner.pixel_x + 32

/// Checks if an eligible target is within the specified range. If true, the user will be moved towards them.
/datum/action/ability/activable/xeno/conqueror_will/proc/check_range(datum/source, atom/atom_target, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["ctrl"] || modifiers["alt"])
		return
	if(xeno_owner.buckled || world.time <= xeno_owner.next_move)
		return
	if(!can_use_action(TRUE))
		return
	var/list/turf/turfs_to_check = get_line(xeno_owner.loc, atom_target) - xeno_owner.loc
	while(length(turfs_to_check) > CONQUEROR_WILL_DASH_RANGE)
		pop(turfs_to_check)
	for(var/turf/turf_to_check AS in turfs_to_check)
		for(var/atom/atom_to_check in turf_to_check)
			if(!atom_to_check.CanPass(xeno_owner, turf_to_check))
				break
		for(var/mob/potential_mob in turf_to_check)
			if(!iscarbon(potential_mob))
				continue
			if(!line_of_sight(potential_mob, xeno_owner, CONQUEROR_WILL_DASH_RANGE))
				continue
			if(potential_mob.stat == DEAD || potential_mob.issamexenohive(xeno_owner))
				continue
			if(!potential_mob.Adjacent(xeno_owner))
				playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_enhanced_charge.ogg', 7, TRUE)
				step_towards(xeno_owner, potential_mob, get_dist(xeno_owner, potential_mob) - 1)
			break

/// Adds bonuses to normal attacks, usually replacing visuals and sound effects, and builds up combos if the ability isn't on cooldown.
/datum/action/ability/activable/xeno/conqueror_will/proc/add_to_attack(datum/source, mob/living/living_target, isrightclick = FALSE)
	SIGNAL_HANDLER
	if(!iscarbon(living_target) || living_target.stat == DEAD || !living_target.can_xeno_slash(xeno_owner))
		return
	if(action_cooldown_finished() && xeno_owner.selected_ability == src)
		combo_streak += isrightclick ? "R" : "L"
		if(display_combos)
			xeno_owner.hud_used?.combo_display.update_icon_state(combo_streak)
	if(length(combo_streak) < CONQUEROR_WILL_MAX_COMBO)
		no_combo(living_target)
		if(action_cooldown_finished() && xeno_owner.selected_ability == src)
			reset_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo)), CONQUEROR_WILL_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
			warning_timer = addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, playsound_local), xeno_owner, 'sound/voice/hiss4.ogg', 25, TRUE), CONQUEROR_WILL_RESET_TIME - 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return
	var/combo_check = CONQUEROR_WILL_MAX_COMBO - 1
	if(findtext(combo_streak, COMBO_LEFT_RIGHT, combo_check))
		combo_punch(living_target)
	else if(findtext(combo_streak, COMBO_RIGHT_LEFT, combo_check))
		combo_uppercut(living_target)
	else if(findtext(combo_streak, COMBO_LEFT_LEFT, combo_check))
		combo_jab(living_target)
	else if(findtext(combo_streak, COMBO_RIGHT_RIGHT, combo_check))
		combo_kick(living_target)
	playsound(living_target, 'sound/effects/alien/conqueror/will_extra_3.ogg', 20, TRUE)
	playsound(xeno_owner, 'sound/voice/alien/roar2.ogg', 20, TRUE)
	reset_combo(TRUE)
	add_cooldown()

/// Resets any ongoing combos.
/datum/action/ability/activable/xeno/conqueror_will/proc/reset_combo(silent = FALSE)
	if(display_combos)
		if(!silent)
			xeno_owner.hud_used?.combo_display.reset_icons()
		else
			xeno_owner.hud_used?.combo_display.update_icon_state(combo_streak)
			xeno_owner.hud_used?.combo_display.clear_streak()
	combo_streak = initial(combo_streak)
	if(reset_timer)
		if(!silent)
			xeno_owner.playsound_local(xeno_owner, 'sound/voice/hiss5.ogg', 25, TRUE)
		deltimer(reset_timer)
	if(warning_timer)
		deltimer(warning_timer)

/// A simple hook.
/datum/action/ability/activable/xeno/conqueror_will/proc/no_combo(mob/living/living_target)
	playsound(living_target, SFX_CONQUEROR_WILL_HOOK, 35, TRUE)
	playsound(living_target, SFX_CONQUEROR_WILL_EXTRA, 15, TRUE)
	new /obj/effect/temp_visual/conqueror/hook(living_target.loc)

/// A well delivered punch to a weak point, incapacitating the target for the duration.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_punch(mob/living/living_target)
	playsound(living_target, 'sound/effects/alien/conqueror/will_punch.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/punch(living_target.loc)
	living_target.do_attack_animation(get_step(living_target, REVERSE_DIR(get_dir(living_target, xeno_owner))))
	living_target.do_jitter_animation(700, CONQUEROR_WILL_COMBO_DEBUFF / 10)
	living_target.knockback(xeno_owner, 1, 1)
	var/immobilize_time = CONQUEROR_WILL_COMBO_DEBUFF * 0.7
	living_target.Immobilize(immobilize_time)
	addtimer(CALLBACK(living_target, TYPE_PROC_REF(/mob/living, Knockdown), CONQUEROR_WILL_COMBO_DEBUFF * 0.3), immobilize_time)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "gored")

/// A strong uppercut that knocks the target upwards, incapacitating them for the duration.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_uppercut(mob/living/living_target)
	playsound(living_target, 'sound/effects/alien/conqueror/will_uppercut.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/uppercut(living_target.loc)
	var/immobilize_duration = CONQUEROR_WILL_COMBO_DEBUFF * 0.8
	living_target.Immobilize(immobilize_duration)
	if(!(living_target.pass_flags & PASS_MOB))
		living_target.add_pass_flags(PASS_MOB, CONQUEROR_ABILITY_TRAIT)
	living_target.knockback(xeno_owner, 1, 1)
	addtimer(CALLBACK(src, PROC_REF(uppercut_landing), living_target, CONQUEROR_WILL_COMBO_DEBUFF * 0.2), immobilize_duration)
	animate(living_target, pixel_y = living_target.pixel_y + 70, time = immobilize_duration * 0.3, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(time = immobilize_duration * 0.4)
	animate(pixel_y = living_target.pixel_y - 70, time = immobilize_duration * 0.3, easing = SINE_EASING|EASE_IN)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "gored")

/// After the target lands, certain traits are reset, and the rest of the effects are applied.
/datum/action/ability/activable/xeno/conqueror_will/proc/uppercut_landing(mob/living/living_target, debuff_duration)
	if(!living_target)
		return
	if(living_target.pass_flags & PASS_MOB)
		living_target.remove_pass_flags(PASS_MOB, CONQUEROR_ABILITY_TRAIT)
	playsound(living_target, 'sound/effects/alien/conqueror/will_uppercut_landing.ogg', 30, TRUE)
	living_target.Knockdown(debuff_duration)

/// A flurry of rapid and precise strikes, dealing additional damage.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_jab(mob/living/living_target)
	playsound(living_target, 'sound/effects/alien/conqueror/will_jab.ogg', 40, TRUE)
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(playsound), living_target, 'sound/effects/alien/conqueror/will_extra_3.ogg', 15, TRUE), 0.2 SECONDS, TIMER_CLIENT_TIME)
	new /obj/effect/temp_visual/conqueror/hook/jab/initial(living_target.loc)
	living_target.do_attack_animation(get_step(living_target, REVERSE_DIR(get_dir(living_target, xeno_owner))))
	if(jab_damage_multiplier)
		living_target.apply_damage((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * jab_damage_multiplier, BRUTE, xeno_owner.get_limb(xeno_owner.zone_selected), MELEE, TRUE, TRUE, TRUE, CONQUEROR_WILL_JAB_PENETRATION, owner)
	if(jab_heal_percentage)
		var/health_to_heal = xeno_owner.xeno_caste.max_health * jab_heal_percentage
		HEAL_XENO_DAMAGE(xeno_owner, health_to_heal, FALSE)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "pain")

/// A mighty kick that sends the target flying. If they collide with another atom, that atom is also affected.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_kick(mob/living/living_target)
	playsound(living_target, 'sound/effects/alien/conqueror/will_kick.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/kick(living_target.loc)
	if(!(living_target.pass_flags & PASS_XENO))
		living_target.add_pass_flags(PASS_XENO, CONQUEROR_ABILITY_TRAIT)
	RegisterSignal(living_target, COMSIG_MOVABLE_IMPACT, PROC_REF(kicked_into))
	RegisterSignal(living_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(kicked_end))
	living_target.knockback(xeno_owner, CONQUEROR_WILL_KICK_PUSH, 1)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")

/// If the target collides into another atom, that atom is affected. Taken from Warrior code.
/datum/action/ability/activable/xeno/conqueror_will/proc/kicked_into(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/mob/living/living_target = source
	new /obj/effect/temp_visual/warrior/impact(living_target.loc, get_dir(living_target, xeno_owner))
	if(!isliving(hit_atom))
		return
	var/mob/living/hit_living = hit_atom
	if(hit_living.issamexenohive(xeno_owner))
		return
	INVOKE_ASYNC(hit_living, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(hit_living, 'sound/weapons/punch1.ogg', 30, TRUE)
	hit_living.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, BRUTE, 0, MELEE, TRUE, TRUE, TRUE, xeno_owner.xeno_caste.melee_ap, owner)
	hit_living.Knockdown(CONQUEROR_WILL_COMBO_DEBUFF * 2)
	hit_living.knockback(living_target, 1, 1)

/// Ends the target's throw. Taken from Warrior code.
/datum/action/ability/activable/xeno/conqueror_will/proc/kicked_end(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT))
	var/mob/living/living_target = source
	living_target.Knockdown(CONQUEROR_WILL_COMBO_DEBUFF)
	if(living_target.pass_flags & PASS_XENO)
		living_target.remove_pass_flags(PASS_XENO, CONQUEROR_ABILITY_TRAIT)

/particles/conqueror_will
	icon = 'icons/effects/particles/conqueror.dmi'
	icon_state = "Conqueror2"
	width = 96
	height = 96
	count = 5
	spawning = 1
	lifespan = 3
	fade = 3
	grow = 0.12
	color = COLOR_VIOLET

/obj/effect/temp_visual/conqueror/hook
	layer = ABOVE_MOB_LAYER
	icon = 'icons/effects/64x64.dmi'
	icon_state = "conqueror_hook"
	pixel_x = -16
	pixel_y = -16
	duration = 2.5

/obj/effect/temp_visual/conqueror/hook/Initialize(mapload)
	. = ..()
	var/matrix/current_matrix = matrix()
	transform = current_matrix.Scale(0.8, 0.8)
	animate(src, time = duration + 1, alpha = 55)

/obj/effect/temp_visual/conqueror/hook/punch
	icon_state = "conqueror_punch"
	duration = 4
	pixel_x = 4
	pixel_y = 3

/obj/effect/temp_visual/conqueror/hook/jab
	icon_state = "conqueror_jab"
	duration = 4

/obj/effect/temp_visual/conqueror/hook/jab/Initialize(mapload)
	. = ..()
	pixel_x += rand(-6, 6)
	pixel_y += rand(-6, 6)

/obj/effect/temp_visual/conqueror/hook/jab/initial/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(repeat_effect)), 0.2 SECONDS, TIMER_CLIENT_TIME)

/// Repeats the visual effect by spawning another.
/obj/effect/temp_visual/conqueror/hook/jab/initial/proc/repeat_effect()
	new /obj/effect/temp_visual/conqueror/hook/jab/duplicate(loc)

/obj/effect/temp_visual/conqueror/hook/jab/duplicate // This doesn't loop anymore, for the record.

/obj/effect/temp_visual/conqueror/hook/uppercut
	icon_state = "conqueror_uppercut"
	duration = 5
	pixel_y = 2

/obj/effect/temp_visual/conqueror/hook/kick
	icon_state = "conqueror_kick"
	duration = 5


// ***************************************
// *********** Conqueror's Endurance
// ***************************************
#define CONQUEROR_ENDURANCE_SPEED_MODIFIER 2.0 // Speed modifier applied while this ability is active.
#define CONQUEROR_ENDURANCE_SUNDER_MULTIPLIER 0 // Amount of sunder reduction applied while this ability is active (as a percentage; 0 is 100%).
#define CONQUEROR_ENDURANCE_DAMAGE_REDUCTION 0.5 // Amount of damage reduction applied while this ability is active (as a percentage).
#define CONQUEROR_ENDURANCE_BROKEN_KNOCKDOWN 1.5 SECONDS // Duration of the debuff inflicted when this ability loses all of its resource.

/datum/action/ability/xeno_action/conqueror_endurance
	name = "Endurance"
	desc = "Block attacks with your forearms, reducing damage received."
	action_type = ACTION_TOGGLE
	action_icon = 'icons/Xeno/actions/defender.dmi'
	action_icon_state = "fortify"
	cooldown_duration = 0.2 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_HOLD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_TOGGLE,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/xeno_action/conqueror_endurance/give_action(mob/living/L)
	. = ..()
	xeno_owner.endurance_health_max = xeno_owner.xeno_caste.max_health * 1.5
	xeno_owner.endurance_health = xeno_owner.endurance_health_max
	START_PROCESSING(SSprocessing, src)
	particle_holder = new(xeno_owner, /particles/conqueror_endurance)
	adjust_particles()

/datum/action/ability/xeno_action/conqueror_endurance/remove_action(mob/living/L)
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSprocessing, src)
	if(toggled)
		disable_ability()
	return ..()

/datum/action/ability/xeno_action/conqueror_endurance/clean_action()
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSprocessing, src)
	if(toggled)
		disable_ability()
	return ..()

/datum/action/ability/xeno_action/conqueror_endurance/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(xeno_owner.endurance_broken)
		return FALSE
	if(xeno_owner.endurance_active)
		return FALSE
	return TRUE

/datum/action/ability/xeno_action/conqueror_endurance/keybind_activation()
	if(can_use_action())
		INVOKE_ASYNC(src, PROC_REF(toggle_ability), TRUE)
	return COMSIG_KB_ACTIVATED

// Should only happen when clicking on the button. Toggle functionality.
/datum/action/ability/xeno_action/conqueror_endurance/action_activate()
	. = ..()
	toggle_ability()

// Should only happen when clicking on the button OR using the alternate keybind. Toggle functionality.
/datum/action/ability/xeno_action/conqueror_endurance/alternate_action_activate()
	. = ..()
	toggle_ability()

/datum/action/ability/xeno_action/conqueror_endurance/process()
	if(xeno_owner.stat == DEAD)
		if(datum_flags & DF_ISPROCESSING)
			STOP_PROCESSING(SSprocessing, src)
		RegisterSignal(xeno_owner, COMSIG_MOB_REVIVE, PROC_REF(restart_regen))
		return
	if(xeno_owner.endurance_health >= xeno_owner.endurance_health_max)
		return
	if(!xeno_owner.loc_weeds_type && !HAS_TRAIT(xeno_owner, TRAIT_INNATE_HEALING))
		return
	var/regen_amount = 1 + (xeno_owner.xeno_caste.max_health * 0.0375)
	if(xeno_owner.recovery_aura)
		regen_amount += (xeno_owner.recovery_aura * xeno_owner.xeno_caste.max_health * 0.01)
	if(xeno_owner.regen_power < 0)
		return
	regen_amount *= xeno_owner.regen_power
	xeno_owner.endurance_health = clamp(xeno_owner.endurance_health + regen_amount, 0, xeno_owner.endurance_health_max)
	if(xeno_owner.endurance_health >= xeno_owner.endurance_health_max && xeno_owner.endurance_broken)
		xeno_owner.endurance_broken = FALSE

/// Toggles the ability.
/datum/action/ability/xeno_action/conqueror_endurance/proc/toggle_ability(keybind = FALSE)
	SIGNAL_HANDLER
	if(toggled)
		disable_ability()
		return
	enable_ability(keybind)

/// Enables the ability.
/datum/action/ability/xeno_action/conqueror_endurance/proc/enable_ability(keybind)
	toggled = TRUE
	set_toggle(TRUE)
	xeno_owner.endurance_active = TRUE
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_CONQUEROR_ENDURANCE, TRUE, 0, NONE, TRUE, CONQUEROR_ENDURANCE_SPEED_MODIFIER)
	xeno_owner.xeno_caste.sunder_multiplier = CONQUEROR_ENDURANCE_SUNDER_MULTIPLIER
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(disable_ability))
	RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(reduce_damage))
	if(keybind && xeno_owner.client)
		RegisterSignal(xeno_owner.client, COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_UP, PROC_REF(toggle_ability))

/// Disables the ability.
/datum/action/ability/xeno_action/conqueror_endurance/proc/disable_ability()
	SIGNAL_HANDLER
	toggled = FALSE
	set_toggle(FALSE)
	xeno_owner.endurance_active = FALSE
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_CONQUEROR_ENDURANCE)
	xeno_owner.xeno_caste.sunder_multiplier = initial(xeno_owner.xeno_caste.sunder_multiplier)
	add_cooldown()
	UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	if(xeno_owner.client)
		UnregisterSignal(xeno_owner.client, COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_UP)

/// Reduces damage received and deduces that amount from this ability's health.
/datum/action/ability/xeno_action/conqueror_endurance/proc/reduce_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xeno_owner.stat || xeno_owner.lying_angle)
		return
	adjust_particles()
	amount_mod += amount * CONQUEROR_ENDURANCE_DAMAGE_REDUCTION
	xeno_owner.endurance_health = clamp(xeno_owner.endurance_health - amount, 0, xeno_owner.endurance_health_max)
	xeno_owner.hud_set_plasma()
	if(!xeno_owner.endurance_health)
		endurance_broken()

/// If this ability loses all of its health, it will knock down the user and prevent the ability from being used until it has regenerated.
/datum/action/ability/xeno_action/conqueror_endurance/proc/endurance_broken()
	disable_ability()
	xeno_owner.endurance_broken = TRUE
	INVOKE_ASYNC(xeno_owner, TYPE_PROC_REF(/mob, emote), "hiss1")
	xeno_owner.Knockdown(CONQUEROR_ENDURANCE_BROKEN_KNOCKDOWN)

/// Adjust particles and their visuals.
/datum/action/ability/xeno_action/conqueror_endurance/proc/adjust_particles()
	var/particles_dir = closest_cardinal_dir(xeno_owner.dir)
	particle_holder.particles.icon_state = "[xeno_owner.xeno_caste.caste_name] Blocking[particles_dir]"
	particle_holder.layer = xeno_owner.layer + 0.01
	particle_holder.pixel_y = xeno_owner.pixel_y + 16
	particle_holder.pixel_x = xeno_owner.pixel_x + 32
	particle_holder.alpha = initial(particle_holder.alpha)
	animate(particle_holder, alpha = 0, time = 0.2 SECONDS)

/// Restarts regeneration if the user died and was revived.
/datum/action/ability/xeno_action/conqueror_endurance/proc/restart_regen()
	SIGNAL_HANDLER
	START_PROCESSING(SSprocessing, src)

/particles/conqueror_endurance
	icon = 'icons/effects/particles/conqueror.dmi'
	width = 96
	height = 96
	count = 1
	spawning = 1
	lifespan = 1


// ***************************************
// *********** Conqueror's Domination
// ***************************************
#define CONQUEROR_DOMINATION_CASTING_RANGE 5 // The casting range for this ability, in tiles.
#define CONQUEROR_DOMINATION_CASTING_DELAY 1.2 SECONDS // The wind-up delay for this ability.
#define CONQUEROR_DOMINATION_EFFECT_RADIUS 2 // The radius for this ability's area of effect, in tiles.
#define CONQUEROR_DOMINATION_MAX_PUSH_RANGE 3 // How far can our ability knock back its victims.
#define CONQUEROR_DOMINATION_KNOCKDOWN 0.8 SECONDS // The stacks or duration of this ability's debuffs, if any.

/datum/action/ability/activable/xeno/conqueror_domination
	name = "Domination"
	desc = "Teleport towards a target location, distorting reality, and creating powerful shockwaves upon reappearing."
	action_icon = 'icons/Xeno/actions/king.dmi'
	action_icon_state = "conqueror_domination"
	ability_cost = 120
	cooldown_duration = 20 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_DOMINATION,
	)
	/// The radius of the area of effect.
	var/radius = CONQUEROR_DOMINATION_EFFECT_RADIUS
	/// The amount of deciseconds that the affected will be knocked down for.
	var/knockdown_duration = CONQUEROR_DOMINATION_KNOCKDOWN

/datum/action/ability/activable/xeno/conqueror_domination/on_cooldown_finish()
	. = ..()
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 30, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

/datum/action/ability/activable/xeno/conqueror_domination/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!xeno_owner.canmove)
		return FALSE
	if(xeno_owner.endurance_active)
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/conqueror_domination/use_ability(atom/atom_target)
	var/turf/turf_target = isturf(atom_target) ? atom_target : atom_target.loc
	if(isclosedturf(turf_target) || isspaceturf(turf_target) || isspacearea(get_area(turf_target)))
		xeno_owner.balloon_alert(xeno_owner, "Cannot go there")
		return
	if(!line_of_sight(xeno_owner, turf_target) || IS_OPAQUE_TURF(turf_target))
		xeno_owner.balloon_alert(xeno_owner, "No vision")
		return
	var/check_distance = min(CONQUEROR_DOMINATION_CASTING_RANGE, get_dist(xeno_owner, turf_target))
	var/list/valid_turfs = list()
	for(var/turf/turf_to_check AS in get_line(xeno_owner.loc, turf_target) - xeno_owner.loc)
		if(LinkBlocked(xeno_owner.loc, turf_to_check, xeno_owner.pass_flags))
			break
		valid_turfs += turf_to_check
	check_distance = min(length(valid_turfs), check_distance)
	var/list/turf/reappearance_turfs = filled_circle_turfs(valid_turfs[check_distance], radius)
	for(var/turf/turf_to_affect AS in reappearance_turfs)
		if(isclosedturf(turf_to_affect) || isspaceturf(turf_to_affect) || isspacearea(get_area(turf_to_affect)) || !line_of_sight(turf_target, turf_to_affect, radius, TRUE))
			reappearance_turfs -= turf_to_affect
			continue
		new /obj/effect/temp_visual/behemoth/warning/conqueror(turf_to_affect, CONQUEROR_DOMINATION_CASTING_DELAY)
	if(!check_distance || !length(reappearance_turfs))
		xeno_owner.balloon_alert(xeno_owner, "Cannot go there")
		return
	if(xeno_owner.buckled)
		xeno_owner.buckled.unbuckle_mob(xeno_owner, TRUE)
	xeno_owner.set_canmove(FALSE)
	xeno_owner.status_flags |= (GODMODE|INCORPOREAL)
	xeno_owner.add_pass_flags(PASS_GLASS|PASS_GRILLE|PASS_XENO|PASS_WALKOVER|PASS_TANK|PASSABLE|HOVERING, CONQUEROR_ABILITY_TRAIT)
	xeno_owner.alpha = 0
	playsound(xeno_owner.loc, 'sound/effects/alien/conqueror/domination_reappearance.ogg', 25, TRUE)
	new /obj/effect/temp_visual/conqueror/reappearance(xeno_owner.loc)
	xeno_owner.forceMove(valid_turfs[check_distance])
	addtimer(CALLBACK(src, PROC_REF(do_reappearance), reappearance_turfs), CONQUEROR_DOMINATION_CASTING_DELAY)
	add_cooldown()
	succeed_activate()

/// Does various effects upon reappearing.
/datum/action/ability/activable/xeno/conqueror_domination/proc/do_reappearance(list/turf/affected_turfs)
	xeno_owner.set_canmove(TRUE)
	xeno_owner.status_flags &= ~(GODMODE|INCORPOREAL)
	xeno_owner.remove_pass_flags(PASS_GLASS|PASS_GRILLE|PASS_XENO|PASS_WALKOVER|PASS_TANK|PASSABLE|HOVERING, CONQUEROR_ABILITY_TRAIT)
	xeno_owner.alpha = initial(xeno_owner.alpha)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_roar.ogg', 45, TRUE)
	playsound(xeno_owner.loc, 'sound/effects/alien/conqueror/domination_reappearance.ogg', 10, TRUE)
	new /obj/effect/temp_visual/conqueror/reappearance(xeno_owner.loc)
	playsound(xeno_owner.loc, 'sound/effects/alien/conqueror/domination_explosion.ogg', 8, TRUE)
	new /obj/effect/temp_visual/conqueror/domination(xeno_owner.loc)
	for(var/turf/affected_turf AS in affected_turfs)
		for(var/mob/mob_target in affected_turf)
			if(!isliving(mob_target) || mob_target.stat == DEAD || mob_target.issamexenohive(xeno_owner))
				continue
			var/distance = get_dist(mob_target, xeno_owner)
			if(distance)
				var/knockback_dist = clamp(CONQUEROR_DOMINATION_MAX_PUSH_RANGE - distance, 1, CONQUEROR_DOMINATION_MAX_PUSH_RANGE)
				mob_target.knockback(xeno_owner, knockback_dist, 1)
			var/mob/living/living_target = mob_target
			living_target.Knockdown(knockdown_duration)
			living_target.take_overall_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, xeno_owner.xeno_caste.melee_damage_type, MELEE, TRUE, TRUE, TRUE, xeno_owner.xeno_caste.melee_ap, 5)

/obj/effect/temp_visual/conqueror/reappearance
	icon = 'icons/effects/128x128.dmi'
	icon_state = "reappearance"
	duration = 6
	pixel_x = -49
	pixel_y = -30

/obj/effect/temp_visual/conqueror/domination
	icon = 'icons/effects/conqueror_domination.dmi'
	icon_state = "domination"
	duration = 7
	pixel_x = -70
	pixel_y = -28

/obj/effect/temp_visual/behemoth/warning/conqueror
	color = COLOR_VIOLET


// ***************************************
// *********** Conqueror's Obliteration
// ***************************************
#define CONQUEROR_OBLITERATION_SPEED_MODIFIER 2.0 // The speed modifier applied while the ability is channeling.
#define CONQUEROR_OBLITERATION_MAX_RANGE 3 // The maximum range for the initial AoE (and the warning). This is NOT a range limiter for the attacks themselves.
#define CONQUEROR_OBLITERATION_DAMAGE_MULTIPLIER 1.2 // Damage multiplier applied to this ability's attacks.
#define CONQUEROR_OBLITERATION_DEBUFF 1.2 // Amount of stacks applied on any given debuff.
#define CONQUEROR_OBLITERATION_ATTACK_DELAY 0.35 SECONDS // Delay between this ability's attacks.

/datum/action/ability/xeno_action/conqueror_obliteration
	name = "Obliteration"
	desc = "Unleash your latent power. Creates an area of effect that will slowly expand. Activating the ability again will attack everyone caught within it."
	action_type = ACTION_TOGGLE
	action_icon = 'icons/Xeno/actions/queen.dmi'
	action_icon_state = "screech"
	ability_cost = 150
	cooldown_duration = 20 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_HOLD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_TOGGLE,
	)
	/// The current range of the AoE.
	var/ability_range = 0
	/// Stores the visual effect for the AoE's warning.
	var/obj/effect/obliteration_warning/ability_warning
	/// List containing the targets that we will attack while executing this ability.
	var/list/mob/living/targets_to_attack = list()
	/// Timer ID. Stores the timer after which an attack will repeat.
	var/attack_timer

/datum/action/ability/xeno_action/conqueror_obliteration/remove_action(mob/living/L)
	if(toggled)
		end_ability()
	return ..()

/datum/action/ability/xeno_action/conqueror_obliteration/on_cooldown_finish()
	. = ..()
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 30, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

/datum/action/ability/xeno_action/conqueror_obliteration/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!xeno_owner.canmove)
		return FALSE
	if(xeno_owner.endurance_active)
		return FALSE
	return TRUE

/datum/action/ability/xeno_action/conqueror_obliteration/keybind_activation()
	if(can_use_action())
		if(toggled)
			INVOKE_ASYNC(src, PROC_REF(try_start_attack), TRUE)
		else
			INVOKE_ASYNC(src, PROC_REF(enable_ability), TRUE)
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/conqueror_obliteration/action_activate()
	. = ..()
	if(toggled)
		try_start_attack()
		return
	enable_ability()

/datum/action/ability/xeno_action/conqueror_obliteration/alternate_action_activate()
	. = ..()
	if(toggled)
		try_start_attack()
		return
	enable_ability()

/datum/action/ability/xeno_action/conqueror_obliteration/clean_action()
	if(toggled)
		end_ability()
	return ..()

/datum/action/ability/xeno_action/conqueror_obliteration/process()
	if(!can_use_action(TRUE))
		end_ability()
		return
	if(ability_range < CONQUEROR_OBLITERATION_MAX_RANGE)
		ability_range++
	if(!ability_warning)
		return
	var/matrix/new_matrix = matrix()
	var/effect_scale = 0.2 + (ability_range * 0.4)
	new_matrix.Scale(effect_scale, effect_scale)
	new_matrix.Translate(-49, -64)
	animate(ability_warning, time = 0, alpha = 255, color = initial(ability_warning.color), transform = new_matrix, flags = ANIMATION_END_NOW)
	animate(time = 1 SECONDS, alpha = 0, color = COLOR_BLACK)

/// Enables the abiity. If activated via the keybind, releasing it will move on to the next step.
/datum/action/ability/xeno_action/conqueror_obliteration/proc/enable_ability(keybind = FALSE)
	toggled = TRUE
	set_toggle(TRUE)
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_CONQUEROR_OBLITERATION, TRUE, 0, NONE, TRUE, CONQUEROR_OBLITERATION_SPEED_MODIFIER)
	ADD_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, CONQUEROR_OBLITERATION_TRAIT)
	ability_warning = new
	xeno_owner.vis_contents += ability_warning
	START_PROCESSING(SSprocessing, src)
	succeed_activate()
	RegisterSignals(xeno_owner, list(COMSIG_QDELETING, COMSIG_MOB_DEATH), PROC_REF(end_ability))
	if(keybind && xeno_owner.client)
		RegisterSignal(xeno_owner.client, COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_UP, PROC_REF(try_start_attack))

/// Checks if we meet the conditions to begin our attack, and tries to do so.
/datum/action/ability/xeno_action/conqueror_obliteration/proc/try_start_attack()
	SIGNAL_HANDLER
	if(xeno_owner.client)
		UnregisterSignal(xeno_owner.client, COMSIG_XENOABILITY_CONQUEROR_OBLITERATION_UP)
	STOP_PROCESSING(SSprocessing, src)
	if(ability_warning)
		xeno_owner.vis_contents -= ability_warning
		QDEL_NULL(ability_warning)
	if(!can_use_action(TRUE))
		end_ability()
		return
	for(var/turf/affected_turf AS in filled_circle_turfs(xeno_owner, ability_range))
		for(var/atom/movable/target in affected_turf)
			if(target.issamexenohive(xeno_owner) || !line_of_sight(xeno_owner, target, CONQUEROR_OBLITERATION_MAX_RANGE))
				continue
			if(isliving(target))
				var/mob/living/living_target = target
				if(living_target.stat == DEAD)
					continue
			//only attack mobs and vehicles
			else if(!isvehicle(target))
				continue
			targets_to_attack += target
			RegisterSignals(target, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(clear_ref))
	if(!length(targets_to_attack))
		end_ability()
		return
	if(xeno_owner.buckled)
		xeno_owner.buckled.unbuckle_mob(xeno_owner, TRUE)
	xeno_owner.alpha = 0
	xeno_owner.set_canmove(FALSE)
	xeno_owner.status_flags |= (GODMODE|INCORPOREAL)
	playsound(xeno_owner, 'sound/effects/alien/conqueror/obliteration_roar.ogg', 35, TRUE, 15)
	attack_targets()

/// Removes a target from the list and clears related signals.
/datum/action/ability/xeno_action/conqueror_obliteration/proc/clear_ref(datum/source)
	SIGNAL_HANDLER
	targets_to_attack -= source
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_Z_CHANGED))

/// Attacks all eligible targets, inflicting damage and creating visuals.
/datum/action/ability/xeno_action/conqueror_obliteration/proc/attack_targets()
	var/atom/movable/target = targets_to_attack[1]
	var/turf/new_turf = get_step_rand(target.loc)
	for(var/turf/turf_to_check AS in get_line(xeno_owner.loc, new_turf) - xeno_owner.loc)
		for(var/atom/atom_to_check AS in turf_to_check)
			if(atom_to_check.CanPass(xeno_owner, turf_to_check))
				new /obj/effect/temp_visual/conqueror/dash_trail(turf_to_check, get_dir(xeno_owner, target))
	playsound(new_turf, 'sound/effects/alien/behemoth/landslide_enhanced_charge.ogg', 8, TRUE)
	playsound(target, 'sound/effects/alien/conqueror/will_kick.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/punch(target.loc)
	xeno_owner.forceMove(new_turf)
	target.do_jitter_animation(700, CONQUEROR_OBLITERATION_DEBUFF)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.Immobilize(CONQUEROR_OBLITERATION_DEBUFF SECONDS)
		living_target.adjust_stagger(CONQUEROR_OBLITERATION_DEBUFF)
		living_target.adjust_slowdown(CONQUEROR_OBLITERATION_DEBUFF)
		living_target.apply_damage((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * CONQUEROR_OBLITERATION_DAMAGE_MULTIPLIER, BRUTE, 0, MELEE, TRUE, TRUE, TRUE, xeno_owner.xeno_caste.melee_ap, owner)
		INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "gored")
	else
		///not a mob so its an obj
		var/obj/obj_target = target
		obj_target.take_damage((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * CONQUEROR_OBLITERATION_DAMAGE_MULTIPLIER, BRUTE, MELEE,TRUE, get_dir(xeno_owner, obj_target), xeno_owner.xeno_caste.melee_ap, xeno_owner)
	UnregisterSignal(target, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_Z_CHANGED))
	targets_to_attack -= target
	if(length(targets_to_attack))
		attack_timer = addtimer(CALLBACK(src, PROC_REF(attack_targets)), CONQUEROR_OBLITERATION_ATTACK_DELAY, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return
	add_cooldown()
	end_ability()

/// Ends the ability.
/datum/action/ability/xeno_action/conqueror_obliteration/proc/end_ability()
	SIGNAL_HANDLER
	xeno_owner.playsound_local(xeno_owner.loc, 'sound/voice/hiss5.ogg', 20, TRUE)
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_CONQUEROR_OBLITERATION)
	REMOVE_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, CONQUEROR_OBLITERATION_TRAIT)
	STOP_PROCESSING(SSprocessing, src)
	ability_range = initial(ability_range)
	xeno_owner.alpha = initial(xeno_owner.alpha)
	xeno_owner.status_flags &= ~(GODMODE|INCORPOREAL)
	UnregisterSignal(xeno_owner, list(COMSIG_QDELETING, COMSIG_MOB_DEATH))
	if(toggled)
		toggled = FALSE
		set_toggle(FALSE)
	if(ability_warning)
		xeno_owner.vis_contents -= ability_warning
		QDEL_NULL(ability_warning)
	if(xeno_owner.client)
		UnregisterSignal(xeno_owner.client, COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_UP)
	if(!xeno_owner.canmove)
		xeno_owner.set_canmove(TRUE)
	if(length(targets_to_attack))
		for(var/atom/movable/ref_target AS in targets_to_attack)
			UnregisterSignal(ref_target, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_Z_CHANGED))
			targets_to_attack -= ref_target
	targets_to_attack = list()
	if(attack_timer)
		deltimer(attack_timer)

/obj/effect/obliteration_warning
	icon = 'icons/effects/160x160.dmi'
	icon_state = "obliteration_warning"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	appearance_flags = TILE_BOUND
	alpha = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	color = COLOR_VIOLET
