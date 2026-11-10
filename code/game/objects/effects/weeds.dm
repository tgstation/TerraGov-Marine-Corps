// Color variant defines.
#define NORMAL_COLOR ""
#define RESTING_COLOR "white"
#define STICKY_COLOR "green"

// Stat defines.
#define RESTING_BUFF 1.2
#define WEED_SLOWDOWN 2

// ***************************************
// *********** Weeds
// ***************************************

/obj/alien/weeds
	name = "weeds"
	desc = "A layer of oozy slime, it feels slick, but not as slick for you to slip."
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "base"
	anchored = TRUE
	density = FALSE
	layer = XENO_WEEDS_LAYER
	plane = FLOOR_PLANE
	max_integrity = 25
	ignore_weed_destruction = TRUE
	/// The node that owns this weed.
	var/obj/alien/weeds/node/parent_node
	/// The color variant of the sprite.
	var/color_variant = NORMAL_COLOR
	/// The multiplier of an xenomorph's passive health/plasma regeneration.
	/// Health multiplier is conditional to resting (or alike). Plasma multiplier is unconditional.
	var/regeneration_multiplier = 1
	/// Is our deletion because we're being changed with different weed type? Used to prevent certain effects from occurring.
	/// Use [replace_weed()] when swapping weed types.
	var/swapped = FALSE

/obj/alien/weeds/Initialize(mapload, obj/alien/weeds/node/node, swapped = FALSE)
	. = ..()
	if(!set_parent_node(node))
		stack_trace("Weed was created without a parent node!")
		return INITIALIZE_HINT_QDEL

	var/static/list/connections = list(
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_ATOM_ENTERED = PROC_REF(on_loc_entered),
	)
	AddElement(/datum/element/connect_loc, connections)

	update_icon()
	if(!swapped)
		update_neighbours()
	for(var/mob/living/living_mob in loc.contents)
		SEND_SIGNAL(living_mob, COMSIG_LIVING_WEEDS_AT_LOC_CREATED, src)

/obj/alien/weeds/Destroy()
	parent_node = null
	if(swapped)
		return ..()
	for(var/mob/living/living_mob in range(1, src))
		SEND_SIGNAL(living_mob, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED)
	SEND_SIGNAL(loc, COMSIG_TURF_WEED_REMOVED)
	INVOKE_NEXT_TICK(src, PROC_REF(update_neighbours), loc)
	return ..()

/obj/alien/weeds/examine(mob/user)
	. = ..()
	var/turf/current_turf = get_turf(src)
	if(isfloorturf(current_turf))
		. += current_turf.ceiling_desc()

/obj/alien/weeds/update_icon_state()
	. = ..()
	var/new_direction = 0
	for(var/cardinal_direction in GLOB.cardinals)
		var/turf/nearby_turf = get_step(src, cardinal_direction)
		if(!istype(nearby_turf))
			continue
		if(istype(nearby_turf, /turf/closed/wall/resin))
			new_direction |= cardinal_direction
			continue
		if(locate(/obj/alien/weeds) in nearby_turf)
			new_direction |= cardinal_direction
			continue

	if(new_direction == 15) // Weeds in all four directions.
		icon_state = "weed[rand(0,15)]"
	else if(new_direction == 0) // No weeds in any direction.
		icon_state = "base"
	else
		icon_state = "weed_dir[new_direction]"
	icon_state += color_variant

/obj/alien/weeds/ex_act(severity)
	if(severity == EXPLODE_WEAK)
		return
	return ..()

/obj/alien/weeds/plasmacutter_act(mob/user, obj/item/tool)
	return FALSE // Just attack normally.

/obj/alien/weeds/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	GLOB.round_statistics.weeds_destroyed++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_destroyed")
	return ..()

/obj/alien/weeds/footstep_override(atom/movable/source, list/footstep_overrides)
	footstep_overrides[FOOTSTEP_RESIN] = get_footstep_layer(layer, plane)

