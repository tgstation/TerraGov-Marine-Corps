//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

var/list/all_supply_groups = list("Operations","Weapons","Attachments","Ammo","Armor","Clothing","Medical","Engineering","Science","Supplies")

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = null
	var/containername = null
	var/access = null
	var/hidden = 0
	var/contraband = 0
	var/group = null
	var/randomised_num_contained = 0 //randomly picks X of items out of the contains list instead of using all.

/datum/supply_packs/New()
	if(randomised_num_contained)
		manifest += "Contains any [randomised_num_contained] of:"
	manifest += "<ul>"
	for(var/atom/movable/path in contains)
		if(!path)	continue
		manifest += "<li>[initial(path.name)]</li>"
	manifest += "</ul>"


/*******************************************************************************
OPERATIONS
*******************************************************************************/


/datum/supply_packs/specialops
	name = "Special Ops supplies"
	contains = list(/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/explosive/grenade/smokebomb,
					/obj/item/explosive/grenade/smokebomb,
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing
					)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	group = "Operations"

/datum/supply_packs/beacons_supply
	name = "Supply Beacons crate (x4)"
	contains = list(
			/obj/item/device/squad_beacon,
			/obj/item/device/squad_beacon,
			/obj/item/device/squad_beacon,
			/obj/item/device/squad_beacon
			)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "supply beacons crate"
	group = "Operations"

