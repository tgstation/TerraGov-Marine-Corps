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
 * Seller: The datum in charge of checking for points and buying_flags
 * Master: used for modules, when the item need to be installed on master. Can be null
 * User: The human trying to equip this item
 * Return the instantatiated item if it was successfully sold, and return null otherwise
 */
/datum/item_representation/proc/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	if(seller && !bypass_vendor_check && !buy_item_in_vendor(item_type, seller, user))
		return
	if(!text2path("[item_type]"))
		to_chat(user, span_warning("[item_type] in your loadout is an invalid item, it has probably been changed or removed."))
		return
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
		item_representation_type = item2representation_type(thing_in_content.type)
		if(item_representation_type == /datum/item_representation/storage) //Storage nested in storage tends to be erased by jatum, so just give the default content
			item_representation_type = /datum/item_representation
		contents += new item_representation_type(thing_in_content)

/datum/item_representation/storage/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	//Some storage cannot handle custom contents
	if(is_type_in_typecache(item_type, GLOB.bypass_storage_content_save))
		return
	var/obj/item/storage/storage = .
	var/list/obj/item/starting_items = list()
	for(var/obj/item/I AS in storage.contents)
		starting_items[I.type] = starting_items[I.type] + get_item_stack_number(I)
	storage.delete_contents()
	for(var/datum/item_representation/item_representation AS in contents)
		if(!item_representation.bypass_vendor_check && starting_items[item_representation.item_type] > 0)
			var/amount_to_remove = get_item_stack_representation_amount(item_representation)
			if(starting_items[item_representation.item_type] < amount_to_remove)
				amount_to_remove = starting_items[item_representation.item_type]
				var/datum/item_representation/stack/stack_representation = item_representation
				stack_representation.amount = amount_to_remove
			starting_items[item_representation.item_type] = starting_items[item_representation.item_type] - amount_to_remove
			item_representation.bypass_vendor_check = TRUE
		var/obj/item/item_to_insert = item_representation.instantiate_object(seller, null, user)
		if(!item_to_insert)
			continue
		if(storage.can_be_inserted(item_to_insert))
			storage.handle_item_insertion(item_to_insert)
			continue
		item_to_insert.forceMove(get_turf(user))

/**
 * Allow to representate stacks of item of type /obj/item/stack
 */
/datum/item_representation/stack
	///Amount of items in the stack
	var/amount = 0

/datum/item_representation/stack/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isitemstack(item_to_copy))
		CRASH("/datum/item_representation/stack created from an item that is not a stack of items")
	..()
	var/obj/item/stack/stack_to_copy = item_to_copy
	amount = stack_to_copy.amount

/datum/item_representation/stack/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	if(seller && !bypass_vendor_check && !buy_stack(item_type, seller, user, amount) && !buy_item_in_vendor(item_type, seller, user))
		return
	var/obj/item/stack/stack = new item_type(master)
	stack.amount = amount
	stack.update_weight()
	stack.update_icon()
	return stack

/**
 * Allow to representate an id card (/obj/item/card/id)
 */
/datum/item_representation/id
	/// the access of the id
	var/list/access = list()
	/// the iff signal registered on the id
	var/iff_signal = NONE

/datum/item_representation/id/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!isidcard(item_to_copy))
		CRASH("/datum/item_representation/id created from an item that is not an id card")
	..()
	var/obj/item/card/id/id_to_copy = item_to_copy
	access = id_to_copy.access
	iff_signal = id_to_copy.iff_signal

/datum/item_representation/id/instantiate_object(datum/loadout_seller/seller, master = null, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/card/id/id = .
	id.access = access
	id.iff_signal = iff_signal
	return id

/datum/item_representation/boot
	/// The item stored in the boot
	var/datum/item_representation/boot_content

/datum/item_representation/boot/New(obj/item/item_to_copy)
	if(!item_to_copy)
		return
	if(!istype(item_to_copy, /obj/item/clothing/shoes/marine))
		CRASH("/datum/item_representation/boot created from an item that is not a marine boot")
	..()
	var/obj/item/clothing/shoes/marine/marine_shoes = item_to_copy
	for(var/atom/item_in_pocket AS in marine_shoes.pockets.contents)
		var/item_representation_type = item2representation_type(item_in_pocket.type)
		boot_content = new item_representation_type(item_in_pocket)

/datum/item_representation/boot/instantiate_object(datum/loadout_seller/seller, master, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/shoes/marine/marine_shoes = .
	marine_shoes.pockets.delete_contents()
	var/obj/item/item_in_pocket = boot_content.instantiate_object(seller, master, user)
	if(!item_in_pocket)
		return
	if(marine_shoes.pockets.can_be_inserted(item_in_pocket))
		marine_shoes.pockets.handle_item_insertion(item_in_pocket)
