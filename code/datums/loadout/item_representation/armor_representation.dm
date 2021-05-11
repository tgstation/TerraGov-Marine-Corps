/**
 * Allow to representate a suit that has storage
 * This is only able to representate items of type /obj/item/clothing/suit/storage
 * In practice only PAS will use it, but it supports a lot of objects
 */
/datum/item_representation/suit_with_storage
	///The storage of the suit
	var/datum/item_representation/storage/pockets

/datum/item_representation/suit_with_storage/New(obj/item/item_to_copy)
	. = ..()
	if(!item_to_copy)
		return
	if(!issuitwithstorage(item_to_copy))
		CRASH("/datum/item_representation/suit_with_storage created from an item that is not a suit with storage")
	..()
	var/obj/item/clothing/suit/storage/suit_to_copy = item_to_copy
	pockets = new /datum/item_representation/storage(suit_to_copy.pockets)

/datum/item_representation/suit_with_storage/instantiate_object(datum/loadout_seller/seller)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/storage/suit = .
	suit.pockets = pockets.instantiate_object(seller, suit)
	return suit

/**
 * Allow to representate a jaeger modular armor with its modules
 * This is only able to representate items of type /obj/item/clothing/suit/modular
 */
/datum/item_representation/modular_armor
	/// Attachment slots for chest armor
	var/datum/item_representation/armor_module/colored/slot_chest
	/// Attachment slots for arm armor
	var/datum/item_representation/armor_module/colored/slot_arms
	/// Attachment slots for leg armor
	var/datum/item_representation/armor_module/colored/slot_legs
	/// What modules are installed
	var/datum/item_representation/armor_module/installed_module
	/// What storage is installed
	var/datum/item_representation/armor_module/installed_storage
	///The implementation of the storage
	var/datum/item_representation/storage/storage_implementation

/datum/item_representation/modular_armor/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isjaeger(item_to_copy))
		CRASH("/datum/item_representation/modular_armor created from an item that is not a jaeger")
	..()
	var/obj/item/clothing/suit/modular/jaeger_to_copy = item_to_copy
	if(jaeger_to_copy.slot_chest)
		slot_chest = new /datum/item_representation/armor_module/colored(jaeger_to_copy.slot_chest)
	if(jaeger_to_copy.slot_arms)
		slot_arms = new /datum/item_representation/armor_module/colored(jaeger_to_copy.slot_arms)
	if(jaeger_to_copy.slot_legs)
		slot_legs = new /datum/item_representation/armor_module/colored(jaeger_to_copy.slot_legs)
	if(jaeger_to_copy.installed_storage)
		installed_storage = new /datum/item_representation/armor_module(jaeger_to_copy.installed_storage)
		storage_implementation = new /datum/item_representation/storage(jaeger_to_copy.storage)
	if(!length(jaeger_to_copy.installed_modules) || !is_savable_in_loadout(jaeger_to_copy.installed_modules[1]?.type)) //Not supporting mutiple modules, but no object in game has that so
		return
	installed_module = new /datum/item_representation/armor_module(jaeger_to_copy.installed_modules[1])

/datum/item_representation/modular_armor/instantiate_object(datum/loadout_seller/seller)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/suit/modular/modular_armor = .
	slot_chest?.install_on_armor(seller, modular_armor)
	slot_arms?.install_on_armor(seller, modular_armor)
	slot_legs?.install_on_armor(seller, modular_armor)
	installed_module?.install_on_armor(seller, modular_armor)
	if(installed_storage)
		installed_storage.install_on_armor(seller, modular_armor)
		modular_armor.storage = storage_implementation.instantiate_object(seller, modular_armor)
	modular_armor.update_overlays()
	return modular_armor

/**
 * Allow to representate an module of a jaeger
 * This is only able to representate items of type /obj/item/armor_module
 */
/datum/item_representation/armor_module

/datum/item_representation/armor_module/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isjaegermodule(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger module")
	..()

///Attach the instantiated item on an armor
/datum/item_representation/armor_module/proc/install_on_armor(datum/loadout_seller/seller, obj/item/clothing/suit/modular/armor)
	var/obj/item/armor_module/module = instantiate_object(seller)
	module.do_attach(null, armor)

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
	if(!isjaegerarmorpiece(item_to_copy))
		CRASH("/datum/item_representation/armor_module created from an item that is not a jaeger armor piece")
	..()
	greyscale_colors = item_to_copy.greyscale_colors

/datum/item_representation/armor_module/colored/instantiate_object(datum/loadout_seller/seller)
	. = ..()
	if(!.)
		return
	var/obj/item/armor_module/armor/armor = .
	armor.set_greyscale_colors(greyscale_colors)
	return armor
