GLOBAL_LIST_INIT(campaign_perk_list, list(
	//perks here
))

/datum/individual_stats
	interaction_flags = INTERACT_UI_INTERACT
	///ckey associated with this datum
	var/ckey
	///currently occupied mob - if any
	var/mob/living/carbon/current_mob //will we actually need this?
	///whatever cash/xp/placeholdershit. fun tokens
	var/currency = 0
	///Player perks
	var/list/datum/perk/perks = list()
	///Unlocked items
	var/list/datum/loadout_item/unlocked_items = list() //probs some initial list here based on class etc.
	///List of loadouts by role
	var/list/datum/outfit/quick/loadouts = list()
	///The faction associated with these stats
	var/faction //will we actually need this? Maybe more relevant to have available perks,but may need for ui, depending on how this is viewed

/datum/individual_stats/New(new_faction, new_currency)
	. = ..()
	faction = new_faction
	currency = new_currency
	loadouts[SQUAD_MARINE] = new /datum/outfit/quick //we'll do some faction based thing to setup a loadout for every role in the faction, as required


/datum/individual_stats/Destroy(force, ...)
	ckey = null
	current_mob = null
	QDEL_NULL(perks)
	QDEL_NULL(unlocked_items)
	return ..()

///uses some funtokens, returns the amount missing, if insufficient funds
/datum/individual_stats/proc/give_funds(amount)
	currency += amount
	if(!current_mob)
		return
	to_chat(current_mob, "<span class='warning'>You have received a cash bonus of [amount].")

///uses some funtokens, returns the amount missing, if insufficient funds
/datum/individual_stats/proc/use_funds(amount)
	if(amount > currency)
		return amount - currency
	currency -= amount

/datum/individual_stats/proc/apply_perks(mob/living/carbon/user)
	for(var/datum/perk/perk AS in perks)
		perk.apply_perk(user)

///Attempts to add an item to a loadout
/datum/individual_stats/proc/attempt_add_loadout_item(datum/loadout_item/new_item, role)
	if(!loadouts[role])
		CRASH("tried to load [new_item] to a nonexistant loadout for role [role]")
	if(length(new_item.item_whitelist) && !new_item.whitelist_check(loadouts[role]))
		return
	if(length(new_item.item_blacklist) && !new_item.blacklist_check(loadouts[role]))
		return
	apply_loadout_item(new_item, loadouts[role])

///Actually adds an item to a loadout
/datum/individual_stats/proc/apply_loadout_item(datum/loadout_item/new_item, datum/outfit/quick/loadout)
	var/slot_bit = new_item.item_slot
	switch(slot_bit) //note, might need to make this new_item, not the item type path, so we can ref cost and other details. Unless we load that somewhere else?
		if(ITEM_SLOT_OCLOTHING)
			loadout.wear_suit = new_item.item_typepath
		if(ITEM_SLOT_ICLOTHING)
			loadout.w_uniform = new_item.item_typepath
		if(ITEM_SLOT_GLOVES)
			loadout.gloves = new_item.item_typepath
		if(ITEM_SLOT_EYES)
			loadout.glasses = new_item.item_typepath
		if(ITEM_SLOT_EARS)
			loadout.ears = new_item.item_typepath
		if(ITEM_SLOT_MASK)
			loadout.mask = new_item.item_typepath
		if(ITEM_SLOT_HEAD)
			loadout.head = new_item.item_typepath
		if(ITEM_SLOT_FEET)
			loadout.shoes = new_item.item_typepath
		if(ITEM_SLOT_ID)
			loadout.id = new_item.item_typepath
		if(ITEM_SLOT_BELT)
			loadout.belt = new_item.item_typepath
		if(ITEM_SLOT_BACK)
			loadout.back = new_item.item_typepath
		if(ITEM_SLOT_R_POCKET)
			loadout.r_store = new_item.item_typepath
		if(ITEM_SLOT_L_POCKET)
			loadout.l_store = new_item.item_typepath
		if(ITEM_SLOT_SUITSTORE)
			loadout.suit_store = new_item.item_typepath
		else
			CRASH("Invalid item slot specified [new_item.item_slot]")
	//do post equip stuff here probs, or when?
