/datum/supply_packs/weapons/rifle/T25
	name = "T25 smartrifle"
	contains = list(/obj/item/weapon/gun/rifle/T25)
	cost = 400

/datum/supply_packs/weapons/ammo_magazine/rifle/T25
	name = "T25 smartrifle magazine"
	contains = list(/obj/item/ammo_magazine/rifle/T25)
	cost = 20

/datum/supply_packs/weapons/ammo_magazine/packet/T25_rifle
	name = "T25 smartrifle ammo box"
	contains = list(/obj/item/ammo_magazine/packet/T25_rifle)
	cost = 60

/datum/supply_packs/weapons/vector
	name = "Vector"
	contains = list(/obj/item/weapon/gun/smg/vector)
	cost = 200

/datum/supply_packs/weapons/ammo_magazine/vector
	name = "Vector drum magazine"
	contains = list(/obj/item/ammo_magazine/smg/vector)
	cost = 5

/datum/supply_packs/weapons/valihalberd
	name = "VAL-HAL-A"
	contains = list(/obj/item/weapon/twohanded/glaive/harvester)
	cost = 600

/datum/supply_packs/armor/robot/advanced/acid
	name = "Exidobate acid protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/acid,
		/obj/item/clothing/suit/storage/marine/robot/advanced/acid,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/physical
	name = "Cingulata physical protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/physical,
		/obj/item/clothing/suit/storage/marine/robot/advanced/physical,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/bomb
	name = "Tardigrada bomb protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/bomb,
		/obj/item/clothing/suit/storage/marine/robot/advanced/bomb,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/robot/advanced/fire
	name = "Urodela fire protection armor set"
	contains = list(
		/obj/item/clothing/head/helmet/marine/robot/advanced/fire,
		/obj/item/clothing/suit/storage/marine/robot/advanced/fire,
	)
	cost = 600
	available_against_xeno_only = TRUE

/datum/supply_packs/supplies/pigs
	name = "Pig toys crate"
	contains = list(/obj/item/toy/plush/pig, /obj/item/toy/plush/pig, /obj/item/toy/plush/pig, /obj/item/toy/plush/pig, /obj/item/toy/plush/pig)
	cost = 100
	available_against_xeno_only = TRUE
	containertype = /obj/structure/closet/crate/supply

/datum/supply_packs/weapons/t500case
	name = "R-500 bundle"
	contains = list(/obj/item/storage/box/t500case)
	cost = 50

/datum/supply_packs/weapons/T25_extended_mag
	name = "T25 extended magazine"
	contains = list(/obj/item/ammo_magazine/rifle/T25/extended)
	cost = 200
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t21_extended_mag
	name = "AR-21 extended magazines pack"
	contains = list(/obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended, /obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended,/obj/item/ammo_magazine/rifle/standard_skirmishrifle/extended)
	cost = 350
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t21_ap
	name = "AR-21 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_skirmishrifle/ap)
	cost = 53 //30 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t18_ap
	name = "AR-18 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_carbine/ap)
	cost = 60 //36 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/t12_ap
	name = "AR-12 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_assaultrifle/ap)
	cost = 80 //50 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/br64_ap
	name = "BR-64 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/rifle/standard_br/ap)
	cost = 60 //36 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/smg25_ap
	name = "SMG-25 armor piercing magazine"
	contains = list(/obj/item/ammo_magazine/smg/m25/ap)
	cost = 90 //60 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x24mm_ap
	name = "10x24mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x24mm/ap)
	cost = 240 //150 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x25mm_ap
	name = "10x25mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x25mm/ap)
	cost = 220 //125 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x265mm_ap
	name = "10x26.5mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x265mm/ap)
	cost = 160 //100 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/weapons/box_10x20mm_ap
	name = "10x20mm armor piercing ammo box"
	contains = list(/obj/item/ammo_magazine/packet/p10x20mm/ap)
	cost = 225 //150 rounds
	containertype = /obj/structure/closet/crate/ammo

/datum/supply_packs/explosives/knee_mortar
	name = "T-10K Knee Mortar"
	contains = list(/obj/item/mortar_kit/knee)
	cost = 125

/datum/supply_packs/explosives/knee_mortar_ammo
	name = "TA-10K knee mortar HE shell"
	contains = list(/obj/item/mortal_shell/knee, /obj/item/mortal_shell/knee)
	cost = 5
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/imager_goggle
	name = "Optical Imager Goggles"
	contains = list(/obj/item/clothing/glasses/night/imager_goggles)
	cost = 50

/datum/supply_packs/operations/beacons_orbital
	name = "orbital beacon"
	contains = list(/obj/item/beacon/orbital_bombardment_beacon)
	cost = 30
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/thermobaric
	name = "RL-57 Thermobaric Launcher Kit"
	contains = list(/obj/item/storage/holster/backholster/rlquad/full)
	cost = 500 + 50 //ammo price
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/specdemo
	name = "RL-152 SADAR Rocket Launcher kit"
	contains = list(/obj/item/storage/holster/backholster/rlsadar/full)
	cost = SADAR_PRICE + 150 //ammo price
	available_against_xeno_only = TRUE

/datum/supply_packs/weapons/minigun_powerpack
	name = "SG-85 Minigun Powerpack"
	contains = list(/obj/item/ammo_magazine/minigun_powerpack/smartgun)
	cost = 150

/datum/supply_packs/weapons/smarttarget_rifle_ammo
	cost = 25

/datum/supply_packs/weapons/box_10x27mm
	name = "SG-62 smart target rifle ammo box"
	contains = list(/obj/item/ammo_magazine/packet/sg62_rifle)
	cost = 50
