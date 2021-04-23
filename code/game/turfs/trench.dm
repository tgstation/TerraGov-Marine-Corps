obj/structure/trench
	name = "Trench"
	desc = "A wide, narrow earthwork designed to protect the user from any projectiles"
	icon = 'icons/turf/trench.dmi'
	icon_state = "gold0"
	density = FALSE
	anchored = TRUE
	var/slowamt = 4
	tiles_with = list(
		/obj/structure/trench,
	)

turf/open/ground/trenchturf
	name = "Trench Floor"
	desc = "Thats a Trench Floor"


obj/structure/trench/Initialize()
	. = ..()
	new /turf/open/ground/trenchturf(src.loc)
	relativewall()
	relativewall_neighbours()

obj/structure/trench/Crossed(atom/movable/AM)

	var/mob/living/H = AM
	H.next_move_slowdown += slowamt
	ADD_TRAIT(H, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/Uncrossed(atom/movable/AM)
	REMOVE_TRAIT(AM, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)
