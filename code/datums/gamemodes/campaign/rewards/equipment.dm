//Parent for all 'spawn stuff' assets
/datum/campaign_asset/equipment
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_SL_AVAILABLE
	///list of objects to spawn when this asset is activated
	var/list/obj/equipment_to_spawn = list()

/datum/campaign_asset/equipment/activated_effect()
	var/turf/spawn_location = get_turf(pick(GLOB.campaign_reward_spawners[faction.faction]))
	playsound(spawn_location,'sound/effects/phasein.ogg', 80, FALSE)
	for(var/obj/object AS in equipment_to_spawn)
		new object(spawn_location)

/datum/campaign_asset/equipment/power_armor
	name = "B18 consignment"
	desc = "Three sets of B18 power armor"
	detailed_desc = "Activatable by squad leaders. Your battalion has been assigned a number of B18 power armor sets, available at your request. B18 is TGMC's premier infantry armor, providing superior protection, mobility and an advanced automedical system."
	ui_icon = "b18"
	uses = 3
	cost = 25
	equipment_to_spawn = list(
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist,
	)

/datum/campaign_asset/equipment/gorgon_armor
	name = "Gorgon consignment"
	desc = "Five sets of Gorgon power armor"
	detailed_desc = "Activatable by squad leaders. Your battalion has been assigned a number of Gorgon power armor sets, available at your request. Gorgon armor is the SOM's elite infantry armor, providing superior protection and an automedical system without significantly compromising on speed."
	ui_icon = "gorgon"
	uses = 5
	cost = 12
	equipment_to_spawn = list(
		/obj/item/clothing/head/modular/som/leader,
		/obj/item/clothing/suit/modular/som/heavy/leader/valk,
	)

/datum/campaign_asset/equipment/medkit_basic
	name = "Medical supplies"
	desc = "An assortment of medical supplies"
	detailed_desc = "Activatable by squad leaders. An assortment of basic medical supplies and some stimulants."
	ui_icon = "medkit"
	uses = 3
	cost = 1
	equipment_to_spawn = list(
		/obj/item/storage/pouch/firstaid/basic,
		/obj/item/storage/pouch/firstaid/basic,
		/obj/item/storage/pouch/firstaid/basic,
		/obj/item/storage/pouch/firstaid/basic,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
	)

/datum/campaign_asset/equipment/medkit_basic/som
	equipment_to_spawn = list(
		/obj/item/storage/pouch/firstaid/som/full,
		/obj/item/storage/pouch/firstaid/som/full,
		/obj/item/storage/pouch/firstaid/som/full,
		/obj/item/storage/pouch/firstaid/som/full,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine,
	)

/datum/campaign_asset/equipment/materials_pack
	name = "Construction supplies"
	desc = "Metal, plasteel and sandbags"
	detailed_desc = "Activatable by squad leaders. A significant quantity of metal, plasteel and sandbags. Perfect for fortifying a defensive position."
	ui_icon = "materials"
	uses = 1
	cost = 4
	equipment_to_spawn = list(
		/obj/item/storage/box/crate/loot/materials_pack,
	)

/datum/campaign_asset/equipment/ballistic_tgmc
	name = "ballistic weapon cache"
	desc = "Ballistic weapons and ammo"
	detailed_desc = "A number of standard ballistic weapons and ammo to match."
	ui_icon = "ballistic"
	uses = 1
	cost = 2
	equipment_to_spawn = list(
		/obj/effect/supply_drop/standard_carbine,
		/obj/effect/supply_drop/standard_rifle,
		/obj/effect/supply_drop/combat_rifle,
		/obj/item/weapon/gun/rifle/standard_gpmg/machinegunner,
		/obj/item/ammo_magazine/standard_gpmg,
		/obj/item/ammo_magazine/standard_gpmg,
		/obj/item/ammo_magazine/standard_gpmg,
	)

/datum/campaign_asset/equipment/ballistic_som
	name = "ballistic weapon cache"
	desc = "Ballistic weapons and ammo"
	detailed_desc = "A number of standard ballistic weapons and ammo to match."
	ui_icon = "ballistic"
	uses = 1
	cost = 3
	equipment_to_spawn = list(
		/obj/effect/supply_drop/som_rifle,
		/obj/effect/supply_drop/som_smg,
		/obj/effect/supply_drop/som_mg,
		/obj/effect/supply_drop/mpi,
		/obj/effect/supply_drop/som_carbine,
	)

/datum/campaign_asset/equipment/lasers
	name = "Laser weapon cache"
	desc = "Laser weapons and ammo"
	detailed_desc = "A number of laser weapons and ammo to match."
	ui_icon = "lasergun"
	uses = 1
	cost = 3
	equipment_to_spawn = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/mag_harness,
		/obj/item/storage/belt/marine/te_cells,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman,
		/obj/item/storage/belt/marine/te_cells,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol,
		/obj/item/storage/belt/marine/te_cells,
	)

/datum/campaign_asset/equipment/volkite
	name = "Volkite weapon cache"
	desc = "Volkite weapon cache and ammo"
	detailed_desc = "A volkite caliver and charger, with accompanying ammo. Able to deflagrate targets, making them deadly against tightly packed opponents."
	ui_icon = "volkite"
	uses = 1
	cost = 4
	equipment_to_spawn = list(
		/obj/effect/supply_drop/caliver,
		/obj/effect/supply_drop/charger,
	)

/datum/campaign_asset/equipment/scout_rifle
	name = "Scout rifle"
	desc = "BR-8 and ammo"
	detailed_desc = "A BR-8 scout rifle and assorted ammo. An accurate, powerful rifle with integrated IFF."
	ui_icon = "scout"
	uses = 2
	cost = 6
	equipment_to_spawn = list(
		/obj/effect/supply_drop/scout,
	)

