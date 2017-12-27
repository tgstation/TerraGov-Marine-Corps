/*
 * Platforms
 */
/obj/structure/platform
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform"
	climbable = TRUE
	anchored = TRUE
	density = 1
	throwpass = TRUE //You can throw objects over this, despite its density.
	layer = 3
	climb_delay = 20 //Leaping a barricade is universally much faster than clumsily climbing on a table or rack
	breakable = FALSE
	flags_atom = ON_BORDER
	unacidable = TRUE

/obj/structure/platform/New()
	if (dir == 2)
		layer = 5
	.. ()

/obj/structure/platform/CheckExit(atom/movable/O, turf/target)
	if(O && O.throwing)
		return 1

	if(((flags_atom & ON_BORDER) && get_dir(loc, target) == dir))
		return 0
	else
		return 1

/obj/structure/platform/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(air_group || (height == 0)) return 1 //Barricades are never air-proof

	if(mover && mover.throwing)
		return 1

	var/obj/structure/S = locate(/obj/structure) in get_turf(mover)
	if(S && S.climbable && !(S.flags_atom & ON_BORDER) && climbable && isliving(mover)) //Climbable objects allow you to universally climb over others
		return 1

	if(!(flags_atom & ON_BORDER) || get_dir(loc, target) == dir)
		return 0
	else
		return 1

obj/structure/platform_decoration
	name = "platform"
	desc = "A square metal surface resting on four legs."
	icon = 'icons/obj/structures/platforms.dmi'
	icon_state = "platform_deco"
	anchored = TRUE
	density = 0
	throwpass = TRUE
	layer = 3.5
	breakable = FALSE
	flags_atom = ON_BORDER
	unacidable = TRUE

/obj/structure/platform_decoration/New()
	if (dir == 1)
		layer = 5.5
	else if (dir == 2)
		layer = 5.5
	else if (dir == 10)
		layer = 5.5
	else if (dir == 6)
		layer = 5.5
	.. ()