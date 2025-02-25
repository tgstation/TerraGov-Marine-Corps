/obj/effect/temp_visual/conqueror
	icon = 'icons/effects/64x64.dmi'
	pixel_x = -16
	pixel_y = -16

/obj/effect/temp_visual/conqueror/Initialize(mapload, new_layer)
	. = ..()
	layer = new_layer


// ***************************************
// *********** Overrides
// ***************************************
/datum/action/ability/activable/xeno/psydrain/conqueror
	ability_cost = 0

/datum/action/ability/xeno_action/hive_message/conqueror
	ability_cost = 0


// ***************************************
// *********** Conqueror's Dash
// ***************************************
#define CONQUEROR_DASH_RANGE 2 // How far we can go with this ability.
#define CONQUEROR_DASH_SPEED 5 // How fast the ability happens.

/datum/action/ability/xeno_action/conqueror_dash
	name = "Dash"
	desc = "Double tap any movement direction to dash towards it."
	action_type = ACTION_TOGGLE
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "rewind"
	cooldown_duration = 5 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_DASH,
	)
	/// Stores the time at which we last moved.
	var/last_move_time
	/// Stores the direction of the last movement made.
	var/last_move_dir
	/// The timing for activating a dash by double tapping a movement key.
	var/double_tap_timing = 0.18 SECONDS

/datum/action/ability/xeno_action/conqueror_dash/give_action(...)
	. = ..()
	toggled = TRUE
	set_toggle(TRUE)
	enable_ability()

/datum/action/ability/xeno_action/conqueror_dash/remove_action(...)
	toggled = FALSE
	set_toggle(FALSE)
	disable_ability()
	return ..()

/datum/action/ability/xeno_action/conqueror_dash/action_activate()
	toggled = !toggled
	set_toggle(toggled)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] [toggled ? "enabled" : "disabled"]")
	if(!toggled)
		disable_ability()
		return
	enable_ability()

/datum/action/ability/xeno_action/conqueror_dash/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(set_timing))

/datum/action/ability/xeno_action/conqueror_dash/clean_action()
	disable_ability()
	return ..()

/// Enables the ability.
/datum/action/ability/xeno_action/conqueror_dash/proc/enable_ability()
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(disable_ability))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_EAST_DOWN, PROC_REF(dash_east))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_NORTH_DOWN, PROC_REF(dash_north))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_SOUTH_DOWN, PROC_REF(dash_south))
	RegisterSignal(xeno_owner, COMSIG_KB_MOVEMENT_WEST_DOWN, PROC_REF(dash_west))

/// Disables the ability.
/datum/action/ability/xeno_action/conqueror_dash/proc/disable_ability()
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_KB_MOVEMENT_EAST_DOWN, COMSIG_KB_MOVEMENT_NORTH_DOWN, COMSIG_KB_MOVEMENT_SOUTH_DOWN, COMSIG_KB_MOVEMENT_WEST_DOWN))

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
	if(xeno_owner.stat || xeno_owner.lying_angle)
		return
	if(ability_cost && xeno_owner.plasma_stored < ability_cost)
		xeno_owner.balloon_alert(xeno_owner, "Not enough for [initial(name)]")
		return
	if(last_move_dir == direction && last_move_time + double_tap_timing > world.time)
		activate_dash(direction)
		return
	last_move_time = world.time
	last_move_dir = direction

/// Does a dash in the specified direction.
/datum/action/ability/xeno_action/conqueror_dash/proc/activate_dash(direction)
	xeno_owner.pass_flags |= (PASS_MOB|PASS_FIRE|PASS_XENO|PASS_PROJECTILE)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(leave_afterimage))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(end_dash))
	playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_enhanced_charge.ogg', 10, TRUE)
	xeno_owner.throw_at(get_ranged_target_turf(xeno_owner, direction, CONQUEROR_DASH_RANGE), CONQUEROR_DASH_RANGE, CONQUEROR_DASH_SPEED, targetted_throw = FALSE, impact_bounce = FALSE)
	last_move_time = 0
	last_move_dir = null
	add_cooldown()
	succeed_activate()
	disable_ability() // Ability usage is disabled until the cooldown has concluded. This prevents signals from firing, for the purposes of performance efficiency.
	addtimer(CALLBACK(src, PROC_REF(enable_ability)), cooldown_duration)

