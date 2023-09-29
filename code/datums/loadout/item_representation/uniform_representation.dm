/**
 * Allow to representate an uniform and its tie (webbings and such)
 * This is only able to represent /obj/item/clothing/under
 */
/datum/item_representation/uniform_representation
	///List of attachments on the armor.
	var/list/datum/item_representation/armor_module/attachments = list()
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant



/datum/item_representation/uniform_representation/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isuniform(item_to_copy))
		CRASH("/datum/item_representation/uniform_representation created from an item that is not an uniform")
	..()
	var/obj/item/clothing/under/uniform_to_copy = item_to_copy
	current_variant = uniform_to_copy.current_variant
	for(var/key in uniform_to_copy.attachments_by_slot)
		if(!isitem(uniform_to_copy.attachments_by_slot[key]))
			continue
		if(istype(uniform_to_copy.attachments_by_slot[key], /obj/item/armor_module/storage))
			attachments += new /datum/item_representation/armor_module/storage(uniform_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/armor_module(uniform_to_copy.attachments_by_slot[key])

/datum/item_representation/uniform_representation/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/under/uniform = .
	for(var/datum/item_representation/armor_module/uniform_attachement AS in attachments)
		uniform_attachement.install_on_armor(seller, uniform, user)
	uniform.current_variant = (current_variant in uniform.adjustment_variants) ? current_variant : initial(uniform.current_variant)
	uniform.update_icon()
	user.regenerate_icons()

/datum/item_representation/uniform_representation/get_tgui_data()
	var/list/tgui_data = list()
	var/icon/icon_to_convert
	var/icon_state = initial(item_type.icon_state) + (variant ? "_[GLOB.loadout_variant_keys[variant]]" : "")
	if(initial(item_type.greyscale_config))
		icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(item_type.greyscale_config), colors), icon_state,  dir = SOUTH)
	else
		icon_to_convert = icon(initial(item_type.icon), icon_state, SOUTH)
	tgui_data["icons"] = list()
	tgui_data["icons"] += list(list(
		"icon" = icon2base64(icon_to_convert),
		"translateX" = NO_OFFSET,
		"translateY" = NO_OFFSET,
		"scale" = 1,
		))
	for(var/datum/item_representation/armor_module/attachment AS in attachments)
		if(!initial(attachment.item_type.icon_state))
			continue
		var/second_icon_state = initial(attachment.item_type.icon_state) + (attachment.variant ? "_[GLOB.loadout_variant_keys[attachment.variant]]" : "")
		if(initial(attachment.item_type.greyscale_config))
			icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(attachment.item_type.greyscale_config), attachment.colors), second_icon_state, dir = SOUTH)
		else
			icon_to_convert = icon(initial(attachment.item_type.icon), second_icon_state, SOUTH)
		tgui_data["icons"] += list(list(
			"icon" = icon2base64(icon_to_convert),
			"translateX" = NO_OFFSET,
			"translateY" = NO_OFFSET,
			"scale" = 1,
			))
	tgui_data["name"] = initial(item_type.name)
	return tgui_data
