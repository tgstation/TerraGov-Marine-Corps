// ***************************************
// *********** Form Shift
// ***************************************
#define CRYOGEN_FORM_SHIFT_RANGE 2 // How far we can go with this ability.
#define CRYOGEN_FORM_SHIFT_SPEED 5 // How fast the ability happens.
#define CRYOGEN_FORM_SHIFT_DURATION 0.6 SECONDS // The duration for which we benefit from Form Shift's bonuses.

/datum/action/ability/activable/xeno/form_shift
	name = "Form Shift"
	desc = "Double tap any movement direction to dash towards it. Grants a brief period of invulnerability."
	action_icon = 'icons/Xeno/actions/runner.dmi'
	action_icon_state = "evasion"
	ability_cost = 50
	cooldown_duration = 3 SECONDS
	use_state_flags = ABILITY_IGNORE_COOLDOWN
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FORM_SHIFT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_FORM_SHIFT_CONFIGURE,
	)
	/// Whether the ability is active or not.
	var/ability_active = FALSE
	/// Attempting to toggle the ability while a cooldown is active sets a timer, after which it will actually try to toggle itself. This stores that timer.
	var/toggle_timer
	/// Stores the time at which we last moved.
	var/last_move_time
	/// Stores the direction of the last movement made.
	var/last_move_dir
	/// The timing for activating a dash by double tapping a movement key.
	var/double_tap_timing = 0.18 SECONDS
	/// Whether targeted usage is activated or not.
	var/targeted_usage = FALSE

/datum/action/ability/activable/xeno/form_shift/give_action(mob/living/L)
	. = ..()
	use_ability(silent = TRUE)

/datum/action/ability/activable/xeno/form_shift/remove_action(mob/living/L)
	use_ability(silent = TRUE)
	return ..()

/datum/action/ability/activable/xeno/form_shift/use_ability(atom/target_atom, silent = FALSE, force)
	if(targeted_usage)
		activate_dash(target_turf = get_turf(target_atom))
		return
	if(xeno_owner.stat == DEAD)
		return
	ability_active = !ability_active
	set_toggle(ability_active)
	if(!silent)
		xeno_owner.balloon_alert(xeno_owner, "Form Shift [ability_active ? "enabled" : "disabled"]")
	if(!ability_active)
		if(timeleft(toggle_timer))
			deltimer(toggle_timer)
			toggle_timer = null
		set_signals(FALSE)
		return
	if(cooldown_timer)
		toggle_timer = addtimer(CALLBACK(src, PROC_REF(set_signals), TRUE), timeleft(cooldown_timer), TIMER_STOPPABLE)
		return
	set_signals(TRUE)

/datum/action/ability/activable/xeno/form_shift/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(customize_ability))
	return COMSIG_KB_ACTIVATED

/datum/action/ability/activable/xeno/form_shift/proc/set_signals(toggle)
	if(!toggle)
		UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED, COMSIG_KB_MOVEMENT_EAST_DOWN, COMSIG_KB_MOVEMENT_NORTH_DOWN, COMSIG_KB_MOVEMENT_SOUTH_DOWN, COMSIG_KB_MOVEMENT_WEST_DOWN))
		return
	RegisterSignals(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(stop_ability))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_EAST_DOWN, PROC_REF(dash_east))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_NORTH_DOWN, PROC_REF(dash_north))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_SOUTH_DOWN, PROC_REF(dash_south))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_WEST_DOWN, PROC_REF(dash_west))

/// Checks if we can dash to the east.
/datum/action/ability/activable/xeno/form_shift/proc/dash_east()
	SIGNAL_HANDLER
	check_dash(EAST)

/// Checks if we can dash to the north.
/datum/action/ability/activable/xeno/form_shift/proc/dash_north()
	SIGNAL_HANDLER
	check_dash(NORTH)

/// Checks if we can dash to the south.
/datum/action/ability/activable/xeno/form_shift/proc/dash_south()
	SIGNAL_HANDLER
	check_dash(SOUTH)

