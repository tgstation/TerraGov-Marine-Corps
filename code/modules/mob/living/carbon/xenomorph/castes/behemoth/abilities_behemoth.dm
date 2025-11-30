/obj/effect/temp_visual/behemoth
	name = "Behemoth"
	duration = 10 SECONDS


// ***************************************
// *********** Earth Pillar
// ***************************************
#define isearthpillar(A) (istype(A, /obj/structure/xeno/earth_pillar)) // So that we don't need to repeat the type path.
#define COMSIG_EARTH_PILLAR_DESTROY "earth_pillar_destroy"
#define EARTH_PILLAR_REPAIR_DELAY 1.4 SECONDS
#define EARTH_PILLAR_REPAIR_AMOUNT 0.1 // percent

/obj/structure/xeno/earth_pillar
	name = "earth pillar"
	icon = 'icons/effects/effects.dmi'
	icon_state = "earth_pillar"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	climbable = TRUE
	density = TRUE
	coverage = INFINITY
	max_integrity = 500
	soft_armor = list(MELEE = 60, BULLET = 50, LASER = 40, ENERGY = 40, BOMB = 0, BIO = 100, FIRE = 100, ACID = 0)
	hit_sound = SFX_BEHEMOTH_EARTH_PILLAR_HIT
	destroy_sound = 'sound/effects/alien/behemoth/earth_pillar_destroyed.ogg'
	obj_flags = CAN_BE_HIT|BLOCKS_CONSTRUCTION
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	allow_pass_flags = PASS_LOW_STRUCTURE|PASS_THROW|PASS_AIR|PASS_WALKOVER
	hud_possible = HEALTH_HUD_XENO
	/// List of connections used to check for climbing and other stuff.
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	/// The xeno owner that created this object. NOT the holder.
	var/mob/living/carbon/xenomorph/xeno_owner
	/// The atom that's currently holding this object.
	var/mob/living/carbon/xenomorph/current_holder
	/// References the dummy item created when this object is held.
	var/obj/item/pillar_item/dummy_item
	/// Visual overlay applied over this object. Mostly used for warning flashes.
	var/obj/effect/pillar_flash/flash_visual
	/// Cooldown for exploding so that we don't get infinite loops.
	COOLDOWN_DECLARE(explosion_cooldown)

/obj/structure/xeno/earth_pillar/Initialize(mapload, mob/living/carbon/xenomorph/new_owner, health_reduction)
	. = ..()
	if(health_reduction)
		max_integrity -= floor(max_integrity * health_reduction)
		obj_integrity = max_integrity
	transform = matrix(rand(1, 360), MATRIX_ROTATE) // Variety is the spice of life.
	xeno_owner = new_owner
	flash_visual = new
	flash_visual.alpha = 0
	flash_visual.layer = layer + 0.01
	vis_contents += flash_visual
	AddElement(/datum/element/connect_loc, connections)
	RegisterSignal(src, COMSIG_MOVABLE_PRE_THROW, PROC_REF(pre_throw))
	prepare_huds()
	for(var/datum/atom_hud/xeno/xeno_hud in GLOB.huds)
		xeno_hud.add_to_hud(src)
	update_visuals()
	RegisterSignals(src, list(COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_EX_ACT, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, COMSIG_ATOM_ATTACKBY), PROC_REF(update_visuals))

/obj/structure/xeno/earth_pillar/Destroy()
	vis_contents -= flash_visual
	qdel(flash_visual)
	playsound(loc, 'sound/effects/alien/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/creation/destruction(loc)
	if(xeno_owner)
		SEND_SIGNAL(src, COMSIG_EARTH_PILLAR_DESTROY) // Surprised Destroy() doesn't send a signal, but hey, we make do.
		xeno_owner = null
	if(current_holder)
		force_drop()
	return ..()

/* to do: need damage icons
/obj/structure/xeno/earth_pillar/update_icon_state()
	. = ..()
	if(obj_integrity <= max_integrity * 0.25)
		icon_state = "earth_pillar_3"
		return
	if(obj_integrity <= max_integrity * 0.5)
		icon_state = "earth_pillar_2"
		return
	if(obj_integrity <= max_integrity * 0.75)
		icon_state = "earth_pillar_1"
		return
*/

// Adds interactions specifically for Behemoths.
/obj/structure/xeno/earth_pillar/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = xeno_attacker.xeno_caste.melee_damage_type, armor_type = xeno_attacker.xeno_caste.melee_damage_armor, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!isxenobehemoth(xeno_attacker)) // If you're not a Behemoth, then you're unworthy of the rock. Begone, pleb.
		return
	if(xeno_attacker.a_intent == INTENT_HELP) // Repairs the rock if it's damaged.
		if(obj_integrity >= max_integrity)
			balloon_alert(xeno_attacker, "[name] does not need repairs")
			return
		while(do_after(xeno_attacker, EARTH_PILLAR_REPAIR_DELAY, NONE, src, BUSY_ICON_CLOCK))
			var/repair_amount = max_integrity * EARTH_PILLAR_REPAIR_AMOUNT
			repair_damage(repair_amount, xeno_attacker)
			var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_attacker.ckey]
			xeno_stats.earth_pillar_repairs += repair_amount
			playsound(src, SFX_BEHEMOTH_EARTH_PILLAR_HIT, 15, TRUE, 5)
			if(obj_integrity >= max_integrity)
				balloon_alert(xeno_attacker, "Fully repaired ([obj_integrity]/[max_integrity])")
				return
			balloon_alert(xeno_attacker, "+[repair_amount] ([obj_integrity]/[max_integrity])")
	if(xeno_attacker.a_intent == INTENT_GRAB) // Grabs the rock.
		when_grabbed(xeno_attacker)
		return
	xeno_attacker.do_attack_animation(src)
	do_jitter_animation(jitter_loops = 1)
	playsound(src, 'sound/effects/alien/behemoth/earth_pillar_eating.ogg', 30, TRUE)
	xeno_attacker.visible_message(span_xenowarning("\The [xeno_attacker] eats away at the [src.name]!"), \
	span_xenonotice(BEHEMOTH_ROCK_EATING_MESSAGES), null, 5)
	return TRUE

/// Prepares this object to be thrown.
/obj/structure/xeno/earth_pillar/proc/pre_throw(datum/source)
	SIGNAL_HANDLER
	climbable = FALSE
	pixel_y = initial(pixel_y)
	RemoveElement(/datum/element/connect_loc)
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))

/// Cleans up after this object is thrown.
/obj/structure/xeno/earth_pillar/proc/post_throw(datum/source)
	SIGNAL_HANDLER
	climbable = TRUE
	AddElement(/datum/element/connect_loc, connections)
	UnregisterSignal(src, COMSIG_MOVABLE_POST_THROW)

