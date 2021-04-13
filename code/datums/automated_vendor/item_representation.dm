/**
 * Light weight representation of an obj/item
 * This allow us to manipulate and store a lot of item-like object, without it costing a ton of memory
 * This also allow to save loadout with jatum, because it doesn't accept obj/item
 */
/datum/item_representation
	/// Name of the object, identical to the name of the object it represents
	var/name = ""
	/// The type of the object represented, to allow us to create the object when needed
	var/item_type

/// Initiate the item_representation with the necessary vars from the item
/datum/item_representation/proc/copy_vars_from_item(obj/item/item)
	name = item.name
	item_type = item.type

/// Will create a new item, and copy all the vars saved in the item representation to the newly created item
/datum/item_representation/proc/instantiate_object()
	var/obj/item/item = new item_type
	item.name = name
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

/datum/item_representation/gun/copy_vars_from_item(obj/item/weapon/gun/gun)
	..()
	muzzle = gun.muzzle
	rail = gun.rail
	under = gun.rail
	stock = gun.stock

/datum/item_representation/gun/instantiate_object()
	var/obj/item/weapon/gun/gun = ..()
	gun.muzzle = muzzle
	gun.rail = rail
	gun.under = under
	gun.stock = stock
	return gun

/**
 * Allow to representate an item which we want to save its internal storage
 * Unlike all other child of /datum/item_representation ,any item can be represented by /datum/item_representation/storage
 */
/datum/item_representation/storage
	/// A list of datum/item_representation stored in that item
	var/list/contents

/datum/item_representation/storage/copy_vars_from_item(obj/item/storage)
	..()
	contents = storage.contents

/datum/item_representation/storage/instantiate_object()
	var/obj/item/storage = ..() //We don't need to cast more than necessary here, all atoms have content
	storage.contents = contents
	return storage

/**
 * Allow to representate a jaeger modular armor with its module
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
	var/list/datum/item_representation/installed_modules
	/// What storage is installed
	var/datum/item_representation/storage/installed_storage

/datum/item_representation/modular_armor/copy_vars_from_item(obj/item/clothing/suit/modular/modular_armor)
	..()
	slot_chest = modular_armor.slot_chest
	slot_arms = modular_armor.slot_arms
	slot_legs = modular_armor.slot_legs
	installed_modules = modular_armor.installed_modules
	installed_storage = modular_armor.installed_storage

/datum/item_representation/modular_armor/instantiate_object()
	var/obj/item/clothing/suit/modular/modular_armor = ..()
	modular_armor.slot_chest = slot_chest
	modular_armor.slot_arms = slot_arms
	modular_armor.slot_legs = slot_legs
	modular_armor.installed_modules = installed_modules
	modular_armor.installed_storage = installed_storage
	return modular_armor
