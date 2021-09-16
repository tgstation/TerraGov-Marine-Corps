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
	/// Assoc list of all armor modules on that modulare armor
	var/list/datum/item_representation/armor_module/colored/armor_modules
	/// What modules are installed
	var/datum/item_representation/armor_module/installed_module
	/// What storage is installed
	var/datum/item_representation/armor_module/installed_storage
	///The implementation of the storage
	var/datum/item_representation/storage/storage_implementation

/datum/item_representation/modular_armor/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmor(item_to_copy))
		CRASH("/datum/item_representation/modular_armor created from an item that is not a jaeger")
	..()
	var/obj/item/clothing/suit/modular/jaeger_to_copy = item_to_copy
	armor_modules = list()
	if(jaeger_to_copy.slot_chest)
		armor_modules["chest"] = new /datum/item_representation/armor_module/colored(jaeger_to_copy.slot_chest)
	if(jaeger_to_copy.slot_arms)
		armor_modules["arms"] = new /datum/item_representation/armor_module/colored(jaeger_to_copy.slot_arms)
	if(jaeger_to_copy.slot_legs)
		armor_modules["legs"] = new /datum/item_representation/armor_module/colored(jaeger_to_copy.slot_legs)
	if(jaeger_to_copy.installed_storage)
		installed_storage = new /datum/item_representation/armor_module(jaeger_to_copy.installed_storage)
		storage_implementation = new /datum/item_representation/storage(jaeger_to_copy.storage)
	if(!length(jaeger_to_copy.installed_modules)) //Not supporting mutiple modules, but no object in game has that so
		return
	installed_module = new /datum/item_representation/armor_module(jaeger_to_copy.installed_modules[1])

/datum/item_representation/modular_armor/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/modular/modular_armor = .
	for(var/key in armor_modules)
		var/datum/item_representation/armor_module/colored/armor_module = armor_modules[key]
		armor_module.install_on_armor(seller, modular_armor, user)
	installed_module?.install_on_armor(seller, modular_armor, user)
	if(installed_storage)
		installed_storage.install_on_armor(seller, modular_armor, user)
		modular_armor.storage = storage_implementation.instantiate_object(seller, modular_armor, user)
	modular_armor.update_icon()


/datum/item_representation/modular_armor/get_tgui_data()
	var/list/tgui_data = list()
	tgui_data["name"] = initial(item_type.name)
	tgui_data["icons"] = list()
	var/icon/icon_to_convert = icon(initial(item_type.icon), initial(item_type.icon_state), SOUTH)
	tgui_data["icons"] += list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = NO_OFFSET,
				"translateY" = MODULAR_ARMOR_OFFSET_Y,
				"scale" = MODULAR_ARMOR_SCALING,
				))
	for(var/key in armor_modules)
		var/datum/item_representation/armor_module/colored/armor_module = armor_modules[key]
		icon_to_convert = icon(SSgreyscale.GetColoredIconByType(initial(armor_module.item_type.greyscale_config), armor_module.greyscale_colors), dir = SOUTH)
		tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = NO_OFFSET,
					"translateY" = MODULAR_ARMOR_OFFSET_Y,
					"scale" = MODULAR_ARMOR_SCALING,
					))
	if(installed_storage)
		icon_to_convert = icon(initial(installed_storage.item_type.icon), initial(installed_storage.item_type.icon_state), SOUTH)
		tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = NO_OFFSET,
					"translateY" = MODULAR_ARMOR_OFFSET_Y,
					"scale" = MODULAR_ARMOR_SCALING,
					))
	if(installed_module)
		icon_to_convert = icon(initial(installed_module.item_type.icon), initial(installed_module.item_type.icon_state), SOUTH)
		tgui_data["icons"] += list(list(
					"icon" = icon2base64(icon_to_convert),
					"translateX" = "40%",
					"translateY" = "35%",
					"scale" = 0.5,
					))
	return tgui_data


/**
 * Allow to representate an module of a jaeger
 * This is only able to representate items of type /obj/item/armor_module
 */
/datum/item_representation/armor_module

/datum/item_representation/armor_module/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmormodule(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger module")
	..()

///Attach the instantiated item on an armor
/datum/item_representation/armor_module/proc/install_on_armor(datum/loadout_seller/seller, obj/item/clothing/suit/modular/armor, mob/living/user)
	var/obj/item/armor_module/module = instantiate_object(seller, null, user)
	module?.do_attach(null, armor)

/**
 * Allow to representate an armor piece of a jaeger, and to color it
 * This is only able to representate items of type /obj/item/armor_module/armor
 */
/datum/item_representation/armor_module/colored
	///The color of that armor module
	var/greyscale_colors

/datum/item_representation/armor_module/colored/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!ismodulararmorarmorpiece(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger armor piece")
	..()
	greyscale_colors = item_to_copy.greyscale_colors

/datum/item_representation/armor_module/colored/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/armor/armor = .
	if(seller.faction == FACTION_NEUTRAL)
		armor.set_greyscale_colors(greyscale_colors)
		return
	armor.limit_colorable_colors(seller.faction)