/// Checks if we can dash to the west.
/datum/action/ability/activable/xeno/form_shift/proc/dash_west()
	SIGNAL_HANDLER
	check_dash(WEST)

/// Checks if we can dash in the specified direction, and activates the ability if so.
/datum/action/ability/activable/xeno/form_shift/proc/check_dash(direction)
	if(xeno_owner.plasma_stored < ability_cost)
		xeno_owner.balloon_alert(xeno_owner, "Not enough for [initial(name)]")
		return
	if(last_move_dir == direction && last_move_time + double_tap_timing > world.time)
		activate_dash(direction)
		return
	last_move_time = world.time
	last_move_dir = direction

/// Does a dash in the specified direction.
/datum/action/ability/activable/xeno/form_shift/proc/activate_dash(direction, turf/target_turf)
	animate(xeno_owner, alpha = 0, time = 0)
	animate(alpha = initial(xeno_owner.alpha), time = CRYOGEN_FORM_SHIFT_DURATION)
	new /obj/effect/temp_visual/after_image(get_turf(xeno_owner), xeno_owner)
	xeno_owner.pass_flags |= (PASS_GLASS|PASS_GRILLE|PASS_MOB|PASS_FIRE|PASS_XENO|PASS_PROJECTILE)
	xeno_owner.status_flags |= (GODMODE|INCORPOREAL)
	addtimer(CALLBACK(src, PROC_REF(end_dash)), CRYOGEN_FORM_SHIFT_DURATION)
	xeno_owner.throw_at(target_turf ? get_ranged_target_turf(xeno_owner, closest_cardinal_dir(angle2dir(Get_Angle(get_turf(xeno_owner), target_turf))), CRYOGEN_FORM_SHIFT_RANGE) : get_ranged_target_turf(xeno_owner, direction, CRYOGEN_FORM_SHIFT_RANGE), CRYOGEN_FORM_SHIFT_RANGE, CRYOGEN_FORM_SHIFT_SPEED, targetted_throw = FALSE, bounce = FALSE)
	last_move_time = 0
	last_move_dir = null
	add_cooldown()
	succeed_activate()
	if(!targeted_usage)// Ability usage is disabled until the cooldown has concluded. This prevents signals from firing, for the purposes of performance efficiency.
		set_signals(FALSE)
		toggle_timer = addtimer(CALLBACK(src, PROC_REF(set_signals), TRUE), timeleft(cooldown_timer), TIMER_STOPPABLE)

/// Gets rid of dash bonuses, if any.
/datum/action/ability/activable/xeno/form_shift/proc/end_dash()
	xeno_owner.pass_flags &= ~(PASS_GLASS|PASS_GRILLE|PASS_MOB|PASS_FIRE|PASS_XENO|PASS_PROJECTILE)
	xeno_owner.status_flags &= ~(GODMODE|INCORPOREAL)

/// Stops the ability altogether.
/datum/action/ability/activable/xeno/form_shift/proc/stop_ability()
	SIGNAL_HANDLER
	set_signals(FALSE)

/// Shows a radial menu to customize ability usage.
/datum/action/ability/activable/xeno/form_shift/proc/customize_ability()
	var/options_list = list(
		"Double Tap Timing" = image('icons/Xeno/actions/wraith.dmi', icon_state = "time_stop"),
		"Targeted Usage" = image('icons/Xeno/actions/widow.dmi', icon_state = "web_hook")
	)
	var/option_choice = show_radial_menu(xeno_owner, xeno_owner, options_list, radius = 35)
	if(!option_choice)
		return
	switch(option_choice)
		if("Double Tap Timing")
			var/timing = input(xeno_owner, "Specify the double tap timing IN SECONDS.", "Set Double Tap Timing", double_tap_timing * 0.1) as num
			if(timing)
				double_tap_timing = timing SECONDS
		if("Targeted Usage")
			targeted_usage = !targeted_usage
			xeno_owner.balloon_alert(xeno_owner, "Targeted Usage [targeted_usage ? "enabled" : "disabled"]")
			if(!targeted_usage)
				use_state_flags = initial(use_state_flags)
				keybind_flags = initial(keybind_flags)
				use_ability(silent = TRUE)
				return
			use_state_flags &= ~ABILITY_IGNORE_COOLDOWN
			keybind_flags &= ~(ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY)
			ability_active = FALSE
			set_toggle(FALSE)
			set_signals(FALSE)
			if(timeleft(toggle_timer))
				deltimer(toggle_timer)
				toggle_timer = null
	update_button_icon()


