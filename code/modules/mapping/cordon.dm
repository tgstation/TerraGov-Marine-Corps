/// Turf type that appears to be a world border, completely impassable and non-interactable to all physical (alive) entities.
/turf/cordon
	name = "cordon"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cordon"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	resistance_flags = RESIST_ALL
	opacity = TRUE
	density = TRUE
	baseturfs = /turf/cordon

/turf/cordon/ScrapeAway(amount, flags)
	return src // :devilcat:

/turf/cordon/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return FALSE

/turf/cordon/Bumped(atom/movable/bumped_atom)
	. = ..()

	if(HAS_TRAIT(bumped_atom, TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT)) //we could feasibly reach the border, so just don't
		dump_in_space(bumped_atom)

/// Area used in conjunction with the cordon turf to create a fully functioning world border.
/area/misc/cordon
	name = "CORDON"
	icon_state = "cordon"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = CANNOT_NUKE|DISALLOW_WEEDING
	requires_power = FALSE

/area/misc/cordon/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	for(var/mob/living/enterer as anything in arrived.get_all_contents_type(/mob/living))
		to_chat(enterer, span_userdanger("This was a bad idea..."))
		enterer.dust(TRUE, FALSE, TRUE)

/// This type of cordon will block ghosts from passing through it. Useful for stuff like Away Missions, where you feasibly want to block ghosts from entering to keep a certain map section a secret.
/turf/cordon/secret
	name = "secret cordon (ghost blocking)"

/turf/cordon/secret/attack_ghost(mob/dead/observer/user)
	return FALSE
