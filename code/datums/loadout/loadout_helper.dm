///Return a new empty loayout
/proc/create_empty_loadout(name = "Default", job = SQUAD_MARINE)
	var/datum/loadout/empty = new
	empty.name = name
	empty.job = job
	empty.item_list = list()
	return empty

///Return true if the item was found in a linked vendor and successfully bought
/proc/buy_item_in_vendor(obj/item/item_to_buy_type, datum/loadout_seller/seller, mob/living/user)

	if(seller.faction != FACTION_NEUTRAL && is_type_in_typecache(item_to_buy_type, GLOB.hvh_restricted_items_list))
		return FALSE

	//If we can find it for in a shared vendor, we buy it
	for(var/type in (GLOB.loadout_linked_vendor[seller.faction] + GLOB.loadout_linked_vendor[user.job.title]))
		for(var/datum/vending_product/item_datum AS in GLOB.vending_records[type])
			if(item_datum.product_path == item_to_buy_type && item_datum.amount != 0)
				item_datum.amount--
				return TRUE

	var/list/job_specific_list = GLOB.loadout_role_essential_set[user.job.title]

	//If we still have our essential kit, and the item is in there, we take one from it
	if(seller.buying_bitfield & MARINE_CAN_BUY_ESSENTIALS && islist(job_specific_list) && job_specific_list[item_to_buy_type] > seller.unique_items_list[item_to_buy_type])
		seller.unique_items_list[item_to_buy_type]++
		return TRUE

	//If it's in a clothes vendor that uses buying bitfield, we check if we still have that field and we use it
	job_specific_list = GLOB.job_specific_clothes_vendor[user.job.title]
	if(!islist(job_specific_list))
		return FALSE
	var/list/item_info = job_specific_list[item_to_buy_type]
	if(item_info && buy_category(item_info[1], seller))
		return TRUE

	//Lastly, we try to use points to buy from a job specific points vendor
	var/list/listed_products = GLOB.job_specific_points_vendor[user.job.title]
	if(!listed_products)
		return FALSE
	for(var/item_type in listed_products)
		if(item_to_buy_type != item_type)
			continue
		item_info = listed_products[item_type]
		if(item_info[1] == CAT_ESS)
			return FALSE
		if(seller.available_points[item_info[1]] < item_info[3])
			return FALSE
		seller.available_points[item_info[1]] -= item_info[3]
		return TRUE
	return FALSE

/**
 * Check if that stack is buyable in a points vendor (currently, only metal, sandbags and plasteel)
 */
/proc/buy_stack(obj/item/stack/stack_to_buy_type, datum/loadout_seller/seller, mob/living/user, amount)
	//Hardcode to check the category. Why is this function even here? But it doesn't work, and here I am doing hardcode to make it work because it's hardcoded anyway.
	var/item_cat = ""
	if(user.job.title == SQUAD_LEADER)
		item_cat = CAT_LEDSUP
	else if (user.job.title == SQUAD_ENGINEER)
		item_cat = CAT_ENGSUP
	else
		return FALSE

	var/base_amount = 0
	var/base_price = 0
	if(ispath(stack_to_buy_type, /obj/item/stack/sheet/metal) && user.job.title == SQUAD_ENGINEER)
		base_amount = 10
		base_price = METAL_PRICE_IN_GEAR_VENDOR
	else if(ispath(stack_to_buy_type, /obj/item/stack/sheet/plasteel) && user.job.title == SQUAD_ENGINEER)
		base_amount = 10
		base_price = PLASTEEL_PRICE_IN_GEAR_VENDOR
	else if(ispath(stack_to_buy_type, /obj/item/stack/sandbags_empty))
		base_amount = 25
		base_price = SANDBAG_PRICE_IN_GEAR_VENDOR

	if(base_amount && (round(amount / base_amount) * base_price <= seller.available_points[item_cat]))
		var/points_cost = round(amount / base_amount) * base_price
		seller.available_points[item_cat] -= points_cost
		return TRUE