// ***************************************
// *********** Charge Shot
// ***************************************
#define CRYOGEN_CHARGE_SHOT_LEVEL_ONE 2
#define CRYOGEN_CHARGE_SHOT_LEVEL_TWO 4
#define CRYOGEN_CHARGE_SHOT_FULL_CHARGE_SIZE 1

/datum/action/ability/xeno_action/cryogen_shot
	name = "Charge Shot"
	desc = "to do"
	action_icon = 'icons/Xeno/actions/pyrogen.dmi'
	action_icon_state = "fireball"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CRYOGEN_SHOT,
	)
	/// Whether the ability is active or not.
	var/ability_active = FALSE
	///
	var/toggle_timer
	/// How much we've charged our projectile.
	var/charge_stored
	/// Whether auto-charge is active or not. Auto-Charge will automatically charge a shot without needing the player to hold down a button.
	var/auto_charge = FALSE

/datum/action/ability/xeno_action/cryogen_shot/give_action(mob/living/L)
	. = ..()
	action_activate(TRUE)

/datum/action/ability/xeno_action/cryogen_shot/remove_action(mob/living/L)
	action_activate(TRUE)
	return ..()

/datum/action/ability/xeno_action/cryogen_shot/action_activate(silent = FALSE)
	ability_active = !ability_active
	set_toggle(ability_active)
	if(!silent)
		xeno_owner.balloon_alert(xeno_owner, "Charge Shot [ability_active ? "enabled" : "disabled"]")
	if(!ability_active)
		set_signals(FALSE)
		STOP_PROCESSING(SSprocessing, src)
		charge_stored = 0
		return
	set_signals(TRUE)
	if(auto_charge)
		START_PROCESSING(SSprocessing, src)

/datum/action/ability/xeno_action/cryogen_shot/alternate_action_activate(silent = FALSE)
	auto_charge = !auto_charge
	if(!silent)
		xeno_owner.balloon_alert(xeno_owner, "Auto Charge [auto_charge ? "enabled" : "disabled"]")
	if(!auto_charge)
		if(charge_stored)
			UnregisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN)
			RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP, PROC_REF(fire_charge))
			return
		UnregisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP)
		RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_charge))
		return
	UnregisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP)
	RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(fire_charge))

/datum/action/ability/xeno_action/cryogen_shot/proc/set_signals(toggle)
	message_admins("cryogen_shot/set_signals([toggle])")
	UnregisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP)
	if(!toggle)
		UnregisterSignal(xeno_owner, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
		return
	//RegisterSignals(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(stop_ability))
	if(auto_charge)
		RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(fire_charge))
		return
	RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_charge))

/datum/action/ability/xeno_action/cryogen_shot/proc/start_charge()
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN)
	RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP, PROC_REF(fire_charge))
	START_PROCESSING(SSprocessing, src)