/datum/action/ability/xeno_action/conqueror_dash/proc/leave_afterimage(datum/source, old_loc)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/after_image/conqueror(old_loc, xeno_owner)

/// Gets rid of dash bonuses, if any.
/datum/action/ability/xeno_action/conqueror_dash/proc/end_dash()
	SIGNAL_HANDLER
	xeno_owner.pass_flags &= ~(PASS_MOB|PASS_FIRE|PASS_XENO|PASS_PROJECTILE)
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_POST_THROW))

/// Opens an input window to allow customization of the double tap timing.
/datum/action/ability/xeno_action/conqueror_dash/proc/set_timing()
	var/timing = input(xeno_owner, "Specify the double tap timing IN SECONDS.", "Set Double Tap Timing", double_tap_timing * 0.1) as num
	if(timing)
		double_tap_timing = timing SECONDS
	return COMSIG_KB_ACTIVATED

/obj/effect/temp_visual/after_image/conqueror
	alpha = 255


// ***************************************
// *********** Conqueror's Will
// ***************************************
#define CONQUEROR_WILL_MELEE_AP 15
#define CONQUEROR_WILL_ATTACK_SPEED 1
#define CONQUEROR_WILL_ATTACK_RANGE 2
#define CONQUEROR_WILL_MAX_COMBO 3
#define CONQUEROR_WILL_RESET_TIME 6 SECONDS
#define CONQUEROR_WILL_PUNCH_DEBUFF 1.6 SECONDS
#define CONQUEROR_WILL_JAB_MULTIPLIER 0.2 // 20%
#define CONQUEROR_WILL_JAB_PENETRATION 100
#define CONQUEROR_WILL_KICK_DEBUFF 0.5 SECONDS
#define CONQUEROR_WILL_KICK_PUSH 3 //in tiles

// Combo defines. L represents left click, and R represents right click.
#define COMBO_LEFT_RIGHT "LR"
#define COMBO_RIGHT_LEFT "RL"
#define COMBO_LEFT_LEFT "LL"
#define COMBO_RIGHT_RIGHT "RR"

/datum/action/ability/activable/xeno/conqueror_will
	name = "Conqueror's Will"
	desc = "Upgrades slash attacks. Left and right click can be strung together to make combos. Results vary based on input order."
	action_icon = 'icons/Xeno/actions/warrior.dmi'
	action_icon_state = "punch"
	cooldown_duration = 10 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_IGNORE_COOLDOWN|ABILITY_DO_AFTER_ATTACK
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_WILL,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_CONQUEROR_WILL_ALT,
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

/datum/action/ability/activable/xeno/conqueror_will/give_action(...)
	. = ..()
	particle_holder = new(xeno_owner, /particles/conqueror_will)
	adjust_particles(xeno_owner, xeno_owner.dir, xeno_owner.dir)
	enable_ability()

/datum/action/ability/activable/xeno/conqueror_will/remove_action(...)
	disable_ability()
	QDEL_NULL(particle_holder)
	return ..()

/datum/action/ability/activable/xeno/conqueror_will/on_cooldown_finish()
	. = ..()
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 35, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

/// Toggles the combo display.
/datum/action/ability/activable/xeno/conqueror_will/alternate_action_activate()
	display_combos = !display_combos
	xeno_owner.balloon_alert(xeno_owner, "Combo display [display_combos ? "enabled" : "disabled"]")
	if(!display_combos)
		xeno_owner.hud_used?.combo_display.reset_icons()
	return COMSIG_KB_ACTIVATED

