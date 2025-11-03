/datum/loadout_item/secondary/gun/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)
	item_whitelist = list(
		/obj/item/storage/holster/belt/pistol/standard_pistol = ITEM_SLOT_BELT,
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/engineerpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/tech = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/corpsman = ITEM_SLOT_BACK,
	)
	req_desc = "Requires a pistol holster or some kind of back storage."

/datum/loadout_item/secondary/gun/marine/standard_pistol
	name = "P-14"
	desc = "The P-14, produced by Terran Armories. A reliable sidearm that loads 9x19mm Parabellum Auto munitions. Has a good rate of fire and takes 21-round 9mm magazines."
	ui_icon = "tp14"
	item_typepath = /obj/item/weapon/gun/pistol/standard_pistol/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary/gun/marine/fc_pistol
	name = "P-1911A1-C pistol"
	desc = "The P-1911A1-C is a custom modified pistol with impressive stopping power for its size. \
	Light and easy to use one handed, it suffers from a small magazine size and no auto eject feature. Uses .45 ACP ammunition."
	ui_icon = "m1911c"
	item_typepath = /obj/item/weapon/gun/pistol/m1911/custom
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(FIELD_COMMANDER)

/datum/loadout_item/secondary/gun/marine/so_pistol
	name = "RT-3 pistol"
	desc = "TAn RT-3 target pistol, a common sight throughout the bubble and the standard sidearm for noncombat roles in the TGMC. Uses 9mm caseless ammunition."
	ui_icon = "rt3"
	item_typepath = /obj/item/weapon/gun/pistol/rt3
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(STAFF_OFFICER)

/datum/loadout_item/secondary/gun/marine/smart_pistol
	name = "SP-13 pistol"
	desc = "The SP-13 is a IFF-capable sidearm used by the TerraGov Marine Corps. Has good damage, penetration and magazine capacity. \
	Expensive to manufacture, this sophisticated pistol is only occassionally used by smartgunners, or some higher ranking officers who have the skills to use it. Uses 9x19mm Parabellum ammunition."
	ui_icon = "sp13"
	item_typepath = /obj/item/weapon/gun/pistol/smart_pistol
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(CAPTAIN)

/datum/loadout_item/secondary/gun/marine/standard_heavypistol
	name = "P-23"
	desc = "A standard P-23 chambered in .45 ACP. Has a smaller magazine capacity, but packs a better punch. Has an irremovable laser sight. Uses .45 magazines."
	ui_icon = "tp23"
	item_typepath = /obj/item/weapon/gun/pistol/standard_heavypistol/tactical

/datum/loadout_item/secondary/gun/marine/mod_four
	name = "MK88 Mod 4"
	desc = "An uncommon automatic handgun that fires 9mm armor piercing rounds and is capable of 3-round burst or automatic fire. \
	Light and easy to use one handed, but still a sidearm. Comes in a holster that fits on your waist or armor. Uses 9mm AP ammunition."
	ui_icon = "vp70"
	item_typepath = /obj/item/weapon/gun/pistol/vp70/tactical
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

/datum/loadout_item/secondary/gun/marine/standard_revolver
	name = "TP-44"
	desc = "The R-44 standard combat revolver, produced by Terran Armories. A sturdy and hard hitting firearm that loads .44 Magnum rounds. \
	Holds 7 rounds in the cylinder. Due to an error in the cylinder rotation system the fire rate of the gun is much faster than intended, it ended up being billed as a feature of the system."
	ui_icon = "tp44"
	item_typepath = /obj/item/weapon/gun/revolver/standard_revolver
	loadout_item_flags = NONE

/datum/loadout_item/secondary/gun/marine/highpower
	name = "Highpower"
	desc = "A powerful semi-automatic pistol chambered in the devastating .50 AE caliber rounds. Used for centuries by law enforcement and criminals alike, recently recreated with this new model."
	ui_icon = "highpower"
	item_typepath = /obj/item/weapon/gun/pistol/highpower/standard
	loadout_item_flags = NONE

/datum/loadout_item/secondary/gun/marine/laser_pistol
	name = "TE-P"
	desc = "A TerraGov standard issue laser pistol abbreviated as TE-P. It has an integrated charge selector for normal, heat and taser settings. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "default"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical
	loadout_item_flags = NONE

/datum/loadout_item/secondary/gun/marine/standard_machinepistol
	name = "MP-19"
	desc = "Equipped with a motion sensor. The MP-19 is the TerraGov Marine Corps standard-issue machine pistol. It's known for it's low recoil and scatter when used one handed. \
	It's usually carried by specialized troops who do not have the space to carry a much larger gun like medics and engineers. It uses 10x20mm caseless rounds."
	ui_icon = "t19"
	item_typepath = /obj/item/weapon/gun/smg/standard_machinepistol/scanner
	purchase_cost = 15
	item_whitelist = list(
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
	)
	req_desc = "Requires some kind of back storage."

/datum/loadout_item/secondary/gun/marine/standard_smg
	name = "SMG-25"
	desc = "The RivArms SMG-25 submachinegun, an update to a classic design. A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine."
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/holstered
	item_whitelist = list(/obj/item/storage/holster/m25 = ITEM_SLOT_BELT)
	req_desc = "Requires an SMG-25 holster and either a MG-27, FL-84 or MG-100."
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/secondary/gun/marine/standard_smg/item_checks(datum/outfit_holder/outfit_holder)
	. = ..()
	if(!.)
		return
	for(var/typepath in list(LOADOUT_ITEM_MG27, LOADOUT_ITEM_TGMC_FLAMER, LOADOUT_ITEM_TGMC_MINIGUN))
		if(outfit_holder.equipped_things["[ITEM_SLOT_SUITSTORE]"].item_typepath == typepath)
			return TRUE
	return FALSE

/datum/loadout_item/secondary/gun/marine/standard_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/secondary/gun/marine/db_shotgun
	name = "SH-34 shotgun"
	desc = "A double barreled shotgun of archaic, but sturdy design used by the TGMC, loaded with buckshot. Uncommonly seen as a powerful secondary weapon when serious stopping power is required."
	ui_icon = "tx34"
	item_typepath = /obj/item/weapon/gun/shotgun/double/marine
	item_whitelist = list(/obj/item/storage/holster/belt/ts34 = ITEM_SLOT_BELT)
	req_desc = "Requires a shotgun holster."
	jobs_supported = list(SQUAD_SMARTGUNNER)

/datum/loadout_item/secondary/gun/marine/db_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot, SLOT_IN_HOLSTER)
	wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_IN_HOLSTER)
	default_load(wearer, loadout, holder)

//non-standard
/datum/loadout_item/secondary/machete
	name = "Machete"
	desc = "Latest issue of the TGMC Machete. Great for clearing out jungle or brush on outlying colonies, or cutting open heads. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	ui_icon = "machete"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER)
	item_typepath = /obj/item/weapon/sword/machete
	item_whitelist = list(/obj/item/storage/holster/blade/machete = ITEM_SLOT_BELT)
	req_desc = "Requires a scabbard."

/datum/loadout_item/secondary/machete/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_IN_HOLSTER)
	default_load(wearer, loadout, holder)

/datum/loadout_item/secondary/machete/officer
	name = "Officers sword"
	desc = "This appears to be a rather old blade that has been well taken care of, it is probably a family heirloom. Oddly despite its probable non-combat purpose it is sharpened and not blunt."
	ui_icon = "machete"
	jobs_supported = list(FIELD_COMMANDER)
	item_typepath = /obj/item/weapon/sword/officersword
	item_whitelist = list(/obj/item/storage/holster/blade/officer = ITEM_SLOT_BELT)
	req_desc = "Requires a scabbard."

