SUBSYSTEM_DEF(minimap)
	name = "Minimap"
	wait = 0.3 SECONDS
	flags = SS_BACKGROUND
	init_order = INIT_ORDER_MINIMAP
	priority  = FIRE_PRIORITY_MINIMAP

	var/list/currentrun = list()
	var/list/datum/game_map/minimaps = list()

/datum/controller/subsystem/minimap/Initialize(start_timeofday)
	for(var/datum/space_level/SL AS in SSmapping.z_list)
		if(SL.traits[ZTRAIT_GROUND])
			minimaps += new /datum/game_map(SL)

	to_chat(world, span_notice("Generating minimaps.."))
	for(var/datum/game_map/GM as anything in minimaps)
		var/F = file("[MINIMAP_FILE_DIR][GM.name].dmi")
		if(fexists(F))
			GM.set_generated_map(F)
		else
			GM.generate_map()
	to_chat(world, span_notice("Generated minimaps."))
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
