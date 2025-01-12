///Available by default
#define LOADOUT_ITEM_ROUNDSTART_OPTION (1<<0)
///This is the default option for this slot
#define LOADOUT_ITEM_DEFAULT_CHOICE (1<<1)
///Available for unlock by default
#define LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE (1<<2)

#define LOADOUT_ITEM_MG27 /obj/item/weapon/gun/standard_mmg/machinegunner
#define LOADOUT_ITEM_TGMC_FLAMER /obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide
#define LOADOUT_ITEM_TGMC_MINIGUN /obj/item/weapon/gun/minigun/magharness

GLOBAL_LIST_INIT(campaign_loadout_slots, list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_EYES, ITEM_SLOT_EARS, \
ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_FEET, ITEM_SLOT_ID, ITEM_SLOT_BELT, ITEM_SLOT_BACK, ITEM_SLOT_L_POCKET, ITEM_SLOT_R_POCKET, ITEM_SLOT_SUITSTORE, ITEM_SLOT_SECONDARY))

//List of all loadout_item datums
GLOBAL_LIST_INIT_TYPED(campaign_loadout_item_type_list, /datum/loadout_item, init_glob_loadout_item_list())

/proc/init_glob_loadout_item_list()
	. = list()
	for(var/type in subtypesof(/datum/loadout_item))
		var/datum/loadout_item/item_type = new type
		if(!length(item_type.jobs_supported))
			qdel(item_type)
			continue
		.[item_type.type] = item_type

//List of all loadout_item datums by job, excluding ones that must be unlocked //now including those
GLOBAL_LIST_INIT(campaign_loadout_items_by_role, init_campaign_loadout_items_by_role())

/proc/init_campaign_loadout_items_by_role()
	. = list()
	for(var/job in GLOB.campaign_jobs)
		.[job] = list()
		for(var/i in GLOB.campaign_loadout_item_type_list)
			var/datum/loadout_item/option = GLOB.campaign_loadout_item_type_list[i]
			if(option.jobs_supported && !(job in option.jobs_supported))
				continue
			.[job] += option

//represents an equipable item
//Are singletons
/datum/loadout_item
	///Item name
	var/name
	///Item desc
	var/desc
	///Addition desc for special reqs such as black/whitelist
	var/req_desc
	///Typepath of the actual item this datum represents
	var/obj/item/item_typepath
	///UI icon for this item
	var/ui_icon = "default"
	///inventory slot it is intended to go into
	var/item_slot
	///Behavior flags for loadout items
	var/loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION
	///Cost to unlock this option
	var/unlock_cost = 0
	///Cost to use this option
	var/purchase_cost = 0
	///The amount of this available per mission. -1 for unlimited
	var/quantity = -1
	///Job types that this perk is available to
	var/list/jobs_supported
	///assoc list by slot of items required for this to be equipped. Requires only 1 out of the list
	var/list/item_whitelist
	///assoc list by slot of items blacklisted for this to be equipped
	var/list/item_blacklist

///Attempts to add an item to a loadout
/datum/loadout_item/proc/item_checks(datum/outfit_holder/outfit_holder)
	if(length(item_whitelist) && !whitelist_check(outfit_holder))
		return FALSE
	if(length(item_blacklist) && !blacklist_check(outfit_holder))
		return FALSE
	return TRUE

///checks if a loadout has one or more whitelist items
/datum/loadout_item/proc/whitelist_check(datum/outfit_holder/outfit_holder)
	for(var/whitelist_item in item_whitelist)
		var/type_to_check = outfit_holder.equipped_things["[item_whitelist[whitelist_item]]"]?.item_typepath
		if(type_to_check == whitelist_item)
			return TRUE
	return FALSE

///Checks if a loadout has any blacklisted items
/datum/loadout_item/proc/blacklist_check(datum/outfit_holder/outfit_holder)
	for(var/blacklist_item in item_blacklist)
		var/type_to_check = outfit_holder.equipped_things["[item_blacklist[blacklist_item]]"]?.item_typepath
		if(type_to_check == blacklist_item)
			return FALSE
	return TRUE

///Any additional behavior when this datum is equipped to an outfit_holder
/datum/loadout_item/proc/on_holder_equip(datum/outfit_holder)
	//if there is a single whitelist item, this is a guaranteed mandatory prereq for src, so we autoequip for player QOL
	if(length(item_whitelist) != 1)
		return
	for(var/item in item_whitelist)
		equip_mandatory_item(outfit_holder, item, item_whitelist[item])

///Any post equip things related to this item
/datum/loadout_item/proc/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	role_post_equip(wearer, loadout, holder)

///A separate post equip proc for role specific code. Split for more flexible parent overriding
/datum/loadout_item/proc/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	return

///Equips a mandatory item when src is equipt for player convenience
/datum/loadout_item/proc/equip_mandatory_item(datum/outfit_holder/outfit_holder, mandatory_type, mandatory_slot)
	if(!mandatory_slot || !mandatory_type || !outfit_holder)
		return
	if(outfit_holder.equipped_things["[mandatory_slot]"]?.item_typepath == mandatory_type)
		return
	for(var/datum/loadout_item/item AS in outfit_holder.available_list["[mandatory_slot]"])
		if(item.item_typepath != mandatory_type)
			continue
		outfit_holder.equip_loadout_item(item)
