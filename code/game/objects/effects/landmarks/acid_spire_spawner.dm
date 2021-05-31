/**
 * Landmark for spawning acid nodes
 */
/obj/effect/landmark/acid_spire_spawner
	name = "acid spire landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "generic_event"
	var/obj/structure/xeno/resin/acid_spire/spawned_spire

/obj/effect/landmark/acid_spire_spawner/Initialize()
	. = ..()
	GLOB.acid_spire_landmarks_list += src

/obj/effect/landmark/acid_spire_spawner/proc/spawn_spire()
	spawned_spire = new(loc)
