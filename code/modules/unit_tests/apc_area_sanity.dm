/datum/unit_test/area_apc_sanity

/datum/unit_test/area_apc_sanity/Run()
	for(var/area/tested_area in world)
		var/list/cached_apc_list = tested_area.get_apc()
		if(tested_area.requires_power && !tested_area.always_unpowered)
			TEST_ASSERT(length(cached_apc_list), "[tested_area.type] doesn't have an APC while it needs one.")
		if(!tested_area.requires_power || tested_area.always_unpowered)
			TEST_ASSERT(!length(cached_apc_list), "[tested_area] has APC(s) while not needing power.")
			for(var/obj/machinery/power/apc/found_apc in cached_apc_list)
				log_test("Unneded APC at [found_apc.x], [found_apc.y], [found_apc.z]")
		TEST_ASSERT(!(length(cached_apc_list) > 1), "[tested_area] has multiple APCs.")
		for(var/obj/machinery/power/apc/found_apc in cached_apc_list)
			log_test("Duplicate APC at [found_apc.x], [found_apc.y], [found_apc.z]")
