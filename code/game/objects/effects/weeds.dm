//Color variant defines
#define SPEED_COLOR ""
#define RESTING_COLOR "white"
#define STICKY_COLOR "green"

//Stat defines
#define RESTING_BUFF 1.2
#define WEED_SLOWDOWN 2

// base weed type
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
	///The color variant of the sprite
	var/color_variant = SPEED_COLOR
	///The healing buff when resting on this weed
	var/resting_buff = 1
	///If these weeds are not destroyed but just swapped
	var/swapped = FALSE

/obj/effect/alien/weeds/deconstruct(disassembled = TRUE)
	GLOB.round_statistics.weeds_destroyed++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "weeds_destroyed")
	return ..()

/obj/effect/alien/weeds/Initialize(mapload, obj/effect/alien/weeds/node/node, swapped = FALSE)
	. = ..()

	if(!isnull(node))
		if(!istype(node))
			CRASH("Weed created with non-weed node. Type: [node.type]")
		parent_node = node
	update_icon()
	if(!swapped)
		update_neighbours()

/obj/effect/alien/weeds/Destroy()
	parent_node = null
	if(swapped)
		return ..()
	for(var/mob/living/L in range(1, src))
		SEND_SIGNAL(L, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED)
	SEND_SIGNAL(loc, COMSIG_TURF_WEED_REMOVED)
	INVOKE_NEXT_TICK(src, .proc/update_neighbours, loc)
	return ..()

/obj/effect/alien/weeds/examine(mob/user)
	..()
	var/turf/T = get_turf(src)
	if(isfloorturf(T))
		T.ceiling_desc(user)

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
				W.update_icon()

/obj/effect/alien/weeds/update_icon_state()
	. = ..()
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
	icon_state += color_variant

/obj/effect/alien/weeds/speed
	name = "speed weeds"
	desc = "A layer of oozy slime, it feels slick, but not as slick for you to slip."

/obj/effect/alien/weeds/speed/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	AddElement(/datum/element/accelerate_on_crossed)

/obj/effect/alien/weeds/sticky
	name = "sticky weeds"
	desc = "A layer of disgusting sticky slime, it feels like it's going to slow your movement down."
	color_variant = STICKY_COLOR

/obj/effect/alien/weeds/sticky/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	AddElement(/datum/element/slowing_on_crossed, WEED_SLOWDOWN)

/obj/effect/alien/weeds/resting
	name = "resting weeds"
	desc = "This looks almost comfortable."
	color_variant = RESTING_COLOR
	resting_buff = RESTING_BUFF

// =================
// weed wall
/obj/effect/alien/weeds/weedwall
	layer = RESIN_STRUCTURE_LAYER
	plane = GAME_PLANE
	icon_state = "weedwall"

/obj/effect/alien/weeds/weedwall/update_icon_state()
	var/turf/closed/wall/W = loc
	icon_state = W.junctiontype ? "weedwall[W.junctiontype]" : initial(icon_state)
	icon_state += color_variant

// =================
// windowed weed wall
/obj/effect/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/window/update_icon_state()
	var/obj/structure/window/framed/F = locate() in loc
	icon_state = F?.junction ? "weedwall[F.junction]" : initial(icon_state)
	icon_state += color_variant

/obj/effect/alien/weeds/weedwall/window/MouseDrop_T(atom/dropping, mob/user)
	var/obj/structure/window/framed/F = locate() in loc
	if(!F)
		return ..()
	return F.MouseDrop_T(dropping, user)

/obj/effect/alien/weeds/weedwall/frame
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/frame/update_icon_state()
	var/obj/structure/window_frame/WF = locate() in loc
	icon_state = WF?.junction ? "weedframe[WF.junction]" : initial(icon_state)
	icon_state += color_variant

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
	max_integrity = 60
	var/node_icon = "weednode"
	/// list of all potential turfs that we can expand to
	var/node_turfs = list()
	/// How far this node can spread weeds
	var/node_range = 2
	/// What type of weeds this node spreads
	var/obj/effect/alien/weeds/weed_type

/obj/effect/alien/weeds/node/Initialize(mapload, obj/effect/alien/weeds/node/node)
	var/swapped = FALSE
	for(var/obj/effect/alien/weeds/W in loc)
		W.swapped = TRUE
		swapped = TRUE
		if(W != src)
			qdel(W) //replaces the previous weed
			break
	. = ..(mapload, node, swapped)

	update_icon()

	// Generate our full graph before adding to SSweeds
	node_turfs = filled_turfs(src, node_range, "square")
	SSweeds.add_node(src)

/obj/effect/alien/weeds/node/Destroy()
	. = ..()
	if(!swapped)
		SSweeds_decay.decay_weeds(src)

/obj/effect/alien/weeds/node/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()
	if(X.status_flags & INCORPOREAL)
		return FALSE
	if(!do_after(X, 1 SECONDS, FALSE, src, BUSY_ICON_BUILD))
		return
	X.visible_message("<span class='danger'>\The [X] removed \the [src]!</span>", \
		"<span class='danger'>We remove \the [src]!</span>", null, 5)
	log_game("[X] has removed [src] at [AREACOORD(src)]")
	take_damage(max_integrity)
	return TRUE


/obj/effect/alien/weeds/node/update_overlays()
	. = ..()
	overlays.Cut()
	overlays += node_icon

//Speed weed node
/obj/effect/alien/weeds/node/speed
	name = "speed weed sac"
	desc = "A weird, pulsating purple node."
	weed_type = /obj/effect/alien/weeds/speed

/obj/effect/alien/weeds/node/speed/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	AddElement(/datum/element/accelerate_on_crossed)

//Sticky weed node
/obj/effect/alien/weeds/node/sticky
	name = "sticky weed sac"
	desc = "A weird, pulsating red node."
	weed_type = /obj/effect/alien/weeds/sticky
	color_variant = STICKY_COLOR
	node_icon = "weednodegreen"

/obj/effect/alien/weeds/node/sticky/Initialize(mapload, obj/effect/alien/weeds/node/node)
	. = ..()
	AddElement(/datum/element/slowing_on_crossed, WEED_SLOWDOWN)

//Resting weed node
/obj/effect/alien/weeds/node/resting
	name = "resting weed sac"
	desc = "A weird, pulsating white node."
	weed_type = /obj/effect/alien/weeds/resting
	color_variant = RESTING_COLOR
	node_icon = "weednodewhite"
	resting_buff = RESTING_BUFF

/datum/element/slowing_on_crossed
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///How much it slow down on crossed
	var/slow_amount = 0

/datum/element/slowing_on_crossed/Attach(datum/target, slow_amount)
	. = ..()
	src.slow_amount = slow_amount
	RegisterSignal(target, COMSIG_MOVABLE_CROSSED_BY, .proc/slow_down_crosser)

///Slows down human on cross
/datum/element/slowing_on_crossed/proc/slow_down_crosser(datum/source, atom/movable/crosser)
	if(!ishuman(crosser))
		return

	if(CHECK_MULTIPLE_BITFIELDS(crosser.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += slow_amount

/datum/element/accelerate_on_crossed/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_CROSSED_BY, .proc/accelerate_crosser)

///Speeds up xeno on crossed
/datum/element/accelerate_on_crossed/proc/accelerate_crosser(datum/source, atom/movable/crosser)
	if(isxeno(crosser))
		var/mob/living/carbon/xenomorph/X = crosser
		X.next_move_slowdown += X.xeno_caste.weeds_speed_mod
