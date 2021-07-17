//Color variant defines
#define SPEED_COLOR ""
#define HEALING_COLOR "green"
#define TOXIN_COLOR "green"
#define STICKY_COLOR "green"

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
	var/obj/effect/alien/weeds/node/parent_node
	///The color variant of the sprite
	var/color_variant = ""

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
		color_variant = node.color_variant
	update_icon()
	update_neighbours()

/obj/effect/alien/weeds/Destroy()
	for(var/mob/living/L in range(1, src))
		SEND_SIGNAL(L, COMSIG_LIVING_WEEDS_ADJACENT_REMOVED)
	for(var/obj/effect/alien/A in loc.contents)
		if(QDELETED(A) || A == src || A.ignore_weed_destruction)
			continue
		A.obj_destruction(damage_flag = "melee")

	var/oldloc = loc
	parent_node = null
	. = ..()
	update_neighbours(oldloc)

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

/obj/effect/alien/weeds/speedy/Crossed(atom/movable/AM)
	. = ..()
	if(isxeno(AM))
		var/mob/living/carbon/xenomorph/X = AM
		X.next_move_slowdown += X.xeno_caste.weeds_speed_mod

/obj/effect/alien/weeds/sticky
	name = "sticky resin"
	desc = "A layer of disgusting sticky slime."
	color_variant = STICKY_COLOR

/obj/effect/alien/weeds/sticky/Crossed(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return

	if(CHECK_MULTIPLE_BITFIELDS(AM.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/H = AM

	if(H.lying_angle)
		return

	H.next_move_slowdown += 1.5

/obj/effect/alien/weeds/healing
	name = "healing weed"
	desc = "This looks almost confortable."
	color_variant = HEALING_COLOR

/obj/effect/alien/weeds/toxin
	name = "toxin weed"
	desc = "This reeks of disease."
	color_variant = TOXIN_COLOR

/obj/effect/alien/weeds/toxins/Crossed(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return

	if(CHECK_MULTIPLE_BITFIELDS(AM.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/H = AM

	if(H.lying_angle)
		return

	H.apply_damage(3, TOX)

// =================
// weed wall
/obj/effect/alien/weeds/weedwall
	layer = RESIN_STRUCTURE_LAYER
	plane = GAME_PLANE
	icon_state = "weedwall"

/obj/effect/alien/weeds/weedwall/update_icon()
	if(iswallturf(loc))
		var/turf/closed/wall/W = loc
		if(W.junctiontype)
			icon_state = "weedwall[W.junctiontype]"


// =================
// windowed weed wall
/obj/effect/alien/weeds/weedwall/window
	layer = ABOVE_TABLE_LAYER

/obj/effect/alien/weeds/weedwall/window/update_icon()
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

/obj/effect/alien/weeds/weedwall/frame/update_icon()
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
	max_integrity = 60
	ignore_weed_destruction = TRUE
	var/node_icon = "weednode"
	var/node_turfs = list() // list of all potential turfs that we can expand to
	/// What type of weeds this node spreads
	var/weed_type = /obj/effect/alien/weeds/speedy

/obj/effect/alien/weeds/node/Destroy()
	. = ..()
	SSweeds_decay.decay_weeds(node_turfs)

/obj/effect/alien/weeds/node/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(X.status_flags & INCORPOREAL)
		return FALSE
	if(!do_after(X, 1 SECONDS, FALSE, src, BUSY_ICON_BUILD))
		return
	X.visible_message("<span class='danger'>\The [X] removed \the [src]!</span>", \
		"<span class='danger'>We remove \the [src]!</span>", null, 5)
	take_damage(max_integrity)
	return TRUE


/obj/effect/alien/weeds/node/update_icon()
	. = ..()
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
	node_turfs = filled_turfs(src, 2, "square")
	SSweeds.add_node(src)


//Sticky weed node
/obj/effect/alien/weeds/node/sticky
	name = "sticky weed sac"
	desc = "A weird, pulsating red node."
	weed_type = /obj/effect/alien/weeds/sticky
	color_variant = STICKY_COLOR
	node_icon = "weednodegreen"

//Speedy weed node
/obj/effect/alien/weeds/node/speedy
	name = "speed weed sac"
	desc = "A weird, pulsating purple node."

//Healing weed node
/obj/effect/alien/weeds/node/healing
	name = "heal weed sac"
	desc = "A weird, pulsating blue node."
	weed_type = /obj/effect/alien/weeds/healing
	color_variant = HEALING_COLOR
	node_icon = "weednodeblue"

//Toxin weed node
/obj/effect/alien/weeds/node/toxin
	name = "toxin weed sac"
	desc = "A weird, pulsating green node."
	weed_type = /obj/effect/alien/weeds/toxin
	color_variant = TOXIN_COLOR
	node_icon = "weednodegreen"
