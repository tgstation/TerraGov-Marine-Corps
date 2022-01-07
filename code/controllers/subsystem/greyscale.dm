SUBSYSTEM_DEF(greyscale)
	name = "Greyscale"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_GREYSCALE

	var/list/datum/greyscale_config/configurations = list()
	var/list/datum/greyscale_layer/layer_types = list()

/datum/controller/subsystem/greyscale/Initialize(start_timeofday)
	for(var/datum/greyscale_layer/fake_type as anything in subtypesof(/datum/greyscale_layer))
		layer_types[initial(fake_type.layer_type)] = fake_type

	for(var/greyscale_type in subtypesof(/datum/greyscale_config))
		var/datum/greyscale_config/config = new greyscale_type()
		configurations["[greyscale_type]"] = config

	for(var/obj/item/armor_module/armor/armor_type AS in subtypesof(/obj/item/armor_module/armor))
		if(!initial(armor_type.greyscale_config))
			continue
		var/obj/item/armor_module/armor/armor = new armor_type()
		for(var/key in armor.colorable_colors)
			GetColoredIconByType(armor.greyscale_config, armor.colorable_colors[key])
		qdel(armor)

	for(var/obj/item/clothing/head/modular/helmet_type AS in subtypesof(/obj/item/clothing/head/modular))
		if(!initial(helmet_type.greyscale_config))
			continue
		var/obj/item/clothing/head/modular/helmet = new helmet_type()
		for(var/key in helmet.colorable_colors)
			GetColoredIconByType(helmet.greyscale_config, helmet.colorable_colors[key])
		qdel(helmet)

	return ..()

/datum/controller/subsystem/greyscale/proc/RefreshConfigsFromFile()
	for(var/i in configurations)
		configurations[i].Refresh(TRUE)

/datum/controller/subsystem/greyscale/proc/GetColoredIconByType(type, list/colors)
	type = "[type]"
	if(istype(colors)) // It's the color list format
		colors = colors.Join()
	return configurations[type].Generate(colors)
