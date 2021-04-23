obj/structure/trench
	name = "Trench"
	desc = "A wide, narrow earthwork designed to protect soldiers from any projectiles, since WWI!"
	icon = 'icons/turf/trench.dmi'
	icon_state = "gold0"
	layer = TRENCH_LAYER
	density = FALSE
	anchored = TRUE
	tiles_with = list(
		/obj/structure/trench,
	)
	var/slowamt = 4

obj/structure/trench/Initialize()
	. = ..()
	relativewall()
	relativewall_neighbours()

obj/structure/trench/Crossed(atom/movable/AM)

	var/mob/living/H = AM
	H.next_move_slowdown += slowamt
	ADD_TRAIT(H, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/Uncrossed(atom/movable/AM)
	REMOVE_TRAIT(AM, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)
