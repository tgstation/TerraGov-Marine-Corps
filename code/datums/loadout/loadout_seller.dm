/**
 * Small loadout in charge of dealing with a user trying to equip a saved loadout
 * First it will reserve all items that can be bought, and save the name of all items that cannot be bought
 * If the list of items that cannot be bought is empty, the transaction will be automaticly accepted and the loadout will be equipped on the user
 * If it's not empty, it will warn the user and give him the list of non-buyable items.
 * The user can chose to proceed with the buy, and he is equipped with what was already be bought, 
 * or he can chose to refuse, and then the items are put back in the vendors
 */
/datum/loadout_seller
	var/list/unavailable_items = list()