/datum/action/ability/xeno_action/cryogen_shot/proc/fire_charge(datum/source, atom/atom_target, turf/turf_target)
	SIGNAL_HANDLER
	STOP_PROCESSING(SSprocessing, src)
	if(charge_stored < CRYOGEN_CHARGE_SHOT_LEVEL_ONE)
		charge_stored = 0
		UnregisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP)
		RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_charge))
		return
	set_signals(FALSE)
	var/datum/ammo/xeno/cryogen_shot/projectile = GLOB.ammo_list[/datum/ammo/xeno/cryogen_shot/mid_charge]
	if(charge_stored >= CRYOGEN_CHARGE_SHOT_LEVEL_TWO)
	projectile = GLOB.ammo_list[/datum/ammo/xeno/cryogen_shot/full_charge]
	var/source_turf = get_turf(xeno_owner)
	var/obj/projectile/new_projectile = new /obj/projectile(source_turf)
	new_projectile.generate_bullet(projectile)
	new_projectile.fire_at(atom_target ? atom_target : turf_target, xeno_owner, source_turf, new_projectile.ammo.max_range)
	add_cooldown((cooldown_duration * charge_stored) / CRYOGEN_CHARGE_SHOT_LEVEL_ONE)
	succeed_activate()
	toggle_timer = addtimer(CALLBACK(src, PROC_REF(set_signals), TRUE), timeleft(cooldown_timer), TIMER_STOPPABLE)
	message_admins("cryogen_shot/fire_charge([source], [atom_target], [turf_target])")
	charge_stored = 0

/datum/action/ability/xeno_action/cryogen_shot/process()
	charge_stored++
	if(charge_stored == CRYOGEN_CHARGE_SHOT_LEVEL_TWO)
		message_admins("level 2")
		STOP_PROCESSING(SSprocessing, src)
		return
	if(charge_stored == CRYOGEN_CHARGE_SHOT_LEVEL_ONE)
		message_admins("level 1")
		return
	//do something

/datum/ammo/xeno/cryogen_shot
	name = "cryogen shot"
	icon_state = "earth_pillar"
	ping = null
	damage_type = BURN
	armor_type = FIRE
	ammo_behavior_flags = AMMO_XENO|AMMO_ENERGY|AMMO_SKIPS_ALIENS
	bullet_color = COLOR_PULSE_BLUE
	damage_falloff = 0

/datum/ammo/xeno/cryogen_shot/mid_charge
	damage = 15
	slowdown_stacks = 3

/datum/ammo/xeno/cryogen_shot/full_charge
	ammo_behavior_flags = AMMO_XENO|AMMO_ENERGY|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF|AMMO_PASS_THROUGH_MOVABLE
	slowdown_stacks = 5

/datum/ammo/xeno/cryogen_shot/full_charge/do_at_max_range(turf/target_turf, obj/projectile/proj)
	return on_hit_anything(target_turf, proj)

/datum/ammo/xeno/cryogen_shot/full_charge/on_hit_turf(turf/target_turf, obj/projectile/proj)
	return on_hit_anything(target_turf, proj)

/datum/ammo/xeno/cryogen_shot/full_charge/on_hit_obj(obj/target_obj, obj/projectile/proj)
	return on_hit_anything(get_turf(target_obj), proj)

/datum/ammo/xeno/cryogen_shot/full_charge/on_hit_mob(mob/target_mob, obj/projectile/proj)
	return on_hit_anything(get_turf(target_mob), proj)

/datum/ammo/xeno/cryogen_shot/full_charge/proc/on_hit_anything(turf/target_turf, obj/projectile/proj)
	//play a sound
	//visual effects
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	for(var/turf/affected_turf AS in RANGE_TURFS(CRYOGEN_CHARGE_SHOT_FULL_CHARGE_SIZE, target_turf))
		if(isclosedturf(target_turf))
			continue
		for(var/atom/movable/affected_movable AS in affected_turf)
			if(isliving(affected_movable))
				var/mob/living/affected_living = affected_movable
				if(xeno_firer.issamexenohive(affected_living) || affected_living.stat == DEAD || CHECK_BITFIELD(affected_living.status_flags, INCORPOREAL|GODMODE))
					continue
				affected_living.emote("scream")
				affected_living.Knockdown(0.1 SECONDS)
			if(istype(affected_movable, /obj/fire))
				var/obj/fire/affected_fire = affected_movable
				qdel(affected_fire)
