/obj/effect/temp_visual/behemoth
	name = "Behemoth"
	duration = 10 SECONDS


/* ***************************************
// *********** Earth Pillar
// ***************************************
*/
#define isearthpillar(A) (istype(A, /obj/structure/xeno/earth_pillar)) // So that we don't need to repeat the type path.
#define EARTH_PILLAR_REPAIR_DELAY 1.4 SECONDS
#define EARTH_PILLAR_REPAIR_PERCENT 0.1 // 10%
#define EARTH_PILLAR_THROW_RANGE 5 // tiles
#define EARTH_PILLAR_THROW_SPEED 1
#define EARTH_PILLAR_THROW_STAGGER 1 // stacks
#define EARTH_PILLAR_THROW_SLOWDOWN 1 // stacks
#define EARTH_PILLAR_THROW_KNOCKDOWN 0.7 SECONDS
#define EARTH_PILLAR_THROW_KNOCKBACK 1 // tiles

/obj/structure/xeno/earth_pillar
	name = "earth pillar"
	icon = 'icons/effects/effects.dmi'
	icon_state = "earth_pillar"
	layer = MOB_BELOW_PIGGYBACK_LAYER
	climbable = TRUE
	density = TRUE
	coverage = INFINITY
	max_integrity = 500
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 100, FIRE = 100, ACID = 0)
	hit_sound = SFX_BEHEMOTH_EARTH_PILLAR_HIT
	destroy_sound = 'sound/effects/alien/behemoth/earth_pillar_destroyed.ogg'
	interaction_flags = INTERACT_CHECK_INCAPACITATED|INTERACT_POWERLOADER_PICKUP_ALLOWED_BYPASS_ANCHOR
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
	vis_contents += flash_visual
	flash_visual.layer = layer + 0.01
	flash_visual.alpha = 0
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

/// Adds interactions specifically for Behemoths.
/obj/structure/xeno/earth_pillar/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = xeno_attacker.xeno_caste.melee_damage_type, armor_type = xeno_attacker.xeno_caste.melee_damage_armor, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!isxenobehemoth(xeno_attacker)) // If you're not a Behemoth, then you're unworthy of the rock. Begone, pleb.
		return
	if(xeno_attacker.a_intent == INTENT_HELP) // Repairs the rock if it's damaged.
		if(obj_integrity >= max_integrity)
			balloon_alert(xeno_attacker, "[name] does not need repairs")
			return
		while(do_after(xeno_attacker, EARTH_PILLAR_REPAIR_DELAY, NONE, src, BUSY_ICON_CLOCK))
			var/repair_amount = max_integrity * EARTH_PILLAR_REPAIR_PERCENT
			repair_damage(repair_amount, xeno_attacker)
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
	RemoveElement(/datum/element/connect_loc)
	RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))

/// Making impact with living atoms will affect them.
/obj/structure/xeno/earth_pillar/proc/on_impact(datum/source, atom/A, speed)
	SIGNAL_HANDLER
	if(!isliving(A) || xeno_owner?.issamexenohive(A))
		return
	var/mob/living/L = A
	L.Stagger(EARTH_PILLAR_THROW_STAGGER)
	L.add_slowdown(EARTH_PILLAR_THROW_SLOWDOWN)
	L.Knockdown(EARTH_PILLAR_THROW_KNOCKDOWN)
	L.knockback(xeno_owner, EARTH_PILLAR_THROW_KNOCKBACK, 1)
	L.apply_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, xeno_owner.xeno_caste.melee_damage_type, xeno_owner.zone_selected, xeno_owner.xeno_caste.melee_damage_armor, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
	INVOKE_ASYNC(L, TYPE_PROC_REF(/mob, emote), "pain")

/// Cleans up after this object is thrown.
/obj/structure/xeno/earth_pillar/proc/post_throw(datum/source)
	SIGNAL_HANDLER
	climbable = TRUE
	AddElement(/datum/element/connect_loc, connections)
	UnregisterSignal(src, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))