/datum/action/ability/activable/xeno/conqueror_will/clean_action()
	disable_ability()
	QDEL_NULL(particle_holder)
	return ..()

/// Enables the ability.
/datum/action/ability/activable/xeno/conqueror_will/proc/enable_ability()
	particle_holder.alpha = initial(particle_holder.alpha)
	adjust_particles(xeno_owner, xeno_owner.dir, xeno_owner.dir)
	RegisterSignals(xeno_owner, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DO_RESIST, COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST), PROC_REF(adjust_particles))
	RegisterSignal(xeno_owner, COMSIG_MOB_CLICKON, PROC_REF(check_range)) // Happens before the xeno actually attacks.
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(add_to_attack))
	RegisterSignals(xeno_owner, list(COMSIG_MOB_DEATH), PROC_REF(disable_ability))
	xeno_owner.xeno_caste.melee_ap += CONQUEROR_WILL_MELEE_AP
	xeno_owner.xeno_caste.attack_delay -= CONQUEROR_WILL_ATTACK_SPEED

/// Disables the ability.
/datum/action/ability/activable/xeno/conqueror_will/proc/disable_ability()
	SIGNAL_HANDLER
	particle_holder.alpha = 0
	UnregisterSignal(xeno_owner, list(COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DO_RESIST, COMSIG_XENOMORPH_REST, COMSIG_XENOMORPH_UNREST, COMSIG_MOB_CLICKON, COMSIG_XENOMORPH_POSTATTACK_LIVING, COMSIG_MOB_DEATH))
	xeno_owner.xeno_caste.melee_ap -= CONQUEROR_WILL_MELEE_AP
	xeno_owner.xeno_caste.attack_delay += CONQUEROR_WILL_ATTACK_SPEED
	reset_combo()

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

/// Checks if the target is within the specified range. If true, the user will be moved towards them.
/datum/action/ability/activable/xeno/conqueror_will/proc/check_range(datum/source, atom/atom_target)
	SIGNAL_HANDLER
	if(!iscarbon(atom_target) || atom_target.issamexenohive(xeno_owner) || xeno_owner.a_intent == INTENT_HELP || xeno_owner.fortify || xeno_owner.stat || xeno_owner.lying_angle || world.time <= xeno_owner.next_move)
		return
	var/mob/living/carbon/carbon_target = atom_target
	if(carbon_target.stat == DEAD)
		return
	if(!line_of_sight(xeno_owner, carbon_target, CONQUEROR_WILL_ATTACK_RANGE))
		return
	var/distance = get_dist(xeno_owner, carbon_target)
	if(distance <= 1 || distance > CONQUEROR_WILL_ATTACK_RANGE)
		return
	for(var/i in 1 to CONQUEROR_WILL_ATTACK_RANGE - 1)
		step_towards(xeno_owner, carbon_target, 1)

/// Adds bonuses to normal attacks, usually replacing visuals and sound effects, and builds up combos if the ability isn't on cooldown.
/datum/action/ability/activable/xeno/conqueror_will/proc/add_to_attack(datum/source, mob/living/living_target, attack_damage, damage_mod, isrightclick)
	SIGNAL_HANDLER
	if(!iscarbon(living_target))
		return
	if(action_cooldown_check() && xeno_owner.selected_ability == src)
		combo_streak += isrightclick ? "R" : "L"
		if(display_combos)
			xeno_owner.hud_used?.combo_display.update_icon_state(combo_streak, CONQUEROR_WILL_RESET_TIME - 2 SECONDS)
	var/visual_layer = living_target.layer + 0.1
	if(length(combo_streak) < CONQUEROR_WILL_MAX_COMBO)
		no_combo(living_target, visual_layer)
		if(action_cooldown_check() && xeno_owner.selected_ability == src)
			reset_timer = addtimer(CALLBACK(src, PROC_REF(reset_combo), FALSE), CONQUEROR_WILL_RESET_TIME, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
			warning_timer = addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, playsound_local), xeno_owner, 'sound/voice/hiss4.ogg', 25, TRUE), CONQUEROR_WILL_RESET_TIME - 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return CANCEL_FX
	var/combo_check = CONQUEROR_WILL_MAX_COMBO - 1
	if(findtext(combo_streak, COMBO_LEFT_RIGHT, combo_check))
		combo_punch(living_target, visual_layer)
	else if(findtext(combo_streak, COMBO_RIGHT_LEFT, combo_check))
		combo_uppercut(living_target, visual_layer)
	else if(findtext(combo_streak, COMBO_LEFT_LEFT, combo_check))
		combo_jab(living_target, visual_layer)
	else if(findtext(combo_streak, COMBO_RIGHT_RIGHT, combo_check))
		combo_kick(living_target, visual_layer)
	playsound(living_target, 'sound/effects/alien/conqueror/conqueror_will_extra3.ogg', 20, TRUE)
	playsound(xeno_owner, 'sound/voice/alien/roar2.ogg', 20, TRUE)
	reset_combo()
	add_cooldown() // need to test shit, restore this when done
	return CANCEL_FX

