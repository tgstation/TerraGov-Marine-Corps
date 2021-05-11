/**
 * Light weight representation of an obj/item
 * This allow us to manipulate and store a lot of item-like objects, without it costing a ton of memory or having to instantiate all items
 * This also allow to save loadouts with jatum, because it doesn't accept obj/item
 */
/datum/item_representation
	/// The type of the object represented, to allow us to create the object when needed
	var/item_type

/datum/item_representation/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	item_type = item_to_copy.type

/// Will create a new item, and copy all the vars saved in the item representation to the newly created item
/datum/item_representation/proc/instantiate_object(master = null)
	var/obj/item/item = new item_type(master)
	return item

/**
 * Allow to representate a storage
 * This is only able to represent /obj/item/storage
 */
/datum/item_representation/storage
	/// The contents in the storage
	var/contents = list()

/datum/item_representation/storage/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isstorage(item_to_copy))
		CRASH("/datum/item_representation/storage created from an item that is not a storage")
	..()
	var/item_representation_type
	for(var/atom/thing_in_content AS in item_to_copy.contents)
		if(!isitem(thing_in_content))
			continue
		if(!is_savable_in_loadout(thing_in_content.type))
			continue
		item_representation_type = item_representation_type(thing_in_content.type)
		contents += new item_representation_type(thing_in_content)

/datum/item_representation/storage/instantiate_object(master = null)
	var/obj/item/storage/storage = ..()
	for(var/datum/item_representation/representation AS in contents)
		var/obj/item/item_to_insert = get_item_from_item_representation(representation)
		if(storage.can_be_inserted(item_to_insert))
			storage.handle_item_insertion(item_to_insert)
	return storage
