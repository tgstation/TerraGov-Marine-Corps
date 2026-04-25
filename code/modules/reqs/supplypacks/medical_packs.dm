/*******************************************************************************
MEDICAL
*******************************************************************************/
/datum/supply_packs/medical
	group = "Medical"
	containertype = /obj/structure/closet/crate/medical

/datum/supply_packs/medical/advanced_medical
	name = "Emergency medical supplies"
	contains = list(
		/obj/item/storage/pouch/medical_injectors/medic,
		/obj/item/storage/pouch/medical_injectors/medic,
		/obj/item/storage/pouch/medical_injectors/medic,
		/obj/item/storage/pouch/medical_injectors/medic,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus,
		/obj/item/reagent_containers/hypospray/autoinjector/neuraline,
		/obj/item/stack/nanopaste,
	)
	cost = 300

/datum/supply_packs/medical/biomass
	name = "Biomass beaker"
	contains = list(
		/obj/item/reagent_containers/glass/beaker/biomass,
	)
	cost = 150

/datum/supply_packs/medical/Medical_hud
	name = "Healthmate medical hud"
	contains = list(
		/obj/item/clothing/glasses/hud/health,
	)
	cost = 20

/datum/supply_packs/medical/medical
	name = "Pills and chemicals"
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
		/obj/item/storage/box/pillbottles,
	)
	cost = 100

/datum/supply_packs/medical/firstaid
	name = "Advanced first aid kit"
	contains = list(/obj/item/storage/firstaid/adv)
	cost = 50

/datum/supply_packs/medical/bodybag
	name = "Body bags"
	notes = "Contains 7 bodybags"
	contains = list(/obj/item/storage/box/bodybags)
	cost = 50

/datum/supply_packs/medical/cryobag
	name = "Stasis bag"
	contains = list(/obj/item/bodybag/cryobag)
	cost = 50

/datum/supply_packs/medical/surgery
	name = "Surgical equipment"
	contains = list(
		/obj/item/storage/surgical_tray,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/tank/anesthetic,
		/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin,
		/obj/item/reagent_containers/hypospray/autoinjector/sleeptoxin,
	)
	cost = 100
	access = ACCESS_MARINE_MEDBAY
	containertype = /obj/structure/closet/crate/secure/surgery

/datum/supply_packs/medical/hypospray
	name = "Advanced hypospray"
	contains = list(/obj/item/reagent_containers/hypospray/advanced)
	cost = 50
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/hypospray
	name = "Advanced big hypospray"
	contains = list(/obj/item/reagent_containers/hypospray/advanced/big)
	cost = 120 //just a little over the regular hypo.
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/medvac
	name = "MEDEVAC system"
	contains = list(
		/obj/item/roller/medevac,
		/obj/item/medevac_beacon,
	)
	cost = 500
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/lemolime
	name = "Lemoline bottle"
	notes = "Contains 1 bottle of lemoline with 30 units each."
	contains = list(
		/obj/item/reagent_containers/glass/bottle/lemoline/doctor,
	)
	cost = 80

/datum/supply_packs/medical/advancedKits
	name = "Advanced medical packs"
	notes = "Contains 5 advanced packs of each type and 5 splints."
	contains = list(
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
		/obj/item/stack/medical/splint,
	)
	cost = 100 //you have ALMOST infinite ones in medbay if you need this crate you fucked up. but no reason to make the price too high either
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY

/datum/supply_packs/medical/tweezers
	name = "Tweezers"
	notes = "contains a pair of tweezers."
	contains = list(/obj/item/tweezers)
	cost = 200  //shouldn't be easy to get
	containertype = /obj/structure/closet/crate/secure/surgery
	access = ACCESS_MARINE_MEDBAY