/// Resets any ongoing combos.
/datum/action/ability/activable/xeno/conqueror_will/proc/reset_combo(silent = TRUE)
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
/datum/action/ability/activable/xeno/conqueror_will/proc/no_combo(mob/living/living_target, visual_layer)
	playsound(living_target, SFX_CONQUEROR_WILL_HOOK, 35, TRUE)
	playsound(living_target, SFX_CONQUEROR_WILL_EXTRA, 15, TRUE)
	new /obj/effect/temp_visual/conqueror/hook(get_turf(living_target), visual_layer)

/// A well delivered punch to a weak point, incapacitating the target for the duration.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_punch(mob/living/living_target, visual_layer)
	playsound(living_target, 'sound/effects/alien/conqueror/conqueror_will_punch.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/punch(get_turf(living_target), visual_layer)
	living_target.Immobilize(CONQUEROR_WILL_PUNCH_DEBUFF)
	step_away(living_target, xeno_owner)
	living_target.do_attack_animation(get_step(living_target, REVERSE_DIR(get_dir(living_target, xeno_owner))))
	living_target.do_jitter_animation(700, CONQUEROR_WILL_PUNCH_DEBUFF / 10)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "gored")

/// A strong uppercut that knocks the target upwards, incapacitating them for the duration.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_uppercut(mob/living/living_target, visual_layer)
	playsound(living_target, 'sound/effects/alien/conqueror/conqueror_will_uppercut.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/uppercut(get_turf(living_target), visual_layer)
	living_target.Immobilize(CONQUEROR_WILL_PUNCH_DEBUFF * 0.8)
	if(!(living_target.pass_flags & PASS_MOB))
		living_target.pass_flags |= PASS_MOB
	step_away(living_target, xeno_owner)
	addtimer(CALLBACK(src, PROC_REF(uppercut_landing), living_target), CONQUEROR_WILL_PUNCH_DEBUFF * 0.8)
	animate(living_target, pixel_y = living_target.pixel_y + 50, time = CONQUEROR_WILL_PUNCH_DEBUFF * 0.4, easing = SINE_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_y = living_target.pixel_y - 50, time = CONQUEROR_WILL_PUNCH_DEBUFF * 0.4, easing = SINE_EASING|EASE_OUT)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "gored")

/// After the target lands, certain traits are reset, and the rest of the effects are applied.
/datum/action/ability/activable/xeno/conqueror_will/proc/uppercut_landing(mob/living/living_target)
	if(!living_target)
		return
	if(living_target.pass_flags & PASS_MOB)
		living_target.pass_flags &= ~PASS_MOB
	playsound(living_target, 'sound/effects/alien/conqueror/conqueror_will_uppercut_landing.ogg', 30, TRUE)
	new /obj/effect/temp_visual/conqueror/uppercut_landing(get_turf(living_target), living_target.layer - 0.1)
	living_target.Knockdown(CONQUEROR_WILL_PUNCH_DEBUFF * 0.2)

