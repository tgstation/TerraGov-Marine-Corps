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
	/// How many points can be used when equipping the loadout
	var/available_points = 0
	/// The buying bitfield this marine used to equip the loadout
	var/buying_choices_left = list()
	/// Items that were taken from essential kits, used to check for duplicates
	var/unique_items_list = list()
	/// Assoc list of items in visible slots.
	var/list/item_list = list()
	///The faction of the seller.
	var/faction = FACTION_NEUTRAL

/datum/loadout_seller/New(faction)
	. = ..()
	src.faction = faction

///Will save all the bought items in item_list, and keep the record of unavailable_items
/datum/loadout_seller/proc/prepare_to_equip_loadout(datum/loadout/loadout, mob/user)
	unavailable_items = 0
	item_list = list()
	var/obj/item/card/id/id = user.get_idcard()
	available_points = id.marine_points
	buying_choices_left = id.marine_buy_choices
	for(var/slot_key in GLOB.visible_item_slot_list)
		var/datum/item_representation/item_representation = loadout.item_list[slot_key]
		item_list[slot_key] = item_representation?.instantiate_object(src, null, user)

///Will equip the mob with the items that were bought previously
/datum/loadout_seller/proc/do_equip_loadout(mob/living/user)
	var/obj/item/item
	for(var/slot_key in GLOB.visible_item_slot_list)
		if(!item_list[slot_key])
			continue
		item = item_list[slot_key]
		if(!user.equip_to_slot_if_possible(item, GLOB.slot_str_to_slot[slot_key], warning = FALSE))
			item.forceMove(user.loc)
	give_free_headset(user, faction)

/**
 * Buy all items of the loadout from vendors. If some items could not be bought, we warned the user and ask him if he wants to continue.
 * If the user still want to proceed, we equip the user with the loadout
 * Else we sell everything back to vendors
 */
/datum/loadout_seller/proc/try_to_equip_loadout(datum/loadout/loadout, mob/user)
	prepare_to_equip_loadout(loadout, user)
	var/obj/item/card/id/id = user.get_idcard()
	for(var/category in id.marine_buy_choices)
		id.marine_buy_choices[category] = min(buying_choices_left[category], id.marine_buy_choices[category])
	id.marine_points = available_points
	do_equip_loadout(user)
	if(length(unique_items_list))
		id.marine_buy_choices[CAT_ESS] = 0
		sell_rest_of_essential_kit(loadout, user)

/// If one item from essential kit was bought, we sell the rest and put in on the ground
/datum/loadout_seller/proc/sell_rest_of_essential_kit(datum/loadout/loadout, mob/user)
	var/list/job_specific_list = GLOB.loadout_role_essential_set[loadout.job]
	for(var/key in job_specific_list)
		var/item_already_sold = unique_items_list[key]
		while(item_already_sold < job_specific_list[key])
			var/obj/item/item = key
			new item(user.loc)
			item_already_sold++

