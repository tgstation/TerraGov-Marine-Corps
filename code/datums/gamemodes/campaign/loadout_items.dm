#define campaign_loadout_slots list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_EYES, ITEM_SLOT_EARS, \
ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_FEET, ITEM_SLOT_ID, ITEM_SLOT_BELT, ITEM_SLOT_BACK, ITEM_SLOT_R_POCKET, ITEM_SLOT_L_POCKET, ITEM_SLOT_SUITSTORE)

//List of all loadout_item datums
GLOBAL_LIST_INIT_TYPED(campaign_loadout_item_type_list, /datum/loadout_item, init_glob_loadout_item_list())

/proc/init_glob_loadout_item_list()
	. = list()
	for(var/type in subtypesof(/datum/loadout_item))
		var/datum/loadout_item/item_type = new type
		.[item_type.type] = item_type

//List of all loadout_item datums by job, excluding ones that must be unlocked
GLOBAL_LIST_INIT(campaign_loadout_items_by_role, list(
	SQUAD_MARINE = list(),
	SQUAD_ENGINEER = list(),
	SQUAD_CORPSMAN = list(),
	SQUAD_SMARTGUNNER = list(),
	SQUAD_LEADER = list(),
	FIELD_COMMANDER = list(),
	STAFF_OFFICER = list(),
	CAPTAIN = list(),
	SOM_SQUAD_MARINE = list(),
	SOM_SQUAD_ENGINEER = list(),
	SOM_SQUAD_CORPSMAN = list(),
	SOM_SQUAD_VETERAN = list(),
	SOM_SQUAD_LEADER = list(),
	SOM_FIELD_COMMANDER = list(),
	SOM_STAFF_OFFICER = list(),
	SOM_COMMANDER = list(),
))

/proc/init_campaign_loadout_items_by_role()
	. = list(
	SQUAD_MARINE = list(),
	SQUAD_ENGINEER = list(),
	SQUAD_CORPSMAN = list(),
	SQUAD_SMARTGUNNER = list(),
	SQUAD_LEADER = list(),
	FIELD_COMMANDER = list(),
	STAFF_OFFICER = list(),
	CAPTAIN = list(),
	SOM_SQUAD_MARINE = list(),
	SOM_SQUAD_ENGINEER = list(),
	SOM_SQUAD_CORPSMAN = list(),
	SOM_SQUAD_VETERAN = list(),
	SOM_SQUAD_LEADER = list(),
	SOM_FIELD_COMMANDER = list(),
	SOM_STAFF_OFFICER = list(),
	SOM_COMMANDER = list(),
)
	for(var/role in .)
		for(var/datum/loadout_item/option AS in GLOB.campaign_loadout_item_type_list)
			if(!option.round_start_option)
				continue
			if(option.jobs_supported && !(role in option.jobs_supported))
				continue
			.[role] += option

//represents an equipable item
//Are singletons
/datum/loadout_item
	///Item name
	var/name = "item name here"
	///Item desc
	var/desc = "item desc here"
	///Typepath of the actual item this datum represents
	var/item_typepath
	///inventory slot it is intended to go into
	var/item_slot
	///Available at round start or must be unlocked somehow
	var/round_start_option = TRUE
	///Cost to unlock this option
	var/unlock_cost = 0
	///Cost to use this option
	var/purchase_cost = 0
	///Job types that this perk is available to. no list implies this works for any job
	var/list/jobs_supported
	///assoc list by slot of items required for this to be equipped
	var/list/item_whitelist
	///assoc list by slot of items blacklisted for this to be equipped
	var/list/item_blacklist
	//do we need a post equip gear list?

///Attempts to add an item to a loadout
/datum/loadout_item/proc/item_checks(datum/outfit_holder/outfit_holder)
	if(length(item_whitelist) && !whitelist_check(outfit_holder))
		return FALSE
	if(length(item_blacklist) && !blacklist_check(outfit_holder))
		return FALSE
	return TRUE

///checks if a loadout has required whitelist items
/datum/loadout_item/proc/whitelist_check(datum/outfit_holder/outfit_holder)
	for(var/slot in item_whitelist)
		var/type_to_check = outfit_holder.equipped_things[slot].item_typepath
		if(!type_to_check || type_to_check != item_whitelist[slot])
			return FALSE
	return TRUE

///Checks if a loadout has any blacklisted items
/datum/loadout_item/proc/blacklist_check(datum/outfit_holder/outfit_holder)
	for(var/slot in item_blacklist)
		var/type_to_check = outfit_holder.equipped_things[slot].item_typepath
		if(type_to_check == item_blacklist[slot])
			return FALSE
	return TRUE

//suits
/datum/loadout_item/suit_slot
	item_slot = ITEM_SLOT_OCLOTHING

/datum/loadout_item/suit_slot/heavy_shield
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_surt
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/suit_slot/medium_mimir
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/mimir
	jobs_supported = list(SQUAD_CORPSMAN)

//helmets
/datum/loadout_item/helmet
	item_slot = ITEM_SLOT_HEAD

/datum/loadout_item/helmet/standard
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/head/modular/m10x
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/helmet/leader
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/head/modular/m10x/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/helmet/surt
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/head/modular/m10x/surt
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		ITEM_SLOT_OCLOTHING = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	)

/datum/loadout_item/helmet/mimir
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/head/modular/m10x/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	item_whitelist = list(
		ITEM_SLOT_OCLOTHING = /obj/item/clothing/suit/modular/xenonauten/mimir
	)