/// A flurry of rapid and precise strikes, dealing additional damage.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_jab(mob/living/living_target, visual_layer)
	playsound(living_target, 'sound/effects/alien/conqueror/conqueror_will_jab.ogg', 40, TRUE)
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(playsound), living_target, 'sound/effects/alien/conqueror/conqueror_will_extra3.ogg', 15, TRUE), 0.2 SECONDS)
	new /obj/effect/temp_visual/conqueror/hook/jab/initial(get_turf(living_target), visual_layer)
	var/jab_damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * CONQUEROR_WILL_JAB_MULTIPLIER
	var/jab_zone = xeno_owner.get_limb(xeno_owner.zone_selected)
	living_target.apply_damage(jab_damage, BRUTE, jab_zone, MELEE, TRUE, TRUE, TRUE, CONQUEROR_WILL_JAB_PENETRATION)
	living_target.do_attack_animation(get_step(living_target, REVERSE_DIR(get_dir(living_target, xeno_owner))))
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "pain")

/// A mighty kick that sends the target flying. If they collide with another atom, that atom is also affected.
/datum/action/ability/activable/xeno/conqueror_will/proc/combo_kick(mob/living/living_target, visual_layer)
	playsound(living_target, 'sound/effects/alien/conqueror/conqueror_will_kick.ogg', 40, TRUE)
	new /obj/effect/temp_visual/conqueror/hook/kick(get_turf(living_target), visual_layer)
	if(!(living_target.pass_flags & PASS_XENO))
		living_target.pass_flags |= PASS_XENO
	RegisterSignal(living_target, COMSIG_MOVABLE_IMPACT, PROC_REF(kicked_into))
	RegisterSignal(living_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(kicked_end))
	var/push_direction = get_dir(xeno_owner, living_target)
	living_target.throw_at(get_ranged_target_turf(xeno_owner, push_direction, CONQUEROR_WILL_KICK_PUSH), CONQUEROR_WILL_KICK_PUSH, 1, xeno_owner, TRUE)
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")

/// If the target collides into another atom, that atom is affected. Taken from Warrior code.
/datum/action/ability/activable/xeno/conqueror_will/proc/kicked_into(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/mob/living/living_target = source
	living_target.Knockdown(CONQUEROR_WILL_KICK_DEBUFF)
	new /obj/effect/temp_visual/warrior/impact(get_turf(living_target), get_dir(living_target, xeno_owner))
	if(!isliving(hit_atom))
		return
	var/mob/living/hit_living = hit_atom
	if(hit_living.issamexenohive(xeno_owner))
		return
	INVOKE_ASYNC(hit_living, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(hit_living, 'sound/weapons/punch1.ogg', 30, TRUE)
	hit_living.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, BRUTE, 0, MELEE, TRUE, TRUE, TRUE, xeno_owner.xeno_caste.melee_ap)
	hit_living.Knockdown(CONQUEROR_WILL_KICK_DEBUFF)
	step_away(hit_living, living_target, 1, 1)

/// Ends the target's throw. Taken from Warrior code.
/datum/action/ability/activable/xeno/conqueror_will/proc/kicked_end(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	/* So the reason why we do not flat out unregister this is because, when an atom makes impact with something, it calls throw_impact(). Calling it this way causes
	stop_throw() to be called in most cases, because impacts can cause a bounce effect and ending the throw makes it happen. Given the way we have signals setup, unregistering
	it at that point would cause thrown_into() to never get called, and that is exactly the reason why the line of code below exists. */
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, UnregisterSignal), source, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW), 0.5)
	var/mob/living/living_target = source
	living_target.Knockdown(CONQUEROR_WILL_KICK_DEBUFF)
	if(living_target.pass_flags & PASS_XENO)
		living_target.pass_flags &= ~PASS_XENO