/// Applies various changes when this object is held.
/obj/structure/xeno/earth_pillar/proc/when_grabbed(mob/grabber)
	anchored = FALSE
	density = FALSE
	obj_flags = NONE
	resistance_flags = RESIST_ALL
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 20
	current_holder = grabber
	current_holder.held_pillar = src
	RegisterSignals(current_holder, list(COMSIG_QDELETING, COMSIG_MOB_DEATH), PROC_REF(force_drop))
	RegisterSignal(current_holder, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(update_glide))
	RegisterSignal(current_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	forceMove(current_holder.loc)
	dummy_item = new(current_holder.loc)
	RegisterSignal(dummy_item, COMSIG_ITEM_ATTACK_TURF, PROC_REF(attack_turf))
	RegisterSignal(dummy_item, COMSIG_ITEM_REMOVED_INVENTORY, PROC_REF(force_drop))
	current_holder.put_in_active_hand(dummy_item)

/// Resets all changes made when this object is dropped.
/obj/structure/xeno/earth_pillar/proc/when_dropped(datum/source, turf/T)
	SIGNAL_HANDLER
	alpha = initial(alpha) // Changed by Earth Riser.
	anchored = initial(anchored)
	density = initial(density)
	obj_flags = initial(obj_flags)
	resistance_flags = initial(resistance_flags)
	layer = initial(layer)
	mouse_opacity = initial(mouse_opacity)
	pixel_y = initial(pixel_y)
	reset_glide_size()
	UnregisterSignal(current_holder, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, COMSIG_MOVABLE_MOVED))
	forceMove(T ? T : current_holder.loc)
	current_holder.held_pillar = null
	current_holder = null
	if(dummy_item)
		QDEL_NULL(dummy_item)

/// Forces the object to be dropped.
/obj/structure/xeno/earth_pillar/proc/force_drop(datum/source)
	SIGNAL_HANDLER
	when_dropped(current_holder)

/// Updates the glide size to match our current holder's. Results in SMOOTH movement.
/obj/structure/xeno/earth_pillar/proc/update_glide(datum/source, target)
	SIGNAL_HANDLER
	set_glide_size(target)

/// Whenever the current holder moves, this object will follow.
/obj/structure/xeno/earth_pillar/proc/on_move(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	forceMove(current_holder.loc)

/// When the dummy item is used to attack a turf, this object will be dropped on it.
/obj/structure/xeno/earth_pillar/proc/attack_turf(datum/source, turf/T, atom/user)
	SIGNAL_HANDLER
	if(current_holder.a_intent != INTENT_GRAB)
		return
	when_dropped(current_holder, T)

/// Updates appearances, and the HUD elements. Needed to handle signals.
/obj/structure/xeno/earth_pillar/proc/update_visuals(datum/source)
	SIGNAL_HANDLER
	update_appearance()
	var/image/holder = hud_list[HEALTH_HUD_XENO] // TO DO: why is this HUD shit not working? send help
	if(!holder)
		return
	holder.icon = 'icons/mob/hud/xeno_health.dmi'
	holder.icon_state = "health[obj_integrity ? max(round(obj_integrity * 100 / max_integrity, 10), 1) : 0]"

/// Makes the overlay flash to warn of an incoming action.
/obj/structure/xeno/earth_pillar/proc/warning_flash()
	animate(flash_visual, 0, flags = ANIMATION_END_NOW, alpha = initial(alpha))
	animate(0.2 SECONDS, alpha = 0)

/obj/item/pillar_item
	name = "Earth Pillar"
	icon = 'icons/effects/effects.dmi'
	icon_state = "earth_pillar_held"
	item_flags = NOBLUDGEON|DELONDROP|ITEM_ABSTRACT

/obj/effect/pillar_flash
	icon = 'icons/effects/effects.dmi'
	icon_state = "pillar_flash"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = TILE_BOUND


// ***************************************
// *********** Seize
// ***************************************
#define SEIZE_PASS_FLAGS (PASS_LOW_STRUCTURE|PASS_MOB|PASS_XENO|PASS_THROW|PASS_PROJECTILE)
#define SEIZE_SPEED 1

/datum/action/ability/activable/xeno/behemoth_seize
	name = "Seize"
	desc = "Dash towards a target Earth Pillar and grab it. Alternate use finds the nearest one for this purpose."
	action_icon = 'icons/Xeno/actions/runner.dmi'
	action_icon_state = "pounce"
	ability_cost = 40
	cooldown_duration = 15 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BEHEMOTH_SEIZE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_BEHEMOTH_SEIZE_ALTERNATE,
	)
	/// The range of this action, in tiles.
	var/action_range = 3

/datum/action/ability/activable/xeno/behemoth_seize/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!xeno_owner.canmove) // Shouldn't be able to use this ability if you can't move.
		return FALSE

/datum/action/ability/activable/xeno/behemoth_seize/use_ability(atom/target)
	. = ..()
	if(!isearthpillar(target)) // If it's not an Earth Pillar, we don't care about it.
		xeno_owner.balloon_alert(xeno_owner, "[target] is not an Earth Pillar")
		return
	if(!line_of_sight(xeno_owner, target, WORLD_VIEW_NUM))
		xeno_owner.balloon_alert(xeno_owner, "No line of sight with [target]")
		return
	if(xeno_owner.buckled) // Dashing automatically unbuckles you.
		xeno_owner.buckled.unbuckle_mob(xeno_owner, TRUE, FALSE)
	dash_to_pillar(target)

/// Alternate use will try to find the nearest target and seize it.
/datum/action/ability/activable/xeno/behemoth_seize/alternate_action_activate()
	if(!can_use_action(TRUE))
		return
	var/obj/structure/xeno/earth_pillar/pillar_target
	for(var/turf/T AS in RANGE_TURFS(action_range, xeno_owner))
		if(!line_of_sight(xeno_owner, T, action_range))
			continue
		for(var/atom/movable/M in T)
			if(!isearthpillar(M))
				continue
			var/obj/structure/xeno/earth_pillar/P = M
			if(P.current_holder) // If someone's already holding this pillar, then it's an invalid target. Keep looking.
				continue
			pillar_target = P
			break // We already got our target, no need to continue.
	if(!pillar_target) // If at this point we don't have a target, then the ability fails.
		xeno_owner.balloon_alert(xeno_owner, "No pillar within range")
		return
	dash_to_pillar(pillar_target)

/// Dashes towards the nearest Earth Pillar in range and tries to grab it.
/datum/action/ability/activable/xeno/behemoth_seize/proc/dash_to_pillar(obj/structure/xeno/earth_pillar/target)
	if(xeno_owner.held_pillar) // If we're already holding a pillar, drop it so we can grab the targetted one.
		if(!xeno_owner.held_pillar.dummy_item) // Not having the dummy item means it was thrown by Earth Riser. We're not ready for grabbing another.
			return
		xeno_owner.held_pillar.when_dropped(xeno_owner)
	xeno_owner.add_pass_flags(SEIZE_PASS_FLAGS, XENO_TRAIT)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))
	xeno_owner.throw_at(target, action_range, SEIZE_SPEED, xeno_owner, targetted_throw = TRUE)
	target.warning_flash()
	var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
	xeno_stats.seize_uses++
	add_cooldown()
	succeed_activate()

/// Checks if there's an Earth Pillar in the tile we're about to move into, and grabs it if so, allowing movement to continue uninterrupted.
/datum/action/ability/activable/xeno/behemoth_seize/proc/pre_move(datum/source, atom/new_loc, direction)
	SIGNAL_HANDLER
	for(var/atom/movable/M AS in new_loc)
		if(!isearthpillar(M))
			continue
		var/obj/structure/xeno/earth_pillar/P = M
		P.when_grabbed(xeno_owner)

/// Cleans up after the throw is done.
/datum/action/ability/activable/xeno/behemoth_seize/proc/post_throw(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_POST_THROW))
	xeno_owner.remove_pass_flags(SEIZE_PASS_FLAGS, XENO_TRAIT)


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_CREATION_RANGE 2 // tiles
#define EARTH_RISER_CREATION_COST 100
#define EARTH_RISER_THROW_DURATION 1.2 SECONDS
#define EARTH_RISER_THROW_RANGE 5 // tiles
#define EARTH_RISER_THROW_RADIUS 2 // tiles
#define EARTH_RISER_THROW_KNOCKDOWN 1 SECONDS
#define EARTH_RISER_THROW_STAGGER 5 // stacks
#define EARTH_RISER_THROW_SLOWDOWN 5 // stacks
#define EARTH_RISER_THROW_COOLDOWN 10 SECONDS
#define EARTH_RISER_THROW_COST 20

