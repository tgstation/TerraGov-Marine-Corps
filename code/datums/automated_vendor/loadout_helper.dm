///Return a new empty loayout
/proc/create_empty_loadout(name = "Default", job = MARINE_LOADOUT)
	var/datum/loadout/empty = new
	empty.name = name
	empty.job = job
	empty.item_list = list()
	return empty

///Return true if the item was found in a linked vendor
/proc/is_savable_in_loadout(saved_item_type)
	for(var/type in GLOB.loadout_linked_vendor)
		var/obj/machinery/vending/vendor = type
		for(var/item_type in initial(vendor.products))
			if(item_type == saved_item_type)
				return TRUE
	return FALSE

///Return wich type of item_representation should representate any item_type
/proc/item_representation_type(item_type)
	if(ispath(item_type, /obj/item/weapon/gun))
		return /datum/item_representation/gun
	if(ispath(item_type, /obj/item/clothing/suit/modular))
		return /datum/item_representation/modular_armor
	if(ispath(item_type, /obj/item/armor_module/armor))
		return /datum/item_representation/armor_module
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
