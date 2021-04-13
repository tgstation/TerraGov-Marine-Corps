/**
 * Light weight representation of an obj/item
 * This allow us to manipulate and store a lot of item-like object, without it costing a ton of memory
 */
/datum/item_representation
	/// Name of the object, identical to the name of the object it represents
	var/name = ""
	/// The type of the object represented, to allow us to create the object when needed
	var/object_type

/**
 * Allow to representate a gun with its attachements
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

/**
 * Allow to representate an item which has an internal storage
 */
/datum/item_representation/storage
	/// A list of datum/item_representation stored in that item
	var/list/contents

/**
 * Allow to representate a jaeger modular armor with its module
 */
/datum/item_representation/modular_armor
	/// Attachment slots for chest armor
	var/datum/item_representation/slot_chest
	/// Attachment slots for arm armor
	var/datum/item_representation/slot_arms
	/// Attachment slots for leg armor
	var/datum/item_representation/slot_legs
	/// What modules are installed
	var/datum/item_representation/installed_modules
	/// What storage is installed
	var/datum/item_representation/storage/installed_storage

/**
 * Generate an item representation of the argument
 */
/proc/generate_item_representation(obj/item/item)
