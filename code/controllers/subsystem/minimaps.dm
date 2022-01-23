SUBSYSTEM_DEF(minimap)
	name = "Minimap"
	wait = 0.3 SECONDS
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_MINIMAP
	priority  = FIRE_PRIORITY_MINIMAP

	var/list/currentrun = list()
	var/list/datum/game_map/minimaps = list()

/datum/controller/subsystem/minimap/Initialize(start_timeofday)
	var/datum/game_map/GM
	for(var/datum/space_level/SL AS in SSmapping.z_list)
		if(SL.traits[ZTRAIT_GROUND] || SL.traits[ZTRAIT_MARINE_MAIN_SHIP])
			GM = new /datum/game_map(SL)
			if(!CONFIG_GET(flag/disable_minimap))
				GM.generate_map()
			minimaps += GM

	return ..()


/datum/controller/subsystem/minimap/stat_entry(msg)
	msg = "P:[minimaps.len]"
	return ..()


/datum/controller/subsystem/minimap/fire(resumed = FALSE)
	if (!resumed)
		currentrun = minimaps.Copy()

	while (currentrun.len)
		var/datum/game_map/M = currentrun[currentrun.len]
		currentrun.len--

		if (!M || QDELETED(M))
			continue

		M.update_map()

		if (MC_TICK_CHECK)
			return
