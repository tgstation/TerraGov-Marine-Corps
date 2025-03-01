/*******************************************************************************
CLOTHING
*******************************************************************************/
/datum/supply_packs/clothing
	group = "Clothing"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/clothing/combat_pack
	name = "Combat backpack"
	contains = list(/obj/item/storage/backpack/lightpack)
	cost = 150

/datum/supply_packs/clothing/dispenser
	name = "Dispenser"
	contains = list(/obj/item/storage/backpack/dispenser)
	cost = 400

/datum/supply_packs/clothing/welding_pack
	name = "Engineering welding pack"
	contains = list(/obj/item/storage/backpack/marine/engineerpack)
	cost = 50

/datum/supply_packs/clothing/radio_pack
	name = "Radio operator pack"
	contains = list(/obj/item/storage/backpack/marine/radiopack)
	cost = 50

/datum/supply_packs/clothing/technician_pack
	name = "Engineering technician pack"
	contains = list(/obj/item/storage/backpack/marine/tech)
	cost = 50

/datum/supply_packs/clothing/officer_outfits
	name = "Officer outfits"
	contains = list(
		/obj/item/clothing/under/marine/officer/ro_suit,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/bridge,
		/obj/item/clothing/under/marine/officer/exec,
		/obj/item/clothing/under/marine/officer/ce,
	)
	cost = 100

/datum/supply_packs/clothing/marine_outfits
	name = "Marine outfits"
	contains = list(
		/obj/item/clothing/under/marine,
		/obj/item/storage/belt/marine,
		/obj/item/storage/backpack/marine/standard,
		/obj/item/clothing/shoes/marine,
	)
	cost = 50

/datum/supply_packs/clothing/webbing
	name = "Webbing"
	contains = list(/obj/item/armor_module/storage/uniform/webbing)
	cost = 20

/datum/supply_packs/clothing/brown_vest
	name = "Brown vest"
	contains = list(/obj/item/armor_module/storage/uniform/brown_vest)
	cost = 20

/datum/supply_packs/clothing/jetpack
	name = "Jetpack"
	contains = list(/obj/item/jetpack_marine)
	cost = 120

/datum/supply_packs/clothing/night_vision
	name = "BE-47 NVG night vision goggles"
	contains = list(/obj/item/clothing/glasses/night_vision)
	cost = 500

/datum/supply_packs/clothing/night_vision_mounted
	name = "BE-35 NVG night vision module"
	contains = list(/obj/item/armor_module/module/night_vision)
	cost = 300

/datum/supply_packs/clothing/night_vision_batteries
	name = "Double pack of night vision batteries"
	contains = list(/obj/item/cell/night_vision_battery, /obj/item/cell/night_vision_battery)
	cost = 100

/datum/supply_packs/clothing/saddle
	name = "Runner saddle"
	contains = list(/obj/item/storage/backpack/marine/duffelbag/xenosaddle)
	cost = 120
