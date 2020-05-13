//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

GLOBAL_LIST_INIT(all_supply_groups, list("Operations", "Weapons", "Hardpoint Modules", "Attachments", "Ammo", "Armor", "Clothing", "Medical", "Engineering", "Supplies", "Imports"))

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
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


/datum/supply_packs/proc/generate(atom/movable/location)
	for(var/i in contains)
		var/atom/movable/AM = i
		new AM(location)


/*******************************************************************************
OPERATIONS
*******************************************************************************/

/datum/supply_packs/beacons_supply
	name = "supply beacons crate (x2)"
	contains = list(
			/obj/item/squad_beacon,
			/obj/item/squad_beacon
			)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper supply beacons crate"
	group = "Operations"

/datum/supply_packs/beacons_orbital
	name = "orbital beacons crate (x2)"
	contains = list(
					/obj/item/squad_beacon/bomb,
					/obj/item/squad_beacon/bomb
					)
	cost = 60
	containertype = /obj/structure/closet/crate
	containername = "\improper orbital beacons crate"
	group = "Operations"

/datum/supply_packs/binoculars_regular
	name = "binoculars crate (x1)"
	contains = list(
					/obj/item/binoculars
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper binoculars crate"
	group = "Operations"

/datum/supply_packs/binoculars_tatical
	name = "tactical binoculars crate (x1)"
	contains = list(
					/obj/item/binoculars/tactical
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper tactical binoculars crate"
	group = "Operations"

/datum/supply_packs/flares
	name = "flare packs crate (x28)"
	contains = list(
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94,
					/obj/item/storage/box/m94
					)
	cost = 10
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper flare pack crate"
	group = "Operations"

/datum/supply_packs/tarps
	name = "V1 thermal-dampening tarp crate (x5)"
	contains = list(
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp,
					/obj/item/bodybag/tarp
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper V1 thermal-dampening tarp crate"
	group = "Operations"

/datum/supply_packs/alpha
	name = "Alpha Supply Crate"
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate/alpha
	containername = "\improper Alpha Supply Crate"
	group = "Operations"

/datum/supply_packs/bravo
	name = "Bravo Supply Crate"
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate/bravo
	containername = "\improper Bravo Supply Crate"
	group = "Operations"

/datum/supply_packs/charlie
	name = "Charlie Supply Crate"
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate/charlie
	containername = "\improper Charlie Supply Crate"
	group = "Operations"

/datum/supply_packs/delta
	name = "Delta Supply Crate"
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate/delta
	containername = "\improper Delta Supply Crate"
	group = "Operations"

/*******************************************************************************
WEAPONS
*******************************************************************************/

/datum/supply_packs/weapons_sentry
	name = "UA 571-C Base Defense Sentry (x1)"
	contains = list(
					/obj/item/storage/box/sentry
					)
	cost = 120
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper sentry crate"
	group = "Weapons"

/datum/supply_packs/weapons_minisentry
	name = "UA-580 Portable Sentry (x1)"
	contains = list(
					/obj/item/storage/box/minisentry
					)
	cost = 70
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper mini-sentry crate"
	group = "Weapons"

/datum/supply_packs/weapons_m56d_emplacement
	name = "M56D Stationary Machinegun (x1)"
	contains = list(
					/obj/item/storage/box/m56d_hmg
					)
	cost = 80
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M56D emplacement crate"
	group = "Weapons"

/datum/supply_packs/specgrenadier
	name = "Grenadier Specialist crate (M92 x1, HEDP Grenade Box x1)"
	contains = list(
					/obj/item/weapon/gun/launcher/m92,
					/obj/item/storage/box/nade_box
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Grenadier Specialist crate"
	group = "Weapons"

/datum/supply_packs/specscout
	name = "Scout Specialist crate (M4RA x1, M4RA Magazines x2)"
	contains = list(
					/obj/item/weapon/gun/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Scout Specialist crate"
	group = "Weapons"

/datum/supply_packs/specscout2
	name = "Scout Specialist crate (MBX900 x1, Sabot Box x1)"
	contains = list(
					/obj/item/weapon/gun/shotgun/pump/lever/mbx900,
					/obj/item/ammo_magazine/shotgun/mbx900
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Scout Shotgun Specialist crate"
	group = "Weapons"

/datum/supply_packs/specdemo
	name = "Demolitionist Specialist crate (M5 RPG x1, HE Rockets x2)"
	contains = list(
					/obj/item/weapon/gun/launcher/rocket,
					/obj/item/ammo_magazine/rocket,
					/obj/item/ammo_magazine/rocket
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Demolitionist Specialist crate"
	group = "Weapons"

/datum/supply_packs/specpyro
	name = "Pyro Specialist crate (M240T x1, Fuel Backpack x1)"
	contains = list(
					/obj/item/weapon/gun/flamer/M240T,
					/obj/item/storage/backpack/marine/engineerpack/flamethrower
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Pyro Specialist crate"
	group = "Weapons"

/datum/supply_packs/specsniper
	name = "Sniper Specialist crate (M42A x1, M42A Magazines x2)"
	contains = list(
					/obj/item/weapon/gun/rifle/sniper/M42A,
					/obj/item/ammo_magazine/sniper,
					/obj/item/ammo_magazine/sniper
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Sniper Specialist crate"
	group = "Weapons"

/datum/supply_packs/specminigun
	name = "MIC-A7 Vindicator Minigun crate (MIC-A7 x1, MIC-A7 Ammo Drum x1)"
	contains = list(
					/obj/item/weapon/gun/minigun,
					/obj/item/ammo_magazine/minigun
					)
	cost = 100
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper MIC A7 Vindicator Minigun crate"
	group = "Weapons"

/datum/supply_packs/flamethrower
	name = "M240 Flamethrower crate (M240 x3, M240 Tanks x3)"
	contains = list(
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/weapon/gun/flamer,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank
					)
	cost = 40
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240 Flamethrower crate"
	group = "Weapons"

/datum/supply_packs/gun/mateba
	contains = list(
					/obj/item/storage/belt/gun/mateba/full,
					/obj/item/storage/belt/gun/mateba/full
					)
	name = "Mateba Autorevolver crate (Mateba x2, Mateba holster rig x2, Mateba speed loader x12)"
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper Mateba crate"
	group = "Weapons"

/datum/supply_packs/gun/pistols
	contains = list(
					/obj/item/weapon/gun/pistol/standard_pistol,
					/obj/item/weapon/gun/pistol/standard_pistol,
					/obj/item/ammo_magazine/pistol/standard_pistol,
					/obj/item/ammo_magazine/pistol/standard_pistol,
					/obj/item/weapon/gun/revolver/standard_revolver,
					/obj/item/weapon/gun/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver
					)
	name = "surplus sidearms crate (TP-14 x2, TP-44 x2, ammo x2 each)"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper sidearms crate"
	group = "Weapons"

/datum/supply_packs/gun/shotguns
	contains = list(
					/obj/item/weapon/gun/shotgun/pump/t35,
					/obj/item/weapon/gun/shotgun/pump/t35,
					/obj/item/weapon/gun/rifle/standard_autoshotgun,
					/obj/item/weapon/gun/rifle/standard_autoshotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/shotgun/flechette,
					/obj/item/ammo_magazine/rifle/tx15_slug,
					/obj/item/ammo_magazine/rifle/tx15_slug,
					/obj/item/ammo_magazine/rifle/tx15_slug,
					/obj/item/ammo_magazine/rifle/tx15_flechette,
					/obj/item/ammo_magazine/rifle/tx15_flechette,
					/obj/item/ammo_magazine/rifle/tx15_flechette,
					)
	name = "surplus shotguns crate (T-35 x2, T-35 ammo x2 each, TX-15 x2, TX Flechette and slugs x3 each)"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper shotguns crate"
	group = "Weapons"

/datum/supply_packs/gun/smgs
	contains = list(
					/obj/item/weapon/gun/smg/standard_smg,
					/obj/item/weapon/gun/smg/standard_smg,
					/obj/item/ammo_magazine/smg/standard_smg,
					/obj/item/ammo_magazine/smg/standard_smg,
					)
	name = "surplus SMG crate (T-19 x2, 2x Standard)"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper SMGs crate"
	group = "Weapons"

/datum/supply_packs/gun/rifles
	contains = list(
					/obj/item/weapon/gun/rifle/standard_carbine,
					/obj/item/weapon/gun/rifle/standard_carbine,
					/obj/item/ammo_magazine/rifle/standard_carbine,
					/obj/item/ammo_magazine/rifle/standard_carbine,
					)
	name = "surplus rifles crate (T-18 x2, T-18 ammo x2)"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper rifles crate"
	group = "Weapons"

/datum/supply_packs/gun/lasrifle
	contains = list(
					/obj/item/weapon/gun/energy/lasgun/lasrifle,
					/obj/item/weapon/gun/energy/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle
					)
	name = "surplus lasrifle crate (TX-73 lasrifle x2, TX-73 battery packs x2)"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper lasrifle crate"
	group = "Weapons"

/datum/supply_packs/gun/heavyrifle_squad
	contains = list(
					/obj/item/weapon/gun/rifle/standard_lmg,
					/obj/item/weapon/gun/rifle/standard_lmg,
					/obj/item/weapon/gun/rifle/standard_lmg,
					/obj/item/weapon/gun/rifle/standard_lmg,
					/obj/item/weapon/gun/rifle/standard_lmg,
					/obj/item/ammo_magazine/standard_lmg,
					/obj/item/ammo_magazine/standard_lmg,
					/obj/item/ammo_magazine/standard_lmg,
					/obj/item/ammo_magazine/standard_lmg,
					/obj/item/ammo_magazine/standard_lmg
					)
	name = "T-42 LMG squad crate (LMG x5, LMG ammo drums x5)"
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "\improper T-42 LMG squad crate"
	group = "Weapons"

/datum/supply_packs/gun/combatshotgun
	contains = list(
					/obj/item/weapon/gun/shotgun/combat,
					/obj/item/ammo_magazine/shotgun/,
					/obj/item/ammo_magazine/shotgun/buckshot,
					/obj/item/ammo_magazine/shotgun/flechette
					)
	name = "MK221 tactical shotgun (MK221 x1, one box of each shell type)"
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper MK221 tactical shotgun crate"
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
	cost = 20
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosives crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_mines
	name = "claymore mines crate (x10)"
	contains = list(
					/obj/item/storage/box/explosive_mines,
					/obj/item/storage/box/explosive_mines
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive mine boxes crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hedp
	name = "M40 HEDP high explosive grenade box crate (x25)"
	contains = list(
					/obj/item/storage/box/nade_box
					)
	cost = 50
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HEDP grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hidp
	name = "M40 HIDP incendiary explosive grenade box crate (x25)"
	contains = list(
					/obj/item/storage/box/nade_box/HIDP
					)
	cost = 50
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HIDP grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_m15
	name = "M15 fragmentation grenade box crate (x15)"
	contains = list(
					/obj/item/storage/box/nade_box/M15
					)
	cost = 50
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper Fragmentation M15 grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/explosives_hsdp
	name = "M40 HSDP white phosphorous grenade box crate (x15)"
	contains = list(
					/obj/item/storage/box/nade_box/phos
					)
	cost = 70
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper explosive HSDP grenade crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/plastique
	name = "C4 plastic explosives crate (x5)"
	contains = list(
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique,
					/obj/item/explosive/plastique
					)
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper plastic explosives crate (WARNING)"
	group = "Weapons"

/datum/supply_packs/mortar
	name = "M402 mortar crate (x1)"
	contains = list(
					/obj/item/mortar_kit
					)
	cost = 40
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M402 mortar crate"
	group = "Weapons"

/datum/supply_packs/detpack
	name = "detpack explosives crate (Detpack x6, Signaler x3)"
	contains = list(
					/obj/item/detpack,
					/obj/item/detpack,
					/obj/item/detpack,
					/obj/item/detpack,
					/obj/item/detpack,
					/obj/item/detpack,
					/obj/item/assembly/signaler,
					/obj/item/assembly/signaler,
					/obj/item/assembly/signaler,
					)
	cost = 50
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper detpack explosives crate (WARNING)"
	group = "Weapons"

/*******************************************************************************
HARDPOINT MODULES (and their ammo)
*******************************************************************************/

/datum/supply_packs/ltb_cannon
	name = "LTB Cannon Assembly (x1)"
	contains = list(/obj/item/hardpoint/primary/cannon)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun
	name = "LTAA-AP Minigun Assembly (x1)"
	contains = list(/obj/item/hardpoint/primary/minigun)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/flamer_module
	name = "Secondary Flamer Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/flamer)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/towlauncher
	name = "Secondary TOW Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/towlauncher)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/m56_cupola
	name = "Secondary M56 Cupola Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/m56cupola)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_glauncher
	name = "Secondary Grenade Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/secondary/grenade_launcher)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_slauncher
	name = "Smoke Launcher Assembly (x1)"
	contains = list(/obj/item/hardpoint/support/smoke_launcher)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/weapons_sensor
	name = "Weapons Sensor Array (x1)"
	contains = list(/obj/item/hardpoint/support/weapons_sensor)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/artillery_module
	name = "Artillery Module (x1)"
	contains = list(/obj/item/hardpoint/support/artillery_module)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/overdrive_enhancer
	name = "Overdrive Enhancer (x1)"
	contains = list(/obj/item/hardpoint/support/overdrive_enhancer)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ballistic_armor
	name = "Ballistic Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/ballistic)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/caustic_armor
	name = "Caustic Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/caustic)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/concussive_armor
	name = "Concussive Armor Plating (x1)"
	contains = list(/obj/item/hardpoint/armor/concussive)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/paladin_armor
	name = "Paladin Armor Module (x1)"
	contains = list(/obj/item/hardpoint/armor/paladin)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/snowplow_armor
	name = "Snowplow Module (x1)"
	contains = list(/obj/item/hardpoint/armor/snowplow)
	cost = 40
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_treads
	name = "Tank Treads (x1)"
	contains = list(/obj/item/hardpoint/treads/standard)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper hardpoint module assembly crate"
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
					/obj/item/ammo_magazine/tank/ltb_cannon
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/ltaaap_minigun_ammo
	name = "LTAA AP Minigun Magazines (x3)"
	contains = list(
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun,
					/obj/item/ammo_magazine/tank/ltaaap_minigun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
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
					/obj/item/ammo_magazine/tank/tank_glauncher
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
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
					/obj/item/ammo_magazine/tank/tank_slauncher
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_towlauncher_ammo
	name = "TOW Launcher Magazines (x4)"
	contains = list(
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher,
					/obj/item/ammo_magazine/tank/towlauncher
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_cupola_ammo
	name = "M56 Cupola Magazines (x2)"
	contains = list(
					/obj/item/ammo_magazine/tank/m56_cupola,
					/obj/item/ammo_magazine/tank/m56_cupola
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
	group = "Hardpoint Modules"

/datum/supply_packs/tank_flamer_ammo
	name = "Flamer Magazines (x5)"
	contains = list(
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer,
					/obj/item/ammo_magazine/tank/flamer
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper tank ammo crate"
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
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper attachables crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper red-dot sight attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_scope
	name = "railscope attachment crate (x2)"
	contains = list(
					/obj/item/attachable/scope,
					/obj/item/attachable/scope,
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper scope attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_miniscope
	name = "mini railscope attachment crate (x2)"
	contains = list(
					/obj/item/attachable/scope/mini,
					/obj/item/attachable/scope/mini,
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper mini scope attachment crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper magnetic harness attachment crate"
	group = "Attachments"

/datum/supply_packs/rail_quickfire
	name = "quickfire adaptor attachment crate (x2)"
	contains = list(
					/obj/item/attachable/quickfire,
					/obj/item/attachable/quickfire
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper quickfire attachment crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper attachables crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper suppressor attachment crate"
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
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper bayonet attachment crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper extended barrel attachment crate"
	group = "Attachments"

/datum/supply_packs/muzzle_heavy
	name = "barrel charger attachment crate (x3)"
	contains = list(
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel,
					/obj/item/attachable/heavy_barrel
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper heavy barrel attachment crate"
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
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper compensator attachment crate"
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
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper attachables crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper foregrip attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_gyro
	name = "gyroscopic stabilizer attachment crate (x2)"
	contains = list(
					/obj/item/attachable/gyro,
					/obj/item/attachable/gyro
					)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "\improper gyro attachment crate"
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
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "\improper bipod attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_shotgun
	name = "underbarrel shotgun attachment crate (x4)"
	contains = list(
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun,
					/obj/item/attachable/attached_gun/shotgun
					)
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "\improper shotgun attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_flamer
	name = "underbarrel flamer attachment crate (x4)"
	contains = list(
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer,
					/obj/item/attachable/attached_gun/flamer
					)
	cost = 25
	containertype = /obj/structure/closet/crate
	containername = "\improper flamer attachment crate"
	group = "Attachments"

/datum/supply_packs/underbarrel_burstfire_assembly
	name = "burstfire assembly attachment crate (x2)"
	contains = list(
					/obj/item/attachable/burstfire_assembly,
					/obj/item/attachable/burstfire_assembly
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper burstfire assembly attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_shotgun
	name = "shotgun stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/t35stock,
			/obj/item/attachable/stock/t35stock,
			/obj/item/attachable/stock/t35stock,
			/obj/item/attachable/stock/t35stock
			)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper shotgun stock attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_smg
	name = "submachinegun stock attachment crate (x4)"
	contains = list(
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg,
			/obj/item/attachable/stock/smg
			)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper smg stock attachment crate"
	group = "Attachments"

/datum/supply_packs/stock_smg
	name = "combat shotgun stock attachment crate (x3)"
	contains = list(
			/obj/item/attachable/stock/tactical,
			/obj/item/attachable/stock/tactical,
			/obj/item/attachable/stock/tactical
			)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper combat shotgun attachment crate"
	group = "Attachments"

/*******************************************************************************
AMMO
*******************************************************************************/
/datum/supply_packs/ammoboxslug
	name = "Slug Ammo Box Crate"
	contains = list(
					/obj/item/shotgunbox
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Slug ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxbuckshot
	name = "Buckshot Ammo Box Crate"
	contains = list(
					/obj/item/shotgunbox/buckshot
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Buckshot ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxflechette
	name = "Flechette Ammo Box Crate"
	contains = list(
					/obj/item/shotgunbox/flechette
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Flechette ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxcarbine
	name = "T-18 Carbine Ammo Box Crate"
	contains = list(
					/obj/item/ammobox
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper T-18 Carbine ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxrifle
	name = "T-12 Assault Rifle Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/standard_rifle
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper T-12 Assault Rifle ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxsmg
	name = "T-19 SMG Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/standard_smg
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper T-19 SMG ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxlmg
	name = "T-42 LMG Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/standard_lmg
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper T-42 LMG ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxdmr
	name = "T-64 DMR Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/standard_dmr
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper T-64 DMR ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammoboxpistol
	name = "TP-14 Pistol Ammo Box Crate"
	contains = list(
					/obj/item/ammobox/standard_pistol
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper TP-14 Pistol ammo box crate"
	group = "Ammo"

/datum/supply_packs/ammo_regular_tp44
	name = "regular TP-44 magazines crate (x15)"
	contains = list(
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver,
					/obj/item/ammo_magazine/revolver/standard_revolver
					)
	cost = 10
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper TP-44 regular ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_mateba
	name = "Mateba magazines crate (x10)"
	contains = list(
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba,
					/obj/item/ammo_magazine/revolver/mateba
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Mateba speed loader crate"
	group = "Ammo"

/datum/supply_packs/ammo_incendiaryslugs
	name = "Box of Incendiary Slugs (x2)"
	contains = list(
					/obj/item/ammo_magazine/shotgun/incendiary,
					/obj/item/ammo_magazine/shotgun/incendiary
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper Incendiary slug ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_regular
	name = "M4RA scout magazines crate (x5)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra,
					/obj/item/ammo_magazine/rifle/m4ra
					)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper regular scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_impact
	name = "M4RA scout impact magazines crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra/impact,
					/obj/item/ammo_magazine/rifle/m4ra/impact,
					/obj/item/ammo_magazine/rifle/m4ra/impact
					)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper impact scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_incendiary
	name = "M4RA scout incendiary magazines crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra/incendiary,
					/obj/item/ammo_magazine/rifle/m4ra/incendiary,
					/obj/item/ammo_magazine/rifle/m4ra/incendiary
					)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper incendiary scout ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_scout_smart
	name = "M4RA scout smart magazines crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/rifle/m4ra/smart,
					/obj/item/ammo_magazine/rifle/m4ra/smart,
					/obj/item/ammo_magazine/rifle/m4ra/smart
					)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper smart scout ammo crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper regular sniper ammo crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper flak sniper ammo crate"
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
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper incendiary sniper ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_mbx900
	name = "MBX 900 ammo crate (x2 sabot, x2 buckshot, x1 tracking)"
	contains = list(
					/obj/item/ammo_magazine/shotgun/mbx900,
					/obj/item/ammo_magazine/shotgun/mbx900,
					/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
					/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
					/obj/item/ammo_magazine/shotgun/mbx900/tracking
					)
	cost = 40
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper MBX 900 ammo crate"
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
	cost = 40
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper regular M5 RPG ammo crate"
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
	cost = 40
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper armor piercing M5 RPG ammo crate"
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
	cost = 30
	containertype = /obj/structure/closet/crate/explosives
	containername = "\improper white phosphorus M5 RPG ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartgun
	name = "M56 smartgun powerpack crate (x5)"
	contains = list(
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack,
					/obj/item/smartgun_powerpack
					)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper smartgun powerpack crate"
	group = "Ammo"

/datum/supply_packs/ammo_smartmachinegun
	name = "T26 smartmachinegun ammo crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/standard_smartmachinegun,
					/obj/item/ammo_magazine/standard_smartmachinegun,
					/obj/item/ammo_magazine/standard_smartmachinegun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper T-26 ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_sentry
	name = "UA 571-C sentry ammunition (x2)"
	contains = list(
					/obj/item/ammo_magazine/sentry,
					/obj/item/ammo_magazine/sentry
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper sentry ammo crate"
	group = "Ammo"

/datum/supply_packs/napalm
	name = "M240 fuel crate (x6)"
	contains = list(
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank,
					/obj/item/ammo_magazine/flamer_tank
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M240 fuel crate"
	group = "Ammo"

/datum/supply_packs/pyro
	name = "M240-T fuel crate (extended x2, type-B x1, type-X x1)"
	contains = list(
					/obj/item/ammo_magazine/flamer_tank/large,
					/obj/item/ammo_magazine/flamer_tank/large,
					/obj/item/ammo_magazine/flamer_tank/large/B,
					/obj/item/ammo_magazine/flamer_tank/large/X
					)
	cost = 60
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M240-T fuel crate"
	group = "Ammo"

/datum/supply_packs/mortar_ammo_he
	name = "M402 mortar ammo crate (x8 HE)"
	cost = 20
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
	name = "M402 mortar ammo crate (x8 Incend)"
	cost = 20
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
	cost = 10
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
	cost = 10
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
	cost = 10
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

/datum/supply_packs/ammo_minisentry
	name = "UA-580 point defense sentry ammo crate (x3)"
	contains = list(
					/obj/item/ammo_magazine/minisentry,
					/obj/item/ammo_magazine/minisentry,
					/obj/item/ammo_magazine/minisentry
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper mini-sentry ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_m56d
	name = "M56D mounted smartgun ammo crate (x2)"
	contains = list(
					/obj/item/ammo_magazine/m56d,
					/obj/item/ammo_magazine/m56d
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper M56D emplacement ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_lasguncharger
	name = "ColMarTech Lasrifle Field Charger (TX-73 x10, TX-73 Highcap x2)"
	contains = list(
					/obj/machinery/vending/lasgun
					)
	cost = 60
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper ColMarTech Lasrifle Field Charger"
	group = "Ammo"

/datum/supply_packs/ammo_lasgun
	name = "TX-73 lasrifle battery crate (TX-73 x15)"
	contains = list(
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle,
					/obj/item/cell/lasgun/lasrifle
					)
	cost = 20
	containertype = /obj/structure/closet/crate/ammo
	containername = "lasrifle battery crate"
	group = "Ammo"

/datum/supply_packs/ammo_lasgun_highcap
	name = "TX-73 lasrifle highcap battery crate (TX-73 highcap x7)"
	contains = list(
					/obj/item/cell/lasgun/lasrifle/highcap,
					/obj/item/cell/lasgun/lasrifle/highcap,
					/obj/item/cell/lasgun/lasrifle/highcap,
					/obj/item/cell/lasgun/lasrifle/highcap,
					/obj/item/cell/lasgun/lasrifle/highcap,
					/obj/item/cell/lasgun/lasrifle/highcap,
					/obj/item/cell/lasgun/lasrifle/highcap
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "ammo crate"
	group = "Ammo"

/datum/supply_packs/ammo_minigun
	name = "Vindicator Minigun Ammo Drums (x3)"
	contains = list(
					/obj/item/ammo_magazine/minigun,
					/obj/item/ammo_magazine/minigun,
					/obj/item/ammo_magazine/minigun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/ammo
	containername = "\improper minigun ammo crate"
	group = "Ammo"


/*******************************************************************************
ARMOR
*******************************************************************************/

/datum/supply_packs/armor_masks
	name = "SWAT protective masks (x4)"
	contains = list(
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/mask/gas/swat,
					/obj/item/clothing/mask/gas/swat
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper anti-hugger crate"
	group = "Armor"

/datum/supply_packs/armor_riot
	name = "Heavy Riot Armor Set"
	contains = list(
					/obj/item/clothing/suit/armor/riot/marine,
					/obj/item/clothing/head/helmet/riot
					)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "\improper Riot armor crate"
	group = "Armor"

/datum/supply_packs/armor_b18
	name = "B18 Armor Set"
	contains = list(
					/obj/item/clothing/suit/storage/marine/specialist,
					/obj/item/clothing/head/helmet/marine/specialist
					)
	cost = 200
	containertype = /obj/structure/closet/crate
	containername = "\improper B18 armor crate"
	group = "Armor"

/datum/supply_packs/armor_b17
	name = "B17 Armor Set"
	contains = list(
					/obj/item/clothing/suit/storage/marine/B17,
					/obj/item/clothing/head/helmet/marine/grenadier
					)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "\improper B17 armor crate"
	group = "Armor"

/datum/supply_packs/armor_pyro
	name = "Pyro Armor Set"
	contains = list(
					/obj/item/clothing/suit/storage/marine/M35,
					/obj/item/clothing/head/helmet/marine/pyro,
					/obj/item/clothing/shoes/marine/pyro
					)
	cost = 100
	containertype = /obj/structure/closet/crate
	containername = "\improper Pyro armor crate"
	group = "Armor"

/datum/supply_packs/armor_basic
	name = "M3 pattern armor crate (x5 helmet, x5 armor)"
	contains = list(
					/obj/item/clothing/head/helmet/marine/standard,
					/obj/item/clothing/head/helmet/marine/standard,
					/obj/item/clothing/head/helmet/marine/standard,
					/obj/item/clothing/head/helmet/marine/standard,
					/obj/item/clothing/head/helmet/marine/standard,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine,
					/obj/item/clothing/suit/storage/marine
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper armor crate"
	group = "Armor"

/datum/supply_packs/armor_leader
	name = "M3 pattern squad leader crate (x1 helmet, x1 armor)"
	contains = list(
					/obj/item/clothing/head/helmet/marine/leader,
					/obj/item/clothing/suit/storage/marine/leader
					)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper squad leader armor crate"
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
	name = "officer outfit crate"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper officer dress crate"
	group = "Clothing"

/datum/supply_packs/marine_outfits
	contains = list(
					/obj/item/clothing/under/marine/standard,
					/obj/item/clothing/under/marine/standard,
					/obj/item/clothing/under/marine/standard,
					/obj/item/storage/belt/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/belt/marine,
					/obj/item/storage/backpack/marine/standard,
					/obj/item/storage/backpack/marine/standard,
					/obj/item/storage/backpack/marine/standard,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine,
					/obj/item/clothing/shoes/marine
					)
	name = "marine outfit crate"
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "\improper marine outfit crate"
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
					/obj/item/storage/belt/gun/pistol/standard_pistol,
					/obj/item/storage/belt/gun/revolver/standard_revolver,
					/obj/item/storage/large_holster/t19
					)
	cost = 40
	containertype = /obj/structure/closet/crate
	containername = "\improper extra storage crate"
	group = "Clothing"

/datum/supply_packs/T19_holster
	contains = list(
					/obj/item/storage/large_holster/t19,
					/obj/item/storage/large_holster/t19
					)
	name = "T-19 holster crate (x2)"
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper holster crate"
	group = "Clothing"

/datum/supply_packs/gun_holster/revolver
	name = "TP-44 holster crate (x2)"
	cost = 10
	contains = list(
					/obj/item/storage/belt/gun/revolver/standard_revolver,
					/obj/item/storage/belt/gun/revolver/standard_revolver
					)
	group = "Clothing"

/datum/supply_packs/gun_holster/pistol
	name = "TP-14 holster crate (x2)"
	cost = 10
	contains = list(
					/obj/item/storage/belt/gun/pistol/standard_pistol,
					/obj/item/storage/belt/gun/pistol/standard_pistol
					)
	group = "Clothing"

/datum/supply_packs/pouches_general
	name = "general pouches crate (2x normal, 1x medium, 1x large)"
	contains = list(
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general,
					/obj/item/storage/pouch/general/medium,
					/obj/item/storage/pouch/general/large
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper general pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_weapons
	name = "weapons pouches crate (1x bayonet, sidearm, explosive)"
	contains = list(
					/obj/item/storage/pouch/bayonet,
					/obj/item/storage/pouch/pistol,
					/obj/item/storage/pouch/explosive
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper weapons pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_ammo
	name = "ammo pouches crate (1x normal, large, pistol, large pistol)"
	contains = list(
					/obj/item/storage/pouch/magazine,
					/obj/item/storage/pouch/magazine/large,
					/obj/item/storage/pouch/magazine/pistol,
					/obj/item/storage/pouch/magazine/pistol/large
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper ammo pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_medical
	name = "medical pouches crate (1x firstaid, medical, syringe, medkit, autoinjector)"
	contains = list(
					/obj/item/storage/pouch/firstaid,
					/obj/item/storage/pouch/medical,
					/obj/item/storage/pouch/syringe,
					/obj/item/storage/pouch/medkit,
					/obj/item/storage/pouch/autoinjector
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper medical pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_survival
	name = "survival pouches crate (1x radio, flare, survival)"
	contains = list(
					/obj/item/storage/pouch/radio,
					/obj/item/storage/pouch/flare,
					/obj/item/storage/pouch/survival
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper survival pouches crate"
	group = "Clothing"

/datum/supply_packs/pouches_construction
	name = "construction pouches crate (1x document, electronics, tools, construction)"
	contains = list(
					/obj/item/storage/pouch/document,
					/obj/item/storage/pouch/electronics,
					/obj/item/storage/pouch/tools,
					/obj/item/storage/pouch/construction
					)
	cost = 10
	containertype = /obj/structure/closet/crate
	containername = "\improper construction pouches crate"
	group = "Clothing"


/*******************************************************************************
MEDICAL
*******************************************************************************/

datum/supply_packs/advanced_medical
	contains = list(
					/obj/item/storage/pouch/autoinjector/advanced/full,
					/obj/item/storage/pouch/autoinjector/advanced/full,
					/obj/item/storage/pouch/autoinjector/advanced/full,
					/obj/item/storage/pouch/autoinjector/advanced/full,
					/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
					/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
					/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
					/obj/item/stack/nanopaste
					)
	name = "Emergency medical supplies"
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "\improper Emergency medical crate"
	group = "Medical"


/datum/supply_packs/medical
	name = "Pills and Chemicals Crate"
	contains = list(
					/obj/item/storage/box/autoinjectors,
					/obj/item/storage/box/syringes,
					/obj/item/reagent_containers/glass/bottle/inaprovaline,
					/obj/item/reagent_containers/glass/bottle/dylovene,
					/obj/item/reagent_containers/glass/bottle/bicaridine,
					/obj/item/reagent_containers/glass/bottle/dexalin,
					/obj/item/reagent_containers/glass/bottle/spaceacillin,
					/obj/item/reagent_containers/glass/bottle/kelotane,
					/obj/item/reagent_containers/glass/bottle/tramadol,
					/obj/item/storage/pill_bottle/inaprovaline,
					/obj/item/storage/pill_bottle/dylovene,
					/obj/item/storage/pill_bottle/bicaridine,
					/obj/item/storage/pill_bottle/dexalin,
					/obj/item/storage/pill_bottle/spaceacillin,
					/obj/item/storage/pill_bottle/kelotane,
					/obj/item/storage/pill_bottle/tramadol,
					/obj/item/storage/pill_bottle/quickclot,
					/obj/item/storage/pill_bottle/peridaxon,
					/obj/item/storage/box/pillbottles
					)
	cost = 15
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper Chemicals crate"
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
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper medical crate"
	group = "Medical"

/datum/supply_packs/bodybag
	name = "body bag crate (x28)"
	contains = list(
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags,
			/obj/item/storage/box/bodybags
			)
	cost = 20
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper body bag crate"
	group = "Medical"

/datum/supply_packs/cryobag
	name = "stasis bag crate (x3)"
	contains = list(
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag,
			/obj/item/bodybag/cryobag
			)
	cost = 40
	containertype = /obj/structure/closet/crate/medical
	containername = "\improper stasis bag crate"
	group = "Medical"

/datum/supply_packs/surgery
	name = "surgery crate (x1 surgical tray, 1x surgical vest)"
	contains = list(
					/obj/item/storage/surgical_tray,
					/obj/item/clothing/tie/storage/white_vest
					)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper surgery crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/anesthetic
	name = "anesthetic crate (medical mask x1, anesthetic tank x1)"
	contains = list(
					/obj/item/clothing/mask/breath/medical,
					/obj/item/tank/anesthetic
					)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper Anesthetics crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/hypospray
	name = "advanced hypospray crate (x5 advanced hyposprays)"
	contains = list(
					/obj/item/reagent_containers/hypospray/advanced,
					/obj/item/reagent_containers/hypospray/advanced,
					/obj/item/reagent_containers/hypospray/advanced,
					/obj/item/reagent_containers/hypospray/advanced,
					/obj/item/reagent_containers/hypospray/advanced
					)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper advanced hypospray crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/datum/supply_packs/medvac
	name = "medvac system crate (medvac stretcher and beacon)"
	contains = list(
					/obj/item/roller/medevac,
					/obj/item/medevac_beacon
					)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/surgery
	containername = "\improper medevac crate"
	access = ACCESS_MARINE_MEDBAY
	group = "Medical"

/*******************************************************************************
ENGINEERING
*******************************************************************************/


/datum/supply_packs/sandbags
	name = "empty sandbags crate (x50)"
	contains = list(/obj/item/stack/sandbags_empty/full)
	cost = 15
	containertype = "/obj/structure/closet/crate/supply"
	containername = "\improper empty sandbags crate"
	group = "Engineering"

/datum/supply_packs/metal50
	name = "50 metal sheets (x50)"
	contains = list(/obj/item/stack/sheet/metal/large_stack)
	cost = 20
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper metal sheets crate"
	group = "Engineering"

/datum/supply_packs/plas50
	name = "plasteel sheets (x30)"
	contains = list(/obj/item/stack/sheet/plasteel/medium_stack)
	cost = 40
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper plasteel sheets crate"
	group = "Engineering"

/datum/supply_packs/glass50
	name = "50 glass sheets (x50)"
	contains = list(/obj/item/stack/sheet/glass/large_stack)
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper glass sheets crate"
	group = "Engineering"

/datum/supply_packs/wood50
	name = "wooden planks (x50)"
	contains = list(/obj/item/stack/sheet/wood/large_stack)
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper wooden planks crate"
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
	cost = 10
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper electrical maintenance crate"
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
	cost = 10
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper mechanical maintenance crate"
	group = "Engineering"

/datum/supply_packs/fueltank
	name = "fuel tank crate (x1)"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 15
	containertype = /obj/structure/largecrate
	containername = "\improper fuel tank crate"
	group = "Engineering"

/datum/supply_packs/inflatable
	name = "inflatable barriers (x9 doors, x12 walls)"
	contains = list(
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable,
					/obj/item/storage/briefcase/inflatable
					)
	cost = 10
	containertype = /obj/structure/closet/crate/construction
	containername = "\improper inflatable barriers crate"
	group = "Engineering"

/datum/supply_packs/lightbulbs
	name = "replacement lights (x42 tube, x21 bulb)"
	contains = list(
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed,
					/obj/item/storage/box/lights/mixed
					)
	cost = 20
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper replacement lights crate"
	group = "Engineering"

/*******************************************************************************
SUPPLIES
*******************************************************************************/


/datum/supply_packs/mre
	name = "TGMC MRE crate (x40)"
	contains = list(
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
					/obj/item/storage/box/MRE,
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

/datum/supply_packs/crayons
	name = "PFC Jim Special Crayon Packs (x5)"
	contains = list(
					/obj/item/storage/fancy/crayons,
					/obj/item/storage/fancy/crayons,
					/obj/item/storage/fancy/crayons,
					/obj/item/storage/fancy/crayons,
					/obj/item/storage/fancy/crayons
					)
	cost = 20
	containertype = /obj/structure/largecrate/random/case
	containername = "\improper Crayon Box"
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
	cost = 10
	containertype = "/obj/structure/closet/crate/supply"
	containername = "\improper empty box crate"
	group = "Supplies"

/datum/supply_packs/janitor
	name = "assorted janitorial supplies"
	contains = list(
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/reagent_containers/glass/bucket,
					/obj/item/tool/mop,
					/obj/item/tool/wet_sign,
					/obj/item/tool/wet_sign,
					/obj/item/tool/wet_sign,
					/obj/item/storage/bag/trash,
					/obj/item/reagent_containers/spray/cleaner,
					/obj/item/reagent_containers/glass/rag,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/item/explosive/grenade/chem_grenade/cleaner,
					/obj/structure/mopbucket,
					/obj/item/paper/janitor
					)
	cost = 10
	containertype = /obj/structure/closet/crate/supply
	containername = "\improper janitorial supplies crate"
	group = "Supplies"

/*******************************************************************************
Imports
*******************************************************************************/
//New category for any "exotic" or uncommon items
//Several orderable guns for marines to try out that they otherwise would not get a chance to use

/*/datum/supply_packs/imports_m39b2	//M39 will have it's revenge
	name = "M39B2 SMG"
	contains = list(
					/obj/item/weapon/gun/smg/m39/elite,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap,
					/obj/item/ammo_magazine/smg/m39/ap
					)
	cost = 30
	containertype = /obj/structure/closet/crate
	containername = "\improper M39B2 SMG Crate"
*/
/datum/supply_packs/imports_m41a
	name = "M41A Pulse Rifle"
	contains = list(
					/obj/item/weapon/gun/rifle/m41a,
					/obj/item/ammo_magazine/rifle/m41a,
					/obj/item/ammo_magazine/rifle/m41a,
					/obj/item/ammo_magazine/rifle/m41a,
					/obj/item/ammo_magazine/rifle/m41a
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M41A Pulse Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_m41a1
	name = "M41A1 Pulse Rifle"
	contains = list(
					/obj/item/weapon/gun/rifle/m41a1,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle,
					/obj/item/ammo_magazine/rifle
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M41A1 Pulse Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_m41ae2
	name = "M41AE2 Heavy Pulse Rifle"
	contains = list(
					/obj/item/weapon/gun/rifle/m41ae2_hpr,
					/obj/item/ammo_magazine/m41ae2_hpr,
					/obj/item/ammo_magazine/m41ae2_hpr,
					/obj/item/ammo_magazine/m41ae2_hpr,
					/obj/item/ammo_magazine/m41ae2_hpr
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M41AE2 Heavy Pulse Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_type71	//Moff gun
	name = "Type 71 Pulse Rifle"
	contains = list(
					/obj/item/weapon/gun/rifle/type71,
					/obj/item/ammo_magazine/rifle/type71,
					/obj/item/ammo_magazine/rifle/type71,
					/obj/item/ammo_magazine/rifle/type71,
					/obj/item/ammo_magazine/rifle/type71
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Type 71 Pulse Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_mp5
	name = "MP5 SMG"
	contains = list(
					/obj/item/weapon/gun/smg/mp5,
					/obj/item/ammo_magazine/smg/mp5,
					/obj/item/ammo_magazine/smg/mp5,
					/obj/item/ammo_magazine/smg/mp5,
					/obj/item/ammo_magazine/smg/mp5
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper MP5 SMG Crate"
	group = "Imports"

/datum/supply_packs/imports_mp7
	name = "MP7 SMG"
	contains = list(
					/obj/item/weapon/gun/smg/mp7,
					/obj/item/ammo_magazine/smg/mp7,
					/obj/item/ammo_magazine/smg/mp7,
					/obj/item/ammo_magazine/smg/mp7,
					/obj/item/ammo_magazine/smg/mp7
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper MP7 SMG Crate"
	group = "Imports"

/datum/supply_packs/imports_skorpion
	name = "Skorpion SMG"
	contains = list(
					/obj/item/weapon/gun/smg/skorpion,
					/obj/item/ammo_magazine/smg/skorpion,
					/obj/item/ammo_magazine/smg/skorpion,
					/obj/item/ammo_magazine/smg/skorpion,
					/obj/item/ammo_magazine/smg/skorpion
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Skorpion SMG Crate"
	group = "Imports"

/datum/supply_packs/imports_uzi
	name = "GAL-9 SMG"
	contains = list(
					/obj/item/weapon/gun/smg/uzi,
					/obj/item/ammo_magazine/smg/uzi,
					/obj/item/ammo_magazine/smg/uzi,
					/obj/item/ammo_magazine/smg/uzi,
					/obj/item/ammo_magazine/smg/uzi
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper GAL-9 SMG Crate"
	group = "Imports"

/datum/supply_packs/imports_ppsh
	name = "PPSH SMG"
	contains = list(
					/obj/item/weapon/gun/smg/ppsh,
					/obj/item/ammo_magazine/smg/ppsh,
					/obj/item/ammo_magazine/smg/ppsh,
					/obj/item/ammo_magazine/smg/ppsh,
					/obj/item/ammo_magazine/smg/ppsh
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper PPSH SMG Crate"
	group = "Imports"

/datum/supply_packs/imports_p90
	name = "FN P9000 SMG"
	contains = list(
					/obj/item/weapon/gun/smg/p90,
					/obj/item/ammo_magazine/smg/p90,
					/obj/item/ammo_magazine/smg/p90,
					/obj/item/ammo_magazine/smg/p90,
					/obj/item/ammo_magazine/smg/p90
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper FN P9000 SMG Crate"
	group = "Imports"

/datum/supply_packs/imports_customshotgun
	name = "Custom Built Shotgun"
	contains = list(
					/obj/item/weapon/gun/shotgun/merc,
					/obj/item/ammo_magazine/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Custom Built Shotgun Crate"
	group = "Imports"

/datum/supply_packs/imports_doublebarrel
	name = "Double Barrel Shotgun"
	contains = list(
					/obj/item/weapon/gun/shotgun/double,
					/obj/item/ammo_magazine/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Double Barrel Shotgun Crate"
	group = "Imports"

/datum/supply_packs/imports_sawnoff
	name = "Sawn Off Shotgun"
	contains = list(
					/obj/item/weapon/gun/shotgun/double/sawn,
					/obj/item/ammo_magazine/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Sawn Off Shotgun Crate"
	group = "Imports"

/datum/supply_packs/imports_m37a2
	name = "M37A2 Pump Shotgun"
	contains = list(
					/obj/item/weapon/gun/shotgun/pump,
					/obj/item/ammo_magazine/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper M37A2 Pump Shotgun Crate"
	group = "Imports"

/datum/supply_packs/imports_paladin
	name = "Paladin-12 Shotgun"
	contains = list(
					/obj/item/weapon/gun/shotgun/pump/cmb,
					/obj/item/ammo_magazine/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Paladin-12 Shotgun Crate"
	group = "Imports"

/datum/supply_packs/imports_kronos
	name = "Kronos Shotgun"
	contains = list(
					/obj/item/weapon/gun/shotgun/pump/ksg,
					/obj/item/ammo_magazine/shotgun
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Kronos Shotgun Crate"
	group = "Imports"

/datum/supply_packs/imports_leveraction
	name = "Lever Action Rifle"
	contains = list(
					/obj/item/weapon/gun/shotgun/pump/lever,
					/obj/item/ammo_magazine/magnum,
					/obj/item/ammo_magazine/magnum
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Lever Action Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_mosin
	name = "Mosin Nagant Sniper"
	contains = list(
					/obj/item/weapon/gun/shotgun/pump/bolt,
					/obj/item/ammo_magazine/rifle/bolt,
					/obj/item/ammo_magazine/rifle/bolt,
					/obj/item/ammo_magazine/rifle/bolt
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Mosin Nagant Sniper Crate"
	group = "Imports"

/datum/supply_packs/imports_dragunov
	name = "SVD Dragunov Sniper"
	contains = list(
					/obj/item/weapon/gun/rifle/sniper/svd,
					/obj/item/ammo_magazine/sniper/svd,
					/obj/item/ammo_magazine/sniper/svd,
					/obj/item/ammo_magazine/sniper/svd,
					/obj/item/ammo_magazine/sniper/svd
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper SVD Dragunov Sniper Crate"
	group = "Imports"

/datum/supply_packs/imports_ak47
	name = "AK-47 Assault Rifle"
	contains = list(
					/obj/item/weapon/gun/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper AK-47 Assault Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_ak47u
	name = "AK-47U Battle Carbine"
	contains = list(
					/obj/item/weapon/gun/rifle/ak47/carbine,
					/obj/item/ammo_magazine/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47,
					/obj/item/ammo_magazine/rifle/ak47
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper AK-47U Battle Carbine Crate"
	group = "Imports"

/datum/supply_packs/imports_m16	//Vietnam time
	name = "FN M16A Assault Rifle"
	contains = list(
					/obj/item/weapon/gun/rifle/m16,
					/obj/item/ammo_magazine/rifle/m16,
					/obj/item/ammo_magazine/rifle/m16,
					/obj/item/ammo_magazine/rifle/m16,
					/obj/item/ammo_magazine/rifle/m16
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper FN M16A Assault Rifle Crate"
	group = "Imports"

/datum/supply_packs/imports_357
	name = "Smith and Wesson 357 Revolver"
	contains = list(
					/obj/item/weapon/gun/revolver/small,
					/obj/item/ammo_magazine/revolver/small,
					/obj/item/ammo_magazine/revolver/small,
					/obj/item/ammo_magazine/revolver/small,
					/obj/item/ammo_magazine/revolver/small
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper S&W .357 Revolver Crate"
	group = "Imports"

/datum/supply_packs/imports_cmb
	name = "CMB Autorevolver"
	contains = list(
					/obj/item/weapon/gun/revolver/cmb,
					/obj/item/ammo_magazine/revolver/cmb,
					/obj/item/ammo_magazine/revolver/cmb,
					/obj/item/ammo_magazine/revolver/cmb,
					/obj/item/ammo_magazine/revolver/cmb
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper CMB Autorevolver Crate"
	group = "Imports"

/datum/supply_packs/imports_beretta92fs
	name = "Beretta 92FS Handgun"
	contains = list(
					/obj/item/weapon/gun/pistol/b92fs,
					/obj/item/ammo_magazine/pistol/b92fs,
					/obj/item/ammo_magazine/pistol/b92fs,
					/obj/item/ammo_magazine/pistol/b92fs,
					/obj/item/ammo_magazine/pistol/b92fs
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Beretta 92FS Handgun Crate"
	group = "Imports"

/datum/supply_packs/imports_beretta93r
	name = "Beretta 93R Handgun"
	contains = list(
					/obj/item/weapon/gun/pistol/b92fs/raffica,
					/obj/item/ammo_magazine/pistol/b93r,
					/obj/item/ammo_magazine/pistol/b93r,
					/obj/item/ammo_magazine/pistol/b93r,
					/obj/item/ammo_magazine/pistol/b93r
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Beretta 93R Handgun Crate"
	group = "Imports"

/datum/supply_packs/imports_deagle
	name = "Desert Eagle Handgun"
	contains = list(
					/obj/item/weapon/gun/pistol/heavy,
					/obj/item/ammo_magazine/pistol/heavy,
					/obj/item/ammo_magazine/pistol/heavy,
					/obj/item/ammo_magazine/pistol/heavy,
					/obj/item/ammo_magazine/pistol/heavy
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Desert Eagle Handgun Crate"
	group = "Imports"

/datum/supply_packs/imports_kt42
	name = "KT-42 Automag"
	contains = list(
					/obj/item/weapon/gun/pistol/kt42,
					/obj/item/ammo_magazine/pistol/automatic,
					/obj/item/ammo_magazine/pistol/automatic,
					/obj/item/ammo_magazine/pistol/automatic,
					/obj/item/ammo_magazine/pistol/automatic
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper KT-42 Automag Crate"
	group = "Imports"

/datum/supply_packs/imports_vp78
	name = "VP78 Handgun"
	contains = list(
					/obj/item/weapon/gun/pistol/vp78,
					/obj/item/ammo_magazine/pistol/vp78,
					/obj/item/ammo_magazine/pistol/vp78,
					/obj/item/ammo_magazine/pistol/vp78,
					/obj/item/ammo_magazine/pistol/vp78
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper VP78 Handgun Crate"
	group = "Imports"

/datum/supply_packs/imports_highpower
	name = "Highpower Automag"
	contains = list(
					/obj/item/weapon/gun/pistol/highpower,
					/obj/item/ammo_magazine/pistol/highpower,
					/obj/item/ammo_magazine/pistol/highpower,
					/obj/item/ammo_magazine/pistol/highpower,
					/obj/item/ammo_magazine/pistol/highpower
					)
	cost = 30
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Highpower Automag Crate"
	group = "Imports"

/datum/supply_packs/imports_holdout
	name = "Holdout Handgun"
	contains = list(
					/obj/item/weapon/gun/pistol/holdout,
					/obj/item/ammo_magazine/pistol/holdout,
					/obj/item/ammo_magazine/pistol/holdout,
					/obj/item/ammo_magazine/pistol/holdout,
					/obj/item/ammo_magazine/pistol/holdout
					)
	cost = 10
	containertype = /obj/structure/closet/crate/weapon
	containername = "\improper Holdout Crate"
	group = "Imports"
