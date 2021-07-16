//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

GLOBAL_LIST_INIT(all_supply_groups, list("Operations", "Weapons", "Attachments", "Ammo", "Armor", "Clothing", "Medical", "Engineering", "Supplies", "Imports"))

/datum/supply_packs
	var/name
	var/notes
	var/list/contains = list()
	var/cost
	var/obj/containertype
	var/access
	var/group
	///Randomly picks X of items out of the contains list instead of using all.
	var/randomised_num_contained = 0
	///If this supply pack should be buyable in HvH gamemode
	var/available_against_xeno_only = FALSE

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
	contains = list(/obj/item/beacon/supply_beacon)
	cost = 10

/datum/supply_packs/operations/beacons_orbital
	name = "orbital beacon"
	contains = list(/obj/item/beacon/orbital_bombardment_beacon)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/fulton_extraction_pack
	name = "fulton extraction pack"
	contains = list(/obj/item/fulton_extraction_pack)
	cost = 5

/datum/supply_packs/operations/cas_flares
	name = "CAS flare pack"
	contains = list(/obj/item/storage/box/m94/cas)
	available_against_xeno_only = TRUE
	cost = 5

/datum/supply_packs/operations/binoculars_regular
	name = "binoculars"
	contains = list(/obj/item/binoculars)
	cost = 15

/datum/supply_packs/operations/binoculars_tatical
	name = "tactical binoculars crate"
	contains = list(/obj/item/binoculars/tactical)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/motion_detector
	name = "motion detector crate"
	contains = list(/obj/item/motiondetector/scout)
	cost = 20

/datum/supply_packs/operations/pinpointer
	name = "pool tracker crate"
	contains = list(/obj/item/pinpointer/pool)
	cost = 20
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/flares
	name = "flare packs"
	contains = list(/obj/item/storage/box/m94)
	cost = 1
/datum/supply_packs/operations/tarps
	name = "V1 thermal-dampening tarp"
	contains = list(/obj/item/bodybag/tarp)
	cost = 6
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/deployablecams
	name = "3 Deployable Cameras"
	contains = list(/obj/item/deployable_camera)
	cost = 2

/datum/supply_packs/operations/exportpad
	name = "ASRS Bluespace Export Point"
	contains = list(/obj/machinery/exportpad)
	cost = 50

/datum/supply_packs/operations/alpha
	name = "Alpha Supply Crate"
	contains = list(/obj/structure/closet/crate/alpha)
	cost = 5
	containertype = null

/datum/supply_packs/operations/bravo
	name = "Bravo Supply Crate"
	contains = list(/obj/structure/closet/crate/bravo)
	cost = 5
	containertype = null

/datum/supply_packs/operations/charlie
	name = "Charlie Supply Crate"
	contains = list(/obj/structure/closet/crate/charlie)
	cost = 5
	containertype = null

/datum/supply_packs/operations/delta
	name = "Delta Supply Crate"
	contains = list(/obj/structure/closet/crate/delta)
	cost = 5
	containertype = null

/datum/supply_packs/operations/warhead_cluster
	name = "Cluster orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/cluster)
	cost = 20
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/warhead_explosive
	name = "HE orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/explosive)
	cost = 30
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/warhead_incendiary
	name = "Incendiary orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/incendiary)
	cost = 20
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/warhead_plasmaloss
	name = "Plasma draining orbital warhead"
	contains = list(/obj/structure/ob_ammo/warhead/plasmaloss)
	cost = 15
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/ob_fuel
	name = "Solid fuel"
	contains = list(/obj/structure/ob_ammo/ob_fuel)
	cost = 5
	access = ACCESS_MARINE_ENGINEERING
	containertype = /obj/structure/closet/crate/secure/explosives
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/cas_voucher
	name = "100 dropship fabricator points"
	contains = list(/obj/item/dropship_points_voucher)
	cost = 40
	containertype = null
	available_against_xeno_only = TRUE

/datum/supply_packs/operations/autominer
	name = "Autominer upgrade"
	contains = list(/obj/item/minerupgrade/automatic)
	cost = 15

/*******************************************************************************
WEAPONS
*******************************************************************************/

/datum/supply_packs/weapons
	group = "Weapons"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/weapons/sentry
	name = "UA 571-C Base Defense Sentry"
	contains = list(/obj/item/storage/box/sentry)
	cost = 60

/datum/supply_packs/weapons/minisentry
	name = "UA-580 Portable Sentry"
	contains = list(/obj/item/storage/box/minisentry)
	cost = 30

/datum/supply_packs/weapons/m56d_emplacement
	name = "TL-102 Mounted Heavy Smartgun"
	contains = list(/obj/item/storage/box/tl102)
	cost = 80

/datum/supply_packs/weapons/tesla
	name = "Energy Ball Rifle"
	contains = list(
		/obj/item/weapon/gun/energy/lasgun/tesla,
		/obj/item/cell/lasgun/tesla,
		/obj/item/cell/lasgun/tesla,
	)
	cost = 60

/datum/supply_packs/weapons/recoillesskit
	name = "Recoilless rifle kit"
	contains = list(/obj/item/storage/box/recoilless_system)
	cost = 40
	available_against_xeno_only = TRUE


/datum/supply_packs/weapons/railgun
	name = "TX-220 Railgun"
	contains = list(/obj/item/weapon/gun/rifle/railgun)
	cost = 40

/datum/supply_packs/weapons/tx8
	name = "TX-8 Scout Rifle"
	contains = list(/obj/item/weapon/gun/rifle/tx8)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/thermobaric
	name = "T-57 Thermobaric"
	contains = list(/obj/item/weapon/gun/launcher/rocket/m57a4/t57)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/specdemo
	name = "Demolitionist Specialist kit"
	contains = list(/obj/item/weapon/gun/launcher/rocket/sadar)
	cost = SADAR_PRICE
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/autosniper
	name = "IFF Auto Sniper kit"
	contains = list(/obj/item/weapon/gun/rifle/standard_autosniper)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/antimaterial
	name = "T-26 Antimaterial rifle kit"
	contains = list(/obj/item/weapon/gun/rifle/sniper/antimaterial)
	cost = 60
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/specminigun
	name = "MIC-A7 Vindicator Minigun"
	contains = list(/obj/item/weapon/gun/minigun)
	cost = MINIGUN_PRICE
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/smartgun
	name = "T-29 Smart Machinegun"
	contains = list(/obj/item/weapon/gun/rifle/standard_smartmachinegun)
	cost = 40

/datum/supply_packs/weapons/smartrifle
	name = "T-26 Smart Rifle"
	contains = list(/obj/item/weapon/gun/rifle/standard_smartrifle)
	cost = 40

/datum/supply_packs/weapons/flamethrower
	name = "TL-84 Flamethrower"
	contains = list(/obj/item/weapon/gun/flamer/marinestandard)
	cost = 15

/datum/supply_packs/weapons/rpgoneuse
	name = "T-72 RPG"
	contains = list(/obj/item/weapon/gun/launcher/rocket/oneuse)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/mateba
	name = "Mateba Autorevolver belt"
	contains = list(/obj/item/storage/belt/gun/mateba/full)
	notes = "Contains 6 speedloaders"
	cost = 15
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/explosives_mines
	name = "claymore mines"
	notes = "Contains 5 mines"
	contains = list(/obj/item/storage/box/explosive_mines)
	cost = 15

/datum/supply_packs/weapons/explosives_razor
	name = "RB grenade box crate"
	notes = "Containers 20 razor burns"
	contains = list(/obj/item/storage/box/visual/grenade/razorburn)
	cost = 50

/datum/supply_packs/weapons/explosives_hedp
	name = "M40 HEDP high explosive grenade box crate"
	notes = "Contains 25 grenades"
	contains = list(/obj/item/storage/box/visual/grenade/frag)
	cost = 50

/datum/supply_packs/weapons/explosives_hidp
	name = "M40 HIDP incendiary explosive grenade box crate"
	notes = "Contains 25 grenades"
	contains = list(/obj/item/storage/box/visual/grenade/incendiary)
	cost = 50

/datum/supply_packs/weapons/explosives_m15
	name = "M15 fragmentation grenade box crate"
	notes = "Contains 15 grenades"
	contains = list(/obj/item/storage/box/visual/grenade/M15)
	cost = 50

/datum/supply_packs/weapons/explosives_hsdp
	name = "M40 HSDP white phosphorous grenade box crate"
	notes = "Contains 15 grenades"
	contains = list(/obj/item/storage/box/visual/grenade/phosphorus)
	cost = 70

/datum/supply_packs/weapons/explosives_plasmadrain
	name = "M40-T gas grenade box crate"
	notes = "Contains 25 grenades"
	contains = list(/obj/item/storage/box/visual/grenade/drain)
	cost = 70
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/plastique
	name = "C4 plastic explosive"
	contains = list(/obj/item/explosive/plastique)
	cost = 5

/datum/supply_packs/weapons/mortar
	name = "M402 mortar crate"
	contains = list(/obj/item/mortar_kit)
	cost = 40
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/detpack
	name = "detpack explosives"
	contains = list(
		/obj/item/detpack,
		/obj/item/detpack,
		/obj/item/assembly/signaler,
	)
	cost = 15

/*******************************************************************************
ATTACHMENTS
*******************************************************************************/
/datum/supply_packs/attachments
	group = "Attachments"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/attachments/rail_reddot
	name = "red-dot sight attachment"
	contains = list(/obj/item/attachable/reddot)
	cost = 1

/datum/supply_packs/attachments/rail_scope
	name = "railscope attachment"
	contains = list(/obj/item/attachable/scope)
	cost = 1
	available_against_xeno_only = TRUE

/datum/supply_packs/attachments/rail_miniscope
	name = "mini railscope attachment"
	contains = list(/obj/item/attachable/scope/mini)
	cost = 1
	available_against_xeno_only = TRUE

/datum/supply_packs/attachments/rail_magneticharness
	name = "magnetic harness attachment"
	contains = list(/obj/item/attachable/magnetic_harness)
	cost = 1

/datum/supply_packs/attachments/muzzle_suppressor
	name = "suppressor attachment"
	contains = list(/obj/item/attachable/suppressor)
	cost = 1

