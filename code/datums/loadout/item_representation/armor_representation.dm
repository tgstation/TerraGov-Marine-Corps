/**
 * Allow to representate a armor with any modules it might have
 * This is only able to representate items of type /obj/item/clothing/suit
 */
/datum/item_representation/armor_suit
	///List of attachments on the armor.
	var/list/datum/item_representation/armor_module/attachments = list()

/datum/item_representation/armor_suit/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!issuit(item_to_copy))
		CRASH("/datum/item_representation/armor_suit created from an item that is not a suit")
	..()
	var/obj/item/clothing/suit/suit_to_copy = item_to_copy
	for(var/key in suit_to_copy.attachments_by_slot)
		if(!isitem(suit_to_copy.attachments_by_slot[key]))
			continue
		if(istype(suit_to_copy.attachments_by_slot[key], /obj/item/armor_module/storage))
			attachments += new /datum/item_representation/armor_module/storage(suit_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/armor_module(suit_to_copy.attachments_by_slot[key])

/datum/item_representation/armor_suit/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/armor_suit = .
	for(var/datum/item_representation/armor_module/armor_attachement AS in attachments)
		armor_attachement.install_on_armor(seller, armor_suit, user)

/datum/item_representation/armor_suit/get_tgui_data()
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
				"translateY" = MODULAR_ARMOR_OFFSET_Y,
				"scale" = MODULAR_ARMOR_SCALING,
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
		var/translatey = MODULAR_ARMOR_OFFSET_Y
		var/scale = MODULAR_ARMOR_SCALING
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

///////////////////////////////////////////////////////////////////////

/**
 * Allow to representate a armor with any modules it might have
 * This is only able to representate items of type /obj/item/clothing/suit
 */
/datum/item_representation/armor_suit/modular_armor
	///Icon_state suffix for the saved icon_state variant.
	var/current_variant

/datum/item_representation/armor_suit/modular_armor/New(obj/item/item_to_copy)
	..()
	if(!item_to_copy)
		return
	if(!ismodularsuit(item_to_copy))
		CRASH("/datum/item_representation/modular_armor created from an item that is not a modular suit")

	var/obj/item/clothing/suit/modular/suit_to_copy = item_to_copy
	if(item_to_copy.greyscale_config)
		return
	current_variant = suit_to_copy.current_variant

/datum/item_representation/armor_suit/modular_armor/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/modular/modular_armor = .
	if(modular_armor.greyscale_config)
		return
	modular_armor.current_variant = (current_variant in modular_armor.icon_state_variants) ? current_variant : initial(modular_armor.current_variant)
	modular_armor.update_icon()


/datum/item_representation/armor_suit/modular_armor/get_tgui_data()
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
				"translateY" = MODULAR_ARMOR_OFFSET_Y,
				"scale" = MODULAR_ARMOR_SCALING,
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
		var/translatey = MODULAR_ARMOR_OFFSET_Y
		var/scale = MODULAR_ARMOR_SCALING
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

/**
 * Allow to representate an module of a jaeger
 * This is only able to representate items of type /obj/item/armor_module
 */
/datum/item_representation/armor_module
	///List of attachments on the armor.
	var/list/datum/item_representation/armor_module/attachments = list()

/datum/item_representation/armor_module/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmormodule(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger module")
	..()
	var/obj/item/armor_module/module_to_copy = item_to_copy
	for(var/key in module_to_copy.attachments_by_slot)
		if(!isitem(module_to_copy.attachments_by_slot[key]))
			continue
		if(istype(module_to_copy.attachments_by_slot[key], /obj/item/armor_module/storage))
			attachments += new /datum/item_representation/armor_module/storage(module_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/armor_module(module_to_copy.attachments_by_slot[key])

/datum/item_representation/armor_module/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/module = .
	if(colors && CHECK_BITFIELD(module.attach_features_flags, ATTACH_GREYSCALE_PARENT_COPY))
		module.set_greyscale_colors(colors)
	for(var/datum/item_representation/armor_module/armor_attachement AS in attachments)
		armor_attachement.install_on_armor(seller, module, user)

///Attach the instantiated item on an armor
/datum/item_representation/armor_module/proc/install_on_armor(datum/loadout_seller/seller, obj/item/clothing/thing_to_install_on, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	if(!item_type)
		return
	var/obj/item/armor_module/module_type = item_type
	if(!CHECK_BITFIELD(initial(module_type.attach_features_flags), ATTACH_REMOVABLE))
		bypass_vendor_check = TRUE
	var/obj/item/armor_module/module = instantiate_object(seller, null, user)
	if(!module)
		return
	if(thing_to_install_on.attachments_by_slot[module.slot])
		qdel(module)
		return
	SEND_SIGNAL(thing_to_install_on, COMSIG_LOADOUT_VENDOR_VENDED_ARMOR_ATTACHMENT, module)

/datum/item_representation/armor_module/storage
	///Storage repressentation of storage modules.
	var/datum/item_representation/storage/storage

/datum/item_representation/armor_module/storage/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmorstoragemodule(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger storage module")
	..()
	storage = new(item_to_copy)

/datum/item_representation/armor_module/storage/instantiate_object(datum/loadout_seller/seller, master, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/storage/storage_module = .
	if(!storage_module)
		return
	if(!storage)
		return
	storage_module = storage.instantiate_current_storage_datum(seller, storage_module, user)
