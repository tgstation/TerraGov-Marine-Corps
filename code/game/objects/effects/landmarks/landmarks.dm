/obj/effect/landmark
	name = "landmark"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x2"
	anchored = TRUE
	resistance_flags = UNACIDABLE
	layer = MID_LANDMARK_LAYER
	invisibility = INVISIBILITY_ABSTRACT


/obj/effect/landmark/Initialize()
	. = ..()
	GLOB.landmarks_list += src


/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()


/obj/effect/landmark/proc/after_round_start()
	return


/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/landmarks.dmi'
	icon_state = "x"
	anchored = TRUE
	layer = MOB_LAYER
	var/jobspawn_override = FALSE
	var/delete_after_roundstart = TRUE
	var/used = FALSE


/obj/effect/landmark/start/Initialize()
	GLOB.start_landmarks_list += src
	if(jobspawn_override)
		if(!GLOB.jobspawn_overrides[name])
			GLOB.jobspawn_overrides[name] = list()
		GLOB.jobspawn_overrides[name] += src
	. = ..()
	if(name != "start")
		tag = "start*[name]"


/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	if(jobspawn_override)
		GLOB.jobspawn_overrides[name] -= src
	return ..()


/obj/effect/landmark/start/after_round_start()
	if(delete_after_roundstart)
		qdel(src)


/obj/effect/landmark/newplayer_start/New()
	GLOB.newplayer_start += loc
	return

/obj/effect/landmark/start/latejoin/Initialize()
	. = ..()
	GLOB.latejoin += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin_gateway/Initialize()
	. = ..()
	GLOB.latejoin_gateway += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin_cryo/Initialize()
	. = ..()
	GLOB.latejoin_cryo += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/supply_elevator/New()
	GLOB.supply_elevator = loc
	return

/obj/effect/landmark/thunderdome/one
	icon_state = "tdome_t1"

/obj/effect/landmark/thunderdome/one/Initialize()
	. = ..()
	GLOB.tdome1 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two
	icon_state = "tdome_t2"

/obj/effect/landmark/thunderdome/two/Initialize()
	. = ..()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/observe
	icon_state = "tdome_observer"

/obj/effect/landmark/thunderdome/observe/Initialize()
	. = ..()
	return INITIALIZE_HINT_QDEL // unused

/obj/effect/landmark/thunderdome/admin
	icon_state = "tdome_admin"

/obj/effect/landmark/thunderdome/admin/Initialize()
	. = ..()
	return INITIALIZE_HINT_QDEL // unused

/obj/effect/landmark/deathmatch/Initialize()
	. = ..()
	GLOB.deathmatch += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/xeno_spawn
	icon_state = "xeno_spawn"

/obj/effect/landmark/start/xeno_spawn/Initialize()
	. = ..()
	GLOB.xeno_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/surv_spawn/Initialize()
	. = ..()
	GLOB.surv_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/monkey_spawn
	icon_state = "monkey_spawn"

/obj/effect/landmark/monkey_spawn/Initialize() // unused but i won't remove the landmarks for these yet
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress/Initialize()
	. = ..()
	if(!GLOB.distress_spawns_by_name["Distress"])
		GLOB.distress_spawns_by_name["Distress"] = list()
	GLOB.distress_spawns_by_name["Distress"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_item/Initialize()
	. = ..()
	if(!GLOB.distress_spawns_by_name["DistressItem"])
		GLOB.distress_spawns_by_name["DistressItem"] = list()
	GLOB.distress_spawns_by_name["DistressItem"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_pmc/Initialize()
	. = ..()
	if(!GLOB.distress_spawns_by_name["Distress_PMC"])
		GLOB.distress_spawns_by_name["Distress_PMC"] = list()
	GLOB.distress_spawns_by_name["Distress_PMC"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_pmcitem/Initialize()
	. = ..()
	if(!GLOB.distress_spawns_by_name["Distress_PMCItem"])
		GLOB.distress_spawns_by_name["Distress_PMCItem"] = list()
	GLOB.distress_spawns_by_name["Distress_PMCItem"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_upp/Initialize()
	. = ..()
	if(!GLOB.distress_spawns_by_name["Distress_UPP"])
		GLOB.distress_spawns_by_name["Distress_UPP"] = list()
	GLOB.distress_spawns_by_name["Distress_UPP"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_uppitem/Initialize()
	. = ..()
	if(!GLOB.distress_spawns_by_name["Distress_UPPItem"])
		GLOB.distress_spawns_by_name["Distress_UPPItem"] = list()
	GLOB.distress_spawns_by_name["Distress_UPPItem"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/prisonwarp
	icon_state = "prisonwarp"

/obj/effect/landmark/prisonwarp/Initialize()
	. = ..()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL
