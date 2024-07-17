/datum/loadout_item/belt/som_ammo_belt
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
	)

/datum/loadout_item/belt/som_sparepouch
	name = "Utility pouch"
	desc = "A small, lightweight pouch that can be clipped onto armor or your belt to provide additional storage for miscellaneous gear or box and drum magazines. Made from genuine SOM leather."
	item_typepath = /obj/item/storage/belt/sparepouch/som
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/belt/som_shotgun_mixed
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Made with traditional SOM leather. Loaded full of buckshot and flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/som/mixed
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/belt/som_shotgun_flechette
	name = "Shotgun shell rig"
	desc = "An ammunition belt designed to hold shotgun shells or individual bullets. Made with traditional SOM leather. Loaded full of flechette shells."
	item_typepath = /obj/item/storage/belt/shotgun/som/flechette
	jobs_supported = list(SOM_SQUAD_ENGINEER)

/datum/loadout_item/belt/som_grenades
	name = "Grenade rig"
	desc = "A simple harness system available in many configurations. This version is designed to carry bulk quantities of grenades."
	ui_icon = "grenade"
	item_typepath = /obj/item/storage/belt/grenade/som
	jobs_supported = list(SOM_SQUAD_VETERAN)
	purchase_cost = 80
	quantity = 2

/datum/loadout_item/belt/som_grenades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
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

/datum/loadout_item/belt/som_burst_pistol
	name = "V-11e"
	desc = "The standard sidearm used by the Sons of Mars. A reliable and simple weapon that is often seen on the export market on the outer colonies. \
	Typically chambered in 9mm armor piercing rounds. This one is configures for burstfire, and loaded with extended mags."
	ui_icon = "v11"
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN)

/datum/loadout_item/belt/som_burst_pistol/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/burst(wearer), SLOT_IN_HOLSTER)

/datum/loadout_item/belt/sawn_off
	name = "Sawn-off shotgun"
	desc = "A double barreled shotgun whose barrel has been artificially shortened to reduce range for further CQC potiential. Extremely powerful at close range, but is very difficult to handle."
	req_desc = "Requires a VX-42 culverin or VX-33 caliver with powerpack."
	ui_icon = "sshotgun"
	item_typepath = /obj/item/weapon/gun/shotgun/double/sawn
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/belt/energy_sword
	name = "Energy sword"
	desc = "A SOM energy sword. Designed to cut through armored plate. An uncommon primary weapon, typically seen wielded by so called 'blink assault' troops. \
	Can be used defensively to great effect, mainly against opponents trying to strike you in melee, although some users report varying levels of success in blocking ranged projectiles."
	ui_icon = "machete"
	item_typepath = /obj/item/weapon/energy/sword/som
	loadout_item_flags = NONE
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER)

/datum/loadout_item/belt/som_lifesaver
	name = "S17 lifesaver bag"
	desc = "A belt with heavy origins from the belt used by paramedics and doctors in the old mining colonies."
	ui_icon = "medkit"
	item_typepath = /obj/item/storage/belt/lifesaver/som/quick
	jobs_supported = list(SOM_SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/belt/som_officer_pistol
	name = "VX-12 Serpenta"
	desc = "The 'serpenta' is a volkite energy pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size. \
	Comes in a holster that fits on your waist or armor."
	ui_icon = "vx12"
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/som/serpenta
	jobs_supported = list(SOM_SQUAD_LEADER, SOM_STAFF_OFFICER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_blacklist = list(/obj/item/storage/holster/belt/pistol/m4a3/som/serpenta = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/belt/som_officer_pistol_custom
	name = "VX-12c Serpenta"
	desc = "The 'serpenta' is a volkite energy pistol typically seen in the hands of SOM officers and some NCOs, and is quite dangerous for it's size. \
	This particular weapon appears to be a custom model with improved performance. Comes in a fancy holster that fits on your waist or armor."
	ui_icon = "vx12"
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/som/fancy/fieldcommander
	jobs_supported = list(SOM_FIELD_COMMANDER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_blacklist = list(/obj/item/storage/holster/belt/pistol/m4a3/som/fancy/fieldcommander = ITEM_SLOT_SUITSTORE)
