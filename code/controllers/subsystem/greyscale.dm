SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_GREYSCALE

	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()

/datum/controller/subsystem/greyscale/Initialize()
	for(var/datum/greyscale_layer/fake_type AS in subtypesof(/datum/greyscale_layer))
		layer_types[initial(fake_type.layer_type)] = fake_type

	for(var/greyscale_type in subtypesof(/datum/greyscale_config))
		var/datum/greyscale_config/config = new greyscale_type()
		configurations["[greyscale_type]"] = config

	return SS_INIT_SUCCESS

///Proc built to handle cacheing the nested lists of armor colors found in code/modules/clothing/modular_armor
/datum/controller/subsystem/greyscale/proc/cache_list(list/colors, config)
	for(var/key in colors)
		if(islist(colors[key]))
			cache_list(colors[key], config)
			continue
		GetColoredIconByType(config, colors[key])

/datum/controller/subsystem/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/greyscale/proc/GetColoredIconByType(type, list/colors)
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	return configurations[type].Generate(colors)
