/// Initializes any assets that need to be loaded ASAP, before the atoms SS initializes.
SUBSYSTEM_DEF(early_assets)
	name = "Early Assets"
	dependents = list(
		/datum/controller/subsystem/mapping,
		/datum/controller/subsystem/atoms,
	)
	init_stage = INITSTAGE_EARLY
	flags = SS_NO_FIRE

/datum/controller/subsystem/early_assets/Initialize()
	for (var/datum/asset/asset_type as anything in subtypesof(/datum/asset))
		if (initial(asset_type._abstract) == asset_type)
			continue

		if (!initial(asset_type.early))
			continue

		if (!load_asset_datum(asset_type))
			stack_trace("Could not initialize early asset [asset_type]!")

		CHECK_TICK

	return SS_INIT_SUCCESS
