/datum/loadout_item/belt
	item_slot = ITEM_SLOT_BELT

/datum/loadout_item/belt/empty
	name = "no belt"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/ammo_belt
	name = "ammo belt"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. This version is the standard variant designed for bulk ammunition-carrying operations."
	item_typepath = /obj/item/storage/belt/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/belt/sparepouch
	name = "G8 storage pouch"
	desc = "A small, lightweight pouch that can be clipped onto Armat Systems M3 Pattern armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines."
	item_typepath = /obj/item/storage/belt/sparepouch
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/shotgun_mixed
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Loaded full of buckshot and flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/mixed
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/smg_holster
	name = "SMG-25 holster"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. It consists of a modular belt with various clips. \
	This version is designed for the SMG-25, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	item_typepath = /obj/item/storage/holster/m25
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/belt/smg_holster/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m25/holstered(wearer), SLOT_IN_HOLSTER)

/datum/loadout_item/belt/machete
	name = "Machete"
	desc = "A large leather scabbard carrying a M2132 machete. It can be strapped to the back, waist or armor. Extremely dangerous against human opponents - if you can get close enough."
	item_typepath = /obj/item/storage/holster/blade/machete/full
	jobs_supported = list(SQUAD_MARINE)

//medic
/datum/loadout_item/belt/lifesaver
	name = "Lifesaver bag"
	desc = "The M276 is the standard load-bearing equipment of the TGMC. This configuration mounts a duffel bag filled with a range of injectors and light medical supplies and is common among medics."
	item_typepath = /obj/item/storage/belt/lifesaver/quick
	jobs_supported = list(SQUAD_CORPSMAN)
