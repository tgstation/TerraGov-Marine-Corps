/**
 * Allow to representate a modular helmet, and to color it
 * This is only able to representate items of type /obj/item/clothing/head/modular
 */
/datum/item_representation/modular_helmet
	///The attachments installed.
	var/list/datum/item_representation/armor_module/attachments = list()
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant

/datum/item_representation/modular_helmet/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodularhelmet(item_to_copy))
		CRASH("/datum/item_representation/modular_helmet created from an item that is not an modular helmet")
	..()
	var/obj/item/clothing/head/modular/helmet_to_copy = item_to_copy
	current_variant = helmet_to_copy.current_variant
	for(var/key in helmet_to_copy.attachments_by_slot)
		if(istype(helmet_to_copy.attachments_by_slot[key], /obj/item/armor_module/armor))
			attachments += new /datum/item_representation/armor_module/colored(helmet_to_copy.attachments_by_slot[key])
			continue
		if(istype(helmet_to_copy.attachments_by_slot[key], /obj/item/armor_module/storage))
			attachments += new /datum/item_representation/armor_module/storage(helmet_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/armor_module(helmet_to_copy.attachments_by_slot[key])

/datum/item_representation/modular_helmet/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/head/modular/modular_helmet = .
	modular_helmet.current_variant = (current_variant in modular_helmet.icon_state_variants) ? current_variant : initial(modular_helmet.current_variant)
	for(var/datum/item_representation/armor_module/armor_attachement AS in attachments)
		armor_attachement.install_on_armor(seller, modular_helmet, user)
	modular_helmet.update_icon()

/datum/item_representation/modular_helmet/get_tgui_data()
	var/list/tgui_data = list()
	tgui_data["name"] = initial(item_type.name)
	tgui_data["icons"] = list()
	var/icon/icon_to_convert
	if(greyscale_colors)
		icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(item_type.greyscale_config), greyscale_colors), dir = SOUTH)
	else
		icon_to_convert = icon(initial(item_type.icon), current_variant ? initial(item_type.icon_state) + "_[current_variant]" : initial(item_type.icon_state), SOUTH)
	tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = NO_OFFSET,
				"translateY" = "40%",
				"scale" = 1.4,
				))
	for(var/datum/item_representation/armor_module/module AS in attachments)
		if(istype(module, /datum/item_representation/armor_module/colored))
			var/datum/item_representation/armor_module/colored/colored_module = module
			icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(colored_module.item_type.greyscale_config), colored_module.greyscale_colors), dir = SOUTH)
			tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = NO_OFFSET,
					"translateY" = "40%",
					"scale" = 1.4,
					))
			continue
		if(ispath(module.item_type, /obj/item/armor_module/module))
			icon_to_convert = icon(initial(module.item_type.icon), initial(module.item_type.icon_state), SOUTH)
			tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = "40%",
					"translateY" = "35%",
					"scale" = 0.5,
					))
			continue
		icon_to_convert = icon(initial(module.item_type.icon), initial(module.item_type.icon_state), SOUTH)
		tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = NO_OFFSET,
					"translateY" = "40%",
					"scale" = 1.4,
					))
	return tgui_data