/datum/supply_packs/attachments/muzzle_bayonet
	name = "bayonet attachment"
	contains = list(/obj/item/attachable/bayonet)
	cost = 1

/datum/supply_packs/attachments/muzzle_extended
	name = "extended barrel attachment"
	contains = list(/obj/item/attachable/extended_barrel)
	cost = 1

/datum/supply_packs/attachments/muzzle_heavy
	name = "barrel charger attachment"
	contains = list(/obj/item/attachable/heavy_barrel)
	cost = 1

/datum/supply_packs/attachments/muzzle_compensator
	name = "compensator attachment"
	contains = list(/obj/item/attachable/compensator)
	cost = 1

/datum/supply_packs/attachments/lasersight
	name = "lasersight attachment"
	contains = list(/obj/item/attachable/lasersight)
	cost = 1

/datum/supply_packs/attachments/angledgrip
	name = "angledgrip attachment"
	contains = list(/obj/item/attachable/angledgrip)
	cost = 1

/datum/supply_packs/attachments/verticalgrip
	name = "verticalgrip attachment"
	contains = list(/obj/item/attachable/verticalgrip)
	cost = 1

/datum/supply_packs/attachments/underbarrel_gyro
	name = "gyroscopic stabilizer attachment"
	contains = list(/obj/item/attachable/gyro)
	cost = 1

/datum/supply_packs/attachments/underbarrel_bipod
	name = "bipod attachment"
	contains = list(/obj/item/attachable/bipod)
	cost = 1

/datum/supply_packs/attachments/underbarrel_shotgun
	name = "underbarrel shotgun attachment"
	contains = list(/obj/item/attachable/attached_gun/shotgun)
	cost = 1

/datum/supply_packs/attachments/underbarrel_flamer
	name = "underbarrel flamer attachment"
	contains = list(/obj/item/attachable/attached_gun/flamer)
	cost = 1

/datum/supply_packs/attachments/underbarrel_burstfire_assembly
	name = "burstfire assembly attachment"
	contains = list(/obj/item/attachable/burstfire_assembly)
	cost = 1

/datum/supply_packs/attachments/stock_shotgun
	name = "shotgun stock attachment"
	contains = list(/obj/item/attachable/stock/t35stock)
	cost = 1

/datum/supply_packs/attachments/stock_smg
	name = "combat shotgun stock attachment crate"
	contains = list(/obj/item/attachable/stock/tactical)
	cost = 1

/*******************************************************************************
AMMO
*******************************************************************************/
/datum/supply_packs/ammo
	containertype = /obj/structure/closet/crate/ammo
	group = "Ammo"

/datum/supply_packs/ammo
	name = "Energy Rifle cells 3x"
	contains = list(
		/obj/item/cell/lasgun/tesla,
		/obj/item/cell/lasgun/tesla,
		/obj/item/cell/lasgun/tesla,
	)
	cost = 10

/datum/supply_packs/ammo/standard_ammo
	name = "Surplus Standard Ammo Crate"
	notes = "Contains 22 ammo boxes of a wide variety which come prefilled. You lazy bum."
	contains = list(/obj/structure/largecrate/supply/ammo/standard_ammo)
	containertype = null
	cost = 20

/datum/supply_packs/ammo/mateba
	name = "Mateba magazine"
	contains = list(/obj/item/ammo_magazine/revolver/mateba)
	cost = 3
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/incendiaryslugs
	name = "Box of Incendiary Slugs"
	contains = list(/obj/item/ammo_magazine/shotgun/incendiary)
	cost = 10
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/scout_regular
	name = "TX-8 scout magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx8)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/scout_impact
	name = "TX-8 scout impact magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx8/impact)
	cost = 7
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/scout_incendiary
	name = "TX-8 scout incendiary magazine"
	contains = list(/obj/item/ammo_magazine/rifle/tx8/incendiary)
	cost = 7
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/autosniper_regular
	name = "T-81 IFF sniper magazine"
	contains = list(/obj/item/ammo_magazine/rifle/autosniper)
	cost = 3
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/antimaterial
	name = "T-26 magazine"
	contains = list(/obj/item/ammo_magazine/sniper)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/railgun
	name = "Railgun round"
	contains = list(/obj/item/ammo_magazine/railgun)
	cost = 3

/datum/supply_packs/ammo/shotguntracker
	name = "12 Gauge Tracker Shells"
	contains = list(/obj/item/ammo_magazine/shotgun/tracker)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/rpg_regular
	name = "T-152 RPG HE rocket"
	contains = list(/obj/item/ammo_magazine/rocket/sadar)
	cost = 7
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/rpg_ap
	name = "T-152 RPG AP rocket"
	contains = list(/obj/item/ammo_magazine/rocket/sadar/ap)
	cost = 7
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/rpg_wp
	name = "T-152 RPG WP rocket"
	contains = list(/obj/item/ammo_magazine/rocket/sadar/wp)
	cost = 7
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/thermobaric
	name = "T-57 WP rocket array"
	contains = list(/obj/item/ammo_magazine/rocket/m57a4)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/shell_regular
	name = "T-160 RR HE shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless)
	cost = 3
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/shell_le
	name = "T-160 RR LE shell"
	contains = list(/obj/item/ammo_magazine/rocket/recoilless/light)
	cost = 3
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/smartmachinegun
	name = "T-29 smartmachinegun ammo"
	contains = list(/obj/item/ammo_magazine/standard_smartmachinegun)
	cost = 5

/datum/supply_packs/ammo/smartrifle
	name = "T-25 smartrifle magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_smartrifle)
	cost = 2

/datum/supply_packs/ammo/smartrifle_pack
	name = "T-25 smartrifle ammo box"
	notes = "Contains a box with 200 rounds for a T-25 (MAGAZINES SOLD SEPERATELY)"
	contains = list(/obj/item/ammo_magazine/packet/t25)
	cost = 4

/datum/supply_packs/ammo/sentry
	name = "UA 571-C sentry ammunition"
	contains = list(/obj/item/ammo_magazine/sentry)
	cost = 10

/datum/supply_packs/ammo/napalm
	name = "TL-84 normal fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank)
	cost = 3

/datum/supply_packs/ammo/mortar_ammo_he
	name = "M402 mortar HE shell"
	contains = list(/obj/item/mortal_shell/he)
	cost = 2
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/mortar_ammo_incend
	name = "M402 mortar incendiary shell"
	contains = list(/obj/item/mortal_shell/incendiary)
	cost = 2
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/mortar_ammo_flare
	name = "M402 mortar flare shell"
	contains = list(/obj/item/mortal_shell/flare)
	cost = 1
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/mortar_ammo_smoke
	name = "M402 mortar smoke shell"
	contains = list(/obj/item/mortal_shell/smoke)
	cost = 1
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/mortar_ammo_plasmaloss
	name = "M402 mortar tanglefoot shell"
	contains = list(/obj/item/mortal_shell/plasmaloss)
	cost = 2
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/minisentry
	name = "UA-580 point defense sentry ammo"
	contains = list(/obj/item/ammo_magazine/minisentry)
	cost = 5

/datum/supply_packs/ammo/m56d
	name = "TL-102 mounted heavy smartgun ammo"
	contains = list(/obj/item/ammo_magazine/tl102)
	cost = 10

/datum/supply_packs/ammo/lasguncharger
	name = "ColMarTech Lasrifle Field Charger"
	contains = list(/obj/machinery/vending/lasgun)
	cost = 50
	containertype = null

/datum/supply_packs/ammo/lasgun
	name = "Terra Experimental standard battery"
	contains = list(/obj/item/cell/lasgun/lasrifle/marine)
	cost = 2

/datum/supply_packs/ammo/minigun
	name = "Minigun Powerpack"
	contains = list(/obj/item/minigun_powerpack)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/ammo/back_fuel_tank
	name = "Standard back fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank/backtank)
	cost = 20

/datum/supply_packs/ammo/back_fuel_tank_x
	name = "Type X back fuel tank"
	contains = list(/obj/item/ammo_magazine/flamer_tank/backtank/X)
	cost = 60


/*******************************************************************************
ARMOR
*******************************************************************************/
/datum/supply_packs/armor
	group = "Armor"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/armor/masks
	name = "SWAT protective mask"
	contains = list(/obj/item/clothing/mask/gas/swat)
	cost = 5

/datum/supply_packs/armor/imager_goggle
	name = "Optical Imager Goggles"
	contains = list(/obj/item/clothing/glasses/night/imager_goggles)
	cost = 5

/datum/supply_packs/armor/riot
	name = "Heavy Riot Armor Set"
	contains = list(
		/obj/item/clothing/suit/armor/riot/marine,
		/obj/item/clothing/head/helmet/riot,
	)
	cost = 30

/datum/supply_packs/armor/marine_shield
	name = "TL-172 Defensive Shield"
	contains = list(/obj/item/weapon/shield/riot/marine)
	cost = 10

/datum/supply_packs/armor/b18
	name = "B18 Armor Set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
	)
	cost = B18_PRICE

/datum/supply_packs/armor/b17
	name = "B17 Armor Set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/B17,
		/obj/item/clothing/head/helmet/marine/grenadier,
	)
	cost = B17_PRICE

/datum/supply_packs/armor/scout_cloak
	name = "Scout Cloak"
	contains = list(/obj/item/storage/backpack/marine/satchel/scout_cloak/scout)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/sniper_cloak
	name = "Sniper Cloak"
	contains = list(/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper)
	cost = 50
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/grenade_belt
	name = "High Capacity Grenade Belt"
	contains = list(/obj/item/storage/belt/grenade/b17)
	cost = 20
	available_against_xeno_only = TRUE

// Modular armor + Attachments
/datum/supply_packs/armor/modular/exosuit
	name = "Jaeger exosuits"
	contains = list(/obj/item/clothing/suit/modular)
	cost = 1

/datum/supply_packs/armor/modular/armor/infantry
	name = "Jaeger Medium Infantry plates"
	contains = list(
		/obj/item/clothing/head/modular/marine,
		/obj/item/armor_module/armor/chest/marine,
		/obj/item/armor_module/armor/arms/marine,
		/obj/item/armor_module/armor/legs/marine,
	)
	cost = 1

/datum/supply_packs/armor/modular/armor/skirmisher
	name = "Jaeger Light Skirmisher plates"
	contains = list(
		/obj/item/clothing/head/modular/marine/skirmisher,
		/obj/item/armor_module/armor/chest/marine/skirmisher,
		/obj/item/armor_module/armor/arms/marine/skirmisher,
		/obj/item/armor_module/armor/legs/marine/skirmisher,
	)
	cost = 1

/datum/supply_packs/armor/modular/armor/assault
	name = "Jaeger Heavy Assault plates"
	contains = list(
		/obj/item/clothing/head/modular/marine/assault,
		/obj/item/armor_module/armor/chest/marine/assault,
		/obj/item/armor_module/armor/arms/marine/assault,
		/obj/item/armor_module/armor/legs/marine/assault,
	)
	cost = 1

/datum/supply_packs/armor/modular/helmet/infantry
	name = "Jaeger heavy helmets"
	contains = list(/obj/item/clothing/head/modular/marine)
	cost = 1

/datum/supply_packs/armor/modular/helmet/skirmisher
	name = "Jaeger medium helmets"
	contains = list(/obj/item/clothing/head/modular/marine/skirmisher)
	cost = 1

/datum/supply_packs/armor/modular/helmet/assault
	name = "Jaeger light helmets"
	contains = list(/obj/item/clothing/head/modular/marine/assault)
	cost = 1

/datum/supply_packs/armor/modular/storage
	name = "Jaeger assorted storage modules"
	contains = list(
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/engineering,
	)
	cost = 3

/datum/supply_packs/armor/modular/attachments/mixed
	name = "Jaeger experimental mark 2 modules"
	contains = list(
		/obj/item/armor_module/attachable/valkyrie_autodoc,
		/obj/item/armor_module/attachable/fire_proof,
		/obj/item/armor_module/attachable/tyr_extra_armor,
		/obj/item/armor_module/attachable/mimir_environment_protection,
		/obj/item/armor_module/attachable/better_shoulder_lamp,
		/obj/item/armor_module/attachable/hlin_explosive_armor,
	)
	cost = 40

/datum/supply_packs/armor/modular/attachments/lamp
	name = "Jaeger baldur modules"
	contains = list(
		/obj/item/armor_module/attachable/better_shoulder_lamp,
	)
	cost = 10

/datum/supply_packs/armor/modular/attachments/valkyrie_autodoc
	name = "Jaeger valkyrie modules"
	contains = list(
		/obj/item/armor_module/attachable/valkyrie_autodoc,
	)
	cost = 12

/datum/supply_packs/armor/modular/attachments/fire_proof
	name = "Jaeger surt modules"
	contains = list(
		/obj/item/armor_module/attachable/fire_proof,
	)
	cost = 12

/datum/supply_packs/armor/modular/attachments/tyr_extra_armor
	name = "Jaeger tyr mark 2 modules"
	contains = list(
		/obj/item/armor_module/attachable/tyr_extra_armor,
	)
	cost = 12

/datum/supply_packs/armor/modular/attachments/mimir_environment_protection
	name = "Jaeger mimir module"
	contains = list(
		/obj/item/armor_module/attachable/mimir_environment_protection,
	)
	cost = 12

/datum/supply_packs/armor/modular/attachments/mimir_helmet_protection
	name = "Jaeger helmet mimir module"
	contains = list(/obj/item/helmet_module/attachable/mimir_environment_protection)
	cost = 5
/datum/supply_packs/armor/modular/attachments/generic_helmet_modules
	name = "Generic Jaeger helmet modules"
	contains = list(
		/obj/item/helmet_module/welding,
		/obj/item/helmet_module/welding,
		/obj/item/helmet_module/binoculars,
		/obj/item/helmet_module/binoculars,
		/obj/item/helmet_module/antenna,
		/obj/item/helmet_module/antenna,
	)
	cost = 5
/datum/supply_packs/armor/modular/attachments/hlin_bombimmune
	name = "Jaeger Hlin module"
	contains = list(/obj/item/armor_module/attachable/hlin_explosive_armor)
	cost = 12

/*******************************************************************************
CLOTHING
*******************************************************************************/
/datum/supply_packs/clothing
	group = "Clothing"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/clothing/combat_pack
	name = "Combat Backpack"
	contains = list(/obj/item/storage/backpack/lightpack)
	cost = 15

/datum/supply_packs/clothing/welding_pack
	name = "Engineering Welding Pack"
	contains = list(/obj/item/storage/backpack/marine/engineerpack)
	cost = 5

/datum/supply_packs/clothing/technician_pack
	name = "Engineering Technician Pack"
	contains = list(/obj/item/storage/backpack/marine/tech)
	cost = 5

/datum/supply_packs/clothing/officer_outfits
	name = "officer outfits"
	contains = list(
		/obj/item/clothing/under/rank/ro_suit,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/exec,
		/obj/item/clothing/under/marine/officer/ce,
	)
	cost = 10

/datum/supply_packs/clothing/marine_outfits
	name = "marine outfit"
	contains = list(
		/obj/item/clothing/under/marine/standard,
		/obj/item/storage/belt/marine,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/clothing/shoes/marine,
	)
	cost = 5

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
	cost = 2

/datum/supply_packs/clothing/pistol
	name = "TP-14 holster"
	contains = list(/obj/item/storage/belt/gun/pistol/standard_pistol)
	cost = 2

/datum/supply_packs/clothing/pouches_general
	name = "general pouches"
	contains = list(
		/obj/item/storage/pouch/general/large,
		/obj/item/storage/pouch/general/large,
		/obj/item/storage/pouch/general/large,
	)
	cost = 5

/datum/supply_packs/clothing/pouches_weapons
	name = "weapons pouches"
	contains = list(
		/obj/item/storage/pouch/bayonet,
		/obj/item/storage/pouch/pistol,
		/obj/item/storage/pouch/explosive,
	)
	cost = 5

/datum/supply_packs/clothing/pouches_ammo
	name = "ammo pouches"
	contains = list(
		/obj/item/storage/pouch/magazine/large,
		/obj/item/storage/pouch/magazine/large,
		/obj/item/storage/pouch/magazine/pistol/large,
		/obj/item/storage/pouch/magazine/pistol/large,
	)
	cost = 5

/datum/supply_packs/clothing/pouches_medical
	name = "medical pouches"
	contains = list(
		/obj/item/storage/pouch/firstaid,
		/obj/item/storage/pouch/medical,
		/obj/item/storage/pouch/syringe,
		/obj/item/storage/pouch/medkit,
		/obj/item/storage/pouch/autoinjector,
	)
	cost = 5

/datum/supply_packs/clothing/pouches_survival
	name = "survival pouches"
	contains = list(
		/obj/item/storage/pouch/radio,
		/obj/item/storage/pouch/flare,
		/obj/item/storage/pouch/survival,
	)
	cost = 5

/datum/supply_packs/clothing/pouches_construction
	name = "construction pouches"
	contains = list(
		/obj/item/storage/pouch/document,
		/obj/item/storage/pouch/electronics,
		/obj/item/storage/pouch/tools,
		/obj/item/storage/pouch/construction,
	)
	cost = 5

/datum/supply_packs/clothing/jetpack
	name = "Jetpack"
	contains = list(/obj/item/jetpack_marine)
	cost = 12

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
	cost = 30

/datum/supply_packs/medical/dogtags
	name = "dogtags crate"
	contains = list(
		/obj/item/storage/box/ids/dogtag,
		/obj/item/storage/box/ids/dogtag,
		/obj/item/storage/box/ids/dogtag,
	)
	cost = 10

/datum/supply_packs/medical/biomass
	name = "biomass crate"
	contains = list(
		/obj/item/reagent_containers/glass/beaker/biomass,
	)
	cost = 15

/datum/supply_packs/medical/Medical_hud
	name = "Medical Hud Crate"
	contains = list(
		/obj/item/clothing/glasses/hud/health,
	)
	cost = 2

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
	cost = 10

/datum/supply_packs/medical/firstaid
	name = "advanced first aid kit"
	contains = list(/obj/item/storage/firstaid/adv)
	cost = 5

/datum/supply_packs/medical/bodybag
	name = "body bags"
	notes = "Contains 7 bodybags"
	contains = list(/obj/item/storage/box/bodybags)
	cost = 5

/datum/supply_packs/medical/cryobag
	name = "stasis bag"
	contains = list(/obj/item/bodybag/cryobag)
	cost = 5

/datum/supply_packs/medical/surgery
	name = "surgical equipment"
	contains = list(
		/obj/item/storage/surgical_tray,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/tank/anesthetic,
		/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin,
		/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin,
	)
	cost = 10
	access = ACCESS_MARINE_MEDBAY
	containertype = /obj/structure/closet/crate/secure/surgery

/datum/supply_packs/medical/hypospray
	name = "advanced hypospray"
	contains = list(/obj/item/reagent_containers/hypospray/advanced)
	cost = 5
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/hypospray
	name = "advanced big hypospray"
	contains = list(/obj/item/reagent_containers/hypospray/advanced/big)
	cost = 12 //just a little over the regular hypo.
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/medvac
	name = "medvac system"
	contains = list(
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
	)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/lemolime
	name = "lemoline"
	notes = "Contains 1 bottle of lemoline with 10 units."
	contains = list(/obj/item/reagent_containers/glass/bottle/lemoline)
	cost = 25

/datum/supply_packs/medical/advancedKits
	name = "Advanced medical packs"
	notes = "Contains 5 advanced packs of each type and 5 splints."
	contains = list(
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/advanced/ointment,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
	)
	cost = 10 //you have ALMOST infinite ones in medbay if you need this crate you fucked up. but no reason to make the price too high either
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/tweezers
	name = "tweezers"
	notes = "contains a pair of tweezers."
	contains = list(/obj/item/tweezers)
	cost = 20  //shouldn't be easy to get
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/*******************************************************************************
ENGINEERING
*******************************************************************************/
/datum/supply_packs/engineering
	group = "Engineering"
	containertype = /obj/structure/closet/crate/supply

/datum/supply_packs/engineering/powerloader
	name = "RPL-Y Cargo Loader"
	contains = list(/obj/vehicle/powerloader)
	cost = 20
	containertype = null

/datum/supply_packs/engineering/sandbags
	name = "50 empty sandbags"
	contains = list(/obj/item/stack/sandbags_empty/full)
	cost = 10

/datum/supply_packs/engineering/metal50
	name = "50 metal sheets"
	contains = list(/obj/item/stack/sheet/metal/large_stack)
	cost = 20

/datum/supply_packs/engineering/plas50
	name = "50 plasteel sheets"
	contains = list(/obj/item/stack/sheet/plasteel/large_stack)
	cost = 40

/datum/supply_packs/engineering/glass50
	name = "50 glass sheets"
	contains = list(/obj/item/stack/sheet/glass/large_stack)
	cost = 10

/datum/supply_packs/engineering/wood50
	name = "50 wooden planks"
	contains = list(/obj/item/stack/sheet/wood/large_stack)
	cost = 10

/datum/supply_packs/engineering/quikdeploycade
	name = "quikdeploy barricade"
	contains = list(/obj/item/quikdeploy/cade)
	cost = 3

/datum/supply_packs/engineering/pacman
	name = "P.A.C.M.A.N. Portable Generator"
	contains = list(/obj/machinery/power/port_gen/pacman)
	cost = 15
	containertype = null

/datum/supply_packs/engineering/phoron
	name = "Phoron Sheets"
	contains = list(/obj/item/stack/sheet/mineral/phoron/medium_stack)
	cost = 20

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
	cost = 10
	containertype = null

/datum/supply_packs/engineering/watertank
	name = "Water Tank"
	contains = list(/obj/structure/reagent_dispensers/watertank)
	cost = 5
	containertype = null

/datum/supply_packs/engineering/inflatable
	name = "inflatable barriers"
	notes = "Contains 3 doors and 4 walls"
	contains = list(/obj/item/storage/briefcase/inflatable)
	cost = 5

/datum/supply_packs/engineering/lightbulbs
	name = "replacement lights"
	notes = "Contains 14 tubes, 7 bulbs"
	contains = list(/obj/item/storage/box/lights/mixed)
	cost = 5

/datum/supply_packs/engineering/foam_grenade
	name = "Foam Grenade"
	contains = list(/obj/item/explosive/grenade/chem_grenade/metalfoam)
	cost = 3

/datum/supply_packs/engineering/floodlight
	name = "Combat Grade Floodlight"
	contains = list(/obj/machinery/floodlightcombat)
	cost = 5

/datum/supply_packs/engineering/advanced_generator
	name = "Wireless power generator"
	contains = list(/obj/machinery/power/port_gen/pacman/mobile_power)
	cost = 20

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
	cost = 5

/*******************************************************************************
Imports
*******************************************************************************/
/datum/supply_packs/imports
	group = "Imports"
	containertype = /obj/structure/closet/crate/weapon

/datum/supply_packs/imports/m41a
	name = "M41A Pulse Rifle"
	contains = list(/obj/item/weapon/gun/rifle/m41a)
	cost = 15

/datum/supply_packs/imports/m41a/ammo
	name = "M41A Pulse Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/m41a)
	cost = 5

/datum/supply_packs/imports/m412
	name = "M412 Pulse Rifle"
	contains = list(/obj/item/weapon/gun/rifle/m412)
	cost = 15

/datum/supply_packs/imports/m41a2/ammo
	name = "M412 Pulse Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle)
	cost = 5

/datum/supply_packs/imports/m412l1
	name = "M412L1 Heavy Pulse Rifle"
	contains = list(/obj/item/weapon/gun/rifle/m412l1_hpr)
	cost = 15

/datum/supply_packs/imports/m412l1/ammo
	name = "M412L1 Heavy Pulse Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/m412l1_hpr)
	cost = 5

/datum/supply_packs/imports/type71	//Moff gun
	name = "Type 71 Pulse Rifle"
	contains = list(/obj/item/weapon/gun/rifle/type71)
	cost = 15

/datum/supply_packs/imports/type71/ammo
	name = "Type 71 Pulse Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/type71)
	cost = 5

/datum/supply_packs/imports/mp7
	name = "MP7 SMG"
	contains = list(/obj/item/weapon/gun/smg/mp7)
	cost = 15

/datum/supply_packs/imports/mp7/ammo
	name = "MP7 SMG Ammo"
	contains = list(/obj/item/ammo_magazine/smg/mp7)
	cost = 5

/datum/supply_packs/imports/m25
	name = "MR-25 SMG"
	contains = list(/obj/item/weapon/gun/smg/m25)
	cost = 15

/datum/supply_packs/imports/m25/ammo
	name = "MR-25 SMG Ammo"
	contains = list(/obj/item/ammo_magazine/smg/m25)
	cost = 5

/datum/supply_packs/imports/skorpion
	name = "Skorpion SMG"
	contains = list(/obj/item/weapon/gun/smg/skorpion)
	cost = 15

/datum/supply_packs/imports/skorpion/ammo
	name = "Skorpion SMG Ammo"
	contains = list(/obj/item/ammo_magazine/smg/skorpion)
	cost = 5

/datum/supply_packs/imports/uzi
	name = "GAL-9 SMG"
	contains = list(/obj/item/weapon/gun/smg/uzi)
	cost = 10

