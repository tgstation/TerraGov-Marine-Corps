/obj/effect/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	unacidable = 1

/obj/effect/landmark/Initialize()
	. = ..()
	tag = "landmark*[name]"
	invisibility = INVISIBILITY_MAXIMUM
	GLOB.landmarks_list += src

// this proc is called by the gamemode when it starts to enable round type
//   specific landmark behaviour to be defined at a landmark level instead of
//   at the round level.
// where possible replace this with a specific handler for that type
/obj/effect/landmark/proc/on_round_start(flags_round_type=NOFLAGS,flags_landmarks=NOFLAGS)
	return

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	return ..()

/obj/effect/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/effect/landmark/start/Initialize()
	. = ..()
	tag = "start*[name]"
	GLOB.start_landmarks_list += src

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	return ..()

/obj/effect/landmark/newplayer_start/New()
	GLOB.newplayer_start += loc
	return

/obj/effect/landmark/map_tag
#ifdef MAP_NAME
	name = MAP_NAME
#else
	name = "Mapping Tag"
#endif
/obj/effect/landmark/map_tag/Initialize()
	GLOB.map_tag = name
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin/Initialize()
	GLOB.latejoin += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin_gateway/Initialize()
	GLOB.latejoin_gateway += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/latejoin_cryo/Initialize()
	GLOB.latejoin_cryo += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/supply_elevator/New()
	GLOB.supply_elevator = loc
	return

/obj/effect/landmark/thunderdome/one/Initialize()
	GLOB.tdome1 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/two/Initialize()
	GLOB.tdome2 += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/thunderdome/observe/Initialize()
	return INITIALIZE_HINT_QDEL // unused

/obj/effect/landmark/thunderdome/admin/Initialize()
	return INITIALIZE_HINT_QDEL // unused

/obj/effect/landmark/deathmatch/Initialize()
	GLOB.deathmatch += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/xeno_spawn/Initialize()
	GLOB.xeno_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/surv_spawn/Initialize()
	GLOB.surv_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/pred_spawn/Initialize()
	GLOB.pred_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/pred_spawn/elder/Initialize()
	GLOB.pred_elder_spawn += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/pred_teleport_destination/Initialize()
	GLOB.yautja_teleport_loc += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/monkey_spawn/Initialize() // unused but i won't remove the landmarks for these yet
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress/Initialize()
	if(!GLOB.distress_spawns_by_name["Distress"])
		GLOB.distress_spawns_by_name["Distress"] = list()
	GLOB.distress_spawns_by_name["Distress"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_item/Initialize()
	if(!GLOB.distress_spawns_by_name["DistressItem"])
		GLOB.distress_spawns_by_name["DistressItem"] = list()
	GLOB.distress_spawns_by_name["DistressItem"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_pmc/Initialize()
	if(!GLOB.distress_spawns_by_name["Distress_PMC"])
		GLOB.distress_spawns_by_name["Distress_PMC"] = list()
	GLOB.distress_spawns_by_name["Distress_PMC"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_pmcitem/Initialize()
	if(!GLOB.distress_spawns_by_name["Distress_PMCItem"])
		GLOB.distress_spawns_by_name["Distress_PMCItem"] = list()
	GLOB.distress_spawns_by_name["Distress_PMCItem"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_upp/Initialize()
	if(!GLOB.distress_spawns_by_name["Distress_UPP"])
		GLOB.distress_spawns_by_name["Distress_UPP"] = list()
	GLOB.distress_spawns_by_name["Distress_UPP"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/distress_uppitem/Initialize()
	if(!GLOB.distress_spawns_by_name["Distress_UPPItem"])
		GLOB.distress_spawns_by_name["Distress_UPPItem"] = list()
	GLOB.distress_spawns_by_name["Distress_UPPItem"] += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/prisonwarp/Initialize()
	GLOB.prisonwarp += loc
	return INITIALIZE_HINT_QDEL