/datum/action/ability/activable/xeno/earth_riser
	name = "Earth Riser"
	desc = "Create or interact with an Earth Pillar. If holding one, you will instead throw it."
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "earth_riser"
	cooldown_duration = 45 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_IGNORE_PLASMA|ABILITY_IGNORE_COOLDOWN
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EARTH_RISER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE,
	)
	/// List containing all currently active pillars created by this ability.
	var/list/obj/structure/xeno/earth_pillar/active_pillars
	/// The maximum amount of pillars that we can have active. Anything above the initial amount is assumed to be the result of a Shell mutation.
	var/creation_limit = 1

/datum/action/ability/activable/xeno/earth_riser/give_action(mob/living/L)
	. = ..()
	LAZYINITLIST(active_pillars)
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(clear_pillars))
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = mutable_appearance(null, null, ACTION_LAYER_MAPTEXT, appearance_flags = RESET_COLOR)

/datum/action/ability/activable/xeno/earth_riser/remove_action(mob/living/L)
	clear_pillars()
	return ..()

/datum/action/ability/activable/xeno/earth_riser/clean_action()
	clear_pillars()
	return ..()

/datum/action/ability/activable/xeno/earth_riser/update_button_icon()
	. = ..()
	if(!. || !visual_references[VREF_MUTABLE_EARTH_PILLAR])
		return
	var/mutable_appearance/counter = visual_references[VREF_MUTABLE_EARTH_PILLAR]
	button.cut_overlay(counter)
	if(!creation_limit)
		return
	var/condition = creation_limit > 2 ? TRUE : FALSE
	counter.icon = condition ? null : action_icon
	counter.icon_state = condition ? null : "pillar_counter_[creation_limit][LAZYLEN(active_pillars)]" // f.ex pillar_counter_11 means we have 1 pillar as a limit and 1 active pillar
	counter.pixel_x = condition ? 16 : initial(counter.pixel_x)
	counter.pixel_y = condition ? -4 : initial(counter.pixel_y)
	counter.maptext = condition ? MAPTEXT("["[LAZYLEN(active_pillars)]/[creation_limit]"]") : null
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = counter
	button.add_overlay(counter)

// Handles ability checks instead, mostly because we need the final target in the event of target correction.
// We also check for plasma costs and cooldowns here because some parts of this ability ignore them.
/datum/action/ability/activable/xeno/earth_riser/use_ability(atom/target)
	. = ..()
	if(!xeno_owner.incapacitated())
		if(xeno_owner.held_pillar) // If we're holding an Earth Pillar, then we want to throw it.
			if(xeno_owner.plasma_stored < EARTH_RISER_THROW_COST)
				xeno_owner.balloon_alert(xeno_owner, "Need [EARTH_RISER_THROW_COST - xeno_owner.plasma_stored] more plasma")
				return
			if(!action_cooldown_finished())
				xeno_owner.balloon_alert(xeno_owner, "Wait [cooldown_remaining()] seconds!")
				return
			if(!line_of_sight(xeno_owner, target, WORLD_VIEW_NUM))
				xeno_owner.balloon_alert(xeno_owner, "No line of sight with [target]")
				return
			throw_pillar(get_turf(target))
			return
		if(isearthpillar(target) && xeno_owner.Adjacent(target)) // If our target is an Earth Pillar, then we want to grab it. Plasma and cooldown are irrelevant for this.
			var/obj/structure/xeno/earth_pillar/P = target
			P.when_grabbed(xeno_owner)
			return
	if(length(active_pillars) >= creation_limit)
		xeno_owner.balloon_alert(xeno_owner, "Creation limit reached ([creation_limit])")
		return
	if(xeno_owner.plasma_stored < EARTH_RISER_CREATION_COST)
		xeno_owner.balloon_alert(xeno_owner, "Need [EARTH_RISER_CREATION_COST - xeno_owner.plasma_stored] more plasma")
		return
	if(!action_cooldown_finished())
		xeno_owner.balloon_alert(xeno_owner, "Wait [cooldown_remaining()] seconds!")
		return
	target = get_turf(target)
	if((xeno_owner.client?.prefs?.toggles_gameplay & DIRECTIONAL_ATTACKS) && get_dist(xeno_owner, target) > EARTH_RISER_CREATION_RANGE) // When directional attacks are enabled, if the distance to our target exceeds the range, we correct the target.
		var/list/turf/line_to_target = get_line(xeno_owner, target)
		target = line_to_target[EARTH_RISER_CREATION_RANGE + 1] // Gives us the intended tile.
	if(!line_of_sight(xeno_owner, target, WORLD_VIEW_NUM)) // Check it again after correcting the target.
		xeno_owner.balloon_alert(xeno_owner, "No line of sight with [target]")
		return
	for(var/atom/A AS in target)
		if(!isobj(A))
			continue
		var/obj/O = A
		if(O.density && !(O.allow_pass_flags & (PASS_MOB|PASS_XENO)) || O.obj_flags & BLOCKS_CONSTRUCTION)
			xeno_owner.balloon_alert(xeno_owner, "[target] is blocked by [O]")
			return
	create_pillar(target)

/// If there are any active pillars, destroys the oldest one.
/datum/action/ability/activable/xeno/earth_riser/alternate_action_activate()
	if(!can_use_action(FALSE))
		return
	if(!length(active_pillars))
		xeno_owner.balloon_alert(xeno_owner, "No active pillars")
		return
	var/obj/structure/xeno/earth_pillar/oldest_pillar = popleft(active_pillars)
	oldest_pillar.Destroy()

/// Deletes all active pillars.
/datum/action/ability/activable/xeno/earth_riser/proc/clear_pillars(datum/source)
	SIGNAL_HANDLER
	if(length(active_pillars))
		QDEL_LAZYLIST(active_pillars)
	update_button_icon()

