/**
 * Allow to representate a hat
 * This is only able to representate items of type /obj/item/clothing/head
 */
/datum/item_representation/hat
	///The attachments installed.
	var/list/datum/item_representation/armor_module/attachments = list()

/datum/item_representation/hat/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ishat(item_to_copy))
		CRASH("/datum/item_representation/hat created from an item that is not an hat")
	..()
	var/obj/item/clothing/head/helmet_to_copy = item_to_copy
	/*
	// bit of a jank solution but it works
	// this essentially checks if the helmet is a subtype that exists only to have predefined attachments
	// as a base helmet can have starting_attachments (think visors and item storage)
	// comparing the name should be generally a safe solution
	*/
	var/obj/item/clothing/head/parent = new helmet_to_copy.parent_type
	if(helmet_to_copy.starting_attachments && helmet_to_copy.name == parent.name)
		item_type = helmet_to_copy.parent_type
	qdel(parent)
	for(var/key in helmet_to_copy.attachments_by_slot)
		if(!isitem(helmet_to_copy.attachments_by_slot[key]))
			continue
		if(istype(helmet_to_copy.attachments_by_slot[key], /obj/item/armor_module/storage))
			attachments += new /datum/item_representation/armor_module/storage(helmet_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/armor_module(helmet_to_copy.attachments_by_slot[key])

/datum/item_representation/hat/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/head/new_hat = .
	for(var/datum/item_representation/armor_module/armor_attachement AS in attachments)
		armor_attachement.install_on_armor(seller, new_hat, user)
	new_hat.update_icon()

/datum/item_representation/hat/get_tgui_data()
	var/list/tgui_data = list()
	tgui_data["name"] = initial(item_type.name)
	tgui_data["icons"] = list()
	var/icon/icon_to_convert
	var/icon_state = initial(item_type.icon_state) + (variant ? "_[GLOB.loadout_variant_keys[variant]]" : "")
	if(initial(item_type.greyscale_config))
		icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(item_type.greyscale_config), colors), icon_state,  dir = SOUTH)
	else
		icon_to_convert = icon(initial(item_type.icon), icon_state, SOUTH)
	tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = NO_OFFSET,
				"translateY" = "40%",
				"scale" = 1.4,
				))
	for(var/datum/item_representation/armor_module/module AS in attachments)
		if(!initial(module.item_type.icon_state))
			continue
		var/second_icon_state = initial(module.item_type.icon_state) + (module.variant ? "_[GLOB.loadout_variant_keys[module.variant]]" : "")
		if(initial(module.item_type.greyscale_config))
			icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(module.item_type.greyscale_config), module.colors),  second_icon_state, dir = SOUTH)
		else
			icon_to_convert = icon(initial(module.item_type.icon), second_icon_state, SOUTH)

		var/translatex = NO_OFFSET
		var/translatey = "40%"
		var/scale = 1.4
		if(ispath(module.item_type, /obj/item/armor_module/module))
			translatex = "40%"
			translatey = "35%"
			scale = 0.5

		tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = translatex,
				"translateY" = translatey,
				"scale" = scale,
				))

	return tgui_data



/////////////////////////////////////

/**
 * Allow to representate a modular helmet, and to color it
 * This is only able to representate items of type /obj/item/clothing/head/modular
 */
/datum/item_representation/hat/modular_helmet
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant

/datum/item_representation/hat/modular_helmet/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodularhelmet(item_to_copy))
		CRASH("/datum/item_representation/hat/modular_helmet created from an item that is not an modular helmet")
	..()
	if(colors)
		return
	var/obj/item/clothing/head/modular/helmet_to_copy = item_to_copy
	current_variant = helmet_to_copy.current_variant

/datum/item_representation/hat/modular_helmet/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/head/modular/modular_helmet = .
	modular_helmet.current_variant = (current_variant in modular_helmet.icon_state_variants) ? current_variant : initial(modular_helmet.current_variant)
	if(colors)
		modular_helmet.set_greyscale_colors(colors)
	modular_helmet.update_icon()

/datum/item_representation/hat/modular_helmet/get_tgui_data()
	var/list/tgui_data = list()
	tgui_data["name"] = initial(item_type.name)
	tgui_data["icons"] = list()
	var/icon/icon_to_convert
	var/icon_state = initial(item_type.icon_state) + (variant ? "_[GLOB.loadout_variant_keys[variant]]" : "")
	if(initial(item_type.greyscale_config))
		icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(item_type.greyscale_config), colors), icon_state,  dir = SOUTH)
	else
		icon_to_convert = icon(initial(item_type.icon), icon_state, SOUTH)
	tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = NO_OFFSET,
				"translateY" = "40%",
				"scale" = 1.4,
				))
	for(var/datum/item_representation/armor_module/module AS in attachments)
		if(!initial(module.item_type.icon_state))
			continue
		var/second_icon_state = initial(module.item_type.icon_state) + (module.variant ? "_[GLOB.loadout_variant_keys[module.variant]]" : "")
		if(initial(module.item_type.greyscale_config))
			icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(module.item_type.greyscale_config), module.colors),  second_icon_state, dir = SOUTH)
		else
			icon_to_convert = icon(initial(module.item_type.icon), second_icon_state, SOUTH)

		var/translatex = NO_OFFSET
		var/translatey = "40%"
		var/scale = 1.4
		if(ispath(module.item_type, /obj/item/armor_module/module))
			translatex = "40%"
			translatey = "35%"
			scale = 0.5

		tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = translatex,
				"translateY" = translatey,
				"scale" = scale,
				))
	return tgui_data