/obj/alien/weeds/on_loc_entered(datum/source, atom/movable/crosser)
	. = ..()
	if(!isxeno(crosser))
		return
	var/mob/living/carbon/xenomorph/xeno = crosser
	xeno.next_move_slowdown += xeno?.xeno_caste?.weeds_speed_mod

/// Updates the icon of neighbouring weeds.
/obj/alien/weeds/proc/update_neighbours(turf/updated_loc = loc)
	if(!istype(updated_loc))
		return
	for(var/cardinal_direction in GLOB.cardinals)
		var/turf/nearby_turf = get_step(updated_loc, cardinal_direction)
		if(!istype(nearby_turf))
			continue
		var/obj/alien/weeds/nearby_weed = locate() in nearby_turf
		nearby_weed?.update_icon()

/// Replaces src with a new weed type. Will delete itself if none was provided.
/obj/alien/weeds/proc/replace_weed(new_weed_type, new_parent_node = parent_node)
	if(!ispath(new_weed_type, /obj/alien/weeds))
		qdel(src)
		return
	swapped = TRUE
	new new_weed_type(loc, new_parent_node, TRUE)
	qdel(src)

/// Sets our parent node and handles everything that may involve it.
/obj/alien/weeds/proc/set_parent_node(obj/alien/weeds/node/new_parent_node)
	if(!istype(new_parent_node))
		return FALSE
	if(new_parent_node == parent_node) // Should never happen, but might as well check.
		return TRUE
	if(parent_node)
		UnregisterSignal(parent_node, COMSIG_QDELETING)
	parent_node = new_parent_node
	color_variant = parent_node.color_variant
	RegisterSignal(parent_node, COMSIG_QDELETING, PROC_REF(clean_parent_node))
	return TRUE

/// Clears our parent node. Will adds us to the weed decay queue if our previous parent node isn't expected to be replaced.
/obj/alien/weeds/proc/clean_parent_node()
	SIGNAL_HANDLER
	if(!parent_node.swapped)
		SSweeds_decay.decaying_list += src
	parent_node = null

/// Check if we have a parent node. If not, will delete ourselves.
/obj/alien/weeds/proc/check_for_parent_node()
	if(parent_node)
		return
	qdel(src)

/obj/alien/weeds/sticky
	name = "sticky weeds"
	desc = "A layer of disgusting sticky slime, it feels like it's going to slow your movement down."
	color_variant = STICKY_COLOR

/obj/alien/weeds/sticky/on_loc_entered(datum/source, atom/movable/crosser)
	. = ..()
	slow_down_crosser(crosser, WEED_SLOWDOWN)

/obj/alien/weeds/resting
	name = "resting weeds"
	desc = "This looks almost comfortable."
	color_variant = RESTING_COLOR
	regeneration_multiplier = RESTING_BUFF

// ***************************************
// *********** Weed Walls
// ***************************************

/obj/alien/weeds/weedwall
	layer = WEEDWALL_LAYER
	plane = GAME_PLANE
	icon = 'icons/obj/smooth_objects/weedwall.dmi'
	icon_state = "weedwall"

/obj/alien/weeds/weedwall/update_icon_state()
	. = ..()
	var/turf/closed/wall/wall_turf = loc
	icon_state = (istype(wall_turf) && wall_turf.smoothing_junction) ? "weedwall-[wall_turf.smoothing_junction]" : initial(icon_state)
	switch(color_variant)
		if(STICKY_COLOR)
			icon = 'icons/obj/smooth_objects/weedwallsticky.dmi'
		if(RESTING_COLOR)
			icon = 'icons/obj/smooth_objects/weedwallrest.dmi'

// ***************************************
// *********** Weed Walls: Windows
// ***************************************

/obj/alien/weeds/weedwall/window
	layer = GIB_LAYER
	/// The type of window we're expecting to grow on.
	var/window_type = /obj/structure/window/framed

