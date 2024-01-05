///Available by default
#define LOADOUT_ITEM_ROUNDSTART_OPTION (1<<0)
///This is the default option for this slot
#define LOADOUT_ITEM_DEFAULT_CHOICE (1<<1)
///Available for unlock by default
#define LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE (1<<2)

GLOBAL_LIST_INIT(campaign_loadout_slots, list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_EYES, ITEM_SLOT_EARS, \
ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_FEET, ITEM_SLOT_ID, ITEM_SLOT_BELT, ITEM_SLOT_BACK, ITEM_SLOT_R_POCKET, ITEM_SLOT_L_POCKET, ITEM_SLOT_SUITSTORE))

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
			//if(!(option.loadout_item_flags & LOADOUT_ITEM_ROUNDSTART_OPTION) && !(option.loadout_item_flags & LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE))
			//	continue
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
	var/ui_icon = "b18" //placeholder
	///inventory slot it is intended to go into
	var/item_slot

	var/loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION
	///Cost to unlock this option
	var/unlock_cost = 0
	///Cost to use this option
	var/purchase_cost = 0
	///The amount of this available per mission. -1 for unlimited
	var/quantity = -1
	///Job types that this perk is available to
	var/list/jobs_supported
	///assoc list by slot of items required for this to be equipped
	var/list/item_whitelist
	///assoc list by slot of items blacklisted for this to be equipped
	var/list/item_blacklist
	//do we need a post equip gear list?

/datum/loadout_item/New()
	. = ..()
	if(loadout_item_flags & LOADOUT_ITEM_DEFAULT_CHOICE)
		jobs_supported = GLOB.campaign_jobs

///Attempts to add an item to a loadout
/datum/loadout_item/proc/item_checks(datum/outfit_holder/outfit_holder)
	if(length(item_whitelist) && !whitelist_check(outfit_holder))
		return FALSE
	if(length(item_blacklist) && !blacklist_check(outfit_holder))
		return FALSE
	return TRUE

///checks if a loadout has required whitelist items
/datum/loadout_item/proc/whitelist_check(datum/outfit_holder/outfit_holder)
	for(var/whitelist_item in item_whitelist)
		var/type_to_check = outfit_holder.equipped_things["[item_whitelist[whitelist_item]]"]?.item_typepath
		if(!type_to_check || type_to_check != whitelist_item)
			return FALSE
	return TRUE

///Checks if a loadout has any blacklisted items
/datum/loadout_item/proc/blacklist_check(datum/outfit_holder/outfit_holder)
	for(var/blacklist_item in item_blacklist)
		var/type_to_check = outfit_holder.equipped_things["[item_blacklist[blacklist_item]]"]?.item_typepath
		if(type_to_check == blacklist_item)
			return FALSE
	return TRUE

//suits
/datum/loadout_item/suit_slot
	item_slot = ITEM_SLOT_OCLOTHING

/datum/loadout_item/suit_slot/empty
	name = "no suit"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/heavy_shield
	name = "Heavy shielded armor"
	desc = "Heavy armor with a Svallin shield module. Provides excellent protection but lower mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_surt
	name = "Heavy Surt armor"
	desc = "Heavy armor with a Surt fireproof module. Provides excellent protection and almost total fire immunity, but has poor mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	jobs_supported = list(SQUAD_MARINE)
	quantity = 1 //testing purposes only

/datum/loadout_item/suit_slot/medium_mimir
	name = "Medium Mimir armor"
	desc = "Medium armor with a Mimir environmental protection module. Provides respectable armor and total immunity to chemical attacks, and improved radiological protection. Has modest mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/mimir
	jobs_supported = list(SQUAD_CORPSMAN)

//helmets
/datum/loadout_item/helmet
	item_slot = ITEM_SLOT_HEAD

/datum/loadout_item/helmet/empty
	name = "no helmet"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/standard
	name = "M10X helmet"
	desc = "A standard TGMC combat helmet. Apply to head for best results."
	item_typepath = /obj/item/clothing/head/modular/m10x
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/helmet/leader
	name = "M11X helmet"
	desc = "An upgraded helmet for protecting upgraded brains."
	item_typepath = /obj/item/clothing/head/modular/m10x/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/helmet/surt
	name = "M10X-Surt helmet"
	desc = "A standard combat helmet with a Surt fireproof module."
	req_desc = "Requires a suit with a Surt module."
	item_typepath = /obj/item/clothing/head/modular/m10x/surt
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		//"[ITEM_SLOT_OCLOTHING]" = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
		/obj/item/clothing/suit/modular/xenonauten/heavy/surt = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/helmet/mimir
	name = "M10X-Mimir helmet"
	desc = "A standard combat helmet with a Mimir environmental protection module."
	item_typepath = /obj/item/clothing/head/modular/m10x/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	item_whitelist = list(
		//"[ITEM_SLOT_OCLOTHING]" = /obj/item/clothing/suit/modular/xenonauten/mimir
		/obj/item/clothing/suit/modular/xenonauten/mimir = ITEM_SLOT_OCLOTHING,
	)




