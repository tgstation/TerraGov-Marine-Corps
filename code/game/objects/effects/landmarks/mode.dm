/atom/movable/effect/landmark/lv624


/atom/movable/effect/landmark/lv624/fog_blocker
	name = "fog blocker"
	icon_state = "fog_spawn"


/atom/movable/effect/landmark/lv624/fog_blocker/Initialize()
	. = ..()
	store_location()
	flags_atom |= INITIALIZED
	return INITIALIZE_HINT_QDEL

/atom/movable/effect/landmark/lv624/fog_blocker/proc/store_location()
	GLOB.fog_blocker_locations += loc

/atom/movable/effect/landmark/lv624/fog_blocker/xeno_spawn
	name = "xeno spawn protection"

/atom/movable/effect/landmark/lv624/fog_blocker/xeno_spawn/store_location()
	GLOB.xeno_spawn_protection_locations += loc
