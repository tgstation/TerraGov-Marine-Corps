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

/datum/supply_packs/weapons/m56d_emplacement
	name = "M56D Stationary Machinegun"
	contains = list(/obj/item/storage/box/m56d_hmg)
	cost = 80

/datum/supply_packs/weapons/flamethrower
	name = "M240 Flamethrower"
	contains = list(
		/obj/item/weapon/gun/flamer,
		/obj/item/ammo_magazine/flamer_tank,
	)
	cost = 50

/datum/supply_packs/weapons/mateba
	name = "Mateba Autorevolver kit"
	contains = list(/obj/item/storage/belt/gun/mateba/full)
	notes = "Contains 6 speedloaders"
	cost = 50

/datum/supply_packs/weapons/pistols
	name = "surplus sidearms"
	contains = list(
		/obj/item/weapon/gun/pistol/standard_pistol,
		/obj/item/ammo_magazine/pistol/standard_pistol,
		/obj/item/weapon/gun/revolver/standard_revolver,
		/obj/item/ammo_magazine/revolver/standard_revolver,
	)
	cost = 10

/datum/supply_packs/weapons/rifles
	name = "surplus bolt action rifle"
	contains = list(
		/obj/item/weapon/gun/shotgun/pump/bolt/infantry,
		/obj/item/ammo_magazine/rifle/bolt,
	)
	cost = 10

/datum/supply_packs/weapons/heavyrifle_squad
	name = "T-42 LMG"
	contains = list(
		/obj/item/weapon/gun/rifle/standard_lmg,
		/obj/item/ammo_magazine/standard_lmg,
	)
	cost = 40

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

/datum/supply_packs/ammo/smartmachinegun
	name = "T-29 smartmachinegun ammo"
	contains = list(/obj/item/ammo_magazine/standard_smartmachinegun)
	cost = 10

/datum/supply_packs/ammo/sentry
	name = "UA 571-C sentry ammunition"
	contains = list(/obj/item/ammo_magazine/sentry)
	cost = 15

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

/datum/supply_packs/ammo/m56d
	name = "M56D mounted smartgun ammo"
	contains = list(/obj/item/ammo_magazine/m56d)
	cost = 15

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
