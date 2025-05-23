/*******************************************************************************
ARMOR
*******************************************************************************/
/datum/supply_packs/armor
	group = "Armor"
	containertype = /obj/structure/closet/crate

/datum/supply_packs/armor/masks
	name = "SWAT protective mask"
	contains = list(/obj/item/clothing/mask/gas/swat)
	cost = 50

/datum/supply_packs/armor/riot
	name = "Heavy riot armor set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/riot,
		/obj/item/clothing/head/helmet/marine/riot,
	)
	cost = 120
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/marine_shield/deployable
	name = "TL-182 deployable shield"
	contains = list(/obj/item/weapon/shield/riot/marine/deployable)
	cost = 30

/datum/supply_packs/armor/b18
	name = "B18 armor set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/gloves/marine/specialist,
	)
	cost = B18_PRICE

/datum/supply_packs/armor/b17
	name = "B17 armor set"
	contains = list(
		/obj/item/clothing/suit/storage/marine/B17,
		/obj/item/clothing/head/helmet/marine/grenadier,
	)
	cost = B17_PRICE

/datum/supply_packs/armor/scout_cloak
	name = "Scout cloak"
	contains = list(/obj/item/storage/backpack/marine/satchel/scout_cloak)
	cost = 500

/datum/supply_packs/armor/sniper_cloak
	name = "Sniper cloak"
	contains = list(/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper)
	cost = 500

/datum/supply_packs/armor/grenade_belt
	name = "High capacity grenade belt"
	contains = list(/obj/item/storage/belt/grenade/b17)
	cost = 200
	available_against_xeno_only = TRUE

/datum/supply_packs/armor/modular/attachments/mixed
	name = "Combined mark 2 module set"
	contains = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/fire_proof_helmet,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
	)
	cost = 400

/datum/supply_packs/armor/modular/attachments/valkyrie_autodoc
	name = "Valkyrie automedical system"
	contains = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
	)
	cost = 120

/datum/supply_packs/armor/modular/attachments/fire_proof
	name = "Surt thermal insulation system set"
	contains = list(
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/fire_proof_helmet,
	)
	cost = 120

/datum/supply_packs/armor/modular/attachments/tyr_extra_armor
	name = "Tyr Mk.2 armor reinforcement system"
	contains = list(
		/obj/item/armor_module/module/tyr_extra_armor,
	)
	cost = 120

/datum/supply_packs/armor/modular/attachments/mimir_environment_protection
	name = "Mimir Mk.2 environmental resistance system set"
	contains = list(
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection,
	)
	cost = 150

/datum/supply_packs/armor/modular/attachments/hlin_bombimmune
	name = "Hlin explosive compensation system"
	contains = list(/obj/item/armor_module/module/hlin_explosive_armor)
	cost = 120

/datum/supply_packs/armor/modular/attachments/artemis_mark_two
	name = "Freyr Mk.2 visual assistance helmet system"
	contains = list(
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
	)
	cost = 40