/particles/conqueror_will
	icon = 'icons/effects/particles/conqueror.dmi'
	icon_state = "Conqueror2"
	width = 96
	height = 96
	count = 5
	spawning = 1
	lifespan = 3
	fade = 3
	grow = 0.13
	color = "#B200FF"

/obj/effect/temp_visual/conqueror/hook
	icon_state = "conqueror_hook"
	duration = 2.5

/obj/effect/temp_visual/conqueror/hook/Initialize(mapload, new_layer)
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
	duration = 3.6

/obj/effect/temp_visual/conqueror/hook/jab/Initialize(mapload, ...)
	. = ..()
	pixel_x += rand(-5, 5)
	pixel_y += rand(-5, 5)

/obj/effect/temp_visual/conqueror/hook/jab/initial/Initialize(mapload, layer)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(repeat_effect)), 0.2 SECONDS)

/// Repeats the visual effect. This really just spawns another.
/obj/effect/temp_visual/conqueror/hook/jab/initial/proc/repeat_effect()
	new /obj/effect/temp_visual/conqueror/hook/jab/duplicate(get_turf(src), layer)

/obj/effect/temp_visual/conqueror/hook/jab/duplicate

/obj/effect/temp_visual/conqueror/hook/uppercut
	icon_state = "conqueror_uppercut"
	duration = 4.4
	pixel_y = 2

/obj/effect/temp_visual/conqueror/uppercut_landing
	icon_state = "behemoth_stomp"
	duration = 5

/obj/effect/temp_visual/conqueror/uppercut_landing/Initialize(mapload, new_layer)
	. = ..()
	layer = new_layer
	var/matrix/current_matrix = matrix()
	current_matrix.Scale(2.2, 2.2)
	animate(src, alpha = 0, transform = matrix().Scale(0.6, 0.6), time = duration - 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/conqueror/hook/kick
	icon_state = "conqueror_kick"
	duration = 4.4

/obj/effect/temp_visual/conqueror/endurance_combo
	icon = 'icons/effects/128x128.dmi'
	icon_state = "endurance_combo"
	duration = 5.9
	pixel_x = -32
	pixel_y = -46


// ***************************************
// *********** Conqueror's Endurance
// ***************************************
#define CONQUEROR_ENDURANCE_SPEED_MODIFIER 2.5
#define CONQUEROR_ENDURANCE_SUNDER_MULTIPLIER 0
#define CONQUEROR_ENDURANCE_DAMAGE_REDUCTION 0.5 // 50%

/datum/action/ability/xeno_action/conqueror_endurance
	name = "Endurance"
	desc = "Blocks attacks, reducing damage received."
	action_type = ACTION_TOGGLE
	action_icon = 'icons/Xeno/actions/defender.dmi'
	action_icon_state = "fortify"
	cooldown_duration = 2 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED|ABILITY_USE_FORTIFIED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_ENDURANCE,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/xeno_action/conqueror_endurance/give_action(...)
	. = ..()
	particle_holder = new(xeno_owner, /particles/conqueror_endurance)
	adjust_particles()

/datum/action/ability/xeno_action/conqueror_endurance/remove_action(...)
	if(toggled)
		disable_ability()
	return ..()

/datum/action/ability/xeno_action/conqueror_endurance/keybind_activation()
	if(can_use_action())
		INVOKE_ASYNC(src, PROC_REF(toggle_ability), TRUE)
	return COMSIG_KB_ACTIVATED

/datum/action/ability/xeno_action/conqueror_endurance/action_activate()
	toggle_ability()

/datum/action/ability/xeno_action/conqueror_endurance/clean_action()
	if(toggled)
		disable_ability()
	return ..()

/// Toggles the ability.
/datum/action/ability/xeno_action/conqueror_endurance/proc/toggle_ability(keybind = FALSE)
	SIGNAL_HANDLER
	toggled = !toggled
	set_toggle(toggled)
	xeno_owner.fortify = !xeno_owner.fortify
	if(!toggled)
		disable_ability()
		add_cooldown()
		return
	enable_ability(keybind)

/// Enables the ability.
/datum/action/ability/xeno_action/conqueror_endurance/proc/enable_ability(keybind)
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_CONQUEROR_ENDURANCE, TRUE, 0, NONE, TRUE, CONQUEROR_ENDURANCE_SPEED_MODIFIER)
	xeno_owner.xeno_caste.sunder_multiplier = CONQUEROR_ENDURANCE_SUNDER_MULTIPLIER
	ADD_TRAIT(xeno_owner, TRAIT_STUNIMMUNE, FORTIFY_TRAIT)
	ADD_TRAIT(xeno_owner, TRAIT_STAGGERIMMUNE, FORTIFY_TRAIT)
	ADD_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, FORTIFY_TRAIT)
	RegisterSignals(xeno_owner, list(COMSIG_MOB_DEATH), PROC_REF(disable_ability))
	RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(reduce_damage))
	if(keybind && xeno_owner.client)
		RegisterSignal(xeno_owner.client, COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_UP, PROC_REF(toggle_ability))