//kits
/datum/loadout_item/secondary/kit/mirage_nades
	name = "Mirage nades"
	desc = "Three mirage grenades, can provide a handy distraction against unwitting opponents."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary/kit/mirage_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/he_nades
	name = "HE nades"
	desc = "Three HE grenades, for a bit more bang."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary/kit/he_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/deploy_shield
	name = "Deployable shield"
	desc = "Two deployable shields. Can be used as strong, portable barricades, or as a shield in a pinch."
	ui_icon = "riot_shield"
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary/kit/deploy_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/binoculars
	name = "Tac binos"
	desc = "Tactical binoculars, used for scouting positions and calling in fire support, if it's available."
	ui_icon = "default"
	purchase_cost = 20
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER)

/datum/loadout_item/secondary/kit/binoculars/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/cameras
	name = "Cameras"
	desc = "Two deployable cameras and a hud tablet. Useful for watching things remotely, and your command officers might appreciate it as well."
	ui_icon = "default"
	jobs_supported = list(SQUAD_LEADER)

/datum/loadout_item/secondary/kit/cameras/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet(wearer, /datum/job/terragov/squad/leader, wearer.assigned_squad), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/secondary/kit/tgmc_engineer/sentry
	name = "Sentry gun"
	desc = "A point defence sentry gun, with spare ammo. Because more guns are always better."
	ui_icon = "sentry"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary/kit/tgmc_engineer/sentry/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/sentry/mini/combat_patrol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/minisentry, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer/large_mines
	name = "Claymores"
	desc = "Two large boxes of claymores. Mines are extremely effective for creating deadzones or setting up traps. Great on the defence."
	ui_icon = "claymore"

/datum/loadout_item/secondary/kit/tgmc_engineer/large_mines/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer/materials
	name = "Metal/plasteel"
	desc = "A full stack of metal and plasteel. For maximum construction."
	ui_icon = "materials"

/datum/loadout_item/secondary/kit/tgmc_engineer/materials/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer/detpack
	name = "Detpacks"
	desc = "Detpacks, for blowing things up."
	ui_icon = "default"

/datum/loadout_item/secondary/kit/tgmc_engineer/detpack/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/tech))
		wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer/razorburn
	name = "Razorburn"
	desc = "Three razorburn cannisters, able to make large fields of razorwire quickly. 'Everyone laughs at razorwire, until they're trying to get through it while being shot to pieces.' Unknown"
	ui_icon = "default"
	purchase_cost = 15

/datum/loadout_item/secondary/kit/tgmc_engineer/razorburn/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_small, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_small, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer/iguana
	name = "Iguana"
	desc = "A deployable Iguana remote control vehicle. Armed with a IFF enabled light cannon, this speedy vehicle enables the user to harass the enemy from a safe distance, or scout out areas for their team. \
	WARNING: comes with limited ammo and is easily destroyed. Deploy with caution."
	ui_icon = "default"
	purchase_cost = 75

/datum/loadout_item/secondary/kit/tgmc_engineer/iguana/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_vehicle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/uav_turret, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/unmanned_vehicle_remote, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_engineer/skink
	name = "Skink"
	desc = "A deployable Skink remote control vehicle. While lacking any weaponry, this speedy vehicle is perfect for slipping past enemy forces and gathering information. Comes with a spare and remote. \
	WARNING: exceedingly fragile. Keep away from open flames or explosives."
	ui_icon = "default"
	purchase_cost = 15

/datum/loadout_item/secondary/kit/tgmc_engineer/skink/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_vehicle/tiny, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_vehicle/tiny, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/unmanned_vehicle_remote, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/tgmc_corpsman
	jobs_supported = list(SQUAD_CORPSMAN)
	req_desc = "Requires a medical backpack."

/datum/loadout_item/secondary/kit/tgmc_corpsman/advanced
	name = "Advanced meds"
	desc = "A variety of advanced medical injectors including neuraline, rezadone and Re-Grow, allowing for the treatment of cloneloss and missing limbs."
	ui_icon = "medkit"
	purchase_cost = 30

/datum/loadout_item/secondary/kit/tgmc_corpsman/advanced/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/rezadone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/neuraline, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/regrow, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/antitox_mix, SLOT_IN_BACKPACK)
