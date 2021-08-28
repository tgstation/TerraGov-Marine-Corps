#define NODERANGE 2

// =================
// basic weed type
/obj/effect/alien/weeds
	name = "weeds"
	desc = "Weird black weeds..."
	icon = 'icons/Xeno/weeds.dmi'
	icon_state = "base"
	anchored = TRUE
	density = FALSE
	layer = XENO_WEEDS_LAYER
	plane = FLOOR_PLANE
	max_integrity = 25
	ignore_weed_destruction = TRUE

	var/obj/effect/alien/weeds/node/parent_node

/obj/effect/alien/weeds/deconstruct(disassembled = TRUE)
	GLOB.round_statistics.weeds_destroyed++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_destroyed")
	return ..()

/obj/effect/alien/weeds/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()

	if(!isnull(node))
		if(!istype(node))
			CRASH("Weed craeted with non-weed node. Type: [node.type]")
		parent_node = node

	update_sprite()
	update_neighbours()

/obj/effect/alien/weeds/Destroy()
	for(var/mob/living/L in range(1, src))
		SEND_SIGNAL(L, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED)
	SEND_SIGNAL(loc, COMSIG_TURF_WEED_REMOVED)
	var/oldloc = loc
	parent_node = null
	. = ..()
	update_neighbours(oldloc)

/obj/effect/alien/weeds/examine(mob/user)
	..()
	var/turf/T = get_turf(src)
	if(isfloorturf(T))
		T.ceiling_desc(user)

/obj/effect/alien/weeds/Crossed(atom/movable/AM)
	. = ..()
	if(isxeno(AM))
		var/mob/living/carbon/xenomorph/X = AM
		X.next_move_slowdown += X.xeno_caste.weeds_speed_mod

/obj/effect/alien/weeds/proc/update_neighbours(turf/U)
	if(!U)
		U = loc
	if(istype(U))
		for (var/dirn in GLOB.cardinals)
			var/turf/T = get_step(U, dirn)

			if (!istype(T))
				continue

			var/obj/effect/alien/weeds/W = locate() in T
			if(W)
				W.update_sprite()

/obj/effect/alien/weeds/proc/update_sprite()
	var/my_dir = 0
	for (var/check_dir in GLOB.cardinals)
		var/turf/check = get_step(src, check_dir)

		if (!istype(check))
			continue
		if(istype(check, /turf/closed/wall/resin))
			my_dir |= check_dir

		else if (locate(/obj/effect/alien/weeds) in check)
			my_dir |= check_dir

	if (my_dir == 15) //weeds in all four directions
		icon_state = "weed[rand(0,15)]"
	else if(my_dir == 0) //no weeds in any direction
		icon_state = "base"
	else
		icon_state = "weed_dir[my_dir]"


// =================
// weed wall
/obj/effect/alien/weeds/weedwall
	layer = RESIN_STRUCTURE_LAYER
	plane = GAME_PLANE
	icon_state = "weedwall"

/obj/effect/alien/weeds/weedwall/update_sprite()
	if(iswallturf(loc))
		var/turf/closed/wall/W = loc
		if(W.junctiontype)
			icon_state = "weedwall[W.junctiontype]"


// =================
// windowed weed wall
/obj/effect/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/window/update_sprite()
	var/obj/structure/window/framed/F = locate() in loc
	if(F && F.junction)
		icon_state = "weedwall[F.junction]"

/obj/effect/alien/weeds/weedwall/window/MouseDrop_T(atom/dropping, mob/user)
	var/obj/structure/window/framed/F = locate() in loc
	if(!F)
		return ..()
	return F.MouseDrop_T(dropping, user)

/obj/effect/alien/weeds/weedwall/frame
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/frame/update_sprite()
	var/obj/structure/window_frame/WF = locate() in loc
	if(WF && WF.junction)
		icon_state = "weedframe[WF.junction]"

/obj/effect/alien/weeds/weedwall/frame/MouseDrop_T(atom/dropping, mob/user)
	var/obj/structure/window_frame/WF = locate() in loc
	if(!WF)
		return ..()
	return WF.MouseDrop_T(dropping, user)


// =================
// weed node - grows other weeds
/obj/effect/alien/weeds/node
	name = "purple sac"
	desc = "A weird, pulsating node."
	icon_state = "weednode"
	max_integrity = 60
	var/node_icon = "weednode"
	var/node_range = NODERANGE
	var/node_turfs = list() // list of all potential turfs that we can expand to

/obj/effect/alien/weeds/node/Destroy()
	SSweeds_decay.decay_weeds(node_turfs)
	return ..()


/obj/effect/alien/weeds/node/update_icon()
	overlays.Cut()
	overlays += node_icon

/obj/effect/alien/weeds/node/Initialize(mapload, obj/effect/alien/weeds/node/node)
	for(var/obj/effect/alien/weeds/W in loc)
		if(W != src)
			qdel(W) //replaces the previous weed
			break
	. = ..()

	update_icon()

	// Generate our full graph before adding to SSweeds
	node_turfs = filled_turfs(src, node_range, "square")
	SSweeds.add_node(src)


// =================
// stronger weed node
/obj/effect/alien/weeds/node/strong
	name = "strong purple sac"
	desc = "A weird, pulsating node. This looks pretty tough."
	node_range = NODERANGE*2
	max_integrity = 120

#undef NODERANGE
