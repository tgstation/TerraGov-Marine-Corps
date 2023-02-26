/**
 * Allow to representate a suit that has storage
 * This is only able to representate items of type /obj/item/clothing/suit/storage
 * In practice only PAS will use it, but it supports a lot of objects
 */
/datum/item_representation/suit_with_storage
	///The storage of the suit
	var/datum/item_representation/storage/pockets

/datum/item_representation/suit_with_storage/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!issuitwithstorage(item_to_copy))
		CRASH("/datum/item_representation/suit_with_storage created from an item that is not a suit with storage")
	..()
	var/obj/item/clothing/suit/storage/suit_to_copy = item_to_copy
	pockets = new /datum/item_representation/storage(suit_to_copy.pockets)

/datum/item_representation/suit_with_storage/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/storage/suit = .
	suit.pockets = pockets.instantiate_object(seller, suit, user)

/**
 * Allow to representate a jaeger modular armor with its modules
 * This is only able to representate items of type /obj/item/clothing/suit/modular
 */
/datum/item_representation/modular_armor
	///List of attachments on the armor.
	var/list/datum/item_representation/armor_module/attachments = list()
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant

/datum/item_representation/modular_armor/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmor(item_to_copy))
		CRASH("/datum/item_representation/modular_armor created from an item that is not a jaeger")
	..()
	var/obj/item/clothing/suit/modular/jaeger_to_copy = item_to_copy
	current_variant = jaeger_to_copy.current_variant
	for(var/key in jaeger_to_copy.attachments_by_slot)
		if(!isitem(jaeger_to_copy.attachments_by_slot[key]))
			continue
		if(istype(jaeger_to_copy.attachments_by_slot[key], /obj/item/armor_module/greyscale))
			attachments += new /datum/item_representation/armor_module/colored(jaeger_to_copy.attachments_by_slot[key])
			continue
		if(istype(jaeger_to_copy.attachments_by_slot[key], /obj/item/armor_module/armor))
			attachments += new /datum/item_representation/armor_module/armor(jaeger_to_copy.attachments_by_slot[key])
			continue
		if(istype(jaeger_to_copy.attachments_by_slot[key], /obj/item/armor_module/storage))
			attachments += new /datum/item_representation/armor_module/storage(jaeger_to_copy.attachments_by_slot[key])
			continue
		attachments += new /datum/item_representation/armor_module(jaeger_to_copy.attachments_by_slot[key])

/datum/item_representation/modular_armor/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/modular/modular_armor = .
	for(var/datum/item_representation/armor_module/armor_attachement AS in attachments)
		armor_attachement.install_on_armor(seller, modular_armor, user)
	modular_armor.current_variant = (current_variant in modular_armor.icon_state_variants) ? current_variant : initial(modular_armor.current_variant)
	modular_armor.update_icon()


/datum/item_representation/modular_armor/get_tgui_data()
	var/list/tgui_data = list()
	tgui_data["name"] = initial(item_type.name)
	tgui_data["icons"] = list()
	var/icon/icon_to_convert = icon(initial(item_type.icon),current_variant ? initial(item_type.icon_state) + "_[current_variant]" : initial(item_type.icon_state), SOUTH)
	tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = NO_OFFSET,
				"translateY" = MODULAR_ARMOR_OFFSET_Y,
				"scale" = MODULAR_ARMOR_SCALING,
				))
	for(var/datum/item_representation/armor_module/module AS in attachments)
		if(istype(module, /datum/item_representation/armor_module/colored))
			var/datum/item_representation/armor_module/colored/colored_module = module
			icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(colored_module.item_type.greyscale_config), colored_module.greyscale_colors), dir = SOUTH)
			tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = NO_OFFSET,
					"translateY" = MODULAR_ARMOR_OFFSET_Y,
					"scale" = MODULAR_ARMOR_SCALING,
					))
			continue
		if(ispath(module.item_type, /obj/item/armor_module/armor))
			icon_to_convert = icon(initial(module.item_type.icon), initial(module.item_type.icon_state), SOUTH)
			tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = "40%",
					"translateY" = "35%",
					"scale" = 0.5,
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
					"translateY" = MODULAR_ARMOR_OFFSET_Y,
					"scale" = MODULAR_ARMOR_SCALING,
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
		if(istype(module_to_copy.attachments_by_slot[key], /obj/item/armor_module/greyscale))
			attachments += new /datum/item_representation/armor_module/colored(module_to_copy.attachments_by_slot[key])
			continue
		if(istype(module_to_copy.attachments_by_slot[key], /obj/item/armor_module/armor))
			attachments += new /datum/item_representation/armor_module/armor(module_to_copy.attachments_by_slot[key])
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
	for(var/datum/item_representation/armor_module/armor_attachement AS in attachments)
		armor_attachement.install_on_armor(seller, module, user)

///Attach the instantiated item on an armor
/datum/item_representation/armor_module/proc/install_on_armor(datum/loadout_seller/seller, obj/item/clothing/thing_to_install_on, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	//if(!item_type)
	//	return
	var/obj/item/armor_module/module_type = item_type
	if(!CHECK_BITFIELD(initial(module_type.flags_attach_features), ATTACH_REMOVABLE))
		bypass_vendor_check = TRUE
	var/obj/item/armor_module/module = instantiate_object(seller, null, user)
	if(!module)
		return
	if(thing_to_install_on.attachments_by_slot[module.slot])
		qdel(module)
		return
	SEND_SIGNAL(thing_to_install_on, COMSIG_LOADOUT_VENDOR_VENDED_ARMOR_ATTACHMENT, module)



/datum/item_representation/armor_module/armor
	///Icon_state suffix for the saved icon_state varient.
	var/current_variant

/datum/item_representation/armor_module/armor/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmormodule(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger module")
	..()
	var/obj/item/armor_module/armor/module = item_to_copy
	current_variant = module.current_variant

/datum/item_representation/armor_module/armor/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/armor/module = .
	module.current_variant = (current_variant in module.icon_state_variants) ? current_variant : initial(module.current_variant)
	module.update_icon()
/**
 * Allow to representate an armor piece of a jaeger, and to color it
 * This is only able to representate items of type /obj/item/armor_module/greyscale
 */
/datum/item_representation/armor_module/colored
	///The color of that armor module
	var/greyscale_colors

/datum/item_representation/armor_module/colored/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgreyscaleattachment(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger armor piece")
	..()
	greyscale_colors = item_to_copy.greyscale_colors

/datum/item_representation/armor_module/colored/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/greyscale/armor = .
	if(greyscale_colors)
		armor.set_greyscale_colors(greyscale_colors)
	armor.update_icon()

/datum/item_representation/armor_module/storage
	///Storage repressentation of storage modules.
	var/datum/item_representation/storage/storage

/datum/item_representation/armor_module/storage/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmorstoragemodule(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger storage module")
	..()
	var/obj/item/armor_module/storage/storage_module = item_to_copy
	var/obj/item/storage/internal/modular/internal_storage = storage_module.storage
	storage = new(internal_storage)

/datum/item_representation/armor_module/storage/instantiate_object(datum/loadout_seller/seller, master, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/storage/storage_module = .
	if(!storage)
		return
	qdel(storage_module.storage) //an empty storage item is generated when the module is initialised
	storage_module.storage = storage.instantiate_object(seller, storage_module, user)
