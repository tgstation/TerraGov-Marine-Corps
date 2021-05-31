///Return a new empty loayout
/proc/create_empty_loadout(name = "Default", job = SQUAD_MARINE)
	var/datum/loadout/empty = new
	empty.name = name
	empty.job = job
	empty.item_list = list()
	return empty

///Return true if the item was found in a linked vendor
/proc/is_savable_in_loadout(obj/item/saved_item, datum/loadout/loadout)
	//Some items are allowed to bypass everything
	if(is_type_in_typecache(saved_item, GLOB.bypass_loadout_check_item))
		return TRUE
	
	if(ishandful(saved_item))
		return is_handful_savable(saved_item)
	
	//We check if the item is in a public vendor for free
	for(var/type in GLOB.loadout_linked_vendor)
		for(var/datum/vending_product/item_datum AS in GLOB.vending_records[type])
			if(item_datum.product_path == saved_item.type)
				return TRUE

	//If we can't find it for free, we then look if it's in the essential set of each job
	var/list/job_specific_list = GLOB.loadout_role_essential_set[loadout.job]
	if(job_specific_list[saved_item.type] > loadout.unique_items_list[saved_item.type])
		loadout.unique_items_list[saved_item.type] += 1
		return TRUE

	//If we can't find it for free, we then look if it's in a job specific vendor and if we can buy that category
	job_specific_list = GLOB.job_specific_clothes_vendor[loadout.job]
	var/list/item_info = job_specific_list[saved_item.type]
	if(item_info && buy_category(item_info[1], loadout))
		loadout.clothes_item_list[saved_item.type] += 1
		return TRUE

	//We check for specific construction stack items
	if((loadout.job == SQUAD_LEADER || loadout.job == SQUAD_ENGINEER) && isitemstack(saved_item))
		var/obj/item/stack/stack_saved = saved_item
		var/base_amount = 0
		var/base_price = 0
		if(istype(stack_saved, /obj/item/stack/sheet/metal) && loadout.job == SQUAD_ENGINEER)
			base_amount = 10
			base_price = METAL_PRICE_IN_GEAR_VENDOR
		else if(istype(stack_saved, /obj/item/stack/sheet/plasteel) && loadout.job == SQUAD_ENGINEER)
			base_amount = 10
			base_price = PLASTEEL_PRICE_IN_GEAR_VENDOR
		else if(istype(stack_saved, /obj/item/stack/sandbags_empty))
			base_amount = 25
			base_price = SANDBAG_PRICE_IN_GEAR_VENDOR
		if(base_amount && (round(stack_saved.amount / base_amount) * base_price <= loadout.job_points_available))
			loadout.job_points_available -= round(stack_saved.amount / base_amount) * base_price
			loadout.priced_items_list[saved_item.type]++
			return TRUE
	//If it was not in a job specific clothes vendor, we try to use marine points to buy it
	var/list/listed_products = GLOB.job_specific_points_vendor[loadout.job]
	if(!listed_products)
		return FALSE
	for(var/item_type in listed_products)
		if(saved_item.type != item_type)
			continue
		item_info = listed_products[item_type]
		if(loadout.job_points_available < item_info[3])
			return FALSE
		loadout.job_points_available -= item_info[3]
		loadout.priced_items_list[saved_item.type] += 1
		return TRUE
	return FALSE

///Return true if the item was found in a linked vendor and successfully bought
/proc/buy_item_in_vendor(item_to_buy_type, datum/loadout/loadout, mob/user)
	//Some items are allowed to bypass the buy checks
	if(is_type_in_typecache(item_to_buy_type, GLOB.bypass_vendor_item) || is_type_in_typecache(item_to_buy_type, GLOB.bypass_loadout_check_item))
		return TRUE
	
	//Items that were bought using marine points are already taken care of
	if(loadout.priced_items_list[item_to_buy_type])
		return TRUE
	
	//We check if the item is in the essential sets
	var/obj/item/card/id/id = user.get_idcard()
	if(loadout.unique_items_list[item_to_buy_type])
		return id.marine_buy_flags & MARINE_CAN_BUY_ESSENTIALS
	
	//Items that were bought from clothes vendor are changing the marine buy flags of the user
	if(loadout.clothes_item_list[item_to_buy_type])
		var/list/job_specific_list = GLOB.job_specific_clothes_vendor[loadout.job]
		var/list/item_info = job_specific_list[item_to_buy_type]
		if(item_info && can_buy_category(item_info[1], id.marine_buy_flags))
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
	if(ispath(item_type, /obj/item/stack))
		return /datum/item_representation/stack
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

/// Will check if the selected category can be bought according to the buying_bitfield
/proc/can_buy_category(category, buying_bitfield)
	var/selling_bitfield= NONE
	for(var/i in GLOB.marine_selector_cats[category])
		selling_bitfield |= i
	return buying_bitfield & selling_bitfield

/// Return true if you can buy this category, and also change the loadout buying bitfield
/proc/buy_category(category, datum/loadout/loadout)
	var/selling_bitfield= NONE
	for(var/i in GLOB.marine_selector_cats[category])
		selling_bitfield |= i
	if(!(loadout.buying_bitfield & selling_bitfield))
		return FALSE
	if(selling_bitfield == (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH))
		if(loadout.buying_bitfield & MARINE_CAN_BUY_R_POUCH)
			loadout.buying_bitfield &= ~MARINE_CAN_BUY_R_POUCH
		else
			loadout.buying_bitfield &= ~MARINE_CAN_BUY_L_POUCH
	else if(selling_bitfield == (MARINE_CAN_BUY_ATTACHMENT|MARINE_CAN_BUY_ATTACHMENT2))
		if(loadout.buying_bitfield & MARINE_CAN_BUY_ATTACHMENT)
			loadout.buying_bitfield &= ~MARINE_CAN_BUY_ATTACHMENT
		else
			loadout.buying_bitfield&= ~MARINE_CAN_BUY_ATTACHMENT2
	else
		loadout.buying_bitfield &= ~selling_bitfield
	return TRUE
