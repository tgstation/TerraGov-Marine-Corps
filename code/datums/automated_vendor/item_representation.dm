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
	if(!istype(item_to_copy, /obj/item/storage))
		return
	for(var/atom/thing_in_content AS in item_to_copy.contents)
		if(!isitem(thing_in_content))
			continue
		if(!is_savable_in_loadout(thing_in_content.type))
			continue
		item_representation_type = item_representation_type(thing_in_content.type)
		contents += new item_representation_type(thing_in_content)

/// Will create a new item, and copy all the vars saved in the item representation to the newly created item
/datum/item_representation/proc/instantiate_object()
	var/obj/item/item = new item_type
	if(!ispath(item_type, /obj/item/storage))
		return item
	var/obj/item/storage/storage_item = item
	for(var/datum/item_representation/representation AS in contents)
		var/obj/item/item_to_insert = get_item_from_item_representation(representation)
		if(storage_item.can_be_inserted(item_to_insert))
			storage_item.handle_item_insertion(item_to_insert)
	return storage_item

/**
 * Allow to representate a gun with its attachements
 * This is only able to represent guns and child of gun
 */
/datum/item_representation/gun
	/// Muzzle attachement representation
	var/datum/item_representation/gun_attachement/muzzle
	/// Rail attachement representation
	var/datum/item_representation/gun_attachement/rail
	/// Under attachement representation
	var/datum/item_representation/gun_attachement/under
	/// Stock attachement representation
	var/datum/item_representation/gun_attachement/stock

/datum/item_representation/gun/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgun(item_to_copy))
		CRASH("/datum/item_representation/gun created on an item that is not a gun")
	..()
	var/obj/item/weapon/gun/gun_to_copy = item_to_copy
	if(gun_to_copy.muzzle)
		muzzle = new /datum/item_representation/gun_attachement(gun_to_copy.muzzle)
	if(gun_to_copy.rail)
		rail = new /datum/item_representation/gun_attachement(gun_to_copy.rail)
	if(gun_to_copy.under)
		under = new /datum/item_representation/gun_attachement(gun_to_copy.under)
	if(gun_to_copy.stock)
		stock = new /datum/item_representation/gun_attachement(gun_to_copy.stock)

/datum/item_representation/gun/instantiate_object()
	var/obj/item/weapon/gun/gun = ..()
	muzzle?.install_on_gun(gun)
	rail?.install_on_gun(gun)
	under?.install_on_gun(gun)
	stock?.install_on_gun(gun)
	return gun

/**
 * Allow to representate a gun attachement
 *  */
/datum/item_representation/gun_attachement

/datum/item_representation/gun_attachement/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isgunattachment(item_to_copy))
		CRASH("/datum/item_representation/gun_attachement created on an item that is not a gun attachment")
	..()

///Attach the instantiated attachment to the gun
/datum/item_representation/proc/install_on_gun(obj/item/weapon/gun/gun_to_attach)
	var/obj/item/attachable/attachment = instantiate_object()
	attachment.attach_to_gun(gun_to_attach)

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

/datum/item_representation/modular_armor/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isjaeger(item_to_copy))
		CRASH("/datum/item_representation/modular_armor created on an item that is not a jaeger")
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
	
	if(!length(jaeger_to_copy.installed_modules) || !is_savable_in_loadout(jaeger_to_copy.installed_modules[1]?.type)) //Not supporting mutiple modules, but no object in game has that so
		return
	installed_module = new /datum/item_representation/armor_module(jaeger_to_copy.installed_modules[1])

/datum/item_representation/modular_armor/instantiate_object()
	var/obj/item/clothing/suit/modular/modular_armor = ..()
	slot_chest?.install_on_armor(modular_armor)
	slot_arms?.install_on_armor(modular_armor)
	slot_legs?.install_on_armor(modular_armor)
	installed_module?.install_on_armor(modular_armor)
	installed_storage?.install_on_armor(modular_armor)
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
		CRASH("/datum/item_representation/armor_module created on an item that is not a jaeger module")
	..()

///Attach the instantiated item on an armor
/datum/item_representation/armor_module/proc/install_on_armor(obj/item/clothing/suit/modular/armor)
	var/obj/item/armor_module/module = instantiate_object()
	module.do_attach(null, armor)

/**
 * Allow to representate an armor piece of a jaeger
 * This is only able to representate items of type /obj/item/armor_module/armor
 */
/datum/item_representation/armor_module/colored
	///The color of that armor module
	var/greyscale_colors

/datum/item_representation/armor_module/colored/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isjaegerarmorpiece(item_to_copy))
		CRASH("/datum/item_representation/armor_module created on an item that is not a jaeger armor piece")
	..()
	greyscale_colors = item_to_copy.greyscale_colors

/datum/item_representation/armor_module/colored/instantiate_object()
	var/obj/item/armor_module/armor/armor = ..()
	armor.set_greyscale_colors(greyscale_colors)
	return armor
