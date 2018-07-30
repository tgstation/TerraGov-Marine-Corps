//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.
//We are now moving the price of RO orders to defines, try to respect it.

#define RO_PRICE_VERY_CHEAP	20
#define RO_PRICE_CHEAP		30
#define RO_PRICE_NORMAL		40
#define RO_PRICE_PRICY		60
#define RO_PRICE_VERY_PRICY	100

var/list/all_supply_groups = list("Operations", "Weapons", "Hardpoint Modules", "Attachments", "Ammo", "Armor", "Clothing", "Medical", "Engineering", "Science", "Supplies")

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
	var/randomised_num_contained = 0 //Randomly picks X of items out of the contains list instead of using all.

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
	name = "special operations crate (operator kit x2)"
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
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "special ops crate"
	group = "Operations"

/datum/supply_packs/beacons_supply
	name = "supply beacons crate (x2)"
	contains = list(
			/obj/item/device/squad_beacon,
			/obj/item/device/squad_beacon
			)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "supply beacons crate"
	group = "Operations"

/datum/supply_packs/beacons_orbital
	name = "orbital beacons crate (x2)"
	contains = list(
					/obj/item/device/squad_beacon/bomb,
					/obj/item/device/squad_beacon/bomb
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "orbital beacons crate"
	group = "Operations"

/datum/supply_packs/flares
	name = "flare packs crate (x20)"
	contains = list(
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94
					)
	cost = RO_PRICE_NORMAL
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

	name = "contraband crate"
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/supply
	containername = "unlabeled crate"
	contraband = 1
	group = "Operations"


/*******************************************************************************
WEAPONS
*******************************************************************************/


/datum/supply_packs/flamethrower
	name = "M240 Flamethrower crate (M240 x3)"
	contains = list(
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240 Incinerator crate"
	group = "Weapons"

/datum/supply_packs/pyro
	name = "M240-T fuel crate (extended x2, type-B x1, type-X x1)"
	contains = list(
					/obj/item/ammo_magazine/flamer_tank/large,
					/obj/item/ammo_magazine/flamer_tank/large,
					/obj/item/ammo_magazine/flamer_tank/large/B,
					/obj/item/ammo_magazine/flamer_tank/large/X
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240-T fuel crate"
	group = "Weapons"

/datum/supply_packs/weapons_sentry
	name = "UA 571-C sentry crate (x1)"
	contains = list()
	cost = RO_PRICE_VERY_PRICY
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
	name = "surplus idearms crate (M4A3 x2, M44 x2, ammo x2 each)"
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper sidearms crate"
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
	name = "surplus shotguns crate (M37A2 x2, M37A2 ammo x2 each)"
	cost = RO_PRICE_NORMAL
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
	name = "surplus SMGd crate (M39 x2, M39 ammo x2)"
	cost = RO_PRICE_NORMAL
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
	name = "surplus rifles crate (M41A x2, M41A ammo x2)"
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "\improper rifles crate"
	group = "Weapons"

/datum/supply_packs/gun/heavyweapons
	contains = list(
					/obj/item/weapon/gun/rifle/lmg,
					/obj/item/ammo_magazine/rifle/lmg,
					)
	name = "M41AE2 HPR crate (HPR x1, HPR ammo box x1)"
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "\improper M41AE2 HPR crate"
	group = "Weapons"

/datum/supply_packs/gun/merc
	contains = list()
	name = "black market firearms (x1)"
	cost = RO_PRICE_CHEAP
	contraband = 1
	containertype = /obj/structure/largecrate/guns/merc
	containername = "\improper black market firearms crate"
	group = "Weapons"

/datum/supply_packs/gun_holster
	contains = list(
					/obj/item/storage/large_holster/m39,
					/obj/item/storage/large_holster/m39
					)
	name = "M39 holster crate (x2)"
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "holster crate"
	group = "Weapons"

/datum/supply_packs/gun_holster/m44
	name = "M44 holster crate (x2)"
	cost = RO_PRICE_VERY_CHEAP
	contains = list(
					/obj/item/storage/belt/gun/m44,
					/obj/item/storage/belt/gun/m44
					)
	group = "Weapons"

/datum/supply_packs/gun_holster/m4a3
	name = "M4A3 holster crate (x2)"
	cost = RO_PRICE_VERY_CHEAP
	contains = list(
					/obj/item/storage/belt/gun/m4a3,
					/obj/item/storage/belt/gun/m4a3
					)
	group = "Weapons"

/datum/supply_packs/explosives
	name = "surplus explosives crate (claymore mine x4, M40 HIDP x2, M40 HEDP x2, M15 HE x2)"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosives crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_mines
	name = "claymore mines crate (x8)"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/storage/box/explosive_mines
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive mine boxes crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_m15
	name = "M15 high explosive grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15,
					/obj/item/explosive/grenade/frag/m15
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M15 grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_incendiary
	name = "M40 HIDP incendiary grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary,
					/obj/item/explosive/grenade/incendiary
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 HIDP incendiary grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_M40_HEDP
	name = "M40 HEDP high explosive grenades crate (x5)"
	contains = list(
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag,
					/obj/item/explosive/grenade/frag
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive M40 HEDP grenades crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hedp
	name = "M40 HEDP high explosive grenade box crate (x25)"
	contains = list(
					/obj/item/storage/box/nade_box
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HEDP grenade crate (WARNING)"
	group = "Weapons"


/datum/supply_packs/mortar
	name = "M402 mortar crate (x1)"
	contains = list(
					/obj/item/mortar_kit
					)
	cost = RO_PRICE_VERY_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M402 mortar crate"
	group = "Weapons"

/*******************************************************************************
HARDPOINT MODULES (and their ammo)
*******************************************************************************/

/datum/supply_packs/ltb_cannon
	name = "LTB Cannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/primary/cannon)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun
	name = "LTAA-AP Minigun Assembly (x1)"
	contains = list(/obj/item/hardpoint/primary/minigun)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/flamer_module
	name = "Secondary Flamer Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/flamer)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/towlauncher
	name = "Secondary TOW Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/towlauncher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/m56_cupola
	name = "Secondary M56 Cupola Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/m56cupola)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_glauncher
	name = "Secondary Grenade Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/grenade_launcher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_slauncher
	name = "Smoke Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/support/smoke_launcher)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/weapons_sensor
	name = "Weapons Sensor Array (x1)"
	contains = list(/obj/item/hardpoint/support/weapons_sensor)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/artillery_module
	name = "Artillery Module (x1)"
	contains = list(/obj/item/hardpoint/support/artillery_module)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/overdrive_enhancer
	name = "Overdrive Enhancer (x1)"
	contains = list(/obj/item/hardpoint/support/overdrive_enhancer)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ballistic_armor
	name = "Ballistic Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/ballistic)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/caustic_armor
	name = "Caustic Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/caustic)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/concussive_armor
	name = "Concussive Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/concussive)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/paladin_armor
	name = "Paladin Armor Module (x1)"
	contains = list(/obj/item/hardpoint/armor/paladin)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/snowplow_armor
	name = "Snowplow Module (x1)"
	contains = list(/obj/item/hardpoint/armor/snowplow)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_treads
	name = "Tank Treads (x1)"
	contains = list(/obj/item/hardpoint/treads/standard)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/weapon
	containername = "hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltb_cannon_ammo
	name = "LTB Cannon Magazines (x10)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon,
					/obj/item/ammo_magazine/tank/ltb_cannon)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun_ammo
	name = "LTAA AP Minigun Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_glauncher_ammo
	name = "Grenade Launcher Magazines (x10)"
	contains = list(
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher,
					/obj/item/ammo_magazine/tank/tank_glauncher)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_slauncher_ammo
	name = "Smoke Launcher Magazines (x10)"
	contains = list(
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher,
					/obj/item/ammo_magazine/tank/tank_slauncher)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_towlauncher_ammo
	name = "TOW Launcher Magazines (x4)"
	contains = list(
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_cupola_ammo
	name = "M56 Cupola Magazines (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/m56_cupola,
					/obj/item/ammo_magazine/tank/m56_cupola)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_flamer_ammo
	name = "Flamer Magazines (x5)"
	contains = list(
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "tank ammo crate"
	group = "Hardpoint Modules"


/*******************************************************************************
ATTACHMENTS
*******************************************************************************/


/datum/supply_packs/attachables
	name = "rail attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Attachments"

/datum/supply_packs/rail_reddot
	name = "red-dot sight attachment crate (x8)"
	contains = list(
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot,
					/obj/item/attachable/reddot
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "red-dot sight attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_scope
	name = "railscope attachment crate (x2)"
	contains = list(
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "scope attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_miniscope
	name = "mini railscope attachment crate (x2)"
	contains = list(
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/scope/mini,
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "mini scope attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_magneticharness
	name = "magnetic harness attachment crate (x6)"
	contains = list(
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness,
					/obj/item/attachable/magnetic_harness
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "magnetic harness attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_quickfire
	name = "quickfire adaptor attachment crate (x2)"
	contains = list(
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "quickfire attachment crate"
	group = "Attachments"

/datum/supply_packs/m_attachables
	name = "muzzle attachments crate (x2 each)"
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
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Attachments"

/datum/supply_packs/muzzle_suppressor
	name = "suppressor attachment crate (x8)"
	contains = list(
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor,
					/obj/item/attachable/suppressor
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "suppressor attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_bayonet
	name = "bayonet attachment crate (x8)"
	contains = list(
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet,
					/obj/item/attachable/bayonet
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "bayonet attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_extended
	name = "extended barrel attachment crate (x6)"
	contains = list(
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel,
					/obj/item/attachable/extended_barrel
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "extended barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_heavy
	name = "barrel charger attachment crate (x2)"
	contains = list(
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "heavy barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_compensator
	name = "compensator attachment crate (x6)"
	contains = list(
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator,
					/obj/item/attachable/compensator
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "compensator attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_attachables
	name = "underbarrel attachments crate (x2 each)"
	contains = list(
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/lasersight,
					/obj/item/attachable/lasersight,
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "attachables crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_foregrip
	name = "foregrip attachment crate (x8)"
	contains = list(
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/verticalgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					/obj/item/attachable/angledgrip,
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "foregrip attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_gyro
	name = "gyroscopic stabilizer attachment crate (x2)"
	contains = list(
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "gyro attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_bipod
	name = "bipod attachment crate (x6)"
	contains = list(
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod,
					/obj/item/attachable/bipod
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "bipod attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_shotgun
	name = "underbarrel shotgun attachment crate (x4)"
	contains = list(
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "shotgun attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_flamer
	name = "underbarrel flamer attachment crate (x4)"
	contains = list(
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "flamer attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_burstfire_assembly
	name = "burstfire assembly attachment crate (x2)"
	contains = list(
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "burstfire assembly attachment crate"
	group = "Attachments"

/datum/supply_packs/s_attachables
	name = "stock attachments crate (x3 each)"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/rifle,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/shotgun,
					/obj/item/attachable/stock/smg,
					/obj/item/attachable/stock/smg,
					/obj/item/attachable/stock/smg,
					)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate
	containername = "stocks crate"
	group = "Attachments"

/datum/supply_packs/stock_revolver
	name = "revolver stock attachment crate (x4)"
	contains = list(
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver,
					/obj/item/attachable/stock/revolver
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "stock revolver attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_rifle
	name = "rifle stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle,
			/obj/item/attachable/stock/rifle
			)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "stock rifle attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_shotgun
	name = "shotgun stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun,
			/obj/item/attachable/stock/shotgun
			)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "stock shotgun attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_smg
	name = "submachinegun stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg
			)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "stock smg attachment crate"
	group = "Attachments"


/*******************************************************************************
AMMO
*******************************************************************************/


/datum/supply_packs/ammo_regular
	name = "regular magazines crate (M41A x5, M4A3 x2, M44 x2, M39 x2, M37A2 x1 each)"
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
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m41a
	name = "regular M41A magazines crate (x8)"
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M41A regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m4a3
	name = "regular M4A3 magazines crate (x10)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M4A3 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m44
	name = "regular M44 magazines crate (x10)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M44 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m39
	name = "regular M39 magazines crate (x10)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M39 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_m37a2
	name = "regular M37A2 shells crate (x5 slugs, x5 buckshot)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M37A2 ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended
	name = "extended magazines crate (M41A x2, M4A3 x2, M39 x2)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m41a
	name = "extended M41A magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M41A extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m4a3
	name = "extended M4A3 magazines crate (x8)"
	contains = list(
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended,
					/obj/item/ammo_magazine/pistol/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M4A3 extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_extended_m39
	name = "extended M39 magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended,
					/obj/item/ammo_magazine/smg/m39/extended
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "M39 extended ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap
	name = "armor piercing magazines crate (M41A x2, M4A3 x2, M39 x2)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m41a
	name = "armor piercing M41A magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "M41A armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m4a3
	name = "armor piercing M4A3 magazines crate (x8)"
	contains = list(
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap,
					/obj/item/ammo_magazine/pistol/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "M4A3 armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_ap_m39
	name = "armor piercing M39 magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "M39 armor piercing ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_regular
	name = "M4RA scout magazines crate (regular x3, incendiary x1, impact x1)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra/incendiary,
					/obj/item/ammo_magazine/rifle/m4ra/impact,
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_regular
	name = "M42A sniper magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "regular sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_flak
	name = "M42A sniper flak magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak,
					/obj/item/ammo_magazine/sniper/flak
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "flak sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sniper_incendiary
	name = "M42A sniper incendiary magazines crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary,
					/obj/item/ammo_magazine/sniper/incendiary
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "incendiary sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_regular
	name = "M5 RPG HE rockets crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "regular M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_ap
	name = "M5 RPG AP rockets crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap,
					/obj/item/ammo_magazine/rocket/ap
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/explosives
	containername = "armor piercing M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_rpg_wp
	name = "M5 RPG WP rockets crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp,
					/obj/item/ammo_magazine/rocket/wp
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/explosives
	containername = "white phosphorus M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle
	name = "large M41A ammo box crate (x400 rounds)"
	contains = list(/obj/item/big_ammo_box)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_rifle_ap
	name = "large armor piercing M41A ammo box crate (x400 AP rounds)"
	contains = list(/obj/item/big_ammo_box/ap)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_box_smg
	name = "large M39 ammo box crate (x400 rounds)"
	contains = list(/obj/item/big_ammo_box/smg)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_black_market
	name = "black market ammo crate"
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
					/obj/item/ammo_magazine/sniper/svd,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/mar40,
					/obj/item/ammo_magazine/rifle/mar40/extended,
					)
	cost = RO_PRICE_NORMAL
	contraband = 1
	containertype = /obj/structure/closet/crate/ammo
	containername = "black market ammo crate"
	group = "Ammo"

//This crate has a little bit of everything, mostly okay stuff, but it does have some really unique picks.
/datum/supply_packs/surplus
	name = "surplus ammo crate (x10)"
	randomised_num_contained = 10
	contains = list(
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle/extended,
					/obj/item/ammo_magazine/rifle/ap,
					/obj/item/ammo_magazine/rifle/incendiary,
					/obj/item/ammo_magazine/rifle/m41aMK1,
					/obj/item/ammo_magazine/rifle/m4ra,
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
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/ammo
	containername = "surplus ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartgun
	name = "M56 smartgun powerpack crate (x2)"
	contains = list(
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/ammo
	containername = "smartgun powerpack crate"
	group = "Ammo"

/datum/supply_packs/ammo_sentry
	name = "UA 571-C sentry ammunition (x2)"
	contains = list(
					/obj/item/ammo_magazine/sentry,
					/obj/item/ammo_magazine/sentry
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/napalm
	name = "UT-Napthal Fuel (x6)"
	contains = list(
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/ammo
	containername = "napthal fuel crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_he
	name = "M402 mortar ammo crate (x8 HE)"
	cost = RO_PRICE_PRICY
	contains = list(
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he,
					/obj/item/mortal_shell/he
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_incend
	name = "M402 mortar ammo crate (x6 Incend)"
	cost = RO_PRICE_PRICY
	contains = list(
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary,
					/obj/item/mortal_shell/incendiary
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_flare
	name = "M402 mortar ammo crate (x10 Flare)"
	cost = RO_PRICE_NORMAL
	contains = list(
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare,
					/obj/item/mortal_shell/flare
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_smoke
	name = "M402 mortar ammo crate (x10 Smoke)"
	cost = RO_PRICE_NORMAL
	contains = list(
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke,
					/obj/item/mortal_shell/smoke
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_flash
	name = "M402 mortar ammo crate (x10 Flash)"
	cost = RO_PRICE_NORMAL
	contains = list(
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash,
					/obj/item/mortal_shell/flash
					)
	containertype = /obj/structure/closet/crate/mortar_ammo
	containername = "\improper M402 mortar ammo crate"
	group = "Ammo"

/*******************************************************************************
ARMOR
*******************************************************************************/


/datum/supply_packs/armor_basic
	name = "M3 pattern armor crate (x5 helmet, x5 armor)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "armor crate"
	group = "Armor"

/datum/supply_packs/armor_leader
	name = "M3 pattern squad leader crate (x1 helmet, x1 armor)"
	contains = list(
					/obj/item/clothing/head/helmet/marine/leader,
					/obj/item/clothing/suit/storage/marine/leader
					)
	cost = RO_PRICE_VERY_CHEAP
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
	name = "officer outfit closet"
	cost = RO_PRICE_CHEAP
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
	name = "marine outfit closet"
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet
	containername = "marine outfit closet"
	group = "Clothing"

/datum/supply_packs/webbing
	name = "webbings and holsters crate"
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
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate
	containername = "extra storage crate"
	group = "Clothing"

/datum/supply_packs/pouches_general
	name = "general pouches crate (2x normal, 1x medium, 1x large)"
	contains = list(
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general/medium,
					/obj/item/storage/pouch/general/large
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "general pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_weapons
	name = "weapons pouches crate (1x bayonet, pistol, explosive)"
	contains = list(
					/obj/item/storage/pouch/bayonet,
					/obj/item/storage/pouch/pistol,
					/obj/item/storage/pouch/explosive
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "weapons pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_ammo
	name = "ammo pouches crate (1x normal, large, pistol, pistol large)"
	contains = list(
					/obj/item/storage/pouch/magazine,
					/obj/item/storage/pouch/magazine/large,
					/obj/item/storage/pouch/magazine/pistol,
					/obj/item/storage/pouch/magazine/pistol/large
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "ammo pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_medical
	name = "medical pouches crate (1x firstaid, medical, syringe, medkit, autoinjector)"
	contains = list(
					/obj/item/storage/pouch/firstaid,
					/obj/item/storage/pouch/medical,
					/obj/item/storage/pouch/syringe,
					/obj/item/storage/pouch/medkit,
					/obj/item/storage/pouch/autoinjector,
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "medical pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_survival
	name = "survival pouches crate (1x radio, flare, survival)"
	contains = list(
					/obj/item/storage/pouch/radio,
					/obj/item/storage/pouch/flare,
					/obj/item/storage/pouch/survival
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "survival pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_construction
	name = "construction pouches crate (1x document, electronics, tools, construction)"
	contains = list(
					/obj/item/storage/pouch/document,
					/obj/item/storage/pouch/electronics,
                    /obj/item/storage/pouch/tools,
					/obj/item/storage/pouch/construction
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate
	containername = "construction pouches crate"
	group = "Clothing"


/*******************************************************************************
MEDICAL
*******************************************************************************/


/datum/supply_packs/medical
	name = "medical crate"
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
					/obj/item/storage/pill_bottle/quickclot,
					/obj/item/storage/pill_bottle/peridaxon,
					/obj/item/storage/box/pillbottles
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"

/datum/supply_packs/firstaid
	name = "first aid kit crate (2x each)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "medical crate"
	group = "Medical"

/datum/supply_packs/bodybag
	name = "body bag crate (x28)"
	contains = list(
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags
			)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "body bag crate"
	group = "Medical"

/datum/supply_packs/cryobag
	name = "stasis bag crate (x3)"
	contains = list(
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag
			)
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/medical
	containername = "stasis bag crate"
	group = "Medical"

/datum/supply_packs/surgery
	name = "surgery crate (x2 surgical trays)"
	contains = list(
					/obj/item/storage/surgical_tray,
					/obj/item/storage/surgical_tray
					)
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/anesthetic
	name = "anesthetic crate (x4 masks, x4 tanks)"
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
	cost = RO_PRICE_CHEAP
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/sterile
	name = "sterile equipment crate"
	contains = list(
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/clothing/under/rank/medical/green,
					/obj/item/storage/box/masks,
					/obj/item/storage/box/gloves
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/medical
	containername = "sterile equipment crate"
	group = "Medical"


/*******************************************************************************
ENGINEERING
*******************************************************************************/


/datum/supply_packs/sandbags
	name = "empty sandbags crate (x50)"
	contains = list(/obj/item/stack/sandbags_empty)
	amount = 50
	cost = RO_PRICE_VERY_CHEAP
	containertype = "/obj/structure/closet/crate/supply"
	containername = "empty sandbags crate"
	group = "Engineering"

/datum/supply_packs/metal50
	name = "50 metal sheets (x50)"
	contains = list(/obj/item/stack/sheet/metal)
	amount = 50
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "metal sheets crate"
	group = "Engineering"

/datum/supply_packs/plas50
	name = "plasteel sheets (x30)"
	contains = list(/obj/item/stack/sheet/plasteel)
	amount = 30
	cost = RO_PRICE_NORMAL
	containertype = /obj/structure/closet/crate/supply
	containername = "plasteel sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 glass sheets (x50)"
	contains = list(/obj/item/stack/sheet/glass)
	amount = 50
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "glass sheets crate"
	group = "Engineering"

/datum/supply_packs/wood50
	name = "wooden planks (x50)"
	contains = list(/obj/item/stack/sheet/wood)
	amount = 50
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "wooden planks crate"
	group = "Engineering"

/datum/supply_packs/smescoil
	name = "superconducting magnetic coil crate (x1)"
	contains = list(/obj/item/stock_parts/smes_coil)
	cost = RO_PRICE_PRICY
	containertype = /obj/structure/closet/crate/construction
	containername = "superconducting magnetic coil crate"
	group = "Engineering"

/datum/supply_packs/electrical
	name = "electrical maintenance crate (toolbox x2, insulated x2, cell x2, hi-cap cell x2)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/construction
	containername = "electrical maintenance crate"
	group = "Engineering"

/datum/supply_packs/mechanical
	name = "mechanical maintenance crate (utility belt x3, hazard vest x3, welding helmet x2, hard hat x1)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/construction
	containername = "mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/fueltank
	name = "fuel tank crate (x1)"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/largecrate
	containername = "fuel tank crate"
	group = "Engineering"

/datum/supply_packs/inflatable
	name = "inflatable barriers (x9 doors, x12 walls)"
	contains = list(
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/construction
	containername = "inflatable barriers crate"
	group = "Engineering"

/datum/supply_packs/lightbulbs
	name = "replacement lights (x42 tube, x21 bulb)"
	contains = list(
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "replacement lights crate"
	group = "Engineering"

/datum/supply_packs/pacman_parts
	name = "P.A.C.M.A.N. portable generator parts"
	contains = list(
				/obj/item/stock_parts/micro_laser,
				/obj/item/stock_parts/capacitor,
				/obj/item/stock_parts/matter_bin,
				/obj/item/circuitboard/machine/pacman
				)
	cost = RO_PRICE_CHEAP
	containername = "\improper P.A.C.M.A.N. portable generator construction kit"
	containertype = /obj/structure/closet/crate/secure
	group = "Engineering"


/datum/supply_packs/super_pacman_parts
	name = "Super P.A.C.M.A.N. portable generator parts"
	cost = RO_PRICE_NORMAL
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
	name = "phoron assembly crate"
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
	cost = RO_PRICE_PRICY
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/freezer
	containername = "\improper MRE crate"
	group = "Supplies"

/datum/supply_packs/internals
	name = "oxygen internals crate (x3 masks, x3 tanks)"
	contains = list(
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/clothing/mask/gas,
					/obj/item/tank/air,
					/obj/item/tank/air,
					/obj/item/tank/air
					)
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/internals
	containername = "internals crate"
	group = "Supplies"

/datum/supply_packs/evacuation
	name = "emergency equipment (x2 toolbox, x2 hazard vest, x5 oxygen tank, x5 masks)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/internals
	containername = "emergency crate"
	group = "Supplies"

/datum/supply_packs/boxes
	name = "empty boxes (x10)"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = "/obj/structure/closet/crate/supply"
	containername = "empty box crate"
	group = "Supplies"

/datum/supply_packs/janitor
	name = "assorted janitorial supplies"
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
	cost = RO_PRICE_VERY_CHEAP
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper Janitorial supplies crate"
	group = "Supplies"
