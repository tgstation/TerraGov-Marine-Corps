/**
 * Light weight representation of an obj/item
 * This allow us to manipulate and store a lot of item-like objects, without it costing a ton of memory or having to instantiate all items
 * This also allow to save loadouts with jatum, because it doesn't accept obj/item
 */
/datum/item_representation
	/// The type of the object represented, to allow us to create the object when needed
	var/item_type
	/// The contents in that item
	var/contents = list()

/datum/item_representation/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	item_type = item_to_copy.type
	var/item_representation_type
	for(var/atom/thing_in_content AS in contents)
		if(!isitem(thing_in_content))
			continue
		if(!is_savable_in_loadout(thing_in_content.type))
			continue
		item_representation_type = item_representation_type(thing_in_content.type)
		contents += new item_representation_type(thing_in_content)

/// Will create a new item, and copy all the vars saved in the item representation to the newly created item
/datum/item_representation/proc/instantiate_object()
	RETURN_TYPE(item_type)
	var/obj/item/item = new item_type
	contents = list()
	for(var/datum/item_representation/representation AS in contents)
		item.contents += representation.instantiate_object()
	return item

/**
 * Allow to representate a gun with its attachements
 * This is only able to represent guns and child of gun
 */
/datum/item_representation/gun
	/// Muzzle attachement representation
	var/datum/item_representation/muzzle
	/// Rail attachement representation
	var/datum/item_representation/rail
	/// Under attachement representation
	var/datum/item_representation/under
	/// Stock attachement representation
	var/datum/item_representation/stock

/datum/item_representation/gun/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	..()
	if(!isgun(item_to_copy))
		CRASH("/datum/item_representation/gun created on an item that is not a gun")
	var/obj/item/weapon/gun/gun_to_copy = item_to_copy
	if(gun_to_copy.muzzle)
		muzzle = new /datum/item_representation(gun_to_copy.muzzle)
	if(gun_to_copy.rail)
		rail = new /datum/item_representation(gun_to_copy.rail)
	if(gun_to_copy.under)
		under = new /datum/item_representation(gun_to_copy.under)
	if(gun_to_copy.stock)
		stock = new /datum/item_representation(gun_to_copy.stock)

/datum/item_representation/gun/instantiate_object()

	var/obj/item/weapon/gun/gun = ..()
	muzzle?.instantiate_object().attach_to_gun(gun)
	rail?.instantiate_object().attach_to_gun(gun)
	under?.instantiate_object().attach_to_gun(gun)
	stock?.instantiate_object().attach_to_gun(gun)
	return gun

/**
 * Allow to representate a jaeger modular armor with its modules
 * This is only able to representate items of type /obj/item/clothing/suit/modular
 */
/datum/item_representation/modular_armor
	/// Attachment slots for chest armor
	var/datum/item_representation/slot_chest
	/// Attachment slots for arm armor
	var/datum/item_representation/slot_arms
	/// Attachment slots for leg armor
	var/datum/item_representation/slot_legs
	/// What modules are installed
	var/datum/item_representation/installed_module
	/// What storage is installed
	var/datum/item_representation/installed_storage

/datum/item_representation/modular_armor/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	..()
	if(!isjaeger(item_to_copy))
		CRASH("/datum/item_representation/modular_armor created on an item that is not a jaeger")
	var/obj/item/clothing/suit/modular/jaeger_to_copy = item_to_copy
	if(jaeger_to_copy.slot_chest)
		slot_chest = new /datum/item_representation/armor_module(jaeger_to_copy.slot_chest)
	if(jaeger_to_copy.slot_arms)
		slot_arms = new /datum/item_representation/armor_module(jaeger_to_copy.slot_arms)
	if(jaeger_to_copy.slot_legs)
		slot_legs = new /datum/item_representation/armor_module(jaeger_to_copy.slot_legs)
	if(jaeger_to_copy.installed_storage)
		installed_storage = new /datum/item_representation(jaeger_to_copy.installed_storage)
	if(!is_savable_in_loadout(jaeger_to_copy.installed_modules[1]?.type)) //Not supporting mutiple modules, but no object in game has that so
		return
	installed_module = new /datum/item_representation(jaeger_to_copy.installed_modules[1])

/datum/item_representation/modular_armor/instantiate_object()
	var/obj/item/clothing/suit/modular/modular_armor = ..()
	slot_chest?.instantiate_object().do_attach(modular_armor)
	slot_arms?.instantiate_object().do_attach(modular_armor)
	slot_legs?.instantiate_object().do_attach(modular_armor)
	installed_module?.instantiate_object().do_attach(modular_armor)
	installed_storage?.instantiate_object().do_attach(modular_armor)
	return modular_armor

/**
 * Allow to representate an armor piece of a jaeger
 * This is only able to representate items of type /obj/item/armor_module/armor
 */
/datum/item_representation/armor_module
	///The color of that armor module
	var/greyscale_colors

/datum/item_representation/armor_module/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	..()
	if(!isjaegerarmorpiece(item_to_copy))
		CRASH("/datum/item_representation/armor_module created on an item that is not a jaeger armor piece")
	greyscale_colors = item_to_copy.greyscale_colors

/datum/item_representation/armor_module/instantiate_object()
	var/obj/item/armor_module/armor/armor = ..()
	armor.set_greyscale_colors(greyscale_colors)