/// Applies various changes when this object is held.
/obj/structure/xeno/earth_pillar/proc/when_grabbed(mob/grabber)
	layer = ABOVE_ALL_MOB_LAYER
	anchored = FALSE
	density = FALSE
	obj_flags = NONE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	current_holder = grabber
	current_holder.held_pillar = src
	RegisterSignals(current_holder, list(COMSIG_QDELETING, COMSIG_MOB_DEATH), PROC_REF(force_drop))
	RegisterSignal(current_holder, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(update_glide))
	RegisterSignal(current_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	forceMove(current_holder.loc)
	dummy_item = new(current_holder.loc)
	RegisterSignal(dummy_item, COMSIG_ITEM_ATTACK_TURF, PROC_REF(attack_turf)) // to do: this only works on adjacent turfs. find an alternative that checks everything?
	RegisterSignal(dummy_item, COMSIG_ITEM_REMOVED_INVENTORY, PROC_REF(force_drop))
	current_holder.put_in_active_hand(dummy_item)

/// Resets all changes made when this object is dropped.
/obj/structure/xeno/earth_pillar/proc/when_dropped(datum/source, turf/dropped_turf)
	SIGNAL_HANDLER
	alpha = initial(alpha) // Changed by Earth Riser.
	layer = initial(layer)
	anchored = initial(anchored)
	density = initial(density)
	obj_flags = initial(obj_flags)
	resistance_flags = initial(resistance_flags)
	mouse_opacity = initial(mouse_opacity)
	reset_glide_size()
	forceMove(dropped_turf ? dropped_turf : current_holder.loc)
	UnregisterSignal(current_holder, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, COMSIG_MOVABLE_MOVED))
	current_holder.held_pillar = null
	current_holder = null
	if(dummy_item)
		QDEL_NULL(dummy_item)

/// Forces the object to be dropped.
/obj/structure/xeno/earth_pillar/proc/force_drop(datum/source)
	SIGNAL_HANDLER
	when_dropped(current_holder)

/// Updates the glide size to match our current holder's.
/obj/structure/xeno/earth_pillar/proc/update_glide(datum/source, target)
	SIGNAL_HANDLER
	set_glide_size(target)

/// Whenever the current holder moves, this object will also move alongside them.
/obj/structure/xeno/earth_pillar/proc/on_move(datum/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	forceMove(current_holder.loc)

/// When the dummy item is used to attack a turf, this object will be dropped on it.
/obj/structure/xeno/earth_pillar/proc/attack_turf(datum/source, turf/attacked_turf, atom/user)
	SIGNAL_HANDLER
	if(xeno_owner.a_intent != INTENT_GRAB)
		return
	when_dropped(current_holder, attacked_turf)

/// Updates appearances, and the HUD elements. Needed to handle signals.
/obj/structure/xeno/earth_pillar/proc/update_visuals(datum/source)
	SIGNAL_HANDLER
	update_appearance()
	var/image/holder = hud_list[HEALTH_HUD_XENO] // TO DO: why is this not working? send help
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
#define SEIZE_SPEED 1 // throw speed

/datum/action/ability/activable/xeno/behemoth_seize
	name = "Seize"
	desc = "Dash towards an Earth Pillar and grab it."
	action_icon = 'icons/Xeno/actions/runner.dmi'
	action_icon_state = "pounce"
	ability_cost = 30
	cooldown_duration = 10 SECONDS
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
			if(!isearthpillar(M) || !line_of_sight(xeno_owner, M, action_range))
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
/datum/action/ability/activable/xeno/behemoth_seize/proc/dash_to_pillar(obj/structure/xeno/earth_pillar/target_pillar)
	if(!target_pillar)
		return
	if(xeno_owner.held_pillar) // If we're already holding a pillar, drop it so we can grab the targetted one.
		if(!xeno_owner.held_pillar.dummy_item) // to do explanation here
			return
		xeno_owner.held_pillar.when_dropped(xeno_owner)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(check_pre_move))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))
	xeno_owner.throw_at(target_pillar, action_range, SEIZE_SPEED, xeno_owner, targetted_throw = TRUE)
	target_pillar.warning_flash()
	add_cooldown()
	succeed_activate()

/// Checks if there's an Earth Pillar in the tile we're about to move into, and grabs it if so, allowing movement to continue uninterrupted.
/datum/action/ability/activable/xeno/behemoth_seize/proc/check_pre_move(datum/source, atom/new_loc, direction)
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


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_CREATION_RANGE 2 // tiles
#define EARTH_RISER_CREATION_COST 100
#define EARTH_RISER_THROW_DURATION 1.2 SECONDS
#define EARTH_RISER_THROW_RANGE 5 // tiles
#define EARTH_RISER_THROW_SPEED 1
#define EARTH_RISER_THROW_EXPLOSION_SIZE 2 // tiles
#define EARTH_RISER_THROW_EXPLOSION_KNOCKDOWN 0.5 SECONDS
#define EARTH_RISER_THROW_EXPLOSION_STAGGER 5 // stacks
#define EARTH_RISER_THROW_EXPLOSION_SLOWDOWN 5 // stacks
#define EARTH_RISER_THROW_EXPLOSION_DAMAGE_MULTIPLIER 0.5
#define EARTH_RISER_THROW_COOLDOWN 10 SECONDS
#define EARTH_RISER_THROW_COST 20

/datum/action/ability/activable/xeno/earth_riser
	name = "Earth Riser"
	desc = "Create an Earth Pillar in the target location. If holding one, you will throw it there instead."
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "earth_riser"
	cooldown_duration = 45 SECONDS
	use_state_flags = ABILITY_USE_LYING|ABILITY_USE_BUCKLED|ABILITY_IGNORE_PLASMA|ABILITY_IGNORE_COOLDOWN
	target_flags = ABILITY_TURF_TARGET
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
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = mutable_appearance(null, null, ACTION_LAYER_MAPTEXT)
	update_button_icon()

/datum/action/ability/activable/xeno/earth_riser/remove_action(mob/living/L)
	clear_pillars()
	return ..()

/datum/action/ability/activable/xeno/earth_riser/clean_action()
	clear_pillars()
	return ..()

/datum/action/ability/activable/xeno/earth_riser/update_button_icon()
	. = ..()
	if(!.)
		return
	var/mutable_appearance/pillar_counter = visual_references[VREF_MUTABLE_EARTH_PILLAR]
	button.cut_overlay(pillar_counter)
	if(!pillar_counter || !creation_limit)
		return
	if(creation_limit > 2)
		pillar_counter.icon = null
		pillar_counter.icon_state = null
		pillar_counter.pixel_x = 16
		pillar_counter.pixel_y = -4
		pillar_counter.maptext = MAPTEXT("["[length(active_pillars)]/[creation_limit]"]")
	else
		pillar_counter.icon = action_icon
		pillar_counter.icon_state = "pillar_counter_[creation_limit][length(active_pillars)]" // f.ex pillar_counter_11 means we have 1 pillar as a limit and 1 active pillar
		pillar_counter.pixel_x = initial(pillar_counter.pixel_x)
		pillar_counter.pixel_y = initial(pillar_counter.pixel_y)
		pillar_counter.maptext = null
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = pillar_counter
	button.add_overlay(pillar_counter)

// Handles ability checks instead, mostly because we need the final target in the event of target correction.
// We also check for plasma costs and cooldowns here because some parts of this ability ignore them.
/datum/action/ability/activable/xeno/earth_riser/use_ability(atom/target)
	. = ..()
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
		throw_pillar(target)
		return
	if(isearthpillar(target) && xeno_owner.Adjacent(target)) // If our target is an Earth Pillar, then we want to grab it. Plasma and cooldown are irrelevant for this.
		var/obj/structure/xeno/earth_pillar/P = target
		P.when_grabbed(src, xeno_owner)
		return
	if(length(active_pillars) >= creation_limit)
		xeno_owner.balloon_alert(xeno_owner, "Creation limit reached ([creation_limit])")
		return
	if(xeno_owner.plasma_stored < EARTH_RISER_CREATION_COST)
		xeno_owner.balloon_alert(xeno_owner, "Need [EARTH_RISER_CREATION_COST - xeno_owner.plasma_stored] more plasma")
		return
	if(!action_cooldown_finished())
		xeno_owner.balloon_alert(xeno_owner, "Wait [cooldown_remaining()] seconds!")
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
	for(var/atom/affected_atom AS in target)
		if(!isliving(affected_atom))
			continue
		var/mob/living/affected_living = affected_atom
		step_away(affected_living, target, 1, 1) // Living targets get displaced by a pillar spawning beneath them.
	var/obj/structure/xeno/earth_pillar/P = new(target, xeno_owner, creation_limit > initial(creation_limit) ? FOUNDATIONS_HEALTH_REDUCTION : FALSE)
	active_pillars += P
	RegisterSignal(P, COMSIG_QDELETING, PROC_REF(pillar_deleted))
	var/animation_time = 0.6 SECONDS
	animate(P, animation_time / 2, easing = SINE_EASING|EASE_OUT, pixel_y = P.pixel_y + 15)
	animate(animation_time / 2, easing = SINE_EASING|EASE_IN, flags = ANIMATION_CONTINUE, pixel_y = initial(P.pixel_y))
	playsound(xeno_owner, 'sound/effects/alien/behemoth/earth_pillar_landing.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/creation(target)
	add_cooldown(1 SECONDS)
	succeed_activate(EARTH_RISER_CREATION_COST)

/// Removes our reference to a pillar when it is deleted.
/datum/action/ability/activable/xeno/earth_riser/proc/pillar_deleted(datum/source, force)
	SIGNAL_HANDLER
	active_pillars -= source
	add_cooldown()

/// Tries to throw our currently held pillar towards a target.
/datum/action/ability/activable/xeno/earth_riser/proc/throw_pillar(atom/target)
	xeno_owner.held_pillar.alpha = 0
	qdel(xeno_owner.held_pillar.dummy_item)
	var/obj/effect/temp_visual/behemoth/earth_pillar/thrown/throw_visual = new(xeno_owner.loc)
	var/animation_time = EARTH_RISER_THROW_DURATION - 0.21 SECONDS // For some reason the animation sequence below is taking longer than the given duration. BYOND fuckery?
	animate(throw_visual, animation_time / 2, easing = CIRCULAR_EASING|EASE_OUT, pixel_y = xeno_owner.held_pillar.y + 40 - get_dist(xeno_owner.held_pillar, target) * 6)
	animate(animation_time / 2, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_CONTINUE, pixel_y = (target.y - xeno_owner.held_pillar.y) * ICON_SIZE_Y)
	animate(animation_time, flags = ANIMATION_PARALLEL, pixel_x = (target.x - xeno_owner.held_pillar.x) * ICON_SIZE_X)
	var/list/turf/affected_turfs = filled_circle_turfs(target, EARTH_RISER_THROW_EXPLOSION_SIZE)
	for(var/turf/T AS in affected_turfs)
		for(var/atom/movable/M AS in T)
			if(!isearthpillar(M))
				continue
			affected_turfs += filled_circle_turfs(M, EARTH_RISER_THROW_EXPLOSION_SIZE) // Other pillars will mirror the explosion, and we'd like to include them in warnings.
			var/obj/structure/xeno/earth_pillar/P = M
			P.warning_flash()
	xeno_warning(affected_turfs, EARTH_RISER_THROW_DURATION, COLOR_DARK_MODERATE_ORANGE)
	addtimer(CALLBACK(src, PROC_REF(post_throw), target), EARTH_RISER_THROW_DURATION)
	add_cooldown(EARTH_RISER_THROW_COOLDOWN)
	succeed_activate(EARTH_RISER_THROW_COST)

/// Handles anything that should happen after the pillar's throw concludes.
/datum/action/ability/activable/xeno/earth_riser/proc/post_throw(atom/target)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/earth_pillar_landing.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/landing(get_turf(target))
	throw_landing(target, list(xeno_owner.held_pillar))
	xeno_owner.held_pillar.when_dropped(xeno_owner, target)

/// When the pillar lands after being thrown, it will apply various effects around it.
/datum/action/ability/activable/xeno/earth_riser/proc/throw_landing(atom/target, list/pillars_hit)
	for(var/turf/T AS in filled_circle_turfs(target, EARTH_RISER_THROW_EXPLOSION_SIZE))
		for(var/atom/movable/M AS in T)
			if(isearthpillar(M) && !xeno_owner.held_pillar.current_holder)
				pillars_hit += M
				post_throw(M.loc, pillars_hit) // Pillars hit by this will mirror this proc. pillars_hit ensures this doesn't repeat infinitely.
				continue
			if(!isliving(M) || xeno_owner.issamexenohive(M))
				continue
			var/mob/living/L = M
			if(L.loc == get_turf(target)) // If the pillar landed on you, then you're getting knocked down.
				L.Knockdown(EARTH_RISER_THROW_EXPLOSION_KNOCKDOWN)
			L.Stagger(EARTH_RISER_THROW_EXPLOSION_STAGGER)
			L.add_slowdown(EARTH_RISER_THROW_EXPLOSION_SLOWDOWN)
			L.apply_damage((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * EARTH_RISER_THROW_EXPLOSION_DAMAGE_MULTIPLIER, STAMINA, xeno_owner.zone_selected, NONE, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
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
	transform = matrix().Scale(0.8, 0.8)
	animate(src, duration, alpha = 0)


// ***************************************
// *********** Landslide
// ***************************************
#define LANDSLIDE_RANGE 5
#define LANDSLIDE_WIND_UP 0.5 SECONDS
#define LANDSLIDE_SPEED 1
#define LANDSLIDE_DAMAGE_MECHA_MODIFIER 1.5
#define LANDSLIDE_DAMAGE_VEHICLE_MODIFIER 10
#define LANDSLIDE_DAMAGE_LIVING_MULTIPLIER 0.8
#define LANDSLIDE_KNOCKDOWN_DURATION 0.7 SECONDS
#define LANDSLIDE_OBJECT_INTEGRITY_THRESHOLD 150

/datum/action/ability/activable/xeno/landslide
	name = "Landslide"
	desc = "Rush forward in the selected direction, damaging eligible targets in a wide path."
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "landslide"
	ability_cost = 50
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LANDSLIDE,
	)
	/// List of atoms we've hit with Landslide, so that we don't affect them multiple times.
	var/list/atoms_hit
	/// Stores the visual effect for when we're charging.
	var/obj/effect/landslide_charge/charge_visual

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
		if(isclosedturf(step))
			continue
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
			R.take_damage(xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, xeno_owner.xeno_caste.melee_damage_type, xeno_owner.xeno_caste.melee_damage_armor, TRUE, REVERSE_DIR(xeno_owner.dir), xeno_owner.xeno_caste.melee_ap, xeno_owner)
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
				if(L.buckled)
					L.buckled.unbuckle_mob(L, TRUE)
				INVOKE_ASYNC(L, TYPE_PROC_REF(/mob, emote), "scream")
				playsound(T, 'sound/effects/alien/behemoth/landslide_hit.ogg', 30, TRUE)
				L.apply_damage((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * LANDSLIDE_DAMAGE_LIVING_MULTIPLIER, xeno_owner.xeno_caste.melee_damage_type, ran_zone(), xeno_owner.xeno_caste.melee_damage_armor, TRUE, TRUE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
				L.Knockdown(LANDSLIDE_KNOCKDOWN_DURATION)
				atoms_hit += L
				continue
			if(isobj(M))
				if(istype(M, /obj/structure/mineral_door/resin) || istype(M, /obj/structure/razorwire)) // Exclusions. We go through resin doors, and razorwire stops us.
					continue
				if(isearthpillar(M)) // Pillars get thrown in the direction we're charging.
					var/obj/structure/xeno/earth_pillar/P = M
					P.throw_at(get_ranged_target_turf(P, movement_dir, LANDSLIDE_RANGE), LANDSLIDE_RANGE, 1, xeno_owner)
					atoms_hit += P
					continue
				if(isvehicle(M)) // Vehicles take increased damage.
					var/obj/vehicle/V = M
					V.take_damage((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * (ismecha(V) ? LANDSLIDE_DAMAGE_MECHA_MODIFIER : LANDSLIDE_DAMAGE_VEHICLE_MODIFIER), xeno_owner.xeno_caste.melee_damage_type, xeno_owner.xeno_caste.melee_damage_armor, null, get_dir(V, xeno_owner), xeno_owner.xeno_caste.melee_ap, xeno_owner)
					atoms_hit += V
					continue
				var/obj/O = M
				if(!O.density || O.allow_pass_flags & PASS_MOB || O.resistance_flags & INDESTRUCTIBLE)
					continue
				if(O.obj_integrity <= LANDSLIDE_OBJECT_INTEGRITY_THRESHOLD || istype(O, /obj/structure/closet)) // Objects under a certain integrity threshold are destroyed.
					playsound(T, 'sound/effects/meteorimpact.ogg', 30, TRUE)
					O.deconstruct(FALSE, istype(O, /obj/structure/window/framed) ? FALSE : xeno_owner) // Windows want a bool, whereas other objects want a mob to blame.
					atoms_hit += O

/// Adds effects for when we make impact against something.
/datum/action/ability/activable/xeno/landslide/proc/on_impact(datum/source, atom/hit_atom, speed)
	SIGNAL_HANDLER
	var/turf/atom_turf = get_turf(hit_atom)
	playsound(atom_turf, 'sound/effects/alien/behemoth/landslide_impact.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/landslide/impact(atom_turf, get_dir(hit_atom, xeno_owner))

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
#define GEOCRUSH_SLOWDOWN 5 // stacks
#define GEOCRUSH_STAGGER 5 // stacks
#define GEOCRUSH_KNOCKDOWN 1 SECONDS
#define GEOCRUSH_KNOCKBACK 2 // tiles

/datum/action/ability/activable/xeno/geocrush
	name = "Geocrush"
	desc = "Imbue one of your claws with powerful energies and attack a target. Deals damage and applies slowdown, stagger, knockdown, and knockback."
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "geocrush"
	//ability_cost = 60 // RESTORE AFTER DEBUGGING
	//cooldown_duration = 15 SECONDS
	use_state_flags = ABILITY_USE_BUCKLED
	target_flags = ABILITY_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GEOCRUSH,
	)
	/// Whether the Spur mutation is currently enabled.
	var/spur_mutation = FALSE

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
		var/mob/living/living_target = M
		INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")
		living_target.apply_damage(damage, xeno_owner.xeno_caste.melee_damage_type, ran_zone(), xeno_owner.xeno_caste.melee_damage_armor, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
		living_target.apply_damage(damage, STAMINA, xeno_owner.zone_selected, NONE, FALSE, FALSE, TRUE, xeno_owner.xeno_caste.melee_ap, xeno_owner)
		living_target.Knockdown(GEOCRUSH_KNOCKDOWN)
		living_target.add_slowdown(GEOCRUSH_SLOWDOWN)
		living_target.Stagger(GEOCRUSH_STAGGER)
		RegisterSignal(living_target, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
		RegisterSignal(living_target, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))
		living_target.knockback(xeno_owner, GEOCRUSH_KNOCKBACK, 1)
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
/datum/action/ability/xeno_action/primal_wrath
	name = "Primal Wrath"
	action_icon = 'icons/Xeno/actions/behemoth.dmi'
	action_icon_state = "primal_wrath"
	desc = "Hit all adjacent units around you, knocking them away and down."
	ability_cost = 35
	use_state_flags = ABILITY_USE_CRESTED
	cooldown_duration = 12 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_SWEEP,
	)
	/// How far does it knockback?
	var/knockback_distance = 1
	/// How long does it stagger?
	var/stagger_duration = 0 SECONDS
	/// How long does it paralyze?
	var/paralyze_duration = 0.5 SECONDS
	/// If this deals damage, what type of damage is it?
	var/damage_type = BRUTE
	/// The multiplier of the damage to be applied.
	var/damage_multiplier = 1
