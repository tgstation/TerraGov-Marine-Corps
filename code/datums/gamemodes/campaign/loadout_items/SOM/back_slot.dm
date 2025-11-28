/datum/loadout_item/back/som_satchel
	name = "Mining satchel"
	desc = "A satchel with origins dating back to the mining colonies.. Carries less than a backpack, but items can be drawn instantly."
	item_typepath = /obj/item/storage/backpack/satchel/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_STAFF_OFFICER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/som_combat_pack
	name = "Mining rucksack"
	desc = "A rucksack with origins dating back to the mining colonies. Has the storage capacity of a backpack but no draw delay."
	purchase_cost = 25
	item_typepath = /obj/item/storage/backpack/lightpack/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN)

/datum/loadout_item/back/som_combat_pack/free
	purchase_cost = 0
	jobs_supported = list(SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/som_flamer_tank
	name = "Flame tank"
	desc = "A specialized fuel tank for use with the V-62 incinerator."
	req_desc = "Requires a V-62 incinerator."
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank
	jobs_supported = list(SOM_SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/som/mag_harness = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/back/som_flamer_tank/x_fuel
	name = "X-fuel tank"
	desc = "A specialized fuel tank of ultra thick napthal type X, known for its extreme heat and slow burn rate, as well as its distinct blue flames. For use with the V-62 incinerator."
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank/X
	purchase_cost = 50
	unlock_cost = 200
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/back/som_engineer_pack
	name = "Welding bag"
	desc = "A technician backpack with integrated welder tank. Has satchel storage."
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_typepath = /obj/item/storage/backpack/marine/engineerpack/som

/datum/loadout_item/back/blinkdrive
	name = "Blink drive"
	desc = "A portable Bluespace Displacement Drive, otherwise known as a blink drive. \
	Can teleport the user across short distances with a degree of unreliability, with potentially fatal results. \
	Teleporting past 5 tiles, to tiles out of sight or rapid use of the drive add variance to the teleportation destination."
	req_desc = "Requires an energy sword or V-21 SMG."
	item_typepath = /obj/item/blink_drive
	jobs_supported = list(SOM_SQUAD_VETERAN)
	quantity = 2
	item_whitelist = list(
		/obj/item/weapon/energy/sword/som = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/smg/som/veteran = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/back/som_shotgun
	name = "V-51"
	desc = "Equipped with a mag harness, bayonet and undebarrel flashlight. The V-51 is the main shotgun utilised by the Sons of Mars. \
	Semi automatic with great handling and mobility, it is less powerful than the SH-35 used by the TGMC, but makes up for it with a superior rate of fire. \
	Uses 12 gauge shells."
	ui_icon = "v51"
	purchase_cost = 25
	item_typepath = /obj/item/weapon/gun/shotgun/som/back_slot
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER)
	loadout_item_flags = NONE

/datum/loadout_item/back/som_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot, SLOT_R_HAND)

/datum/loadout_item/back/som_rocket_bag
	name = "RPG bag"
	desc = "This backpack holds 4 RPGs, in addition to a V-71 RPG launcher. Equipped with radioactive and incendiary warheads, \
	the V-71 is incredibly effective at softening up or flushing out organic targets, making them easy prey to finish off. Has a draw delay."
	req_desc = "Requires a suit with a Mithridatius environmental protection module."
	ui_icon = "rpg"
	purchase_cost = 50
	quantity = 2
	item_typepath = /obj/item/storage/holster/backholster/rpg/som/war_crimes
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/mithridatius = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/back/som_heat_rocket_bag
	name = "HEAT RPG bag"
	desc = "Unlocked for free with the Heavy weapon specialisation perk. This backpack holds 4 high explosive anti armor RPGs, in addition to a V-71 RPG launcher. Deals significant damage against vehicles and mechs, but will also generally devastate human victims in a pinch. \
	Has a draw delay and has poor accuracy against human targets."
	ui_icon = "rpg"
	unlock_cost = 300
	purchase_cost = 100
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE
	quantity = 2
	item_typepath = /obj/item/storage/holster/backholster/rpg/som/heat
	jobs_supported = list(SOM_SQUAD_VETERAN)

/datum/loadout_item/back/volkite_powerpack
	name = "M-70 powerpack"
	desc = "A heavy reinforced backpack with an array of ultradensity energy cells, linked to a miniature radioisotope thermoelectric generator for continuous power generation. \
	Used to power the largest man portable volkite weaponry. Click drag cells to the powerpack to recharge."
	req_desc = "Requires a VX-42 culverin or VX-33 caliver."
	item_typepath = /obj/item/cell/lasgun/volkite/powerpack
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/back/boarding_axe
	name = "Boarding axe"
	desc = "A SOM boarding axe, a monstrous two handed weapon that inflicts terrible damage even through heavy armor. \
	When wielded it can be used to block as well as attack, and can also be used to force unpowered airlocks open. \
	You'll kill pretty much anything you can hit with this - providing you can get close enough to use it."
	ui_icon = "axe"
	item_typepath = /obj/item/weapon/twohanded/fireaxe/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	item_blacklist = list(/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_SUITSTORE)
	loadout_item_flags = NONE
