/datum/loadout_item/secondary_weapon/gun/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)
	item_whitelist = list(
		/obj/item/storage/holster/belt/pistol/standard_pistol = ITEM_SLOT_BELT,
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/engineerpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/tech = ITEM_SLOT_BACK,
	)

/datum/loadout_item/secondary_weapon/gun/marine/standard_pistol
	name = "P-14"
	desc = "The P-14, produced by Terran Armories. A reliable sidearm that loads 9x19mm Parabellum Auto munitions. Has a good rate of fire and takes 21-round 9mm magazines."
	ui_icon = "tp14"
	item_typepath = /obj/item/weapon/gun/pistol/standard_pistol
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary_weapon/gun/marine/standard_heavypistol
	name = "P-23"
	desc = "A standard P-23 chambered in .45 ACP. Has a smaller magazine capacity, but packs a better punch. Has an irremovable laser sight. Uses .45 magazines."
	ui_icon = "tp23"
	item_typepath = /obj/item/weapon/gun/pistol/standard_heavypistol/tactical

/datum/loadout_item/secondary_weapon/gun/marine/mod_four
	name = "MK88 Mod 4"
	desc = "An uncommon automatic handgun that fires 9mm armor piercing rounds and is capable of 3-round burst or automatic fire. \
	Light and easy to use one handed, but still a sidearm. Comes in a holster that fits on your waist or armor. Uses 9mm AP ammunition."
	ui_icon = "vp70"
	item_typepath = /obj/item/weapon/gun/pistol/vp70/tactical

/datum/loadout_item/secondary_weapon/gun/marine/standard_revolver
	name = "TP-44"
	desc = "The R-44 standard combat revolver, produced by Terran Armories. A sturdy and hard hitting firearm that loads .44 Magnum rounds. \
	Holds 7 rounds in the cylinder. Due to an error in the cylinder rotation system the fire rate of the gun is much faster than intended, it ended up being billed as a feature of the system."
	ui_icon = "tp44"
	item_typepath = /obj/item/weapon/gun/revolver/standard_revolver

/datum/loadout_item/secondary_weapon/gun/marine/highpower
	name = "Highpower"
	desc = "A powerful semi-automatic pistol chambered in the devastating .50 AE caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	ui_icon = "highpower"
	item_typepath = /obj/item/weapon/gun/pistol/highpower

/datum/loadout_item/secondary_weapon/gun/marine/laser_pistol
	name = "TE-P"
	desc = "A TerraGov standard issue laser pistol abbreviated as TE-P. It has an integrated charge selector for normal, heat and taser settings. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "default"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol

/datum/loadout_item/secondary_weapon/gun/marine/standard_machinepistol
	name = "MP-19"
	desc = "The MP-19 is the TerraGov Marine Corps standard-issue machine pistol. It's known for it's low recoil and scatter when used one handed. \
	It's usually carried by specialized troops who do not have the space to carry a much larger gun like medics and engineers. It uses 10x20mm caseless rounds."
	ui_icon = "t19"
	item_typepath = /obj/item/weapon/gun/smg/standard_machinepistol/compact
	item_whitelist = list(
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
	)

/datum/loadout_item/secondary_weapon/gun/marine/standard_machinepistol/scanner
	name = "MP-19-m"
	desc = "Equipped with a motion sensor. The MP-19 is the TerraGov Marine Corps standard-issue machine pistol. It's known for it's low recoil and scatter when used one handed. \
	It's usually carried by specialized troops who do not have the space to carry a much larger gun like medics and engineers. It uses 10x20mm caseless rounds."
	item_typepath = /obj/item/weapon/gun/smg/standard_machinepistol/scanner