/// Creates an Earth Pillar at the target location.
/datum/action/ability/activable/xeno/earth_riser/proc/create_pillar(turf/target)
	for(var/atom/A AS in target)
		if(!isliving(A))
			continue
		step_away(A, target, 1, 1) // Displaced by a pillar spawning underneath.
	var/obj/structure/xeno/earth_pillar/P = new(target, xeno_owner, creation_limit > initial(creation_limit) ? FOUNDATIONS_HEALTH_REDUCTION : FALSE)
	active_pillars += P
	RegisterSignals(P, list(COMSIG_QDELETING, COMSIG_EARTH_PILLAR_DESTROY), PROC_REF(pillar_deleted))
	var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
	xeno_stats.earth_pillars_created++
	var/animation_time = 0.6 SECONDS
	animate(P, animation_time / 2, easing = SINE_EASING|EASE_OUT, pixel_y = P.pixel_y + 15)
	animate(animation_time / 2, easing = SINE_EASING|EASE_IN, flags = ANIMATION_CONTINUE, pixel_y = initial(P.pixel_y))
	playsound(xeno_owner, 'sound/effects/alien/behemoth/earth_pillar_landing.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/creation(target)
	add_cooldown(1 SECONDS)
	succeed_activate(EARTH_RISER_CREATION_COST)

/// Removes our reference to a pillar when it is deleted.
/datum/action/ability/activable/xeno/earth_riser/proc/pillar_deleted(datum/source)
	SIGNAL_HANDLER
	active_pillars -= source
	add_cooldown()

/// 'Throws' our currently held pillar towards a target.
/datum/action/ability/activable/xeno/earth_riser/proc/throw_pillar(turf/target)
	xeno_owner.held_pillar.alpha = 0
	qdel(xeno_owner.held_pillar.dummy_item)
	var/obj/effect/temp_visual/behemoth/earth_pillar/thrown/throw_visual = new(xeno_owner.loc)
	var/animation_time = EARTH_RISER_THROW_DURATION - 0.21 SECONDS // For some reason the animation sequence below is taking longer than the given duration. BYOND fuckery?
	animate(throw_visual, animation_time / 2, easing = CIRCULAR_EASING|EASE_OUT, pixel_y = xeno_owner.held_pillar.y + 40 - get_dist(xeno_owner.held_pillar, target) * 6)
	animate(animation_time / 2, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_CONTINUE, pixel_y = (target.y - xeno_owner.held_pillar.y) * ICON_SIZE_Y)
	animate(animation_time, flags = ANIMATION_PARALLEL, pixel_x = (target.x - xeno_owner.held_pillar.x) * ICON_SIZE_X)
	var/list/turf/affected_turfs = filled_circle_turfs(target, EARTH_RISER_THROW_RADIUS)
	for(var/turf/T AS in affected_turfs)
		for(var/atom/movable/M AS in T)
			if(!isearthpillar(M))
				continue
			affected_turfs += filled_circle_turfs(T, EARTH_RISER_THROW_RADIUS) // Other pillars will mirror the explosion, and we'd like to include them in warnings.
			var/obj/structure/xeno/earth_pillar/P = M
			P.warning_flash()
	var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
	xeno_stats.earth_pillars_thrown++
	xeno_warning(affected_turfs, EARTH_RISER_THROW_DURATION, COLOR_DARK_MODERATE_ORANGE)
	addtimer(CALLBACK(src, PROC_REF(post_throw), target), EARTH_RISER_THROW_DURATION)
	add_cooldown(EARTH_RISER_THROW_COOLDOWN)
	succeed_activate(EARTH_RISER_THROW_COST)

/// Handles anything that should happen after the pillar's throw concludes.
/datum/action/ability/activable/xeno/earth_riser/proc/post_throw(turf/target)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/earth_pillar_landing.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/landing(target)
	throw_landing(target, list(xeno_owner.held_pillar))
	xeno_owner.held_pillar.when_dropped(xeno_owner, target)

/// When the pillar lands after being thrown, it will apply various effects around it.
/datum/action/ability/activable/xeno/earth_riser/proc/throw_landing(turf/target, list/pillars_hit)
	for(var/turf/T AS in filled_circle_turfs(target, EARTH_RISER_THROW_RADIUS))
		for(var/atom/movable/M AS in T)
			if(isearthpillar(M) && M.density && !(M in pillars_hit))
				pillars_hit += M
				throw_landing(M.loc, pillars_hit) // Pillars hit by this will mirror this proc. pillars_hit ensures this doesn't repeat infinitely.
				continue
			if(!isliving(M) || xeno_owner.issamexenohive(M))
				continue
			var/mob/living/L = M
			if(L.loc == get_turf(target)) // If the pillar landed on you, then you're getting knocked down.
				L.Knockdown(EARTH_RISER_THROW_KNOCKDOWN)
			L.Stagger(EARTH_RISER_THROW_STAGGER)
			L.add_slowdown(EARTH_RISER_THROW_SLOWDOWN)
			L.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, STAMINA, xeno_owner.zone_selected, NONE, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
			step_towards(L, target, get_dist(L, target) - 1) // Drags you in.

/obj/effect/temp_visual/behemoth/earth_pillar
	name = "Earth Pillar"
	icon = 'icons/effects/effects.dmi'
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/behemoth/earth_pillar/creation
	icon = 'icons/effects/96x96.dmi'
	icon_state = "pillar_creation"
	duration = 0.4 SECONDS
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/behemoth/earth_pillar/creation/Initialize(mapload)
	. = ..()
	animate(src, duration, alpha = 0)
	for(var/i in 1 to rand(6, 10))
		new /obj/effect/temp_visual/behemoth/earth_pillar/debris(loc)

/obj/effect/temp_visual/behemoth/earth_pillar/creation/destruction
	pixel_y = -24

/obj/effect/temp_visual/behemoth/earth_pillar/debris
	icon_state = "pillar_debris"
	layer = TANK_DECORATION_LAYER
	duration = 4 SECONDS

/obj/effect/temp_visual/behemoth/earth_pillar/debris/Initialize(mapload)
	. = ..() // I fucking hate matrices so much holy SHIT
	var/matrix/m1 = matrix(randfloat(0.4, 0.8), MATRIX_SCALE)
	var/matrix/m2 = m1.Multiply(matrix(rand(1, 360), MATRIX_ROTATE))
	transform = m2
	var/new_y = pixel_y + rand(-10, 10)
	animate(src, 0.4 SECONDS, easing = SINE_EASING|EASE_IN, pixel_y = new_y + rand(10, 40))
	animate(0.6 SECONDS, easing = BOUNCE_EASING, flags = ANIMATION_CONTINUE, pixel_y = new_y)
	animate(1 SECONDS, flags = ANIMATION_PARALLEL, pixel_x = pixel_x + rand(-50, 50), transform = m2.Multiply(matrix(rand(60, 1080), MATRIX_ROTATE)))
	animate(2.5 SECONDS, flags = ANIMATION_CONTINUE)
	animate(0.5 SECONDS, flags = ANIMATION_CONTINUE, alpha = 0)

/obj/effect/temp_visual/behemoth/earth_pillar/thrown
	icon_state = "earth_pillar"
	duration = EARTH_RISER_THROW_DURATION

/obj/effect/temp_visual/behemoth/earth_pillar/landing
	icon = 'icons/effects/96x96.dmi'
	icon_state = "pillar_landing"
	duration = 0.53 SECONDS
	pixel_x = -32
	pixel_y = -42

/obj/effect/temp_visual/behemoth/earth_pillar/landing/Initialize(mapload)
	. = ..()
	transform = matrix(0.7, MATRIX_SCALE)
	animate(src, duration, alpha = 0)


// ***************************************
// *********** Landslide
// ***************************************
#define LANDSLIDE_RANGE 5
#define LANDSLIDE_WIND_UP 0.5 SECONDS
#define LANDSLIDE_SPEED 1
#define LANDSLIDE_DAMAGE_MECHA_MODIFIER 1.5
#define LANDSLIDE_DAMAGE_VEHICLE_MODIFIER 10
#define LANDSLIDE_DAMAGE_LIVING_MULTIPLIER 0.8 // percent
#define LANDSLIDE_KNOCKDOWN_DURATION 0.7 SECONDS

/datum/action/ability/activable/xeno/landslide
	name = "Landslide"
	desc = "Charge forward in the nearest cardinal direction, affecting eligible targets in a wide path."
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "landslide"
	ability_cost = 40
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LANDSLIDE,
	)
	/// List of atoms we've hit with Landslide, so that we don't affect them multiple times.
	var/list/atoms_hit
	/// Stores the visual effect for when we're charging.
	var/obj/effect/landslide_charge/charge_visual

/datum/action/ability/activable/xeno/landslide/on_cooldown_finish()
	. = ..()
	if(xeno_owner.stat >= DEAD) // If we're dead, we don't really care.
		return
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 20, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

