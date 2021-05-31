/**
 * Small loadout in charge of dealing with a user trying to equip a saved loadout
 * First it will reserve all items that can be bought, and save the name of all items that cannot be bought
 * If the list of items that cannot be bought is empty, the transaction will be automaticly accepted and the loadout will be equipped on the user
 * If it's not empty, it will warn the user and give him the list of non-buyable items.
 * The user can chose to proceed with the buy, and he is equipped with what was already be bought, 
 * or he can chose to refuse, and then the items are put back in the vendors
 */
/datum/loadout_seller
	/// How many items were not available
	var/unavailable_items = 0
	/// List of all items that were bought
	var/list/bought_items = list()
	/// Assoc list of items in visible slots. 
	var/list/item_list = list()

///Will save all the bought items in item_list, and keep the record of unavailable_items
/datum/loadout_seller/proc/prepare_to_equip_loadout(datum/loadout/loadout, mob/user)
	unavailable_items = 0
	bought_items = list()
	item_list = list()
	for(var/slot_key in GLOB.visible_item_slot_list)
		var/datum/item_representation/item_representation = loadout.item_list[slot_key]
		item_list[slot_key] = item_representation?.instantiate_object(src, null, loadout, user)

///The user chose to abort equiping that loadout, so we put back all items in vendor
/datum/loadout_seller/proc/sell_back_items()
	for(var/item_type AS in bought_items)
		sell_back_item_in_vendor(item_type)

///Will equip the mob with the items that were bought previously
/datum/loadout_seller/proc/do_equip_loadout(mob/living/user)
	var/obj/item/item
	for(var/slot_key in GLOB.visible_item_slot_list)
		if(!item_list[slot_key])
			continue
		item = item_list[slot_key]
		if(!user.equip_to_slot_if_possible(item, GLOB.slot_str_to_slot[slot_key], warning = FALSE))
			sell_back_item_in_vendor(item.type)
			qdel(item)
	give_free_headset(user)

/**
 * Buy all items of the loadout from vendors. If some items could not be bought, we warned the user and ask him if he wants to continue.
 * If the user still want to proceed, we equip the user with the loadout
 * Else we sell everything back to vendors
 */
/datum/loadout_seller/proc/try_to_equip_loadout(datum/loadout/loadout, mob/user)
	var/obj/item/card/id/id = user.get_idcard()
	if(MARINE_TOTAL_BUY_POINTS - loadout.job_points_available > id.marine_points)
		to_chat(user, "<span class='warning'>You don't have enough points to equip that loadout</span>")
		return FALSE
	prepare_to_equip_loadout(loadout, user)
	if(unavailable_items && tgui_alert(user, "[unavailable_items] items were not found in vendors and won't be delivered. Do you want to equip that loadout anyway?", "Items missing", list("Yes", "No")) != "Yes")
		sell_back_items()
		return FALSE
	do_equip_loadout(user)
	sell_rest_of_essential_kit(loadout, user)

/// If one item from essential kit was bought, we sell the rest and put in on the ground
/datum/loadout_seller/proc/sell_rest_of_essential_kit(datum/loadout/loadout, mob/user)
	var/obj/item/card/id/id = user.get_idcard()
	if(!(id.marine_buy_flags & MARINE_CAN_BUY_ESSENTIALS))
		return
	id.marine_buy_flags &= ~MARINE_CAN_BUY_ESSENTIALS
	var/list/job_specific_list = GLOB.loadout_role_essential_set[loadout.job]
	for(var/key in job_specific_list)
		var/item_already_sold = loadout.unique_items_list[key]
		while(item_already_sold < job_specific_list[key])
			var/obj/item/item = key
			new item(user.loc)
			item_already_sold++

