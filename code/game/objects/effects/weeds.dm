//Color variant defines
#define SPEED_COLOR ""
#define RESTING_COLOR "white"
#define STICKY_COLOR "green"

//Stat defines
#define RESTING_BUFF 1.2
#define WEED_SLOWDOWN 2

// base weed type
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

	var/obj/alien/weeds/node/parent_node
	///The color variant of the sprite
	var/color_variant = SPEED_COLOR
	///The healing buff when resting on this weed
	var/resting_buff = 1
	///If these weeds are not destroyed but just swapped
	var/swapped = FALSE

/obj/alien/weeds/deconstruct(disassembled = TRUE)
	GLOB.round_statistics.weeds_destroyed++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_destroyed")
	return ..()

/obj/alien/weeds/Initialize(mapload, obj/alien/weeds/node/node, swapped = FALSE)
	. = ..()

	if(!isnull(node))
		if(!istype(node))
			CRASH("Weed created with non-weed node. Type: [node.type]")
		set_parent_node(node)
	update_icon()
	AddElement(/datum/element/accelerate_on_crossed)
	if(!swapped)
		update_neighbours()
	for(var/mob/living/living_mob in loc.contents)
		SEND_SIGNAL(living_mob, COMSIG_LIVING_WEEDS_AT_LOC_CREATED, src)

/obj/alien/weeds/Destroy()
	parent_node = null
	if(swapped)
		return ..()
	for(var/mob/living/L in range(1, src))
		SEND_SIGNAL(L, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED)
	SEND_SIGNAL(loc, COMSIG_TURF_WEED_REMOVED)
	INVOKE_NEXT_TICK(src, .proc/update_neighbours, loc)
	return ..()

/obj/alien/weeds/examine(mob/user)
	. = ..()
	var/turf/T = get_turf(src)
	if(isfloorturf(T))
		. += T.ceiling_desc()

/obj/alien/weeds/proc/update_neighbours(turf/U)
	if(!U)
		U = loc
	if(istype(U))
		for (var/dirn in GLOB.cardinals)
			var/turf/T = get_step(U, dirn)

			if (!istype(T))
				continue

			var/obj/alien/weeds/W = locate() in T
			if(W)
				W.update_icon()

///Check if we have a parent node, if not, qdel ourselve
/obj/alien/weeds/proc/check_for_parent_node()
	if(parent_node)
		return
	qdel(src)

/obj/alien/weeds/update_icon_state()
	. = ..()
	var/my_dir = 0
	for (var/check_dir in GLOB.cardinals)
		var/turf/check = get_step(src, check_dir)

		if (!istype(check))
			continue
		if(istype(check, /turf/closed/wall/resin))
			my_dir |= check_dir

		else if (locate(/obj/alien/weeds) in check)
			my_dir |= check_dir

	if (my_dir == 15) //weeds in all four directions
		icon_state = "weed[rand(0,15)]"
	else if(my_dir == 0) //no weeds in any direction
		icon_state = "base"
	else
		icon_state = "weed_dir[my_dir]"
	icon_state += color_variant

///Set the parent_node to node
/obj/alien/weeds/proc/set_parent_node(atom/node)
	if(parent_node)
		UnregisterSignal(parent_node, COMSIG_PARENT_QDELETING)
	parent_node = node
	RegisterSignal(parent_node, COMSIG_PARENT_QDELETING, .proc/clean_parent_node)

///Clean the parent node var
/obj/alien/weeds/proc/clean_parent_node()
	SIGNAL_HANDLER
	if(!parent_node.swapped)
		SSweeds_decay.decaying_list += src
	parent_node = null

/obj/alien/weeds/sticky
	name = "sticky weeds"
	desc = "A layer of disgusting sticky slime, it feels like it's going to slow your movement down."
	color_variant = STICKY_COLOR

