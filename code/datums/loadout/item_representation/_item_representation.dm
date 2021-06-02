/**
 * Light weight representation of an obj/item
 * This allow us to manipulate and store a lot of item-like objects, without it costing a ton of memory or having to instantiate all items
 * This also allow to save loadouts with jatum, because it doesn't accept obj/item
 */
/datum/item_representation
	/// The type of the object represented, to allow us to create the object when needed
	var/obj/item/item_type
	/// If it's allowed to bypass the vendor check
	var/bypass_vendor_check = FALSE

/datum/item_representation/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	item_type = item_to_copy.type

/**
 * This will attempt to instantiate an object.
 * First, it tries to find that object in a vendor with enough supplies.
 * If it finds one vendor with that item in reserve, it sells it and instantiate that item.
 * If it fails to find a vendor, it will add that item to a list on seller to warns him that it failed
 * Return the instantatiated item if it was successfully sold, and return null otherwise
 */
/datum/item_representation/proc/instantiate_object(datum/loadout_seller/seller, master = null)
	if(seller && !bypass_vendor_check)
		if(!buy_item_in_vendor(item_type))
			seller.unavailable_items ++
			return
		seller.bought_items += item_type
	var/obj/item/item = new item_type(master)
	return item

/**
 * This is in charge of generating a visualisation of the item, that will then be gave to TGUI
 */
/datum/item_representation/proc/get_tgui_data()
	var/list/tgui_data = list()
	var/icon/icon_to_convert = icon(initial(item_type.icon), initial(item_type.icon_state), SOUTH)
	tgui_data["icons"] = list(list(
				"icon" = icon2base64(icon_to_convert),
				"translateX" = NO_OFFSET,
				"translateY" = NO_OFFSET,
				"scale" = 1,
				))
	tgui_data["name"] = initial(item_type.name)
	return tgui_data

/**
 * Allow to representate a storage
 * This is only able to represent /obj/item/storage
 */
/datum/item_representation/storage
	/// The contents in the storage
	var/list/contents = list()

/datum/item_representation/storage/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isstorage(item_to_copy))
		CRASH("/datum/item_representation/storage created from an item that is not a storage")
	..()
	//Internal storage are not in vendors. They should always be available for the loadout vendors, because they are instantiated like any other object
	if(istype(item_to_copy, /obj/item/storage/internal))
		bypass_vendor_check = TRUE
	var/item_representation_type
	for(var/atom/thing_in_content AS in item_to_copy.contents)
		if(!isitem(thing_in_content))
			continue
		if(!is_savable_in_loadout(thing_in_content))
			continue
		item_representation_type = item2representation_type(thing_in_content.type)
		contents += new item_representation_type(thing_in_content)

/datum/item_representation/storage/instantiate_object(datum/loadout_seller/seller, master = null)
	. = ..()
	if(!.)
		return
	var/obj/item/storage/storage = .
	for(var/datum/item_representation/item_representation AS in contents)
		var/obj/item/item_to_insert = item_representation.instantiate_object(seller)
		if(!item_to_insert)
			continue
		if(storage.can_be_inserted(item_to_insert))
			storage.handle_item_insertion(item_to_insert)