/// Disables the ability.
/datum/action/ability/xeno_action/conqueror_endurance/proc/disable_ability()
	SIGNAL_HANDLER
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_CONQUEROR_ENDURANCE)
	xeno_owner.xeno_caste.sunder_multiplier = initial(xeno_owner.xeno_caste.sunder_multiplier)
	REMOVE_TRAIT(xeno_owner, TRAIT_STUNIMMUNE, FORTIFY_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_STAGGERIMMUNE, FORTIFY_TRAIT)
	REMOVE_TRAIT(xeno_owner, TRAIT_NOPLASMAREGEN, FORTIFY_TRAIT)
	UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE, COMSIG_XENOABILITY_CONQUEROR_ENDURANCE_UP))

/// Reduces damage received.
/datum/action/ability/xeno_action/conqueror_endurance/proc/reduce_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || xeno_owner.stat || xeno_owner.lying_angle)
		return
	amount_mod += amount * CONQUEROR_ENDURANCE_DAMAGE_REDUCTION
	adjust_particles()

/// Adjust particles and their visuals.
/datum/action/ability/xeno_action/conqueror_endurance/proc/adjust_particles()
	var/particles_dir = closest_cardinal_dir(xeno_owner.dir)
	particle_holder.particles.icon_state = "[xeno_owner.xeno_caste.caste_name] Blocking[particles_dir]"
	particle_holder.layer = xeno_owner.layer + 0.01
	particle_holder.pixel_y = xeno_owner.pixel_y + 16
	particle_holder.pixel_x = xeno_owner.pixel_x + 32
	particle_holder.alpha = initial(particle_holder.alpha)
	animate(particle_holder, alpha = 0, time = 0.2 SECONDS)

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
#define CONQUEROR_DOMINATION_CASTING_RANGE 5
#define CONQUEROR_DOMINATION_LEAP_SPEED 1
#define CONQUEROR_DOMINATION_EFFECT_RANGE 2
#define CONQUEROR_DOMINATION_MAX_PUSH_RANGE 3
#define CONQUEROR_DOMINATION_DEBUFF 2
#define CONQUEROR_DOMINATION_DAMAGE_MULTIPLIER 1.2
#define CONQUEROR_DOMINATION_DAMAGE_FALLOFF 4

/datum/action/ability/activable/xeno/conqueror_domination
	name = "Domination"
	desc = "Jump towards a target location, creating a large shockwave and affecting foes around you."
	action_icon = 'icons/Xeno/actions/wraith.dmi'
	action_icon_state = "Banish"
	cooldown_duration = 1 SECONDS //cooldown_duration = 25 SECONDS // restore when done debugging
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CONQUEROR_DOMINATION,
	)