//uniform
/datum/loadout_item/uniform
	item_slot = ITEM_SLOT_ICLOTHING

/datum/loadout_item/uniform/empty
	name = "no uniform"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/uniform/marine_standard
	name = "TGMC uniform"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/under/marine/black_vest
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/uniform/marine_corpsman
	name = "corpsman fatigues"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/under/marine/corpsman/corpman_vest
	jobs_supported = list(SQUAD_MARINE)

//gloves
/datum/loadout_item/gloves
	item_slot = ITEM_SLOT_GLOVES

/datum/loadout_item/gloves/empty
	name = "no gloves"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/marine_gloves
	name = "Standard combat gloves"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/gloves/marine
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/gloves/marine_black_gloves
	name = "Black combat gloves"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/gloves/marine/black
	jobs_supported = list(SQUAD_MARINE)

//eyes
/datum/loadout_item/eyes
	item_slot = ITEM_SLOT_EYES

/datum/loadout_item/eyes/empty
	name = "no eyewear"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/eyes/health_hud
	name = "HealthMate HUD"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/glasses/hud/health
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/eyes/mesons
	name = "optical meson scanner"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/glasses/meson
	jobs_supported = list(SQUAD_MARINE)
	purchase_cost = 12 //test only

//ears
/datum/loadout_item/ears
	item_slot = ITEM_SLOT_EARS

/datum/loadout_item/ears/empty
	name = "no headset"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/ears/marine_standard
	name = "Standard headset"
	desc = "item desc here"
	item_typepath = /obj/item/radio/headset/mainship/marine
	jobs_supported = list(SQUAD_MARINE)

//mask
/datum/loadout_item/mask
	item_slot = ITEM_SLOT_MASK

/datum/loadout_item/mask/empty
	name = "no mask"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/mask/standard
	name = "Standard gas mask"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/mask/gas
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/mask/tactical
	name = "Tactical gas mask"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/mask/gas/tactical
	jobs_supported = list(SQUAD_MARINE)

//feet
/datum/loadout_item/feet
	item_slot = ITEM_SLOT_FEET

/datum/loadout_item/feet/empty
	name = "no footwear"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/feet/marine_boots
	name = "Combat boots"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/shoes/marine/full
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/feet/marine_brown_boots
	name = "Brown combat boots"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/shoes/marine/brown/full
	jobs_supported = list(SQUAD_MARINE)

//belt
/datum/loadout_item/belt
	item_slot = ITEM_SLOT_BELT

/datum/loadout_item/belt/empty
	name = "no belt"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/t12_ammo
	name = "T12 ammo belt"
	desc = "item desc here"
	item_typepath = /obj/item/storage/belt/marine/t12
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/te_cell_ammo //will likely be loaded in post equip later
	name = "TE cell ammo belt"
	desc = "item desc here"
	item_typepath = /obj/item/storage/belt/marine/te_cells
	jobs_supported = list(SQUAD_MARINE)

//back
/datum/loadout_item/back
	item_slot = ITEM_SLOT_BACK

/datum/loadout_item/back/empty
	name = "no backpack"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/marine_satchel
	name = "Satchel"
	desc = "item desc here"
	item_typepath = /obj/item/storage/backpack/marine/satchel
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/back/flamer_tank
	name = "Flame tank"
	desc = "item desc here"
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank
	jobs_supported = list(SQUAD_MARINE)

//r_pocket
/datum/loadout_item/r_pocket
	item_slot = ITEM_SLOT_R_POCKET

/datum/loadout_item/r_pocket/empty
	name = "no right pocket"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/r_pocket/standard_first_aid
	name = "First aid pouch"
	desc = "item desc here"
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/marine_standard_grenades
	name = "Standard grenades"
	desc = "item desc here"
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/grenade/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

//l_pocket
/datum/loadout_item/l_pocket
	item_slot = ITEM_SLOT_L_POCKET

/datum/loadout_item/l_pocket/empty
	name = "no left pocket"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/l_pocket/standard_first_aid
	name = "First aid pouch"
	desc = "item desc here"
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/marine_standard_grenades
	name = "Standard grenades"
	desc = "item desc here"
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/grenade/combat_patrol
	jobs_supported = list(SQUAD_MARINE)

//suit_store
/datum/loadout_item/suit_store
	item_slot = ITEM_SLOT_SUITSTORE

/datum/loadout_item/suit_store/empty
	name = "no suit stored"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/standard_rifle
	name = "AR12"
	desc = "item desc here"
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/suit_store/laser_rifle
	name = "Laser rifle"
	desc = "item desc here"
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	jobs_supported = list(SQUAD_MARINE)
	unlock_cost = 2
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE
