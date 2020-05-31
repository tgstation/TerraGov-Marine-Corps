//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

GLOBAL_LIST_INIT(all_supply_groups, list("Operations", "Weapons", "Hardpoint Modules", "Attachments", "Ammo", "Armor", "Clothing", "Medical", "Engineering", "Supplies", "Imports"))

/datum/supply_packs
	var/name
	var/notes
	var/list/contains = list()
	var/cost
	var/obj/containertype
	var/access
	var/hidden = FALSE
	var/contraband = FALSE
	var/group
	var/randomised_num_contained = 0 //Randomly picks X of items out of the contains list instead of using all.

/datum/supply_packs/proc/generate(atom/movable/location)
	for(var/i in contains)
		var/atom/movable/AM = i
		new AM(location)


/*******************************************************************************
OPERATIONS
*******************************************************************************/
/datum/supply_packs/operations
	group = "Operations"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/operations/beacons_supply
	name = "supply beacon"
	contains = list(/obj/item/squad_beacon)
	cost = 20

/datum/supply_packs/operations/beacons_orbital
	name = "orbital beacon"
	contains = list(/obj/item/squad_beacon/bomb)
	cost = 30

/datum/supply_packs/operations/binoculars_regular
	name = "binoculars"
	contains = list(/obj/item/binoculars)
	cost = 20

/datum/supply_packs/operations/binoculars_tatical
	name = "tactical binoculars crate"
	contains = list(/obj/item/binoculars/tactical)
	cost = 40

/datum/supply_packs/operations/flares
	name = "2 flare packs"
	notes = "Contains 14 flares"
	contains = list(
		/obj/item/storage/box/m94,
		/obj/item/storage/box/m94,
	)
	cost = 5

/datum/supply_packs/operations/tarps
	name = "V1 thermal-dampening tarp"
	contains = list(/obj/item/bodybag/tarp)
	cost = 6

/datum/supply_packs/operations/alpha
	name = "Alpha Supply Crate"
	contains = list(/obj/structure/closet/crate/alpha)
	cost = 10
	containertype = null

/datum/supply_packs/operations/bravo
	name = "Bravo Supply Crate"
	contains = list(/obj/structure/closet/crate/bravo)
	cost = 10
	containertype = null

/datum/supply_packs/operations/charlie
	name = "Charlie Supply Crate"
	contains = list(/obj/structure/closet/crate/charlie)
	cost = 10
	containertype = null

/datum/supply_packs/operations/delta
	name = "Delta Supply Crate"
	contains = list(/obj/structure/closet/crate/delta)
	cost = 10
	containertype = null

/*******************************************************************************
WEAPONS
*******************************************************************************/

/datum/supply_packs/weapons
	group = "Weapons"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/weapons/sentry
	name = "UA 571-C Base Defense Sentry"
	contains = list(/obj/item/storage/box/sentry)
	cost = 120

/datum/supply_packs/weapons/minisentry
	name = "UA-580 Portable Sentry"
	contains = list(/obj/item/storage/box/minisentry)
	cost = 70

/datum/supply_packs/weapons/m56d_emplacement
	name = "M56D Stationary Machinegun"
	contains = list(/obj/item/storage/box/m56d_hmg)
	cost = 80

/datum/supply_packs/weapons/specgrenadier
	name = "Grenadier Specialist kit"
	contains = list(
		/obj/item/weapon/gun/launcher/m92,
		/obj/item/storage/box/nade_box,
	)
	cost = 100

/datum/supply_packs/weapons/specscoutm4ra
	name = "Scout Specialist kit (M4RA)"
	contains = list(
		/obj/item/weapon/gun/rifle/m4ra,
		/obj/item/ammo_magazine/rifle/m4ra,
		/obj/item/ammo_magazine/rifle/m4ra,
	)
	cost = 100

/datum/supply_packs/weapons/specscoutmbx
	name = "Scout Specialist kit (MBR-900)"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump/lever/mbx900,
		/obj/item/ammo_magazine/shotgun/mbx900,
	)
	cost = 100

/datum/supply_packs/weapons/specdemo
	name = "Demolitionist Specialist kit"
	contains = list(
		/obj/item/weapon/gun/launcher/rocket,
		/obj/item/ammo_magazine/rocket,
		/obj/item/ammo_magazine/rocket,
	)
	cost = 100

/datum/supply_packs/weapons/specpyro
	name = "Pyro Specialist kit"
	contains = list(
		/obj/item/weapon/gun/flamer/M240T,
		/obj/item/storage/backpack/marine/engineerpack/flamethrower,
	)
	cost = 100

/datum/supply_packs/weapons/specsniper
	name = "Sniper Specialist kit"
	contains = list(
		/obj/item/weapon/gun/rifle/sniper/M42A,
		/obj/item/ammo_magazine/sniper,
		/obj/item/ammo_magazine/sniper,
	)
	cost = 100

/datum/supply_packs/weapons/specminigun
	name = "MIC-A7 Vindicator Minigun"
	contains = list(
		/obj/item/weapon/gun/minigun,
		/obj/item/ammo_magazine/minigun,
	)
	cost = 100

/datum/supply_packs/weapons/flamethrower
	name = "M240 Flamethrower"
	contains = list(
		/obj/item/weapon/gun/flamer,
		/obj/item/ammo_magazine/flamer_tank,
	)
	cost = 13

/datum/supply_packs/weapons/mateba
	name = "Mateba Autorevolver kit"
	contains = list(/obj/item/storage/belt/gun/mateba/full)
	notes = "Contains 6 speedloaders"
	cost = 15

/datum/supply_packs/weapons/pistols
	name = "surplus sidearms"
	contains = list(
		/obj/item/weapon/gun/pistol/standard_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol,
		/obj/item/weapon/gun/revolver/standard_revolver,
		/obj/item/ammo_magazine/revolver/standard_revolver,
	)
	cost = 10

/datum/supply_packs/weapons/shotguns
	name = "surplus shotguns"
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
	cost = 20

/datum/supply_packs/weapons/smgs
	name = "surplus SMG"
	contains = list(
		/obj/item/weapon/gun/smg/standard_smg,
		/obj/item/ammo_magazine/smg/standard_smg,
	)
	cost = 10

/datum/supply_packs/weapons/rifles
	name = "surplus rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/standard_carbine,
		/obj/item/ammo_magazine/rifle/standard_carbine,
	)
	cost = 10

/datum/supply_packs/weapons/lasrifle
	name = "surplus lasrifle"
	contains = list(
		/obj/item/weapon/gun/energy/lasgun/lasrifle,
		/obj/item/cell/lasgun/lasrifle,
	)
	cost = 10

/datum/supply_packs/weapons/heavyrifle_squad
	name = "T-42 LMG"
	contains = list(
		/obj/item/weapon/gun/rifle/standard_lmg,
		/obj/item/ammo_magazine/standard_lmg,
	)
	cost = 10

/datum/supply_packs/weapons/combatshotgun
	name = "MK221 tactical shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/combat,
		/obj/item/ammo_magazine/shotgun/,
		/obj/item/ammo_magazine/shotgun/buckshot,
		/obj/item/ammo_magazine/shotgun/flechette,
	)
	cost = 10

/datum/supply_packs/weapons/explosives
	name = "surplus explosives"
	contains = list(
		/obj/item/storage/box/explosive_mines,
		/obj/item/explosive/grenade/frag,
		/obj/item/explosive/grenade/frag,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/incendiary,
		/obj/item/explosive/grenade/frag/m15,
		/obj/item/explosive/grenade/frag/m15,
	)
	cost = 20

/datum/supply_packs/weapons/explosives_mines
	name = "claymore mines"
	notes = "Contains 5 mines"
	contains = list(/obj/item/storage/box/explosive_mines)
	cost = 15

/datum/supply_packs/weapons/explosives_hedp
	name = "M40 HEDP high explosive grenade box crate"
	notes = "Contains 25 grenades"
	contains = list(/obj/item/storage/box/nade_box)
	cost = 50

/datum/supply_packs/weapons/explosives_hidp
	name = "M40 HIDP incendiary explosive grenade box crate"
	notes = "Contains 25 grenades"
	contains = list(/obj/item/storage/box/nade_box/HIDP)
	cost = 50

/datum/supply_packs/weapons/explosives_m15
	name = "M15 fragmentation grenade box crate"
	notes = "Contains 15 grenades"
	contains = list(/obj/item/storage/box/nade_box/M15)
	cost = 50

/datum/supply_packs/weapons/explosives_hsdp
	name = "M40 HSDP white phosphorous grenade box crate"
	notes = "Contains 15 grenades"
	contains = list(/obj/item/storage/box/nade_box/phos)
	cost = 70

/datum/supply_packs/weapons/plastique
	name = "C4 plastic explosive"
	contains = list(/obj/item/explosive/plastique)
	cost = 6

/datum/supply_packs/weapons/mortar
	name = "M402 mortar crate"
	contains = list(/obj/item/mortar_kit)
	cost = 40

/datum/supply_packs/weapons/detpack
	name = "detpack explosives"
	contains = list(
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/assembly/signaler,
	)
	cost = 16

/*******************************************************************************
HARDPOINT MODULES (and their ammo)
*******************************************************************************/
/datum/supply_packs/hardpoints
	group = "Hardpoint Modules"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/hardpoints/ltb_cannon
	name = "LTB Cannon Assembly"
	contains = list(/obj/item/hardpoint/primary/cannon)
	cost = 60

/datum/supply_packs/hardpoints/ltaaap_minigun
	name = "LTAA-AP Minigun Assembly"
	contains = list(/obj/item/hardpoint/primary/minigun)
	cost = 60

/datum/supply_packs/hardpoints/flamer_module
	name = "Secondary Flamer Assembly"
	contains = list(/obj/item/hardpoint/secondary/flamer)
	cost = 60

/datum/supply_packs/hardpoints/towlauncher
	name = "Secondary TOW Launcher Assembly"
	contains = list(/obj/item/hardpoint/secondary/towlauncher)
	cost = 60

/datum/supply_packs/hardpoints/m56_cupola
	name = "Secondary M56 Cupola Assembly"
	contains = list(/obj/item/hardpoint/secondary/m56cupola)
	cost = 60

/datum/supply_packs/hardpoints/tank_glauncher
	name = "Secondary Grenade Launcher Assembly"
	contains = list(/obj/item/hardpoint/secondary/grenade_launcher)
	cost = 60

/datum/supply_packs/hardpoints/tank_slauncher
	name = "Smoke Launcher Assembly"
	contains = list(/obj/item/hardpoint/support/smoke_launcher)
	cost = 60

/datum/supply_packs/hardpoints/weapons_sensor
	name = "Weapons Sensor Array"
	contains = list(/obj/item/hardpoint/support/weapons_sensor)
	cost = 60

/datum/supply_packs/hardpoints/artillery_module
	name = "Artillery Module"
	contains = list(/obj/item/hardpoint/support/artillery_module)
	cost = 60

/datum/supply_packs/hardpoints/overdrive_enhancer
	name = "Overdrive Enhancer"
	contains = list(/obj/item/hardpoint/support/overdrive_enhancer)
	cost = 60

/datum/supply_packs/hardpoints/ballistic_armor
	name = "Ballistic Armor Plating"
	contains = list(/obj/item/hardpoint/armor/ballistic)
	cost = 60

/datum/supply_packs/hardpoints/caustic_armor
	name = "Caustic Armor Plating"
	contains = list(/obj/item/hardpoint/armor/caustic)
	cost = 60

/datum/supply_packs/hardpoints/concussive_armor
	name = "Concussive Armor Plating"
	contains = list(/obj/item/hardpoint/armor/concussive)
	cost = 60

/datum/supply_packs/hardpoints/paladin_armor
	name = "Paladin Armor Module"
	contains = list(/obj/item/hardpoint/armor/paladin)
	cost = 60

/datum/supply_packs/hardpoints/snowplow_armor
	name = "Snowplow Module"
	contains = list(/obj/item/hardpoint/armor/snowplow)
	cost = 40

/datum/supply_packs/hardpoints/tank_treads
	name = "Tank Treads"
	contains = list(/obj/item/hardpoint/treads/standard)
	cost = 60

/datum/supply_packs/hardpoints/ltb_cannon_ammo
	name = "LTB Cannon Magazine"
	contains = list(/obj/item/ammo_magazine/tank/ltb_cannon)
	cost = 3

/datum/supply_packs/hardpoints/ltaaap_minigun_ammo
	name = "LTAA AP Minigun Magazine"
	contains = list(/obj/item/ammo_magazine/tank/ltaaap_minigun)
	cost = 10

/datum/supply_packs/hardpoints/tank_glauncher_ammo
	name = "Grenade Launcher Magazine"
	contains = list(/obj/item/ammo_magazine/tank/tank_glauncher)
	cost = 3

/datum/supply_packs/hardpoints/tank_slauncher_ammo
	name = "Smoke Launcher Magazine"
	contains = list(/obj/item/ammo_magazine/tank/tank_slauncher)
	cost = 3

/datum/supply_packs/hardpoints/tank_towlauncher_ammo
	name = "TOW Launcher Magazine"
	contains = list(/obj/item/ammo_magazine/tank/towlauncher)
	cost = 7

/datum/supply_packs/hardpoints/tank_cupola_ammo
	name = "M56 Cupola Magazine"
	contains = list(/obj/item/ammo_magazine/tank/m56_cupola)
	cost = 15

/datum/supply_packs/hardpoints/tank_flamer_ammo
	name = "Flamer Magazine"
	contains = list(/obj/item/ammo_magazine/tank/flamer)
	cost = 6

/*******************************************************************************
ATTACHMENTS
*******************************************************************************/
/datum/supply_packs/attachments
	group = "Attachments"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/attachments/rail_reddot
	name = "red-dot sight attachment"
	contains = list(/obj/item/attachable/reddot)
	cost = 4

/datum/supply_packs/attachments/rail_scope
	name = "railscope attachment"
	contains = list(/obj/item/attachable/scope)
	cost = 10

/datum/supply_packs/attachments/rail_miniscope
	name = "mini railscope attachment"
	contains = list(/obj/item/attachable/scope/mini)
	cost = 10

/datum/supply_packs/attachments/rail_magneticharness
	name = "magnetic harness attachment"
	contains = list(/obj/item/attachable/magnetic_harness)
	cost = 5

/datum/supply_packs/attachments/rail_quickfire
	name = "quickfire adaptor attachment"
	contains = list(/obj/item/attachable/quickfire)
	cost = 15

/datum/supply_packs/attachments/muzzle_suppressor
	name = "suppressor attachment"
	contains = list(/obj/item/attachable/suppressor)
	cost = 4

/datum/supply_packs/attachments/muzzle_bayonet
	name = "bayonet attachment"
	contains = list(/obj/item/attachable/bayonet)
	cost = 2

/datum/supply_packs/attachments/muzzle_extended
	name = "extended barrel attachment"
	contains = list(/obj/item/attachable/extended_barrel)
	cost = 5

/datum/supply_packs/attachments/muzzle_heavy
	name = "barrel charger attachment"
	contains = list(/obj/item/attachable/heavy_barrel)
	cost = 10

/datum/supply_packs/attachments/muzzle_compensator
	name = "compensator attachment"
	contains = list(/obj/item/attachable/compensator)
	cost = 3

/datum/supply_packs/attachments/lasersight
	name = "lasersight attachment"
	contains = list(/obj/item/attachable/lasersight)
	cost = 4

/datum/supply_packs/attachments/angledgrip
	name = "angledgrip attachment"
	contains = list(/obj/item/attachable/angledgrip)
	cost = 4

/datum/supply_packs/attachments/verticalgrip
	name = "verticalgrip attachment"
	contains = list(/obj/item/attachable/verticalgrip)
	cost = 4

/datum/supply_packs/attachments/underbarrel_gyro
	name = "gyroscopic stabilizer attachment"
	contains = list(/obj/item/attachable/gyro)
	cost = 7

/datum/supply_packs/attachments/underbarrel_bipod
	name = "bipod attachment"
	contains = list(/obj/item/attachable/bipod)
	cost = 4

/datum/supply_packs/attachments/underbarrel_shotgun
	name = "underbarrel shotgun attachment"
	contains = list(/obj/item/attachable/attached_gun/shotgun)
	cost = 6

/datum/supply_packs/attachments/underbarrel_flamer
	name = "underbarrel flamer attachment"
	contains = list(/obj/item/attachable/attached_gun/flamer)
	cost = 6

/datum/supply_packs/attachments/underbarrel_burstfire_assembly
	name = "burstfire assembly attachment"
	contains = list(/obj/item/attachable/burstfire_assembly)
	cost = 10

/datum/supply_packs/attachments/stock_shotgun
	name = "shotgun stock attachment"
	contains = list(/obj/item/attachable/stock/t35stock)
	cost = 5

/datum/supply_packs/attachments/stock_smg
	name = "submachinegun stock attachment crate"
	contains = list(/obj/item/attachable/stock/smg)
	cost = 5

/datum/supply_packs/attachments/stock_smg
	name = "combat shotgun stock attachment crate"
	contains = list(/obj/item/attachable/stock/tactical)
	cost = 6

/*******************************************************************************
AMMO
*******************************************************************************/
/datum/supply_packs/ammo
	containertype = /obj/structure/closet/crate/ammo
	group = "Ammo"

/datum/supply_packs/ammo/boxslug
	name = "Slug Ammo Box"
	contains = list(/obj/item/shotgunbox)
	cost = 30

/datum/supply_packs/ammo/boxbuckshot
	name = "Buckshot Ammo Box"
	contains = list(/obj/item/shotgunbox/buckshot)
	cost = 30

/datum/supply_packs/ammo/boxflechette
	name = "Flechette Ammo Box"
	contains = list(/obj/item/shotgunbox/flechette)
	cost = 30

/datum/supply_packs/ammo/boxcarbine
	name = "T-18 Carbine Ammo Box"
	contains = list(/obj/item/ammobox)
	cost = 30

/datum/supply_packs/ammo/boxrifle
	name = "T-12 Assault Rifle Ammo Box"
	contains = list(/obj/item/ammobox/standard_rifle)
	cost = 30

/datum/supply_packs/ammo/boxsmg
	name = "T-19 SMG Ammo Box"
	contains = list(/obj/item/ammobox/standard_smg)
	cost = 30

/datum/supply_packs/ammo/boxlmg
	name = "T-42 LMG Ammo Box"
	contains = list(/obj/item/ammobox/standard_lmg)
	cost = 30

/datum/supply_packs/ammo/boxdmr
	name = "T-64 DMR Ammo Box"
	contains = list(/obj/item/ammobox/standard_dmr)
	cost = 30

/datum/supply_packs/ammo/boxpistol
	name = "TP-14 Pistol Ammo Box"
	contains = list(/obj/item/ammobox/standard_pistol)
	cost = 30

/datum/supply_packs/ammo/regular_tp44
	name = "regular TP-44 magazines"
	contains = list(
		/obj/item/ammo_magazine/revolver/standard_revolver,
		/obj/item/ammo_magazine/revolver/standard_revolver,
	)
	cost = 1

/datum/supply_packs/ammo/mateba
	name = "Mateba magazine"
	contains = list(/obj/item/ammo_magazine/revolver/mateba)
	cost = 3

/datum/supply_packs/ammo/incendiaryslugs
	name = "Box of Incendiary Slugs"
	contains = list(/obj/item/ammo_magazine/shotgun/incendiary)
	cost = 15

/datum/supply_packs/ammo/scout_regular
	name = "M4RA scout magazine"
	contains = list(/obj/item/ammo_magazine/rifle/m4ra)
	cost = 4

/datum/supply_packs/ammo/scout_impact
	name = "M4RA scout impact magazine"
	contains = list(/obj/item/ammo_magazine/rifle/m4ra/impact)
	cost = 13

/datum/supply_packs/ammo/scout_incendiary
	name = "M4RA scout incendiary magazine"
	contains = list(/obj/item/ammo_magazine/rifle/m4ra/incendiary)
	cost = 13

/datum/supply_packs/ammo/scout_smart
	name = "M4RA scout smart magazine"
	contains = list(/obj/item/ammo_magazine/rifle/m4ra/smart)
	cost = 13

/datum/supply_packs/ammo/sniper_regular
	name = "M42A sniper magazine"
	contains = list(/obj/item/ammo_magazine/sniper)
	cost = 5

/datum/supply_packs/ammo/sniper_flak
	name = "M42A sniper flak magazine"
	contains = list(/obj/item/ammo_magazine/sniper/flak)
	cost = 5

/datum/supply_packs/ammo/sniper_incendiary
	name = "M42A sniper incendiary magazine"
	contains = list(/obj/item/ammo_magazine/sniper/incendiary)
	cost = 7

/datum/supply_packs/ammo/mbx900
	name = "MBX 900 ammo crate"
	contains = list(
		/obj/item/ammo_magazine/shotgun/mbx900,
		/obj/item/ammo_magazine/shotgun/mbx900,
		/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
		/obj/item/ammo_magazine/shotgun/mbx900/buckshot,
		/obj/item/ammo_magazine/shotgun/mbx900/tracking,
	)
	cost = 40

/datum/supply_packs/ammo/rpg_regular
	name = "M5 RPG HE rocket"
	contains = list(/obj/item/ammo_magazine/rocket)
	cost = 7

/datum/supply_packs/ammo/rpg_ap
	name = "M5 RPG AP rocket"
	contains = list(/obj/item/ammo_magazine/rocket/ap)
	cost = 7

/datum/supply_packs/ammo/rpg_wp
	name = "M5 RPG WP rocket"
	contains = list(/obj/item/ammo_magazine/rocket/wp)
	cost = 5

/datum/supply_packs/ammo/smartgun
	name = "M56 smartgun powerpack"
	contains = list(/obj/item/smartgun_powerpack)
	cost = 12

/datum/supply_packs/ammo/smartmachinegun
	name = "T-29 smartmachinegun ammo"
	contains = list(/obj/item/ammo_magazine/standard_smartmachinegun)
	cost = 10

/datum/supply_packs/ammo/sentry
	name = "UA 571-C sentry ammunition"
	contains = list(/obj/item/ammo_magazine/sentry)
	cost = 15

/datum/supply_packs/ammo/napalm
	name = "M240 fuel crate"
	contains = list(/obj/item/ammo_magazine/flamer_tank)
	cost = 5

/datum/supply_packs/ammo/pyro
	name = "M240-T fuels"
	contains = list(
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large,
		/obj/item/ammo_magazine/flamer_tank/large/B,
		/obj/item/ammo_magazine/flamer_tank/large/X,
	)
	cost = 60

/datum/supply_packs/ammo/mortar_ammo_he
	name = "M402 mortar HE shell"
	contains = list(/obj/item/mortal_shell/he)
	cost = 3

/datum/supply_packs/ammo/mortar_ammo_incend
	name = "M402 mortar incendiary shell"
	contains = list(/obj/item/mortal_shell/incendiary)
	cost = 3

/datum/supply_packs/ammo/mortar_ammo_flare
	name = "M402 mortar flare shell"
	contains = list(/obj/item/mortal_shell/flare)
	cost = 1

/datum/supply_packs/ammo/mortar_ammo_smoke
	name = "M402 mortar smoke shell"
	contains = list(/obj/item/mortal_shell/smoke)
	cost = 1

/datum/supply_packs/ammo/mortar_ammo_flash
	name = "M402 mortar flash shell"
	contains = list(/obj/item/mortal_shell/flash)
	cost = 1

/datum/supply_packs/ammo/minisentry
	name = "UA-580 point defense sentry ammo"
	contains = list(/obj/item/ammo_magazine/minisentry)
	cost = 10

/datum/supply_packs/ammo/m56d
	name = "M56D mounted smartgun ammo"
	contains = list(/obj/item/ammo_magazine/m56d)
	cost = 15

/datum/supply_packs/ammo/lasguncharger
	name = "ColMarTech Lasrifle Field Charger"
	contains = list(/obj/machinery/vending/lasgun)
	cost = 60
	containertype = null

/datum/supply_packs/ammo/lasgun
	name = "TX-73 lasrifle battery"
	contains = list(/obj/item/cell/lasgun/lasrifle)
	cost = 2

/datum/supply_packs/ammo/lasgun_highcap
	name = "TX-73 lasrifle highcap battery"
	contains = list(/obj/item/cell/lasgun/lasrifle/highcap)
	cost = 4

/datum/supply_packs/ammo/minigun
	name = "Vindicator Minigun Ammo Drum"
	contains = list(/obj/item/ammo_magazine/minigun)
	cost = 10


/*******************************************************************************
ARMOR
*******************************************************************************/
/datum/supply_packs/armor
	group = "Armor"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/armor/masks
	name = "SWAT protective mask"
	contains = list(/obj/item/clothing/mask/gas/swat)
	cost = 10

/datum/supply_packs/armor/riot
	name = "Heavy Riot Armor Set"
	contains = list(
		/obj/item/clothing/suit/armor/riot/marine,
		/obj/item/clothing/head/helmet/riot,
	)
	cost = 50

/datum/supply_packs/armor/b18
	name = "B18 Armor Set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
	)
	cost = 200

/datum/supply_packs/armor/b17
	name = "B17 Armor Set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/B17,
		/obj/item/clothing/head/helmet/marine/grenadier,
	)
	cost = 100

/datum/supply_packs/armor/pyro
	name = "Pyro Armor Set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/M35,
		/obj/item/clothing/head/helmet/marine/pyro,
		/obj/item/clothing/shoes/marine/pyro,
	)
	cost = 100

/datum/supply_packs/armor/basic
	name = "M3 pattern armor"
	contains = list(
		/obj/item/clothing/head/helmet/marine/standard,
		/obj/item/clothing/suit/storage/marine,
	)
	cost = 4

/datum/supply_packs/armor/leader
	name = "M3 pattern squad leader armor"
	contains = list(
		/obj/item/clothing/head/helmet/marine/leader,
		/obj/item/clothing/suit/storage/marine/leader,
	)
	cost = 20


/*******************************************************************************
CLOTHING
*******************************************************************************/
/datum/supply_packs/clothing
	group = "Clothing"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/clothing/officer_outfits
	name = "officer outfits"
	contains = list(
		/obj/item/clothing/under/rank/ro_suit,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/exec,
		/obj/item/clothing/under/marine/officer/ce,
	)
	cost = 20

/datum/supply_packs/clothing/marine_outfits
	name = "marine outfit"
	contains = list(
		/obj/item/clothing/under/marine/standard,
		/obj/item/storage/belt/marine,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/clothing/shoes/marine,
	)
	cost = 6

/datum/supply_packs/clothing/webbing
	name = "webbing"
	contains = list(/obj/item/clothing/tie/storage/webbing)
	cost = 2

/datum/supply_packs/clothing/brown_vest
	name = "brown_vest"
	contains = list(/obj/item/clothing/tie/storage/brown_vest)
	cost = 2

/datum/supply_packs/clothing/revolver
	name = "TP-44 holster"
	contains = list(/obj/item/storage/belt/gun/revolver/standard_revolver)
	cost = 5

/datum/supply_packs/clothing/pistol
	name = "TP-14 holster"
	contains = list(/obj/item/storage/belt/gun/pistol/standard_pistol)
	cost = 5

/datum/supply_packs/clothing/pouches_general
	name = "general pouches"
	contains = list(
		/obj/item/storage/pouch/general,
		/obj/item/storage/pouch/general,
		/obj/item/storage/pouch/general/medium,
		/obj/item/storage/pouch/general/large,
	)
	cost = 10

/datum/supply_packs/clothing/pouches_weapons
	name = "weapons pouches"
	contains = list(
		/obj/item/storage/pouch/bayonet,
		/obj/item/storage/pouch/pistol,
		/obj/item/storage/pouch/explosive,
	)
	cost = 10

/datum/supply_packs/clothing/pouches_ammo
	name = "ammo pouches"
	contains = list(
		/obj/item/storage/pouch/magazine,
		/obj/item/storage/pouch/magazine/large,
		/obj/item/storage/pouch/magazine/pistol,
		/obj/item/storage/pouch/magazine/pistol/large,
	)
	cost = 10

/datum/supply_packs/clothing/pouches_medical
	name = "medical pouches"
	contains = list(
		/obj/item/storage/pouch/firstaid,
		/obj/item/storage/pouch/medical,
		/obj/item/storage/pouch/syringe,
		/obj/item/storage/pouch/medkit,
		/obj/item/storage/pouch/autoinjector,
	)
	cost = 10

/datum/supply_packs/clothing/pouches_survival
	name = "survival pouches"
	contains = list(
		/obj/item/storage/pouch/radio,
		/obj/item/storage/pouch/flare,
		/obj/item/storage/pouch/survival,
	)
	cost = 10

/datum/supply_packs/clothing/pouches_construction
	name = "construction pouches"
	contains = list(
		/obj/item/storage/pouch/document,
		/obj/item/storage/pouch/electronics,
		/obj/item/storage/pouch/tools,
		/obj/item/storage/pouch/construction,
	)
	cost = 10


/*******************************************************************************
MEDICAL
*******************************************************************************/
/datum/supply_packs/medical
	group = "Medical"
	containertype = /obj/structure/closet/crate/medical

/datum/supply_packs/medical/advanced_medical
	name = "Emergency medical supplies"
	contains = list(
		/obj/item/storage/pouch/autoinjector/advanced/full,
		/obj/item/storage/pouch/autoinjector/advanced/full,
		/obj/item/storage/pouch/autoinjector/advanced/full,
		/obj/item/storage/pouch/autoinjector/advanced/full,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
		/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
		/obj/item/stack/nanopaste,
	)
	cost = 50

/datum/supply_packs/medical/medical
	name = "Pills and Chemicals"
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
		/obj/item/storage/box/pillbottles,
	)
	cost = 15

/datum/supply_packs/medical/firstaid
	name = "first aid kits"
	contains = list(/obj/item/storage/firstaid/regular,
					/obj/item/storage/firstaid/fire,
					/obj/item/storage/firstaid/toxin,
					/obj/item/storage/firstaid/o2,
					/obj/item/storage/firstaid/adv,
					)
	cost = 10

/datum/supply_packs/medical/bodybag
	name = "body bags"
	notes = "Contains 7 bodybags"
	contains = list(/obj/item/storage/box/bodybags)
	cost = 5

/datum/supply_packs/medical/cryobag
	name = "stasis bag"
	contains = list(/obj/item/bodybag/cryobag)
	cost = 13

/datum/supply_packs/medical/surgery
	name = "surgery kit"
	contains = list(
		/obj/item/storage/surgical_tray,
		/obj/item/clothing/tie/storage/white_vest,
	)
	cost = 20
	access = ACCESS_MARINE_MEDBAY
	containertype = /obj/structure/closet/crate/secure/surgery

/datum/supply_packs/medical/anesthetic
	name = "anesthetic kit"
	contains = list(
		/obj/item/clothing/mask/breath/medical,
		/obj/item/tank/anesthetic,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/hypospray
	name = "advanced hypospray"
	contains = list(/obj/item/reagent_containers/hypospray/advanced)
	cost = 6
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/medvac
	name = "medvac system"
	contains = list(
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/*******************************************************************************
ENGINEERING
*******************************************************************************/
/datum/supply_packs/engineering
	group = "Engineering"
	containertype = /obj/structure/closet/crate/supply

/datum/supply_packs/engineering/sandbags
	name = "50 empty sandbags"
	contains = list(/obj/item/stack/sandbags_empty/full)
	cost = 15

/datum/supply_packs/engineering/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal/large_stack)
	cost = 20

/datum/supply_packs/engineering/plas50
	name = "30 plasteel sheets"
	contains = list(/obj/item/stack/sheet/plasteel/medium_stack)
	cost = 40

/datum/supply_packs/engineering/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass/large_stack)
	cost = 10

/datum/supply_packs/engineering/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood/large_stack)
	cost = 10

/datum/supply_packs/engineering/electrical
	name = "electrical maintenance supplies"
	contains = list(
		/obj/item/storage/toolbox/electrical,
		/obj/item/clothing/gloves/yellow,
		/obj/item/cell,
		/obj/item/cell/high,
	)
	cost = 5

/datum/supply_packs/engineering/mechanical
	name = "mechanical maintenance crate"
	contains = list(
		/obj/item/storage/belt/utility/full,
		/obj/item/storage/belt/utility/full,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/hardhat,
	)
	cost = 10

/datum/supply_packs/engineering/fueltank
	name = "fuel tank"
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	cost = 15
	containertype = null

/datum/supply_packs/engineering/inflatable
	name = "inflatable barriers"
	notes = "Contains 3 doors and 4 walls"
	contains = list(/obj/item/storage/briefcase/inflatable)
	cost = 3

/datum/supply_packs/engineering/lightbulbs
	name = "replacement lights"
	notes = "Contains 14 tubes, 7 bulbs"
	contains = list(/obj/item/storage/box/lights/mixed)
	cost = 6

/*******************************************************************************
SUPPLIES
*******************************************************************************/
/datum/supply_packs/supplies
	group = "Supplies"
	containertype = /obj/structure/closet/crate/supply

/datum/supply_packs/supplies/mre
	name = "TGMC MRE crate"
	notes = "Contains 4 MREs"
	contains = list(/obj/item/storage/box/MRE)
	cost = 1

/datum/supply_packs/supplies/crayons
	name = "PFC Jim Special Crayon Pack"
	contains = list(/obj/item/storage/fancy/crayons)
	cost = 4

/datum/supply_packs/supplies/boxes
	name = "empty box"
	contains = list(/obj/item/storage/box)
	cost = 1

/datum/supply_packs/supplies/janitor
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
		/obj/item/paper/janitor,
	)
	cost = 10

/*******************************************************************************
Imports
*******************************************************************************/
/datum/supply_packs/imports
	group = "Imports"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/imports/m41a
	name = "M41A Pulse Rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/m41a,
		/obj/item/ammo_magazine/rifle/m41a,
		/obj/item/ammo_magazine/rifle/m41a,
		/obj/item/ammo_magazine/rifle/m41a,
		/obj/item/ammo_magazine/rifle/m41a,
	)
	cost = 30

/datum/supply_packs/imports/m41a1
	name = "M41A1 Pulse Rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/m41a1,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/rifle
	)
	cost = 30

/datum/supply_packs/imports/m41ae2
	name = "M41AE2 Heavy Pulse Rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/m41ae2_hpr,
		/obj/item/ammo_magazine/m41ae2_hpr,
		/obj/item/ammo_magazine/m41ae2_hpr,
		/obj/item/ammo_magazine/m41ae2_hpr,
		/obj/item/ammo_magazine/m41ae2_hpr,
	)
	cost = 30

/datum/supply_packs/imports/type71	//Moff gun
	name = "Type 71 Pulse Rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/type71,
		/obj/item/ammo_magazine/rifle/type71,
		/obj/item/ammo_magazine/rifle/type71,
		/obj/item/ammo_magazine/rifle/type71,
		/obj/item/ammo_magazine/rifle/type71,
	)
	cost = 30

/datum/supply_packs/imports/mp5
	name = "MP5 SMG"
	contains = list(
		/obj/item/weapon/gun/smg/mp5,
		/obj/item/ammo_magazine/smg/mp5,
		/obj/item/ammo_magazine/smg/mp5,
		/obj/item/ammo_magazine/smg/mp5,
		/obj/item/ammo_magazine/smg/mp5,
	)
	cost = 30

/datum/supply_packs/imports/mp7
	name = "MP7 SMG"
	contains = list(
		/obj/item/weapon/gun/smg/mp7,
		/obj/item/ammo_magazine/smg/mp7,
		/obj/item/ammo_magazine/smg/mp7,
		/obj/item/ammo_magazine/smg/mp7,
		/obj/item/ammo_magazine/smg/mp7,
	)
	cost = 30

/datum/supply_packs/imports/skorpion
	name = "Skorpion SMG"
	contains = list(
		/obj/item/weapon/gun/smg/skorpion,
		/obj/item/ammo_magazine/smg/skorpion,
		/obj/item/ammo_magazine/smg/skorpion,
		/obj/item/ammo_magazine/smg/skorpion,
		/obj/item/ammo_magazine/smg/skorpion,
	)
	cost = 30

/datum/supply_packs/imports/uzi
	name = "GAL-9 SMG"
	contains = list(
		/obj/item/weapon/gun/smg/uzi,
		/obj/item/ammo_magazine/smg/uzi,
		/obj/item/ammo_magazine/smg/uzi,
		/obj/item/ammo_magazine/smg/uzi,
		/obj/item/ammo_magazine/smg/uzi,
	)
	cost = 30

/datum/supply_packs/imports/ppsh
	name = "PPSH SMG"
	contains = list(
		/obj/item/weapon/gun/smg/ppsh,
		/obj/item/ammo_magazine/smg/ppsh,
		/obj/item/ammo_magazine/smg/ppsh,
		/obj/item/ammo_magazine/smg/ppsh,
		/obj/item/ammo_magazine/smg/ppsh,
	)
	cost = 30

/datum/supply_packs/imports/p90
	name = "FN P9000 SMG"
	contains = list(
		/obj/item/weapon/gun/smg/p90,
		/obj/item/ammo_magazine/smg/p90,
		/obj/item/ammo_magazine/smg/p90,
		/obj/item/ammo_magazine/smg/p90,
		/obj/item/ammo_magazine/smg/p90,
	)
	cost = 30

/datum/supply_packs/imports/customshotgun
	name = "Custom Built Shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/merc,
		/obj/item/ammo_magazine/shotgun,
	)
	cost = 30

/datum/supply_packs/imports/doublebarrel
	name = "Double Barrel Shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/double,
		/obj/item/ammo_magazine/shotgun,
	)
	cost = 30

/datum/supply_packs/imports/sawnoff
	name = "Sawn Off Shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/double/sawn,
		/obj/item/ammo_magazine/shotgun,
	)
	cost = 30

/datum/supply_packs/imports/m37a2
	name = "M37A2 Pump Shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump,
		/obj/item/ammo_magazine/shotgun,
	)
	cost = 30

/datum/supply_packs/imports/paladin
	name = "Paladin-12 Shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump/cmb,
		/obj/item/ammo_magazine/shotgun,
	)
	cost = 30

/datum/supply_packs/imports/kronos
	name = "Kronos Shotgun"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump/ksg,
		/obj/item/ammo_magazine/shotgun,
	)
	cost = 30

/datum/supply_packs/imports/leveraction
	name = "Lever Action Rifle"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump/lever,
		/obj/item/ammo_magazine/magnum,
		/obj/item/ammo_magazine/magnum,
	)
	cost = 30

/datum/supply_packs/imports/mosin
	name = "Mosin Nagant Sniper"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump/bolt,
		/obj/item/ammo_magazine/rifle/bolt,
		/obj/item/ammo_magazine/rifle/bolt,
		/obj/item/ammo_magazine/rifle/bolt,
	)
	cost = 30

/datum/supply_packs/imports/dragunov
	name = "SVD Dragunov Sniper"
	contains = list(
		/obj/item/weapon/gun/rifle/sniper/svd,
		/obj/item/ammo_magazine/sniper/svd,
		/obj/item/ammo_magazine/sniper/svd,
		/obj/item/ammo_magazine/sniper/svd,
		/obj/item/ammo_magazine/sniper/svd,
	)
	cost = 30

/datum/supply_packs/imports/ak47
	name = "AK-47 Assault Rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
	)
	cost = 30

/datum/supply_packs/imports/ak47u
	name = "AK-47U Battle Carbine"
	contains = list(
		/obj/item/weapon/gun/rifle/ak47/carbine,
		/obj/item/ammo_magazine/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
		/obj/item/ammo_magazine/rifle/ak47,
	)
	cost = 30

/datum/supply_packs/imports/m16	//Vietnam time
	name = "FN M16A Assault Rifle"
	contains = list(
		/obj/item/weapon/gun/rifle/m16,
		/obj/item/ammo_magazine/rifle/m16,
		/obj/item/ammo_magazine/rifle/m16,
		/obj/item/ammo_magazine/rifle/m16,
		/obj/item/ammo_magazine/rifle/m16,
	)
	cost = 30

/datum/supply_packs/imports/rev357
	name = "Smith and Wesson 357 Revolver"
	contains = list(
		/obj/item/weapon/gun/revolver/small,
		/obj/item/ammo_magazine/revolver/small,
		/obj/item/ammo_magazine/revolver/small,
		/obj/item/ammo_magazine/revolver/small,
		/obj/item/ammo_magazine/revolver/small,
	)
	cost = 30

/datum/supply_packs/imports/cmb
	name = "CMB Autorevolver"
	contains = list(
		/obj/item/weapon/gun/revolver/cmb,
		/obj/item/ammo_magazine/revolver/cmb,
		/obj/item/ammo_magazine/revolver/cmb,
		/obj/item/ammo_magazine/revolver/cmb,
		/obj/item/ammo_magazine/revolver/cmb,
	)
	cost = 30

/datum/supply_packs/imports/beretta92fs
	name = "Beretta 92FS Handgun"
	contains = list(
		/obj/item/weapon/gun/pistol/b92fs,
		/obj/item/ammo_magazine/pistol/b92fs,
		/obj/item/ammo_magazine/pistol/b92fs,
		/obj/item/ammo_magazine/pistol/b92fs,
		/obj/item/ammo_magazine/pistol/b92fs,
	)
	cost = 30

/datum/supply_packs/imports/beretta93r
	name = "Beretta 93R Handgun"
	contains = list(
		/obj/item/weapon/gun/pistol/b92fs/raffica,
		/obj/item/ammo_magazine/pistol/b93r,
		/obj/item/ammo_magazine/pistol/b93r,
		/obj/item/ammo_magazine/pistol/b93r,
		/obj/item/ammo_magazine/pistol/b93r,
	)
	cost = 30

/datum/supply_packs/imports/deagle
	name = "Desert Eagle Handgun"
	contains = list(
		/obj/item/weapon/gun/pistol/heavy,
		/obj/item/ammo_magazine/pistol/heavy,
		/obj/item/ammo_magazine/pistol/heavy,
		/obj/item/ammo_magazine/pistol/heavy,
		/obj/item/ammo_magazine/pistol/heavy,
	)
	cost = 30

/datum/supply_packs/imports/kt42
	name = "KT-42 Automag"
	contains = list(
		/obj/item/weapon/gun/pistol/kt42,
		/obj/item/ammo_magazine/pistol/automatic,
		/obj/item/ammo_magazine/pistol/automatic,
		/obj/item/ammo_magazine/pistol/automatic,
		/obj/item/ammo_magazine/pistol/automatic,
	)
	cost = 30

/datum/supply_packs/imports/vp78
	name = "VP78 Handgun"
	contains = list(
		/obj/item/weapon/gun/pistol/vp78,
		/obj/item/ammo_magazine/pistol/vp78,
		/obj/item/ammo_magazine/pistol/vp78,
		/obj/item/ammo_magazine/pistol/vp78,
		/obj/item/ammo_magazine/pistol/vp78,
	)
	cost = 30

/datum/supply_packs/imports/highpower
	name = "Highpower Automag"
	contains = list(
		/obj/item/weapon/gun/pistol/highpower,
		/obj/item/ammo_magazine/pistol/highpower,
		/obj/item/ammo_magazine/pistol/highpower,
		/obj/item/ammo_magazine/pistol/highpower,
		/obj/item/ammo_magazine/pistol/highpower,
	)
	cost = 30

/datum/supply_packs/imports/holdout
	name = "Holdout Handgun"
	contains = list(
		/obj/item/weapon/gun/pistol/holdout,
		/obj/item/ammo_magazine/pistol/holdout,
		/obj/item/ammo_magazine/pistol/holdout,
		/obj/item/ammo_magazine/pistol/holdout,
		/obj/item/ammo_magazine/pistol/holdout,
	)
	cost = 10
