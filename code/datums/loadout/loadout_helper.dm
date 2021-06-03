///Return a new empty loayout
/proc/create_empty_loadout(name = "Default", job = MARINE_LOADOUT)
	var/datum/loadout/empty = new
	empty.name = name
	empty.job = job
	empty.item_list = list()
	return empty

///Return true if the item was found in a linked vendor
/proc/is_savable_in_loadout(obj/item/saved_item)
	if(ishandful(saved_item))
		return is_handful_savable(saved_item)
	for(var/type in GLOB.loadout_linked_vendor)
		for(var/datum/vending_product/item_datum AS in GLOB.vending_records[type])
			if(item_datum.product_path == saved_item.type)
				return TRUE
	return FALSE

///Return true if the item was found in a linked vendor and successfully bought
/proc/buy_item_in_vendor(item_to_buy_type)
	if(is_type_in_typecache(item_to_buy_type, GLOB.bypass_vendor_item))
		return TRUE
	for(var/type in GLOB.loadout_linked_vendor)
		for(var/datum/vending_product/item_datum AS in GLOB.vending_records[type])
			if(item_datum.product_path == item_to_buy_type && item_datum.amount != 0)
				item_datum.amount--
				return TRUE
	return FALSE

/// Will put back an item in a linked vendor
/proc/sell_back_item_in_vendor(item_to_give_back_type)
	for(var/type in GLOB.loadout_linked_vendor)
		for(var/datum/vending_product/item_datum AS in GLOB.vending_records[type])
			if(item_datum.product_path != item_to_give_back_type)
				continue
			if(item_datum.amount >= 0)
				item_datum.amount++
			return 

///Return wich type of item_representation should representate any item_type
/proc/item2representation_type(item_type)
	if(ispath(item_type, /obj/item/weapon/gun))
		return /datum/item_representation/gun
	if(ispath(item_type, /obj/item/clothing/suit/modular))
		return /datum/item_representation/modular_armor
	if(ispath(item_type, /obj/item/armor_module/armor))
		return /datum/item_representation/armor_module/colored
	if(ispath(item_type, /obj/item/storage))
		return /datum/item_representation/storage
	if(ispath(item_type, /obj/item/clothing/suit/storage))
		return /datum/item_representation/suit_with_storage
	if(ispath(item_type, /obj/item/clothing/head/modular))
		return /datum/item_representation/modular_helmet
	if(ispath(item_type, /obj/item/clothing/under))
		return /datum/item_representation/uniform_representation
	if(ispath(item_type, /obj/item/clothing/tie/storage))
		return /datum/item_representation/tie
	if(ispath(item_type, /obj/item/ammo_magazine/handful))
		return /datum/item_representation/handful_representation
	return /datum/item_representation

/// Return TRUE if this handful should be savable, aka if it's corresponding aka box is in a linked vendor
/proc/is_handful_savable(obj/item/ammo_magazine/handful/handful)
	for(var/datum/vending_product/item_datum AS in GLOB.vending_records[/obj/machinery/vending/marine/shared])
		var/product_path = item_datum.product_path
		if(!ispath(product_path, /obj/item/ammo_magazine))
			continue
		var/obj/item/ammo_magazine/ammo = product_path
		if(initial(ammo.default_ammo) == handful.default_ammo)
			return TRUE
	return FALSE

/// Will give a headset corresponding to the user job to the user
/proc/give_free_headset(mob/living/carbon/human/user)
	if(user.wear_ear)
		return
	if(user.job.outfit.ears)
		user.equip_to_slot_or_del(new user.job.outfit.ears(user), SLOT_EARS, override_nodrop = TRUE)
		return
	if(!user.assigned_squad)
		return
	user.equip_to_slot_or_del(new /obj/item/radio/headset/mainship/marine(null, user.assigned_squad, user.job), SLOT_EARS, override_nodrop = TRUE)
