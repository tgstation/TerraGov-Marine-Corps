/datum/loadout_item/belt/som
	item_blacklist = list(
		/obj/item/weapon/gun/shotgun/double/sawn = ITEM_SLOT_SECONDARY,
		/obj/item/weapon/energy/sword/som = ITEM_SLOT_SECONDARY,
	)


/datum/loadout_item/belt/som/ammo_belt
	name = "Ammo belt"
	desc = "A belt with origins traced to the M276 ammo belt and some old colony security. Holds 6 normal sized magazines."
	item_typepath = /obj/item/storage/belt/marine/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_blacklist = list(
		/obj/item/weapon/gun/rifle/som_mg/standard = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/flamer/som/mag_harness = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/som/standard = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/som/support = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/double/sawn = ITEM_SLOT_SECONDARY,
		/obj/item/weapon/energy/sword/som = ITEM_SLOT_SECONDARY,
	)

/datum/loadout_item/belt/som/sparepouch
	name = "Utility pouch"
	desc = "A small, lightweight pouch that can be clipped onto armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines. Made from genuine SOM leather."
	item_typepath = /obj/item/storage/belt/sparepouch/som
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/belt/som/shotgun_mixed
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Made with traditional SOM leather. Loaded full of buckshot and flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/som/mixed
	jobs_supported = list(SOM_SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/weapon/gun/shotgun/som/standard = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/som/support = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/som/back_slot = ITEM_SLOT_BACK,
	)

/datum/loadout_item/belt/som/shotgun_flechette
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Made with traditional SOM leather. Loaded full of flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/som/flechette
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	item_whitelist = list(
		/obj/item/weapon/gun/shotgun/som/standard = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/som/support = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/shotgun/som/back_slot = ITEM_SLOT_BACK,
	)

/datum/loadout_item/belt/som/grenades
	name = "Grenade rig"
	desc = "A simple harness system available in many configurations. This version is designed to carry bulk quantities of grenades."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/belt/grenade/som
	jobs_supported = list(SOM_SQUAD_VETERAN)
	purchase_cost = 80
	quantity = 2

/datum/loadout_item/belt/som/grenades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BELT)

/datum/loadout_item/belt/som/pistol_holster
	name = "Pistol holster"
	desc = "A belt with origins dating back to old colony security holster rigs. Holds any pistol secondary, and plenty of ammo."
	ui_icon = "v11"
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER)
	item_whitelist = list(
		/obj/item/weapon/gun/pistol/som/standard = ITEM_SLOT_SECONDARY,
		/obj/item/weapon/gun/pistol/som/burst = ITEM_SLOT_SECONDARY,
		/obj/item/weapon/gun/pistol/highpower/standard = ITEM_SLOT_SECONDARY,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = ITEM_SLOT_SECONDARY,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom = ITEM_SLOT_SECONDARY,
	)
	req_desc = "Requires a pistol secondary."

/datum/loadout_item/belt/som/pistol_holster/default
	jobs_supported = list(SOM_STAFF_OFFICER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/som/pistol_holster/officer
	desc = "A quality pistol belt of a style typically seen worn by SOM officers. It looks old, but well looked after. Holds any pistol secondary, and plenty of ammo."
	ui_icon = "vx12"
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/som/fancy
	jobs_supported = list(SOM_FIELD_COMMANDER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/som/lifesaver
	name = "S17 lifesaver bag"
	desc = "A belt with heavy origins from the belt used by paramedics and doctors in the old mining colonies."
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/belt/lifesaver/som/quick
	jobs_supported = list(SOM_SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
