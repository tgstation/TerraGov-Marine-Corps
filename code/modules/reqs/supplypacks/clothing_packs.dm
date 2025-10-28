/*******************************************************************************
CLOTHING
*******************************************************************************/
/datum/supply_packs/clothing
	group = "Clothing"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/clothing/combat_pack
	name = "Combat Backpack"
	contains = list(/obj/item/storage/backpack/lightpack)
	cost = 150

/datum/supply_packs/clothing/dispenser
	name = "Dispenser"
	contains = list(/obj/item/storage/backpack/dispenser)
	cost = 400

/datum/supply_packs/clothing/welding_pack
	name = "Engineering Welding Pack"
	contains = list(/obj/item/storage/backpack/marine/engineerpack)
	cost = 50

/datum/supply_packs/clothing/radio_pack
	name = "Radio Operator Pack"
	contains = list(/obj/item/storage/backpack/marine/radiopack)
	cost = 50

/datum/supply_packs/clothing/technician_pack
	name = "Engineering Technician Pack"
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
	name = "Marine outfit"
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
	name = "BE-47 Night Vision Goggles (Requires nvg batteries to operate)"
	contains = list(/obj/item/clothing/glasses/night_vision)
	cost = 500 //requires batteries and not great vis range

/datum/supply_packs/clothing/night_vision_mounted
	name = "BE-35 Night Vision Module (Requires nvg batteries to operate)"
	contains = list(/obj/item/armor_module/module/night_vision)
	cost = 400

/datum/supply_packs/clothing/night_vision_batteries
	name = "Double pack of night vision batteries"
	contains = list(/obj/item/cell/night_vision_battery, /obj/item/cell/night_vision_battery)
	cost = 50

/datum/supply_packs/clothing/saddle
	name = "Runner Saddle"
	contains = list(/obj/item/storage/backpack/marine/duffelbag/xenosaddle)
	cost = 120

/datum/supply_packs/clothing/ktlnvg
	name = "KTLD head mounted sight"
	contains = list(/obj/item/clothing/glasses/night/m56_goggles)
	cost = 2000

/datum/supply_packs/clothing/cm12nvg
	name = "CM-12 night vision goggles"
	contains = list(/obj/item/clothing/glasses/night/vsd)
	cost = 1500

/datum/supply_packs/clothing/m42nvg
	name = "M42 scout sight"
	contains = list(/obj/item/clothing/glasses/night/m42_night_goggles)
	cost = 2500

/datum/supply_packs/clothing/night_visionvsd
	name = "KZ Type 9 goggles"
	contains = list(/obj/item/clothing/glasses/night/m42_night_goggles/upp)
	cost = 2500

/datum/supply_packs/clothing/hypnogoggles
	name = "Hypnotic goggles"
	contains = list(/obj/item/clothing/glasses/hypno)
	cost = 100

/datum/supply_packs/clothing/insuls
	name = "Insulated gloves"
	notes = "For only 10 more points you can get these as part of the Electrical Maintenance crate under engineering"
	contains = list(/obj/item/clothing/gloves/insulated)
	cost = 40