/datum/supply_packs/beacons_orbital
	name = "Orbital Beacons crate (x4)"
	contains = list(
					/obj/item/device/squad_beacon/bomb,
					/obj/item/device/squad_beacon/bomb,
					/obj/item/device/squad_beacon/bomb,
					/obj/item/device/squad_beacon/bomb
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "orbital beacons crate"
	group = "Operations"

/datum/supply_packs/flares
	name = "Flare pack crate (x20)"
	contains = list(
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94
					)
	cost = 10
	containertype = /obj/structure/closet/crate/ammo
	containername = "flare pack crate"
	group = "Operations"

/datum/supply_packs/contraband
	randomised_num_contained = 5
	contains = list(
					/obj/item/seeds/bloodtomatoseed,
					/obj/item/storage/pill_bottle/zoom,
					/obj/item/storage/pill_bottle/happy,
					/obj/item/reagent_container/food/drinks/bottle/pwine
					)

	name = "Contraband crate"
	cost = 50
	containertype = /obj/structure/closet/crate/supply
	containername = "unlabeled crate"
	contraband = 1
	group = "Operations"

/datum/supply_packs/sandbags
	name = "Empty sandbags crate (x50)"
	contains = list(/obj/item/stack/sandbags_empty)
	amount = 50
	cost = 15
	containertype = "/obj/structure/closet/crate/supply"
	containername = "empty sandbags crate"
	group = "Supplies"


/*******************************************************************************
WEAPONS
*******************************************************************************/


/datum/supply_packs/flamethrower
	name = "M240 Flamethrower crate (x3)"
	contains = list(
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank
					)
	cost = 150
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240 Incinerator crate"
	group = "Weapons"

/datum/supply_packs/weapons_sentry
	name = "UA 571-C sentry crate (x1)"
	contains = list()
	cost = 120
	containertype = /obj/item/storage/box/sentry
	containername = "sentry crate"
	group = "Weapons"

/datum/supply_packs/gun/pistols
	contains = list(
					/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/weapon/gun/pistol/m4a3,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/weapon/gun/revolver/m44,
					/obj/item/weapon/gun/revolver/m44,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver
					)
	name = "Pistols crate"
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper pistols crate"
	group = "Weapons"

/datum/supply_packs/gun/shotguns
	contains = list(
					/obj/item/weapon/gun/shotgun/pump,
					/obj/item/weapon/gun/shotgun/pump,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot
					)
	name = "Shotguns crate"
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper shotguns crate"
	group = "Weapons"

/datum/supply_packs/gun/smgs
	contains = list(
					/obj/item/weapon/gun/smg/m39,
					/obj/item/weapon/gun/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39
					)
	name = "SMGs crate"
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper SMGs crate"
	group = "Weapons"

/datum/supply_packs/gun/rifles
	contains = list(
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle
					)
	name = "Rifles crate"
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper rifles crate"
	group = "Weapons"

/datum/supply_packs/gun/heavyweapons
	contains = list(
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg
					)
	name = "LMG crate"
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper LMG crate"
	group = "Weapons"

/datum/supply_packs/gun/merc
	contains = list()
	name = "Black Market firearm (x1)"
	cost = 25
	contraband = 1
	containertype = /obj/structure/largecrate/guns/merc
	containername = "\improper black market firearms crate"
	group = "Weapons"

/datum/supply_packs/gun_holster
	contains = list(
					/obj/item/storage/large_holster/m39,
					/obj/item/storage/large_holster/m39
					)
	name = "M39 Holster crate (x2)"
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "holster crate"
	group = "Weapons"

/datum/supply_packs/gun_holster/m44
	name = "M44 Holster crate (x2)"
	cost = 15
	contains = list(
					/obj/item/storage/belt/gun/m44,
					/obj/item/storage/belt/gun/m44
					)
	group = "Weapons"

/datum/supply_packs/gun_holster/m4a3
	name = "M4A3 Holster crate (x2)"
	cost = 15
	contains = list(
					/obj/item/storage/belt/gun/m4a3,
					/obj/item/storage/belt/gun/m4a3
					)
	group = "Weapons"

/datum/supply_packs/explosives
	name = "Explosives crate"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15
					)
	cost = 50
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosives crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_mines
	name = " - x8 explosive mines crate"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/storage/box/explosive_mines
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive mine boxes crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_m15
	name = " - x5 M15 grenades crate"
	contains = list(
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M15 grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_incendiary
	name = " - x5 M40 HIDP incendiary grenades crate"
	contains = list(
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 HIDP incendiary grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_M40_HEDP
	name = " - x5 M40 HEDP grenades crate"
	contains = list(
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 HEDP grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hedp
	name = " -- x25 M40 HEDP grenade box crate"
	contains = list(
					/obj/item/storage/box/nade_box
					)
	cost = 100
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HEDP grenade crate (WARNING)"
	group = "Weapons"


/*******************************************************************************
ATTACHMENTS
*******************************************************************************/


/datum/supply_packs/attachables
	name = "Rail Attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Attachments"

/datum/supply_packs/rail_reddot
	name = " - x10 red-dot sight attachment crate"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "red-dot sight attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_scope
	name = " - x3 scope attachment crate"
	contains = list(
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "scope attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_magneticharness
	name = " - x8 magnetic harness attachment crate"
	contains = list(
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "magnetic harness attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_quickfire
	name = " - x2 quickfire attachment crate"
	contains = list(
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "quickfire attachment crate"
	group = "Attachments"

/datum/supply_packs/m_attachables
	name = "Muzzle attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Attachments"

/datum/supply_packs/muzzle_suppressor
	name = " - x10 suppressor attachment crate"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "suppressor attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_bayonet
	name = " - x20 bayonet attachment crate"
	contains = list(
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "bayonet attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_extended
	name = " - x10 extended barrel attachment crate"
	contains = list(
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "extended barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_heavy
	name = " - x2 barrel charger attachment crate"
	contains = list(
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "heavy barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_compensator
	name = " - x5 compensator attachment crate"
	contains = list(
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "compensator attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_attachables
	name = "Underbarrel attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/flamer,
					/obj/item/attachable/flamer,
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_foregrip
	name = " - x10 foregrip attachment crate"
	contains = list(
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip,
					/obj/item/attachable/foregrip
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "foregrip attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_gyro
	name = " - x5 gyro attachment crate"
	contains = list(
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "gyro attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_bipod
	name = " - x8 bipod attachment crate"
	contains = list(
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "bipod attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_shotgun
	name = " - x6 shotgun attachment crate"
	contains = list(
					/obj/item/attachable/shotgun,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/shotgun,
					/obj/item/attachable/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "shotgun attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_flamer
	name = " - x6 flamer attachment crate"
	contains = list(
					/obj/item/attachable/flamer,
					/obj/item/attachable/flamer,
					/obj/item/attachable/flamer,
					/obj/item/attachable/flamer,
					/obj/item/attachable/flamer,
					/obj/item/attachable/flamer
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "flamer attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_burstfire_assembly
	name = " - x3 burstfire assembly attachment crate"
	contains = list(
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "burstfire assembly attachment crate"
	group = "Attachments"

/datum/supply_packs/s_attachables
	name = "Stock attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/shotgun
					)
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "stocks crate"
	group = "Attachments"

/datum/supply_packs/stock_revolver
	name = " - x6 stock revolver attachment crate"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "stock revolver attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_rifle
	name = " - x6 stock rifle attachment crate"
	contains = list(
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle
			)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "stock rifle attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_shotgun
	name = " - x6 stock shotgun attachment crate"
	contains = list(
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun
			)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "stock shotgun attachment crate"
	group = "Attachments"


/*******************************************************************************
AMMO
*******************************************************************************/


/datum/supply_packs/ammo_regular
	name = "Regular Magazine crate (M41A, M4A3, M44, M39, M37A2)"
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot
					)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m41a
	name = " - Regular Magazine crate (M41A x10)"
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle
					)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "M41A regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m4a3
	name = " - Regular Magazine crate (M4A3 x10)"
	contains = list(
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol
					)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "M4A3 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m44
	name = " - Regular Magazine crate (M44 x10)"
	contains = list(
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver
					)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "M44 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m39
	name = " - Regular Magazine crate (M39 x10)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39
					)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "M39 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m37a2
	name = " - Regular Magazine crate (M37A2 x5 slugs, x5 buckshot)"
	contains = list(
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot
					)
	cost = 15
	containertype = /obj/structure/closet/crate/ammo
	containername = "M37A2 ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended
	name = "Extended Magazine crate (M41A, M4A3, M39; x2 each)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m41a
	name = " - Extended Magazine crate (M41A x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M41A extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m4a3
	name = " - Extended Magazine crate (M4A3 x6)"
	contains = list(
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M4A3 extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m39
	name = " - Extended Magazine crate (M39 x6)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M39 extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap
	name = "Armor Piercing Magazine crate (M41A, M4A3, M39; x2 each)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m41a
	name = " - Armor Piercing Magazine crate (M41A x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M41A armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m4a3
	name = " - Armor Piercing Magazine crate (M4A3 x6)"
	contains = list(
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M4A3 armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m39
	name = " - Armor Piercing Magazine crate (M39 x6)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "M39 armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_regular
	name = "M4RA Scout Ammo crate (Regular x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/marksman
					)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "regular scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_regular
	name = "M42A Sniper Ammo crate (Regular x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper
					)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "regular sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_flak
	name = " - M42A Sniper Ammo crate (Flak x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "flak sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_incendiary
	name = " - M42A Sniper Ammo crate (Incendiary x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "incendiary sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_regular
	name = "M5 RPG Rocket Ammo crate (Regular x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket
					)
	cost = 20
	containertype = /obj/structure/closet/crate/explosives
	containername = "regular M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_ap
	name = " - M5 RPG Rocket Ammo crate (Armor Piercing x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "armor piercing M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_wp
	name = " - M5 RPG Rocket Ammo crate (White Phosphorus x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "white phosphorus M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle
	name = "Large Ammo Box crate (M41A x800 rounds)"
	contains = list(/obj/item/ammo_magazine/big_box)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle_ap
	name = "Large AP Ammo Box crate (M41A x800 rounds)"
	contains = list(/obj/item/ammo_magazine/big_box/ap)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_smg
	name = "Large Ammo Box crate (M39 x800 rounds)"
	contains = list(/obj/item/ammo_magazine/big_box/smg)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_black_market
	name = "Black Market ammo crate"
	randomised_num_contained = 6
	contains = list(
					/obj/item/ammo_magazine/revolver/upp,
					/obj/item/ammo_magazine/revolver/small,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/cmb,
					/obj/item/ammo_magazine/pistol/heavy,
					/obj/item/ammo_magazine/pistol/c99,
					/obj/item/ammo_magazine/pistol/automatic,
					/obj/item/ammo_magazine/pistol/holdout,
					/obj/item/ammo_magazine/pistol/highpower,
					/obj/item/ammo_magazine/pistol/vp70,
					/obj/item/ammo_magazine/pistol/vp78,
					/obj/item/ammo_magazine/smg/mp7,
					/obj/item/ammo_magazine/smg/skorpion,
					/obj/item/ammo_magazine/smg/ppsh,
					/obj/item/ammo_magazine/smg/ppsh/extended,
					/obj/item/ammo_magazine/smg/uzi,
					/obj/item/ammo_magazine/smg/p90,
					/obj/item/ammo_magazine/rifle/sniper/svd,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/mar40,
					/obj/item/ammo_magazine/rifle/mar40/extended,
					)
	cost = 40
	contraband = 1
	containertype = /obj/structure/closet/crate/ammo
	containername = "black market ammo crate"
	group = "Ammo"

//This crate has a little bit of everything, mostly okay stuff, but it does have some really unique picks.
/datum/supply_packs/surplus
	name = "Surplus Ammo crate (x10 random)"
	randomised_num_contained = 10
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/incendiary,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/marksman,
					/obj/item/ammo_magazine/rifle/lmg,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/hp,
					/obj/item/ammo_magazine/pistol/incendiary,
					/obj/item/ammo_magazine/pistol/m1911,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver,
					/obj/item/ammo_magazine/revolver/marksman,
					/obj/item/ammo_magazine/revolver/heavy,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/incendiary
					)
	cost = 50
	containertype = /obj/structure/closet/crate/ammo
	containername = "surplus ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartgun
	name = "M56 Smartgun Powerpack crate (x2)"
	contains = list(
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
					)
	cost = 25
	containertype = /obj/structure/closet/crate/ammo
	containername = "smartgun powerpack crate"
	group = "Ammo"

/datum/supply_packs/ammo_sentry
	name = "UA 571-C Sentry ammunition (x2)"
	contains = list(
					/obj/item/ammo_magazine/sentry,
					/obj/item/ammo_magazine/sentry
					)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"


/*******************************************************************************
ARMOR
*******************************************************************************/


/datum/supply_packs/armor_basic
	name = "M3 Pattern armor crate (x5 helmets, x5 bodyarmor)"
	contains = list(
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/head/helmet/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "armor crate"
	group = "Armor"

/datum/supply_packs/armor_leader
	name = "M3 Pattern Squad Leader crate (x1 helmet, x1 bodyarmor)"
	contains = list(
					/obj/item/clothing/head/helmet/marine/leader,
					/obj/item/clothing/suit/storage/marine/leader
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "squad leader armor crate"
	group = "Armor"


/*******************************************************************************
CLOTHING
*******************************************************************************/


/datum/supply_packs/officer_outfits
	contains = list(
					/obj/item/clothing/under/rank/ro_suit,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/bridge,
					/obj/item/clothing/under/marine/officer/exec,
					/obj/item/clothing/under/marine/officer/ce
					)
	name = "Officer outfit closet"
	cost = 45
	containertype = /obj/structure/closet
	containername = "officer dress closet"
	group = "Clothing"

/datum/supply_packs/marine_outfits
	contains = list(
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/clothing/under/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/backpack/marine,
					/obj/item/storage/backpack/marine,
					/obj/item/storage/backpack/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine
					)
	name = "Marine outfit closet"
	cost = 15
	containertype = /obj/structure/closet
	containername = "marine outfit closet"
	group = "Clothing"

/datum/supply_packs/webbing
	name = "Webbings and Gun Belts crate"
	contains = list(
					/obj/item/clothing/tie/holster,
					/obj/item/clothing/tie/storage/brown_vest,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/clothing/tie/storage/webbing,
					/obj/item/storage/belt/gun/m4a3,
					/obj/item/storage/belt/gun/m44,
					/obj/item/storage/large_holster/m39
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "extra storage crate"
	group = "Clothing"

/datum/supply_packs/pouches_general
	name = "General pouches crate (1x normal, medium, large)"
	contains = list(
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general/medium,
					/obj/item/storage/pouch/general/large
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "general pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_weapons
	name = "Weapons pouches crate (1x bayonet, pistol, explosive)"
	contains = list(
					/obj/item/storage/pouch/bayonet,
					/obj/item/storage/pouch/pistol,
					/obj/item/storage/pouch/explosive
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "weapons pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_ammo
	name = "Ammo pouches crate (1x normal, large, pistol, pistol large)"
	contains = list(
					/obj/item/storage/pouch/magazine,
					/obj/item/storage/pouch/magazine/large,
					/obj/item/storage/pouch/magazine/pistol,
					/obj/item/storage/pouch/magazine/pistol/large
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "ammo pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_medical
	name = "Medical pouches crate (1x firstaid, medical, syringe, medkit)"
	contains = list(
					/obj/item/storage/pouch/firstaid,
					/obj/item/storage/pouch/medical,
					/obj/item/storage/pouch/syringe,
					/obj/item/storage/pouch/medkit
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "medical pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_survival
	name = "Survival pouches crate (1x radio, flare, survival)"
	contains = list(
					/obj/item/storage/pouch/radio,
					/obj/item/storage/pouch/flare,
					/obj/item/storage/pouch/survival
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "survival pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_construction
	name = "Construction pouches crate (1x document, electronics, tools, construction)"
	contains = list(
					/obj/item/storage/pouch/document,
					/obj/item/storage/pouch/electronics,
                    /obj/item/storage/pouch/tools,
					/obj/item/storage/pouch/construction
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "construction pouches crate"
	group = "Clothing"


/*******************************************************************************
MEDICAL
*******************************************************************************/


/datum/supply_packs/medical
	name = "Medical crate"
	contains = list(
					/obj/item/storage/box/autoinjectors,
					/obj/item/storage/box/syringes,
					/obj/item/reagent_container/glass/bottle/inaprovaline,
					/obj/item/reagent_container/glass/bottle/antitoxin,
					/obj/item/reagent_container/glass/bottle/bicaridine,
					/obj/item/reagent_container/glass/bottle/dexalin,
					/obj/item/reagent_container/glass/bottle/spaceacillin,
					/obj/item/reagent_container/glass/bottle/kelotane,
					/obj/item/reagent_container/glass/bottle/tramadol,
					/obj/item/storage/pill_bottle/inaprovaline,
					/obj/item/storage/pill_bottle/antitox,
					/obj/item/storage/pill_bottle/bicaridine,
					/obj/item/storage/pill_bottle/dexalin,
					/obj/item/storage/pill_bottle/spaceacillin,
					/obj/item/storage/pill_bottle/kelotane,
					/obj/item/storage/pill_bottle/tramadol,
					/obj/item/storage/box/pillbottles
					)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"

/datum/supply_packs/firstaid
	name = "First-aid kit crate (2x each)"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/adv,
					/obj/item/storage/firstaid/adv
					)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"

/datum/supply_packs/bodybag
	name = "Body bag crate (x28)"
	contains = list(
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags
			)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "body bag crate"
	group = "Medical"

/datum/supply_packs/cryobag
	name = "Stasis bag crate (x3)"
	contains = list(
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag
			)
	cost = 40
	containertype = /obj/structure/closet/crate/medical
	containername = "stasis bag crate"
	group = "Medical"

/datum/supply_packs/surgery
	name = "Surgery crate"
	contains = list(
					/obj/item/tool/surgery/cautery,
					/obj/item/tool/surgery/surgicaldrill,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/anesthetic,
					/obj/item/tool/surgery/FixOVein,
					/obj/item/tool/surgery/hemostat,
					/obj/item/tool/surgery/scalpel,
					/obj/item/tool/surgery/bonegel,
					/obj/item/tool/surgery/retractor,
					/obj/item/tool/surgery/bonesetter,
					/obj/item/tool/surgery/circular_saw,
					/obj/item/tool/surgery/scalpel/manager
					)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/anesthetic
	name = "Anesthetic crate (x4 masks, x4 tanks)"
	contains = list(
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/anesthetic,
					/obj/item/tank/anesthetic,
					/obj/item/tank/anesthetic,
					/obj/item/tank/anesthetic
					)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/sterile
	name = "Sterile equipment crate"
	contains = list(
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves
					)
	cost = 10
	containertype = /obj/structure/closet/crate/medical
	containername = "sterile equipment crate"
	group = "Medical"

/datum/supply_packs/quickclot
	name = "Quickclot autoinjectors (x14)"
	contains = list(
					/obj/item/storage/box/quickclot,
					/obj/item/storage/box/quickclot
					)
	cost = 25
	containertype = /obj/structure/closet/crate/medical
	containername = "quickclot equipment crate"
	group = "Medical"


/*******************************************************************************
ENGINEERING
*******************************************************************************/


/datum/supply_packs/inflatable
	name = "Inflatable barriers (x9 doors, x12 walls)"
	contains = list(
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable
					)
	cost = 20
	containertype = /obj/structure/closet/crate/construction
	containername = "inflatable barriers crate"
	group = "Engineering"

/datum/supply_packs/lightbulbs
	name = "Replacement lights (x42 tube, x21 bulb)"
	contains = list(
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed
					)
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "replacement lights crate"
	group = "Engineering"

/datum/supply_packs/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "metal sheets crate"
	group = "Engineering"

/datum/supply_packs/plas50
	name = "30 plasteel sheets"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 30
	cost = 50
	containertype = /obj/structure/closet/crate/supply
	containername = "plasteel sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "glass sheets crate"
	group = "Engineering"

/datum/supply_packs/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "wooden planks crate"
	group = "Engineering"

/datum/supply_packs/smescoil
	name = "Superconducting Magnetic Coil"
	contains = list(/obj/item/stock_parts/smes_coil)
	cost = 150
	containertype = /obj/structure/closet/crate/construction
	containername = "superconducting magnetic coil crate"
	group = "Engineering"

/datum/supply_packs/electrical
	name = "Electrical maintenance crate"
	contains = list(
					/obj/item/storage/toolbox/electrical,
					/obj/item/storage/toolbox/electrical,
					/obj/item/clothing/gloves/yellow,
					/obj/item/clothing/gloves/yellow,
					/obj/item/cell,
					/obj/item/cell,
					/obj/item/cell/high,
					/obj/item/cell/high
					)
	cost = 15
	containertype = /obj/structure/closet/crate/construction
	containername = "electrical maintenance crate"
	group = "Engineering"

/datum/supply_packs/mechanical
	name = "Mechanical maintenance crate"
	contains = list(
					/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/storage/belt/utility/full,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/welding,
					/obj/item/clothing/head/hardhat
					)
	cost = 10
	containertype = /obj/structure/closet/crate/construction
	containername = "mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/fueltank
	name = "Fuel tank crate"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 10
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = "Engineering"

/datum/supply_packs/pacman_parts
	name = "P.A.C.M.A.N. portable generator parts"
	cost = 45
	containername = "\improper P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(
					/obj/item/stock_parts/micro_laser,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/matter_bin,
					/obj/item/circuitboard/machine/pacman
					)

/datum/supply_packs/super_pacman_parts
	name = "Super P.A.C.M.A.N. portable generator parts"
	cost = 55
	containername = "\improper Super P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"
	contains = list(
					/obj/item/stock_parts/micro_laser,
					/obj/item/stock_parts/capacitor,
					/obj/item/stock_parts/matter_bin,
					/obj/item/circuitboard/machine/pacman/super
					)


/*******************************************************************************
SCIENCE
*******************************************************************************/


/datum/supply_packs/phoron
	name = "Phoron assembly crate"
	contains = list(
					/obj/item/tank/phoron,
					/obj/item/tank/phoron,
					/obj/item/tank/phoron,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/igniter,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/prox_sensor,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer,
					/obj/item/device/assembly/timer
					)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/phoron
	containername = "phoron assembly crate"
	access = ACCESS_MARINE_ENGINEERING
	group = "Science"


/*******************************************************************************
SUPPLIES
*******************************************************************************/


/datum/supply_packs/mre
	name = "USCM MRE crate (x20)"
	contains = list(
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE
					)
	cost = 10
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper MRE crate"
	group = "Supplies"

/datum/supply_packs/internals
	name = "Oxygen Internals crate (x3 masks, x3 tanks)"
	contains = list(
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/air,
					/obj/item/tank/air,
					/obj/item/tank/air
					)
	cost = 10
	containertype = /obj/structure/closet/crate/internals
	containername = "internals crate"
	group = "Supplies"

/datum/supply_packs/evacuation
	name = "\improper Emergency equipment"
	contains = list(
					/obj/item/storage/toolbox/emergency,
					/obj/item/storage/toolbox/emergency,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/tank/emergency_oxygen,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas
					)
	cost = 15
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"
	group = "Supplies"

/datum/supply_packs/boxes
	name = "Empty boxes (x10)"
	contains = list(
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box,
					/obj/item/storage/box
					)
	cost = 10
	containertype = "/obj/structure/closet/crate/supply"
	containername = "empty box crate"
	group = "Supplies"

/datum/supply_packs/janitor
	name = "\improper Janitorial supplies"
	contains = list(
					/obj/item/reagent_container/glass/bucket,
					/obj/item/reagent_container/glass/bucket,
					/obj/item/reagent_container/glass/bucket,
					/obj/item/tool/mop,
					/obj/item/tool/wet_sign,
					/obj/item/tool/wet_sign,
					/obj/item/tool/wet_sign,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_container/spray/cleaner,
					/obj/item/reagent_container/glass/rag,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket,
					/obj/item/paper/janitor
					)
	cost = 15
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper Janitorial supplies crate"
	group = "Supplies"