/datum/supply_packs/imports/uzi/ammo
	name = "GAL-9 SMG Ammo"
	contains = list(/obj/item/ammo_magazine/smg/uzi)
	cost = 3

/datum/supply_packs/imports/ppsh
	name = "PPSH SMG"
	contains = list(/obj/item/weapon/gun/smg/ppsh)
	cost = 15

/datum/supply_packs/imports/ppsh/ammo
	name = "PPSH SMG Ammo Drum"
	contains = list(/obj/item/ammo_magazine/smg/ppsh/extended)
	cost = 5

/datum/supply_packs/imports/sawnoff
	name = "Sawn Off Shotgun"
	contains = list(/obj/item/weapon/gun/shotgun/double/sawn)
	cost = 15
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/leveraction
	name = "Lever Action Rifle"
	contains = list(/obj/item/weapon/gun/shotgun/pump/lever)
	cost = 15
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/leveraction/ammo
	name = "Lever Action Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/packet/magnum)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mbx900
	name = "MBX 900"
	contains = list(/obj/item/weapon/gun/shotgun/pump/lever/mbx900)
	cost = 15
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mbx900/buckshot
	name = "MBX-900 Buckshot Shells"
	contains = list(/obj/item/ammo_magazine/shotgun/mbx900/buckshot)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mosin
	name = "Mosin Nagant Sniper"
	contains = list(/obj/item/weapon/gun/shotgun/pump/bolt)
	cost = 15
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/mosin/ammo
	name = "Mosin Nagant Sniper Ammo (x2)"
	contains = list(
		/obj/item/ammo_magazine/rifle/bolt,
		/obj/item/ammo_magazine/rifle/bolt,
	)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/dragunov
	name = "SVD Dragunov Sniper"
	contains = list(/obj/item/weapon/gun/rifle/sniper/svd)
	cost = 15
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/dragunov/ammo
	name = "SVD Dragunov Sniper Ammo"
	contains = list(/obj/item/ammo_magazine/sniper/svd)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/imports/ak47
	name = "AK-47 Assault Rifle"
	contains = list(/obj/item/weapon/gun/rifle/ak47)
	cost = 15

/datum/supply_packs/imports/ak47/ammo
	name = "AK-47 Assault Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/ak47)
	cost = 5

/datum/supply_packs/imports/m16	//Vietnam time
	name = "FN M16A Assault Rifle"
	contains = list(/obj/item/weapon/gun/rifle/m16)
	cost = 15

/datum/supply_packs/imports/m16/ammo
	name = "FN M16A Assault Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/m16)
	cost = 5

/datum/supply_packs/imports/famas //bread joke here
	name = "FAMAS Assault Rifle"
	contains = list(/obj/item/weapon/gun/rifle/famas)
	cost = 15

/datum/supply_packs/imports/famas/ammo
	name = "FAMAS Assault Rifle Ammo"
	contains = list(/obj/item/ammo_magazine/rifle/famas)
	cost = 5

/datum/supply_packs/imports/rev357
	name = "Smith and Wesson 357 Revolver"
	contains = list(/obj/item/weapon/gun/revolver/small)
	cost = 7

/datum/supply_packs/imports/rev357/ammo
	name = "Smith and Wesson 357 Revolver Ammo"
	contains = list(/obj/item/ammo_magazine/revolver/small)
	cost = 3

/datum/supply_packs/imports/rev44
	name = "M-44 SAA Revolver"
	contains = list(/obj/item/weapon/gun/revolver/m44)
	cost = 7

/datum/supply_packs/imports/rev357/ammo
	name = "M-44 SAA Revolver Ammo"
	contains = list(/obj/item/ammo_magazine/revolver)
	cost = 3

/datum/supply_packs/imports/g22
	name = "G-22 Handgun"
	contains = list(/obj/item/weapon/gun/pistol/g22)
	cost = 7

/datum/supply_packs/imports/beretta92fs/ammo
	name = "G-22 Handgun Ammo"
	contains = list(/obj/item/ammo_magazine/pistol/g22)
	cost = 3

/datum/supply_packs/imports/deagle
	name = "Desert Eagle Handgun"
	contains = list(/obj/item/weapon/gun/pistol/heavy)
	cost = 7

/datum/supply_packs/imports/deagle/ammo
	name = "Desert Eagle Handgun Ammo"
	contains = list(/obj/item/ammo_magazine/pistol/heavy)
	cost = 3

/datum/supply_packs/imports/vp78
	name = "VP78 Handgun"
	contains = list(/obj/item/weapon/gun/pistol/vp78)
	cost = 7

/datum/supply_packs/imports/vp78/ammo
	name = "VP78 Handgun Ammo"
	contains = list(/obj/item/ammo_magazine/pistol/vp78)
	cost = 3

/datum/supply_packs/imports/highpower
	name = "Highpower Automag"
	contains = list(/obj/item/weapon/gun/pistol/highpower)
	cost = 7

/datum/supply_packs/imports/highpower/ammo
	name = "Highpower Automag Ammo"
	contains = list(/obj/item/ammo_magazine/pistol/highpower)
	cost = 3

/datum/supply_packs/imports/strawhat
	name = "Straw hat"
	contains = list(/obj/item/clothing/head/strawhat)
	cost = 1
