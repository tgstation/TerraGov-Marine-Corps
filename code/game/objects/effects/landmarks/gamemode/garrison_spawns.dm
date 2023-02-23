
/obj/effect/landmark/xeno_base
	name = "xeno base spawn landmark"
	icon = 'icons/Xeno/resin_silo.dmi'
	icon_state = "xeno_base"

/obj/effect/landmark/xeno_base/Initialize()
	GLOB.xeno_base_silo_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/marine_base
	name = "marine base spawn landmark"
	icon_state = "frame_med"
	icon = 'icons/obj/machines/computer3.dmi'

/obj/effect/landmark/marine_base/Initialize()
	GLOB.marine_control_unit_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/xeno_base_turret
	name = "xeno base turret spawn landmark"
	icon = 'icons/Xeno/acidturret.dmi'
	icon_state = "acid_turret"

/obj/effect/landmark/xeno_base_turret/Initialize()
	GLOB.xeno_base_turret_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/marine_base_turret
	name = "marine base turret spawn landmark"
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "sentry_deployed"

/obj/effect/landmark/marine_base_turret/Initialize()
	GLOB.marine_base_turret_turfs += loc
	..()
	return INITIALIZE_HINT_QDEL