/obj/alien/weeds/sticky/Initialize(mapload, obj/alien/weeds/node/node)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/slow_down_crosser
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/alien/weeds/sticky/proc/slow_down_crosser(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER
	if(crosser.throwing || crosser.buckled)
		return

	if(isvehicle(crosser))
		var/obj/vehicle/vehicle = crosser
		vehicle.last_move_time += WEED_SLOWDOWN
		return

	if(isxeno(crosser))
		var/mob/living/carbon/xenomorph/X = crosser
		X.next_move_slowdown += X.xeno_caste.weeds_speed_mod
		return

	if(!ishuman(crosser))
		return

	if(CHECK_MULTIPLE_BITFIELDS(crosser.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += WEED_SLOWDOWN


/obj/alien/weeds/resting
	name = "resting weeds"
	desc = "This looks almost comfortable."
	color_variant = RESTING_COLOR
	resting_buff = RESTING_BUFF

// =================
// weed wall
/obj/alien/weeds/weedwall
	layer = RESIN_STRUCTURE_LAYER
	plane = GAME_PLANE
	icon_state = "weedwall"

/obj/alien/weeds/weedwall/update_icon_state()
	var/turf/closed/wall/W = loc
	icon_state = W.junctiontype ? "weedwall[W.junctiontype]" : initial(icon_state)
	icon_state += color_variant

// =================
// windowed weed wall
/obj/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/alien/weeds/weedwall/window/update_icon_state()
	var/obj/structure/window/framed/F = locate() in loc
	icon_state = F?.junction ? "weedwall[F.junction]" : initial(icon_state)
	icon_state += color_variant

/obj/alien/weeds/weedwall/window/MouseDrop_T(atom/dropping, mob/user)
	var/obj/structure/window/framed/F = locate() in loc
	if(!F)
		return ..()
	return F.MouseDrop_T(dropping, user)

/obj/alien/weeds/weedwall/frame
	layer = ABOVE_TABLE_LAYER

/obj/alien/weeds/weedwall/frame/update_icon_state()
	var/obj/structure/window_frame/WF = locate() in loc
	icon_state = WF?.junction ? "weedframe[WF.junction]" : initial(icon_state)
	icon_state += color_variant

/obj/alien/weeds/weedwall/frame/MouseDrop_T(atom/dropping, mob/user)
	var/obj/structure/window_frame/WF = locate() in loc
	if(!WF)
		return ..()
	return WF.MouseDrop_T(dropping, user)


// =================
// weed node - grows other weeds
/obj/alien/weeds/node
	name = WEED
	desc = "A weird, pulsating purple node."
	max_integrity = 60
	var/node_icon = "weednode"
	/// list of all potential turfs that we can expand to
	var/node_turfs = list()
	/// How far this node can spread weeds
	var/node_range = 2
	/// What type of weeds this node spreads
	var/obj/alien/weeds/weed_type = /obj/alien/weeds
	///The plasma cost multiplier for this node
	var/plasma_cost_mult = 1

/obj/alien/weeds/node/Initialize(mapload, obj/alien/weeds/node/node)
	var/swapped = FALSE
	for(var/obj/alien/weeds/W in loc)
		if(W != src)
			W.swapped = TRUE
			swapped = TRUE
			qdel(W) //replaces the previous weed
			break
	. = ..(mapload, node, swapped)

	// Generate our full graph before adding to SSweeds
	node_turfs = filled_turfs(src, node_range, "square")
	SSweeds.add_node(src)
	swapped = FALSE

/obj/alien/weeds/node/set_parent_node(atom/node)
	CRASH("set_parent_node was called on a /obj/alien/weeds/node, node are not supposed to have node themselves")

/obj/alien/weeds/node/update_overlays()
	. = ..()
	overlays.Cut()
	overlays += node_icon

//Sticky weed node
/obj/alien/weeds/node/sticky
	name = STICKY_WEED
	desc = "A weird, pulsating red node."
	weed_type = /obj/alien/weeds/sticky
	color_variant = STICKY_COLOR
	node_icon = "weednodegreen"
	plasma_cost_mult = 3

/obj/alien/weeds/node/sticky/Initialize(mapload, obj/alien/weeds/node/node)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/slow_down_crosser
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/alien/weeds/node/sticky/proc/slow_down_crosser(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER
	if(crosser.throwing || crosser.buckled)
		return

	if(isvehicle(crosser))
		var/obj/vehicle/vehicle = crosser
		vehicle.last_move_time += WEED_SLOWDOWN
		return

	if(!ishuman(crosser))
		return

	if(CHECK_MULTIPLE_BITFIELDS(crosser.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += WEED_SLOWDOWN

//Resting weed node
/obj/alien/weeds/node/resting
	name = RESTING_WEED
	desc = "A weird, pulsating white node."
	weed_type = /obj/alien/weeds/resting
	color_variant = RESTING_COLOR
	node_icon = "weednodewhite"
	resting_buff = RESTING_BUFF
	plasma_cost_mult = 2
