//r_pocket
/datum/loadout_item/r_pocket
	item_slot = ITEM_SLOT_R_POCKET

/datum/loadout_item/r_pocket/empty
	name = "no right pocket"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_CORPSMAN,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		STAFF_OFFICER,
		CAPTAIN,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_CORPSMAN,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
		SOM_STAFF_OFFICER,
		SOM_COMMANDER,
	)


/datum/loadout_item/r_pocket/standard_first_aid
	name = "First aid pouch"
	desc = "Standard marine first-aid pouch. Contains a basic set of medical supplies."
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER)

/datum/loadout_item/r_pocket/standard_first_aid/improved
	desc = "Standard marine first-aid pouch. Contains a improved set of medical supplies."
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol_leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/r_pocket/marine_standard_grenades
	name = "Grenade pouch"
	desc = "A pouch carrying a set of six standard support grenades."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/grenade/combat_patrol
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/r_pocket/shotgun
	name = "Buckshot shells"
	desc = "A pouch specialized for holding shotgun ammo. Contains buckshot shells."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/shotgun
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)

/datum/loadout_item/r_pocket/marine_construction
	name = "Construction pouch"
	desc = "A pouch containing an assortment of construction supplies. Allows for the rapid establishment of fortified positions."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/construction
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/r_pocket/marine_construction/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/half, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_R_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/full, SLOT_IN_R_POUCH)

/datum/loadout_item/r_pocket/magazine
	name = "Magazine pouch"
	desc = "A pouch containing three ammo magazines."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/magazine/large
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	item_blacklist = list(
		/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/minigun/smart_minigun/motion_detector = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/r_pocket/tools
	name = "Tool pouch"
	desc = "It's designed to hold maintenance tools - screwdriver, wrench, cable coil, etc. It also has a hook for an entrenching tool."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/tools/full
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/r_pocket/general
	name = "General pouch"
	desc = "A general purpose pouch used to carry small items."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/general/large
	jobs_supported = list(STAFF_OFFICER, CAPTAIN)

//l_pocket
/datum/loadout_item/l_pocket
	item_slot = ITEM_SLOT_L_POCKET

/datum/loadout_item/l_pocket/empty
	name = "no left pocket"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_CORPSMAN,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		STAFF_OFFICER,
		CAPTAIN,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_CORPSMAN,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
		SOM_STAFF_OFFICER,
		SOM_COMMANDER,
	)


/datum/loadout_item/l_pocket/standard_first_aid
	name = "First aid pouch"
	desc = "Standard marine first-aid pouch. Contains a basic set of medical supplies."
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/l_pocket/standard_first_aid/improved
	desc = "Standard marine first-aid pouch. Contains a improved set of medical supplies."
	item_typepath = /obj/item/storage/pouch/firstaid/combat_patrol_leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/l_pocket/marine_standard_grenades
	name = "Grenade pouch"
	desc = "A pouch carrying a set of six standard support grenades. Includes smoke grenades of both lethal and nonlethal varieties, as well as stun grenades."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/grenade/combat_patrol
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/l_pocket/shotgun
	name = "Flechette shells"
	desc = "A pouch specialized for holding shotgun ammo. Contains Flechette shells."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/shotgun
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_L_POUCH)

/datum/loadout_item/l_pocket/marine_construction
	name = "Construction pouch"
	desc = "A pouch containing an assortment of construction supplies. Allows for the rapid establishment of fortified positions."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/construction
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/l_pocket/marine_construction/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/half, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_L_POUCH)
	wearer.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/full, SLOT_IN_L_POUCH)

/datum/loadout_item/l_pocket/magazine
	name = "Magazine pouch"
	desc = "A pouch containing three ammo magazines."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/magazine/large
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	item_blacklist = list(
		/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/minigun/smart_minigun/motion_detector = ITEM_SLOT_SUITSTORE,
	)


/datum/loadout_item/l_pocket/magazine/medic
	jobs_supported = list(SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/l_pocket/general
	name = "General pouch"
	desc = "A general purpose pouch used to carry small items."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/pouch/general/large
	jobs_supported = list(STAFF_OFFICER, CAPTAIN)