/obj/alien/weeds/weedwall/window/update_icon_state()
	. = ..()
	var/obj/structure/window = locate(window_type) in loc
	icon_state = window?.smoothing_junction ? "weedwall-[window.smoothing_junction]" : initial(icon_state)
	switch(color_variant)
		if(STICKY_COLOR)
			icon = 'icons/obj/smooth_objects/weedwallsticky.dmi'
		if(RESTING_COLOR)
			icon = 'icons/obj/smooth_objects/weedwallrest.dmi'

/obj/alien/weeds/weedwall/window/MouseDrop_T(atom/dropping, mob/user, params)
	var/obj/structure/window = locate(window_type) in loc
	if(!window)
		return ..()
	return window.MouseDrop_T(dropping, user)

/obj/alien/weeds/weedwall/window/CtrlClick(mob/living/carbon/user)
	var/obj/structure/window = locate(window_type) in loc
	if(!window)
		return ..()
	return window.CtrlClick(user)

/obj/alien/weeds/weedwall/window/attackby(obj/item/attacking_item, mob/user, params) // Yes, this blocks attacking the weed itself, but if you destroy the frame you destroy the weed!
	var/obj/structure/window = locate(window_type) in loc
	if(!window)
		return ..()
	return window.attackby(attacking_item, user, params)

/obj/alien/weeds/weedwall/window/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	var/obj/structure/window = locate(window_type) in loc
	if(!window)
		return ..()
	return window.attack_alien(xeno_attacker, damage_amount, damage_type, armor_type, effects, armor_penetration, isrightclick)

/obj/alien/weeds/weedwall/window/frame
	window_type = /obj/structure/window_frame

// ***************************************
// *********** Weed Nodes
// ***************************************

/obj/alien/weeds/node
	name = WEED
	desc = "A weird, pulsating purple node."
	max_integrity = 60
	/// The node icon overlay to apply to us.
	var/node_icon = "weednode"
	/// List of all potential turfs that we can expand to.
	var/node_turfs = list()
	/// How far this node can spread weeds?
	var/node_range = 2
	/// What type of weeds this node spreads?
	var/obj/alien/weeds/weed_type = /obj/alien/weeds
	/// The plasma cost multiplier for this node.
	var/ability_cost_mult = 1

/obj/alien/weeds/node/Initialize(mapload, obj/alien/weeds/node/node, swapped)
	var/are_we_swapping = FALSE
	for(var/obj/alien/weeds/replaced_weed in loc)
		if(replaced_weed == src)
			continue
		replaced_weed.swapped = TRUE
		are_we_swapping = TRUE
		qdel(replaced_weed)
		break
	. = ..(mapload, node, are_we_swapping)

	// Generate our full graph before adding to SSweeds.
	node_turfs = filled_turfs(src, node_range, "square")
	SSweeds.add_node(src)

/obj/alien/weeds/node/set_parent_node(atom/node)
	return TRUE // We're nodeless - because we are the node.

/obj/alien/weeds/node/update_overlays()
	. = ..()
	. += mutable_appearance(icon, node_icon + "[rand(0,5)]")

// Sticky weed node.
/obj/alien/weeds/node/sticky
	name = STICKY_WEED
	desc = "A weird, pulsating blue node."
	weed_type = /obj/alien/weeds/sticky
	color_variant = STICKY_COLOR
	node_icon = "weednodegreen"
	ability_cost_mult = 3

/obj/alien/weeds/node/sticky/on_loc_entered(datum/source, atom/movable/crosser)
	. = ..()
	slow_down_crosser(crosser, WEED_SLOWDOWN)

// Resting weed node.
/obj/alien/weeds/node/resting
	name = RESTING_WEED
	desc = "A weird, pulsating pale node."
	weed_type = /obj/alien/weeds/resting
	color_variant = RESTING_COLOR
	node_icon = "weednodewhite"
	regeneration_multiplier = RESTING_BUFF
	ability_cost_mult = 2
