obj/structure/trench
	name = "Trench"
	desc = "A wide, narrow earthwork designed to protect soldiers from any projectiles, since WWI!"
	icon = 'icons/turf/trenchicon.dmi'
	icon_state = "trench0"
	layer = TRENCH_LAYER
	generic_canpass = FALSE
	climbable = TRUE
	climb_delay = 20
	density = TRUE
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
	ADD_TRAIT(H, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/Uncrossed(atom/movable/AM)
	REMOVE_TRAIT(AM, TRAIT_ISINTRENCH, TRAIT_SOURCE_TRENCH)

obj/structure/trench/CanAllowThrough(atom/movable/mover, turf/target)
	if(HAS_TRAIT(mover, TRAIT_ISINTRENCH))
		return TRUE
	else
		return FALSE
