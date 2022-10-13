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
		cache_list(armor.colorable_colors, armor.greyscale_config)
		qdel(armor)

	for(var/obj/item/clothing/head/modular/helmet_type AS in subtypesof(/obj/item/clothing/head/modular))
		if(!initial(helmet_type.greyscale_config))
			continue
		var/obj/item/clothing/head/modular/helmet = new helmet_type()
		cache_list(helmet.colorable_colors, helmet.greyscale_config)
		qdel(helmet)

	for(var/obj/item/weapon/gun/gun_type AS in subtypesof(/obj/item/weapon/gun))
		if(!initial(gun_type.greyscale_config))
			continue
		var/obj/item/weapon/gun/gun = new gun_type()
		cache_list(gun.colorable_colors, gun.greyscale_config)
		for(var/key in gun.item_icons)
			if(!ispath(gun.item_icons[key], /datum/greyscale_config))
				continue
			cache_list(gun.colorable_colors, gun.item_icons[key])
		qdel(gun)

	for(var/obj/item/attachable/attachment_type AS in subtypesof(/obj/item/attachable))
		if(!initial(attachment_type.greyscale_config))
			continue
		var/obj/item/attachable/attachment = new attachment_type()
		cache_list(attachment.colorable_colors, attachment.greyscale_config)
		qdel(attachment)

	return ..()

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