/datum/loadout_item/secondary_weapon/gun/marine/standard_smg
	name = "SMG-25"
	desc = "The RivArms SMG-25 submachinegun, an update to a classic design. A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine."
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/holstered
	item_whitelist = list(/obj/item/storage/holster/m25 = ITEM_SLOT_BELT)
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/gun/marine/standard_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	var/datum/loadout_item/suit_store/main_gun/primary = holder.equipped_things["[ITEM_SLOT_SUITSTORE]"]
	var/obj/item/storage/pouch/magazine/mag_pouch = wearer.r_store
	var/ammo_type = /obj/item/ammo_magazine/smg/m25
	if(istype(mag_pouch) && (!istype(primary) || !(primary.ammo_type in mag_pouch.storage_datum.can_hold)))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
	mag_pouch = wearer.l_store
	if(wearer.skills.getRating(SKILL_SMGS) >= SKILL_SMGS_TRAINED)
		ammo_type = /obj/item/ammo_magazine/smg/m25/ap
	if(istype(mag_pouch) && (!istype(primary) || !(primary.ammo_type in mag_pouch.storage_datum.can_hold)))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)

//kits
/datum/loadout_item/secondary_weapon/kit
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
	)

/datum/loadout_item/secondary_weapon/kit/primary_ammo
	name = "Extra ammo"
	desc = "Additional ammo for your primary weapon."
	ui_icon = "default"
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/kit/primary_ammo/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	var/datum/loadout_item/suit_store/main_gun/primary = holder.equipped_things["[ITEM_SLOT_SUITSTORE]"]
	wearer.equip_to_slot_or_del(new primary.secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new primary.secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/emp_nades
	name = "EMP nades"
	desc = "Three EMP grenades, excellent against energy weapons and mechs."
	ui_icon = "grenade"

/datum/loadout_item/secondary_weapon/kit/emp_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/mirage_nades
	name = "Mirage nades"
	desc = "Three mirage grenades, can provide a handy distraction against unwitting opponents."
	ui_icon = "grenade"

/datum/loadout_item/secondary_weapon/kit/mirage_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/he_nades
	name = "HE nades"
	desc = "Three HE grenades, for a bit more bang."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER) //todo: make SOM subtype

/datum/loadout_item/secondary_weapon/kit/he_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/stun_nades
	name = "Stun nades"
	desc = "Three stun grenades, able to stagger, slow, and temporarily blind victims."
	ui_icon = "stun_nade"

/datum/loadout_item/secondary_weapon/kit/stun_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/sandbags
	name = "Sandbags"
	desc = "Bags, filled with sand. They catch bullets instead of your face."
	ui_icon = "construction"

/datum/loadout_item/secondary_weapon/kit/sandbags/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/cameras
	name = "Cameras"
	desc = "Two deployable cameras and a hud tablet. Useful for watching things remotely, and your command officers might appreciate it as well."
	ui_icon = "construction"
	jobs_supported = list(SQUAD_LEADER)

/datum/loadout_item/secondary_weapon/kit/cameras/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK) //todo: hook mission end signal to kill these
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet(wearer, /datum/job/terragov/squad/leader, wearer.assigned_squad), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)


/datum/loadout_item/secondary_weapon/kit/tgmc_engineer
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/secondary_weapon/kit/tgmc_engineer/sentry
	name = "Sentry gun"
	desc = "A point defence sentry gun, with spare ammo. Because more guns are always better."
	ui_icon = "sentry"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary_weapon/kit/tgmc_engineer/sentry/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/sentry/mini/combat_patrol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/minisentry, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/tgmc_engineer/large_mines
	name = "Claymores"
	desc = "Two large boxes of claymores. Mines are extremely effective for creating deadzones or setting up traps. Great on the defence."
	ui_icon = "claymore"

/datum/loadout_item/secondary_weapon/kit/tgmc_engineer/large_mines/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/kit/tgmc_engineer/iguana
	name = "Iguana"
	desc = "A deployable Iguana remote control vehicle. Armed with a IFF enabled light cannon, this speedy vehicle enables the user to harass the enemy from a safe distance, or scout out areas for their team. \
	WARNING: comes with limited ammo and is easily destroyed. Deploy with caution."
	ui_icon = "default"

/datum/loadout_item/secondary_weapon/kit/tgmc_engineer/iguana/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_vehicle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/uav_turret, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/unmanned_vehicle_remote, SLOT_IN_BACKPACK)