/datum/action/ability/activable/xeno/landslide/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!xeno_owner.canmove)
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/landslide/use_ability(atom/target)
	. = ..()
	if(!target)
		return
	var/direction = get_cardinal_dir(xeno_owner, target)
	target = get_ranged_target_turf(target, direction, LANDSLIDE_RANGE)
	if(LinkBlocked(xeno_owner.loc, get_step(xeno_owner, direction), pass_flags_checked = PASS_AIR) || xeno_owner.loc == get_turf(target))
		xeno_owner.balloon_alert(xeno_owner, "No space!")
		return
	xeno_owner.set_canmove(FALSE)
	xeno_owner.face_atom(target)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/landslide_roar.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/landslide/dust(xeno_owner.loc, direction)
	xeno_warning(get_affected_turfs(direction), LANDSLIDE_WIND_UP + 0.5 SECONDS, COLOR_ORANGE)
	addtimer(CALLBACK(src, PROC_REF(start_charge), target, direction), LANDSLIDE_WIND_UP)
	succeed_activate()
	add_cooldown()

/// Gets a list of the turfs affected by this ability.
/datum/action/ability/activable/xeno/landslide/proc/get_affected_turfs(direction)
	var/list/turf/affected_turfs = list()
	for(var/i in list(-90, 0, 90)) // These are angles.
		var/step = i ? get_step(xeno_owner, turn(direction, i)) : xeno_owner.loc
		var/list/turf/turf_line = get_line(step, check_path(step, get_ranged_target_turf(step, direction, LANDSLIDE_RANGE + 1), pass_flags_checked = PASS_AIR))
		affected_turfs += turf_line
		for(var/turf/T AS in turf_line)
			for(var/atom/movable/M AS in T)
				if(!isearthpillar(M)) // Pillars extend the range of the ability, and should have warnings too.
					continue
				affected_turfs += get_line(M, check_path(M, get_ranged_target_turf(M, direction, LANDSLIDE_RANGE), pass_flags_checked = PASS_AIR))
				var/obj/structure/xeno/earth_pillar/P = M
				P.warning_flash()
	return affected_turfs

/// Throws the user towards a target after setting them up.
/datum/action/ability/activable/xeno/landslide/proc/start_charge(target, direction)
	var/animation_time = (LANDSLIDE_RANGE - (LANDSLIDE_SPEED - 1)) * 0.8 // This is a Hail Mary, by the way.
	animate(xeno_owner, animation_time / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW, pixel_y = xeno_owner.pixel_y + LANDSLIDE_RANGE)
	animate(animation_time / 2, easing = CIRCULAR_EASING|EASE_IN, pixel_y = initial(xeno_owner.pixel_y))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(pre_move))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(end_charge))
	LAZYINITLIST(atoms_hit)
	on_move(xeno_owner, xeno_owner.loc, direction) // Needed to catch things right next to us when we start our charge.
	playsound(xeno_owner.loc, 'sound/effects/alien/behemoth/landslide_charge.ogg', 30, TRUE)
	xeno_owner.throw_at(target, LANDSLIDE_RANGE, LANDSLIDE_SPEED, xeno_owner)
	charge_visual = new(null, direction)
	xeno_owner.vis_contents += charge_visual
	animate(charge_visual, animation_time, alpha = 0)

