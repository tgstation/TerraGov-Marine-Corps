/**
 * Light weight representation of an obj/item
 * This allow us to manipulate and store a lot of item-like object, without it costing a ton of memory
 * This also allow to save loadout with jatum, because it doesn't accept obj/item
 */
/datum/item_representation
	/// The type of the object represented, to allow us to create the object when needed
	var/item_type
	/// The contents in that item
	var/contents = list()

/// Initiate the item_representation with the necessary vars from the item
/datum/item_representation/proc/copy_vars_from_item_type(_item_type = /obj/item)
	item_type = _item_type

/// Will create a new item, and copy all the vars saved in the item representation to the newly created item
/datum/item_representation/proc/instantiate_object()
	var/obj/item/item = new item_type
	item.contents = contents
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

/datum/item_representation/gun/instantiate_object()
	var/obj/item/weapon/gun/gun = ..()
	gun.muzzle = muzzle
	gun.rail = rail
	gun.under = under
	gun.stock = stock
	return gun

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
	var/datum/item_representation/installed_storage

/datum/item_representation/modular_armor/instantiate_object()
	var/obj/item/clothing/suit/modular/modular_armor = ..()
	modular_armor.slot_chest = slot_chest
	modular_armor.slot_arms = slot_arms
	modular_armor.slot_legs = slot_legs
	modular_armor.installed_modules = installed_modules
	modular_armor.installed_storage = installed_storage
	return modular_armor
	
///Return wich type of item_representation should representate any item_type
/proc/item_representation_type(item_type)
	if(ispath(item_type, /obj/item/weapon/gun))
		return /datum/item_representation/gun
	if(ispath(item_type, /obj/item/clothing/suit/modular))
		return /datum/item_representation/modular_armor
	return /datum/item_representation

///Instantiate the objected linked to the given item_representation
/proc/get_item_from_item_representation(datum/item_representation/item_representation) //Probably a better way of doing this
	if(istype(item_representation, /datum/item_representation/modular_armor))
		var/datum/item_representation/modular_armor/casted = item_representation
		return casted.instantiate_object()
	if(istype(item_representation, /datum/item_representation/gun))
		var/datum/item_representation/gun/casted = item_representation
		return casted.instantiate_object()
	return item_representation.instantiate_object()