/datum/campaign_asset/equipment/smart_guns
	name = "Smartgun weapon cache"
	desc = "Smartguns and ammo"
	detailed_desc = "A SG-27 and SG-85 and ammo to match."
	ui_icon = "smartgun"
	uses = 1
	cost = 4
	equipment_to_spawn = list(
		/obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol,
		/obj/item/storage/belt/marine/smartgun,
		/obj/item/weapon/gun/minigun/smart_minigun/motion_detector,
		/obj/item/ammo_magazine/minigun_powerpack/smartgun,
		/obj/item/weapon/gun/rifle/standard_smarttargetrifle/motion,
		/obj/item/storage/belt/marine/target_rifle,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact,
		/obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact,
	)

/datum/campaign_asset/equipment/shotguns_tgmc
	name = "Shotgun cache"
	desc = "Shotgun and ammo"
	detailed_desc = "A SH-35 and ammo to match."
	ui_icon = "shotgun"
	uses = 1
	cost = 2
	equipment_to_spawn = list(
		/obj/item/storage/belt/shotgun/mixed,
		/obj/item/weapon/gun/shotgun/pump/t35/standard,
	)

/datum/campaign_asset/equipment/shotguns_som
	name = "Shotgun cache"
	desc = "Shotgun and ammo"
	detailed_desc = "A V-51 and ammo to match."
	ui_icon = "shotgun"
	uses = 1
	cost = 2
	equipment_to_spawn = list(
		/obj/item/storage/belt/shotgun/som/mixed,
		/obj/item/weapon/gun/shotgun/som/standard,
	)

/datum/campaign_asset/equipment/heavy_armour_tgmc
	name = "Tyr 2 heavy armour"
	desc = "Heavy armor upgrades"
	detailed_desc = "A pair of heavy armor suits equipped with 'Tyr 2' armour upgrades. Premier protection, but somewhat cumbersome."
	ui_icon = "tyr"
	uses = 2
	cost = 4
	equipment_to_spawn = list(
		/obj/item/clothing/head/modular/m10x/tyr,
		/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two,
	)

/datum/campaign_asset/equipment/shields_tgmc
	name = "Defensive shields"
	desc = "Heavy shields to hide behind"
	detailed_desc = "A pair of heavy riot shields. Able to withstand a tremendous amount of punishment at the cost of occupying a hand and slowing you down."
	ui_icon = "riot_shield"
	uses = 2
	cost = 3
	equipment_to_spawn = list(
		/obj/item/weapon/shield/riot/marine,
		/obj/item/weapon/shield/riot/marine,
	)

/datum/campaign_asset/equipment/grenades_tgmc
	name = "Grenade resupply"
	desc = "An assortment of grenades"
	detailed_desc = "A variety of different grenade types. Throw towards enemy."
	ui_icon = "grenade"
	uses = 2
	cost = 6
	equipment_to_spawn = list(
		/obj/item/storage/belt/grenade/standard,
		/obj/item/storage/pouch/grenade/combat_patrol,
	)

/datum/campaign_asset/equipment/tac_bino_tgmc
	name = "Tactical binoculars"
	desc = "One set of tactical binoculars"
	detailed_desc = "Tactical binoculars for seeing into the distance and calling down air support."
	ui_icon = "binoculars"
	uses = 1
	cost = 3
	equipment_to_spawn = list(
		/obj/item/binoculars/fire_support/campaign,
	)

/datum/campaign_asset/equipment/heavy_armour_som
	name = "Lorica heavy armour"
	desc = "Heavy armor upgrades"
	detailed_desc = "A pair of heavy armor suits equipped with 'Lorica' armour upgrades. Premier protection, but somewhat cumbersome."
	ui_icon = "lorica"
	uses = 2
	cost = 4
	equipment_to_spawn = list(
		/obj/item/clothing/head/modular/som/lorica,
		/obj/item/clothing/suit/modular/som/heavy/lorica,
	)

/datum/campaign_asset/equipment/shields_som
	name = "Defensive shields"
	desc = "Heavy shields to hide behind"
	detailed_desc = "A pair of heavy riot shields. Able to withstand a tremendous amount of punishment at the cost of occupying a hand and slowing you down."
	ui_icon = "riot_shield"
	uses = 2
	cost = 3
	equipment_to_spawn = list(
		/obj/item/weapon/shield/riot/marine/som,
		/obj/item/weapon/shield/riot/marine/som,
	)

/datum/campaign_asset/equipment/grenades_som
	name = "Grenade resupply"
	desc = "An assortment of grenades"
	detailed_desc = "A variety of different grenade types. Throw towards enemy."
	ui_icon = "grenade"
	uses = 2
	cost = 6
	equipment_to_spawn = list(
		/obj/item/storage/belt/grenade/som/standard,
		/obj/item/storage/pouch/grenade/som/combat_patrol,
	)

/datum/campaign_asset/equipment/at_mines
	name = "Anti-tank mines"
	desc = "10 Anti-tank mines"
	detailed_desc = "M92 anti-tank mines. Extremely effective against mechs, but will not trigger against human targets."
	ui_icon = "at_mine"
	uses = 1
	cost = 3
	equipment_to_spawn = list(
		/obj/item/storage/box/explosive_mines/antitank,
		/obj/item/storage/box/explosive_mines/antitank,
	)

/datum/campaign_asset/equipment/tac_bino_som
	name = "Tactical binoculars"
	desc = "One set of tactical binoculars"
	detailed_desc = "Tactical binoculars for seeing into the distance and calling down air support."
	ui_icon = "binoculars"
	uses = 1
	cost = 3
	equipment_to_spawn = list(
		/obj/item/binoculars/fire_support/campaign/som,
	)