/// Checks if the tile we're about to move into doesn't have anything that can block us.
/datum/action/ability/activable/xeno/landslide/proc/pre_move(datum/source, atom/newloc, direction)
	SIGNAL_HANDLER
	for(var/atom/movable/M AS in get_turf(newloc))
		if(M in atoms_hit)
			continue
		if(istype(M, /obj/structure/razorwire) && M.anchored) // Razorwire will stop our charge and entangle us. Effects partially mirrored from Crusher's charge.
			end_charge()
			var/obj/structure/razorwire/R = M
			playsound(R.loc, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
			var/razorwire_damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier
			R.take_damage(razorwire_damage, xeno_owner.xeno_caste.melee_damage_type, xeno_owner.xeno_caste.melee_damage_armor, TRUE, REVERSE_DIR(xeno_owner.dir), xeno_owner.xeno_caste.melee_ap, xeno_owner)
			var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
			xeno_stats.landslide_damage += razorwire_damage
			R.update_icon()
			xeno_owner.forceMove(R.loc) // This automatically entangles us. Refer to razorwire's on_cross proc.
			xeno_owner.Paralyze(0.5 SECONDS)
			INVOKE_ASYNC(xeno_owner, TYPE_PROC_REF(/mob/living/carbon/xenomorph, apply_damage), RAZORWIRE_BASE_DAMAGE * RAZORWIRE_MIN_DAMAGE_MULT_MED, BRUTE, sharp = TRUE, updating_health = TRUE)
			return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
		if(istype(M, /obj/machinery/vending))
			var/obj/machinery/vending/V = M
			playsound(V.loc, 'sound/effects/meteorimpact.ogg', 30, TRUE)
			V.tip_over()

/// Applies various effects to a selection of tiles in front of the user.
/datum/action/ability/activable/xeno/landslide/proc/on_move(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/after_image(get_turf(old_loc), xeno_owner)
	var/list/turf/target_turfs = list()
	for(var/i in list(-90, 45, 0, 45, 90))
		target_turfs += get_step(xeno_owner, i ? turn(movement_dir, i) : movement_dir)
	for(var/turf/T AS in target_turfs)
		for(var/atom/movable/M AS in T)
			if(M in atoms_hit)
				continue
			if(isliving(M))
				var/mob/living/L = M
				if(L.stat == DEAD || L.lying_angle || xeno_owner.issamexenohive(L))
					continue
				living_hit(L)
				continue
			if(isobj(M))
				if(istype(M, /obj/structure/mineral_door/resin) || istype(M, /obj/structure/razorwire)) // Exclusions. We go through resin doors, and razorwire stops us.
					continue
				var/obj/O = M
				if(!O.density || O.allow_pass_flags & PASS_MOB || O.resistance_flags & INDESTRUCTIBLE)
					continue
				if(isearthpillar(O)) // Pillars get thrown in the direction we're charging.
					var/obj/structure/xeno/earth_pillar/P = O
					RegisterSignal(P, COMSIG_MOVABLE_IMPACT, PROC_REF(pillar_hit))
					P.throw_at(get_ranged_target_turf(P, movement_dir, LANDSLIDE_RANGE), LANDSLIDE_RANGE, 1, xeno_owner)
					atoms_hit += P
					var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
					xeno_stats.earth_pillars_thrown++
					continue
				if(isvehicle(O)) // Vehicles take increased damage.
					var/obj/vehicle/V = O
					var/vehicle_damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * (ismecha(V) ? LANDSLIDE_DAMAGE_MECHA_MODIFIER : LANDSLIDE_DAMAGE_VEHICLE_MODIFIER)
					V.take_damage(vehicle_damage, xeno_owner.xeno_caste.melee_damage_type, xeno_owner.xeno_caste.melee_damage_armor, null, get_dir(V, xeno_owner), xeno_owner.xeno_caste.melee_ap, xeno_owner)
					var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
					xeno_stats.landslide_damage += vehicle_damage
					atoms_hit += V
					continue

/// Adds effects for when we make impact against something.
/datum/action/ability/activable/xeno/landslide/proc/on_impact(datum/source, atom/A, speed)
	SIGNAL_HANDLER
	var/turf/T = get_turf(A)
	playsound(T, 'sound/effects/alien/behemoth/landslide_impact.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/landslide/impact(T, get_dir(A, xeno_owner))

/// Adds effects for when we hit a living target.
/datum/action/ability/activable/xeno/landslide/proc/living_hit(mob/living/L)
	SIGNAL_HANDLER
	if(L.buckled)
		L.buckled.unbuckle_mob(L, TRUE)
	playsound(L.loc, 'sound/effects/alien/behemoth/landslide_hit.ogg', 30, TRUE)
	INVOKE_ASYNC(L, TYPE_PROC_REF(/mob, emote), "pain")
	L.Knockdown(LANDSLIDE_KNOCKDOWN_DURATION)
	var/damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier * LANDSLIDE_DAMAGE_LIVING_MULTIPLIER
	L.apply_damage(damage, xeno_owner.xeno_caste.melee_damage_type, ran_zone(), xeno_owner.xeno_caste.melee_damage_armor, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
	var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
	xeno_stats.landslide_damage += damage
	atoms_hit += L

/// Pillars making impact with an atom will mirror Landslide's effects.
/datum/action/ability/activable/xeno/landslide/proc/pillar_hit(datum/source, atom/A, speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	on_impact(source, A, speed)
	if(!isliving(A) || xeno_owner?.issamexenohive(A))
		return
	var/mob/living/L = A
	if(L.stat == DEAD)
		return
	L.knockback(xeno_owner, 1, 1)
	living_hit(L)

/// Handles any events that should happen when hitting a living target.
/datum/action/ability/activable/xeno/landslide/proc/end_charge(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))
	if(xeno_owner.throwing)
		xeno_owner.stop_throw()
	xeno_owner.set_canmove(TRUE)
	xeno_owner.vis_contents -= charge_visual
	QDEL_NULL(charge_visual)
	LAZYNULL(atoms_hit)

/obj/effect/temp_visual/behemoth/landslide/dust
	icon = 'icons/effects/effects.dmi'
	icon_state = "landslide_dust"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	duration = 1.1 SECONDS

/obj/effect/temp_visual/behemoth/landslide/dust/Initialize(mapload, direction)
	. = ..()
	var/variant = pick(0, 1)
	var/pixel_mod = 10
	var/animation_time = duration - duration * 0.2
	switch(direction) // Hand picked offsets. Will need adjustments if Behemoth's sprite ever changes.
		if(NORTH)
			pixel_x += variant ? -12 : 12
			pixel_y -= 2
			animate(src, animation_time, easing = CIRCULAR_EASING|EASE_OUT, alpha = 0, pixel_y = pixel_y - pixel_mod)
		if(SOUTH)
			pixel_x += variant ? -11 : 11
			pixel_y -= 13
			animate(src, animation_time, easing = CIRCULAR_EASING|EASE_OUT, alpha = 0, pixel_y = pixel_y + pixel_mod)
		if(WEST)
			pixel_x += variant ? -25 : -12
			pixel_y -= 13
			animate(src, animation_time, easing = CIRCULAR_EASING|EASE_OUT, alpha = 0, pixel_x = pixel_x + pixel_mod)
		if(EAST)
			pixel_x += variant ? 18 : 31
			pixel_y -= 13
			animate(src, animation_time, easing = CIRCULAR_EASING|EASE_OUT, alpha = 0, pixel_x = pixel_x - pixel_mod)

/obj/effect/temp_visual/behemoth/landslide/impact
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landslide_impact"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	duration = 0.5 SECONDS
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/behemoth/landslide/impact/Initialize(mapload, direction)
	. = ..()
	transform = matrix(dir2angle(ISDIAGONALDIR(direction) ? closest_cardinal_dir(direction) : direction), MATRIX_ROTATE)
	animate(src, duration, alpha = 0)
	switch(direction) // Hand picked offsets.
		if(NORTH)
			pixel_x += 1
			pixel_y += 12
		if(SOUTH)
			pixel_x += 1
			pixel_y -= 12
		if(WEST)
			pixel_x -= 12
			pixel_y += 1
		if(EAST)
			pixel_x += 12
			pixel_y += 1

/obj/effect/landslide_charge
	icon = 'icons/effects/64x64.dmi'
	icon_state = "landslide_charge"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = TILE_BOUND
	layer = ABOVE_MOB_LAYER
	pixel_y = -16

/obj/effect/landslide_charge/Initialize(mapload, direction)
	. = ..()
	transform = matrix(dir2angle(direction), MATRIX_ROTATE)
	switch(direction) // Hand picked offsets. Will need adjustments if Behemoth's sprite ever changes.
		if(NORTH)
			pixel_x += 12
			pixel_y += 16
		if(SOUTH)
			pixel_x += 12
			pixel_y -= 8
		if(WEST)
			pixel_x -= 18
			pixel_y += 3
		if(EAST)
			pixel_x += 52
			pixel_y += 3


// ***************************************
// *********** Geocrush
// ***************************************
#define GEOCRUSH_RANGE 1 // tiles
#define GEOCRUSH_STAMINA_DAMAGE_MODIFIER 0.5 // percent
#define GEOCRUSH_SLOWDOWN 5 // stacks
#define GEOCRUSH_STAGGER 5 // stacks
#define GEOCRUSH_KNOCKDOWN 1 SECONDS
#define GEOCRUSH_KNOCKBACK 2 // tiles

/datum/action/ability/activable/xeno/geocrush
	name = "Geocrush"
	desc = "Attack a target, dealing heavy damage and applying various debuffs."
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "geocrush"
	ability_cost = 40
	cooldown_duration = 12 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GEOCRUSH,
	)
	/// Whether the Spur mutation is currently enabled.
	var/spur_mutation = FALSE

/datum/action/ability/activable/xeno/geocrush/on_cooldown_finish()
	. = ..()
	if(xeno_owner.stat >= DEAD)
		return
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 20, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")

// Handles ability checks instead because we need the final target in the event of target correction.
/datum/action/ability/activable/xeno/geocrush/use_ability(atom/target)
	. = ..()
	if((xeno_owner.client?.prefs?.toggles_gameplay & DIRECTIONAL_ATTACKS) && get_dist(xeno_owner, target) > GEOCRUSH_RANGE) // When directional attacks are enabled, if the distance exceeds the range, we correct the target.
		var/list/turf/turf_line = get_line(xeno_owner, target) // Could be get_step but we're future proofing in case the range is ever more than 1.
		for(var/atom/movable/M AS in turf_line[GEOCRUSH_RANGE + 1])
			if(isliving(M))
				target = M
				break
	if(!line_of_sight(xeno_owner, target, GEOCRUSH_RANGE))
		xeno_owner.balloon_alert(xeno_owner, "No line of sight with [target]")
		return
	if(!isliving(target))
		xeno_owner.balloon_alert(xeno_owner, "[target] is an invalid target")
		return
	var/mob/living/L = target
	if(L.stat == DEAD)
		xeno_owner.balloon_alert(xeno_owner, "[target] is dead")
		return
	do_geocrush(L)

/// Actually does the ability, because use_ability is relegated.
/datum/action/ability/activable/xeno/geocrush/proc/do_geocrush(atom/target)
	xeno_owner.do_attack_animation(target)
	new /obj/effect/temp_visual/behemoth/geocrush(target.loc)
	new /obj/effect/temp_visual/shockwave(target.loc, 4, REVERSE_DIR(target.dir))
	playsound(target.loc, 'sound/effects/alien/behemoth/geocrush.ogg', 40, TRUE, 40) // You can hear someone getting clapped from a long distance.
	var/damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier
	if(spur_mutation && xeno_owner.held_pillar)
		playsound(target.loc, 'sound/effects/alien/behemoth/earth_pillar_destroyed.ogg', 25, TRUE)
		new /obj/effect/temp_visual/behemoth/earth_pillar/creation/destruction(target.loc)
		xeno_owner.held_pillar.take_damage(xeno_owner.held_pillar.max_integrity * EARTH_MIGHT_PILLAR_DAMAGE, xeno_owner.xeno_caste.melee_damage_type, xeno_owner.xeno_caste.melee_damage_armor, TRUE, xeno_owner.dir, 100, xeno_owner)
		xeno_owner.held_pillar.when_dropped(xeno_owner, target.loc)
		damage *= EARTH_MIGHT_ADDITIONAL_DAMAGE
	for(var/atom/movable/M AS in target.loc)
		if(!isliving(M) || xeno_owner.issamexenohive(M))
			continue
		var/mob/living/L = M
		INVOKE_ASYNC(L, TYPE_PROC_REF(/mob, emote), "scream")
		L.apply_damage(damage, xeno_owner.xeno_caste.melee_damage_type, ran_zone(), xeno_owner.xeno_caste.melee_damage_armor, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
		L.apply_damage(damage * GEOCRUSH_STAMINA_DAMAGE_MODIFIER, STAMINA, xeno_owner.zone_selected, NONE, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
		var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
		xeno_stats.geocrush_damage += damage
		L.Knockdown(GEOCRUSH_KNOCKDOWN)
		L.add_slowdown(GEOCRUSH_SLOWDOWN)
		L.Stagger(GEOCRUSH_STAGGER)
		RegisterSignal(L, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
		RegisterSignal(L, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))
		L.knockback(xeno_owner, GEOCRUSH_KNOCKBACK, 1)
	add_cooldown()
	succeed_activate()

/// Adds effects for when our victim makes impact against something.
/datum/action/ability/activable/xeno/geocrush/proc/on_impact(datum/source, atom/hit_atom, speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/turf/atom_turf = get_turf(hit_atom)
	playsound(atom_turf, 'sound/effects/alien/behemoth/landslide_impact.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/landslide/impact(atom_turf, get_dir(hit_atom, source))

/// Cleans up after the knockback is done.
/datum/action/ability/activable/xeno/geocrush/proc/post_throw(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))

/obj/effect/temp_visual/behemoth/geocrush
	name = "Geocrush"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "geocrush"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 0.5 SECONDS
	pixel_x = -53
	pixel_y = -54
	var/possible_angles = list(0, 90, 180, 270)

/obj/effect/temp_visual/behemoth/geocrush/Initialize(mapload)
	. = ..()
	animate(src, duration, easing = CIRCULAR_EASING|EASE_OUT, alpha = 0)
	var/picked_angle = pick(possible_angles)
	transform = matrix(picked_angle, MATRIX_ROTATE)
	switch(picked_angle) // Hand picked offsets.
		if(90)
			pixel_x -= 1
			pixel_y -= 30
		if(180)
			pixel_x -= 28
			pixel_y -= 16
		if(270)
			pixel_x -= 21
			pixel_y += 8


// ***************************************
// *********** Primal Wrath
// ***************************************
#define PRIMAL_WRATH_ACTIVATION_DURATION 3 SECONDS
#define PRIMAL_WRATH_ROAR_RANGE 12 // tiles
#define PRIMAL_WRATH_DAMAGE_TIME 3 SECONDS // Amount of time after which we remove a registered instance of damage.
#define PRIMAL_WRATH_DEBUFF_LIMIT 2 // Limits the ability and its stacking debuffs.
#define PRIMAL_WRATH_DAMAGE_REDUCTION 0.1 // percent
#define PRIMAL_WRATH_HEALTH_REDUCTION 50 // flat
#define PRIMAL_WRATH_SLOWDOWN 0.2 // flat
#define PRIMAL_WRATH_DEBUFF_DURATION 3 MINUTES

/datum/action/ability/xeno_action/primal_wrath
	name = "Primal Wrath"
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "primal_wrath"
	desc = "Recover all damage recently received, and gain a brief moment of invulnerability, in exchange for a stacking debuff."
	ability_cost = 100
	cooldown_duration = 90 SECONDS
	action_type = ACTION_TOGGLE
	use_state_flags = ABILITY_USE_BUCKLED|ABILITY_USE_STAGGERED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PRIMAL_WRATH,
	)
	/// Visual effect that is used to indicate various things.
	var/obj/effect/primal_wrath/visual_effect
	/// List containing another list that specifies damage taken, and includes a timer that will remove it.
	var/list/damage_taken
	/// Counter reflecting the amount of stacks for this action's debuff.
	var/debuff_counter = 0

/datum/action/ability/xeno_action/primal_wrath/give_action(mob/living/L)
	. = ..()
	visual_references[VREF_MUTABLE_PRIMAL_WRATH] = mutable_appearance(null, null, ACTION_LAYER_MAPTEXT, appearance_flags = RESET_COLOR)
	var/mutable_appearance/counter = visual_references[VREF_MUTABLE_PRIMAL_WRATH]
	counter.pixel_x = 16
	counter.pixel_y = -4
	prepare_action()

/datum/action/ability/xeno_action/primal_wrath/remove_action(mob/living/L)
	clean_up()
	return ..()

/datum/action/ability/xeno_action/primal_wrath/clean_action()
	clean_up()
	return ..()

/datum/action/ability/xeno_action/primal_wrath/update_button_icon()
	. = ..()
	if(!. || !visual_references[VREF_MUTABLE_PRIMAL_WRATH])
		return
	var/mutable_appearance/counter = visual_references[VREF_MUTABLE_PRIMAL_WRATH]
	button.cut_overlay(counter)
	if(!debuff_counter)
		return
	counter.maptext = MAPTEXT("x[debuff_counter]")
	visual_references[VREF_MUTABLE_PRIMAL_WRATH] = counter
	button.add_overlay(counter)

/datum/action/ability/xeno_action/primal_wrath/on_cooldown_finish()
	. = ..()
	if(xeno_owner.stat >= DEAD)
		return
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/alien/new_larva.ogg', 20, 0)
	xeno_owner.balloon_alert(xeno_owner, "[initial(name)] ready")
	RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))

/datum/action/ability/xeno_action/primal_wrath/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(debuff_counter >= PRIMAL_WRATH_DEBUFF_LIMIT)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "[initial(name)]'s limit reached")
		return FALSE

/datum/action/ability/xeno_action/primal_wrath/action_activate()
	. = ..()
	UnregisterSignal(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	toggled = TRUE
	set_toggle(TRUE)
	xeno_owner.status_flags |= GODMODE
	xeno_owner.set_canmove(FALSE)
	xeno_owner.fortify = TRUE
	playsound(xeno_owner.loc, 'sound/effects/alien/behemoth/primal_wrath_roar.ogg', 65, TRUE, 40)
	do_roar()
	addtimer(CALLBACK(src, PROC_REF(end_roar)), PRIMAL_WRATH_ACTIVATION_DURATION)
	var/heal_amount = 0
	for(var/i in damage_taken) // Could also have been a backward loop using length but I'm way too lazy to figure it out.
		var/list/params = params2list(i)
		if(text2num(params["time"]) + PRIMAL_WRATH_DAMAGE_TIME < world.time)
			LAZYREMOVE(damage_taken, i)
			continue
		heal_amount += text2num(params["damage"])
	xeno_owner.balloon_alert(xeno_owner, "+[heal_amount]")
	HEAL_XENO_DAMAGE(xeno_owner, heal_amount, FALSE)
	xeno_owner.updatehealth()
	var/datum/personal_statistics/xeno_stats = GLOB.personal_statistics_list[xeno_owner.ckey]
	xeno_stats.self_heals++
	xeno_stats.primal_wrath_healing += heal_amount
	handle_debuff()
	addtimer(CALLBACK(src, PROC_REF(handle_debuff), FALSE), PRIMAL_WRATH_DEBUFF_DURATION)
	succeed_activate()
	add_cooldown()

/datum/action/ability/xeno_action/primal_wrath/process()
	var/initial_time = 0 // Integration tests BEGONE.
	var/animation_time = 0.8 SECONDS
	animate(visual_effect, initial_time, alpha = 230)
	animate(animation_time, easing = CUBIC_EASING|EASE_OUT, alpha = 0)

/// Prepares the action for its usage.
/datum/action/ability/xeno_action/primal_wrath/proc/prepare_action()
	visual_effect = new(null, xeno_owner)
	xeno_owner.vis_contents += visual_effect
	LAZYINITLIST(damage_taken)
	RegisterSignal(xeno_owner, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))

/// Cleans up signals and vars.
/datum/action/ability/xeno_action/primal_wrath/proc/clean_up()
	UnregisterSignal(xeno_owner, list(COMSIG_MOB_DEATH, COMSIG_MOB_REVIVE, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	handle_debuff(cleaning = TRUE)
	LAZYNULL(damage_taken)
	xeno_owner.vis_contents -= visual_effect
	QDEL_NULL(visual_effect)

/// Cleans up on death, and starts listening in case of revival, so that we can prepare the action again.
/datum/action/ability/xeno_action/primal_wrath/proc/on_death(datum/source, gibbing)
	SIGNAL_HANDLER
	clean_up()
	RegisterSignal(xeno_owner, COMSIG_MOB_REVIVE, PROC_REF(on_revive))

/// Prepares the action again after being revived.
/datum/action/ability/xeno_action/primal_wrath/proc/on_revive(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(xeno_owner, COMSIG_MOB_REVIVE)
	prepare_action()

/// Registers the amount of damage taken, and the current time. Also cleans up older entries.
/datum/action/ability/xeno_action/primal_wrath/proc/on_damage(datum/source, amount, list/amount_mod, passive)
	SIGNAL_HANDLER
	LAZYADD(damage_taken, list2params(list(time = world.time, damage = amount)))

/// Distorts the screen of nearby enemies. Huge shoutout to Tivi for providing this code a while back.
/datum/action/ability/xeno_action/primal_wrath/proc/do_roar()
	if(!toggled)
		return
	new /obj/effect/temp_visual/shockwave/primal_wrath(xeno_owner.loc, 4, xeno_owner.dir)
	for(var/mob/living/carbon/human/H AS in cheap_get_humans_near(xeno_owner, PRIMAL_WRATH_ROAR_RANGE))
		if(!H.hud_used)
			continue
		var/atom/movable/plane_master_controller/game_plane = H.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		var/filter_size = 0.01
		game_plane.add_filter("primal_wrath", 2, radial_blur_filter(filter_size))
		for(var/dm_filter/F AS in game_plane.get_filters("primal_wrath"))
			animate(F, size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		roar_check(H, game_plane)
	addtimer(CALLBACK(src, PROC_REF(do_roar)), 0.1 SECONDS)

/// Checks if the victim's screen should still be distorted.
/datum/action/ability/xeno_action/primal_wrath/proc/roar_check(mob/living/carbon/human/H, atom/movable/plane_master_controller/game_plane)
	if(!game_plane.get_filter("primal_wrath"))
		return
	if(!toggled || get_dist(H, xeno_owner) > PRIMAL_WRATH_ROAR_RANGE)
		var/resolve_time = 0.2 SECONDS
		for(var/dm_filter/F AS in game_plane.get_filters("primal_wrath"))
			animate(F, size = 0, time = resolve_time, flags = ANIMATION_PARALLEL)
		addtimer(CALLBACK(game_plane, TYPE_PROC_REF(/datum, remove_filter), "primal_wrath"), resolve_time)
		return
	addtimer(CALLBACK(src, PROC_REF(roar_check), H, game_plane), 0.2 SECONDS)

/// Resets changes made to accomodate for roaring.
/datum/action/ability/xeno_action/primal_wrath/proc/end_roar()
	toggled = FALSE // This stops the roar loop.
	set_toggle(FALSE)
	xeno_owner.status_flags &= ~GODMODE
	xeno_owner.set_canmove(TRUE)
	xeno_owner.fortify = FALSE

/// Handles the addition or removal of any changes related to this action's debuff.
/// Uses a lot of conditionals to cut down on coding lines at the expense of readability. Might be a bad idea?
/datum/action/ability/xeno_action/primal_wrath/proc/handle_debuff(applying = TRUE, cleaning = FALSE)
	debuff_counter = cleaning ? initial(debuff_counter) : debuff_counter + (applying ? 1 : -1)
	xeno_owner.xeno_melee_damage_modifier = cleaning ? initial(xeno_owner.xeno_melee_damage_modifier) : xeno_owner.xeno_melee_damage_modifier + (applying ? -PRIMAL_WRATH_DAMAGE_REDUCTION : PRIMAL_WRATH_DAMAGE_REDUCTION)
	xeno_owner.xeno_caste.max_health = cleaning ? initial(xeno_owner.xeno_caste.max_health) : xeno_owner.xeno_caste.max_health + (applying ? -PRIMAL_WRATH_HEALTH_REDUCTION : PRIMAL_WRATH_HEALTH_REDUCTION)
	xeno_owner.maxHealth = xeno_owner.xeno_caste.max_health
	xeno_owner.health = min(xeno_owner.health, xeno_owner.xeno_caste.max_health)
	if(xeno_owner.has_movespeed_modifier(MOVESPEED_ID_PRIMAL_WRATH) && (cleaning || !applying && xeno_owner.get_movespeed_modifier(MOVESPEED_ID_PRIMAL_WRATH) <= PRIMAL_WRATH_SLOWDOWN))
		xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_PRIMAL_WRATH)
		STOP_PROCESSING(SSslowprocess, src)
		return
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_PRIMAL_WRATH, TRUE, 0, NONE, TRUE, PRIMAL_WRATH_SLOWDOWN * debuff_counter)
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSslowprocess, src)

/obj/effect/temp_visual/shockwave/primal_wrath/Initialize(mapload, radius, direction, speed_rate=1, easing_type = LINEAR_EASING, y_offset=0, x_offset=0)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_y += 16
		if(WEST)
			pixel_x -= 34
			pixel_y += 6
		if(EAST)
			pixel_x += 39
			pixel_y += 6

// TO DO: Primal Wrath shows up on Examine. How do I stop that?
/obj/effect/primal_wrath
	alpha = 0
	color = COLOR_NEARLY_BLACK_VIOLET
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The owner of this effect.
	var/atom/owner

/obj/effect/primal_wrath/Initialize(mapload, atom/target)
	. = ..()
	if(!target)
		return
	owner = target
	icon = owner.icon
	icon_state = owner.icon_state
	layer = owner.layer + 0.4 // Layers over wounds.
	dir = owner.dir
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_REMOVETRAIT(TRAIT_FLOORED)), PROC_REF(copy_state))
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(copy_dir))
	add_filter("primal_wrath_overlay", 2, radial_blur_filter(0.04))

/obj/effect/primal_wrath/Destroy()
	owner = null
	return ..()

/// Copies the target's icon state.
/obj/effect/primal_wrath/proc/copy_state(datum/source)
	SIGNAL_HANDLER
	icon_state = owner.icon_state

/// Copies the target's dir.
/obj/effect/primal_wrath/proc/copy_dir(datum/source, dir, newdir)
	SIGNAL_HANDLER
	setDir(newdir)