/datum/action/ability/activable/xeno/conqueror_domination/use_ability(atom/atom_target)
	if(!atom_target || !isturf(atom_target))
		return
	var/turf/turf_target = atom_target
	if(!line_of_sight(xeno_owner, turf_target, CONQUEROR_DOMINATION_CASTING_RANGE) || LinkBlocked(xeno_owner.loc, turf_target, PASSABLE|HOVERING))
		xeno_owner.balloon_alert(xeno_owner, "Cannot leap")
		return
	playsound(xeno_owner.loc, 'sound/effects/alien/behemoth/landslide_roar.ogg', 45, TRUE)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(landing_effect))
	xeno_owner.throw_at(turf_target, CONQUEROR_DOMINATION_CASTING_RANGE+2, CONQUEROR_DOMINATION_LEAP_SPEED, xeno_owner, flying = TRUE)
	var/distance = get_dist(xeno_owner, turf_target)
	var/duration = distance * 1.5
	landing_warning(filled_circle_turfs(turf_target, CONQUEROR_DOMINATION_EFFECT_RANGE), min(duration, 5))
	var/pixel_y_diff = distance * 15
	animate(xeno_owner, alpha = 200, pixel_y = xeno_owner.pixel_y + pixel_y_diff, time = duration / 2, easing = SINE_EASING|EASE_OUT)
	animate(alpha = 255, pixel_y = xeno_owner.pixel_y - pixel_y_diff, time = duration / 2, easing = SINE_EASING|EASE_IN)
	add_cooldown()
	succeed_activate()

/// Does various effects upon landing.
/datum/action/ability/activable/xeno/conqueror_domination/proc/landing_effect(datum/source)
	SIGNAL_HANDLER
	//xeno_owner.pixel_y = initial(xeno_owner.pixel_y) // for debugging purposes, remove when done
	UnregisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW)
	playsound(xeno_owner.loc, 'sound/effects/alien/conqueror/conqueror_domination.ogg', 8, TRUE)
	new /obj/effect/temp_visual/conqueror/domination(get_turf(xeno_owner), ABOVE_ALL_MOB_LAYER)
	//new /obj/effect/temp_visual/shockwave(get_turf(living_target), CONQUEROR_DOMINATION_EFFECT_RANGE)
	for(var/turf/affected_turf AS in filled_circle_turfs(xeno_owner, CONQUEROR_DOMINATION_EFFECT_RANGE))
		if(isclosedturf(affected_turf))
			continue
		for(var/mob/living/living_target in affected_turf)
			if(living_target.stat == DEAD || living_target.issamexenohive(xeno_owner))
				continue
			var/distance = get_dist(living_target, xeno_owner)
			var/debuff_value = CONQUEROR_DOMINATION_MAX_PUSH_RANGE+1 - min(distance, CONQUEROR_DOMINATION_MAX_PUSH_RANGE)
			if(distance)
				living_target.knockback(xeno_owner, debuff_value, 1)
			living_target.Knockdown((debuff_value * 0.6) SECONDS)
			var/damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * CONQUEROR_DOMINATION_DAMAGE_MULTIPLIER) - ((distance * CONQUEROR_DOMINATION_DAMAGE_FALLOFF) * 0.1)
			living_target.take_overall_damage(damage, xeno_owner.xeno_caste.melee_damage_type, MELEE, TRUE, TRUE, TRUE, xeno_owner.xeno_caste.melee_ap, 5)

/// Warns of an impending landing.
/datum/action/ability/activable/xeno/conqueror_domination/proc/landing_warning(list/turf/affected_turfs, duration)
	if(!length(affected_turfs) || !duration)
		return
	for(var/turf/affected_turf AS in affected_turfs)
		new /obj/effect/temp_visual/behemoth/warning/conqueror(affected_turf, duration)

/obj/effect/temp_visual/conqueror/domination
	icon = 'icons/effects/conqueror_domination.dmi'
	icon_state = "conqueror_domination"
	duration = 6.4
	pixel_x = -70
	pixel_y = -28

/obj/effect/temp_visual/behemoth/warning/conqueror
	color = COLOR_STRONG_VIOLET
