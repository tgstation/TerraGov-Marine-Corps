/obj/structure/guardrail
	name = "guard rails"
	icon = 'icons/obj/doors/railing.dmi'
	icon_state = "railing1"
	flags_atom = ON_BORDER
	opacity = FALSE
	density = TRUE
	throwpass = FALSE
	layer = WINDOW_LAYER
	anchored = TRUE
	coverage = 25
	resistance_flags = UNACIDABLE
	max_integrity = 150
	soft_armor = list("melee" = 90, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 15, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)


/obj/structure/barricade/CheckExit(atom/movable/O, turf/target)
	if(closed)
		return TRUE

	if(O.throwing)
		if(is_wired && iscarbon(O)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE

	if(get_dir(loc, target) & dir)
		return FALSE
	else
		return TRUE

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target)
	if(closed)
		return TRUE

	if(mover && mover.throwing)
		if(is_wired && iscarbon(mover)) //Leaping mob against barbed wire fails
			if(get_dir(loc, target) & dir)
				return FALSE
		return TRUE