///Return wich type of item_representation should representate any item_type
/proc/item2representation_type(item_type)
	if(ispath(item_type, /obj/item/weapon/gun))
		return /datum/item_representation/gun
	if(ispath(item_type, /obj/item/clothing/suit/modular))
		return /datum/item_representation/modular_armor
	if(ispath(item_type, /obj/item/armor_module/armor))
		return /datum/item_representation/armor_module/colored
	if(ispath(item_type, /obj/item/armor_module/storage))
		return /datum/item_representation/armor_module/storage
	if(ispath(item_type, /obj/item/storage))
		return /datum/item_representation/storage
	if(ispath(item_type, /obj/item/clothing/suit/storage))
		return /datum/item_representation/suit_with_storage
	if(ispath(item_type, /obj/item/clothing/head/modular))
		return /datum/item_representation/modular_helmet
	if(ispath(item_type, /obj/item/clothing/under))
		return /datum/item_representation/uniform_representation
	if(ispath(item_type, /obj/item/ammo_magazine/handful))
		return /datum/item_representation/handful_representation
	if(ispath(item_type, /obj/item/stack))
		return /datum/item_representation/stack
	if(ispath(item_type, /obj/item/card/id))
		return /datum/item_representation/id
	if(ispath(item_type, /obj/item/clothing/shoes/marine))
		return /datum/item_representation/boot
	return /datum/item_representation

/// Return TRUE if this handful should be buyable, aka if it's corresponding aka box is in a linked vendor
/proc/is_handful_buyable(ammo_type)
	for(var/datum/vending_product/item_datum AS in GLOB.vending_records[/obj/machinery/vending/weapon])
		var/product_path = item_datum.product_path
		if(!ispath(product_path, /obj/item/ammo_magazine))
			continue
		var/obj/item/ammo_magazine/ammo = product_path
		if(initial(ammo.default_ammo) == ammo_type)
			return TRUE
	return FALSE

/// Will give a headset corresponding to the user job to the user
/proc/give_free_headset(mob/living/carbon/human/user, faction)
	if(user.wear_ear)
		return
	if(user.job.outfit.ears)
		user.equip_to_slot_or_del(new user.job.outfit.ears(user), SLOT_EARS, override_nodrop = TRUE)
		return
	if(!user.assigned_squad)
		return
	var/headset_type = faction == FACTION_TERRAGOV_REBEL ? /obj/item/radio/headset/mainship/marine/rebel : /obj/item/radio/headset/mainship/marine
	user.equip_to_slot_or_del(new headset_type(null, user.assigned_squad, user.job.type), SLOT_EARS, override_nodrop = TRUE)

/// Will check if the selected category can be bought according to the buying_bitfield
/proc/can_buy_category(category, buying_bitfield)
	var/selling_bitfield = NONE
	for(var/i in GLOB.marine_selector_cats[category])
		selling_bitfield |= i
	return buying_bitfield & selling_bitfield

/// Return true if you can buy this category, and also change the loadout seller buying bitfield
/proc/buy_category(category, datum/loadout_seller/seller)
	var/selling_bitfield = NONE
	for(var/i in GLOB.marine_selector_cats[category])
		selling_bitfield |= i
	if(!(seller.buying_bitfield & selling_bitfield))
		return FALSE
	if(selling_bitfield == (MARINE_CAN_BUY_R_POUCH|MARINE_CAN_BUY_L_POUCH))
		if(seller.buying_bitfield & MARINE_CAN_BUY_R_POUCH)
			seller.buying_bitfield &= ~MARINE_CAN_BUY_R_POUCH
		else
			seller.buying_bitfield &= ~MARINE_CAN_BUY_L_POUCH
		return TRUE
	seller.buying_bitfield &= ~selling_bitfield
	return TRUE

/proc/load_player_loadout(player_ckey, loadout_job, loadout_name)
	player_ckey = ckey(player_ckey)
	if(!player_ckey)
		return
	var/path = "data/player_saves/[player_ckey[1]]/[player_ckey]/preferences.sav"
	if(!path)
		return
	if(!fexists(path))
		return
	var/savefile/S = new /savefile(path)
	if(!S)
		return
	S.cd = "/loadouts"
	var/loadout_json = ""
	READ_FILE(S["[loadout_name + loadout_job]"], loadout_json)
	if(!loadout_json)
		return
	var/datum/loadout/loadout = jatum_deserialize(loadout_json)
	return loadout

/proc/convert_loadouts_list(list/loadouts_data)
	var/list/new_loadouts_data = list()
	for(var/i = 1 to length(loadouts_data) step 2)
		var/next_loadout_data = list()
		next_loadout_data += loadouts_data[i]
		next_loadout_data += loadouts_data[++i]
		new_loadouts_data += list(next_loadout_data)
	return new_loadouts_data

///If the item is not a stack, return 1. If it is a stack, return the stack size
/proc/get_item_stack_number(obj/item/I)
	if(!istype(I, /obj/item/stack))
		return 1
	var/obj/item/stack/stack = I
	return stack.amount

///If the item representation is not a stack, return 1. Else, return the satck size
/proc/get_item_stack_representation_amount(datum/item_representation/item_representation)
	if(!istype(item_representation, /datum/item_representation/stack))
		return 1
	var/datum/item_representation/stack/stack = item_representation
	return stack.amount
