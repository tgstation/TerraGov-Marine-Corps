/datum/job/icc
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/craftier
	faction = FACTION_ICC

//ICC Standard
/datum/job/icc
	title = "ICC Standard"
	paygrade = "ICCH"
	outfit = /datum/outfit/job/icc/standard

/datum/outfit/job/icc
	name = "ICC Standard"
	jobtype = /datum/job/icc

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/icc/webbing
	belt = /obj/item/storage/belt/marine/icc
	ears = /obj/item/radio/headset/distress/icc
	w_uniform = /obj/item/clothing/under/icc/webbing
	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc
	gloves = /obj/item/clothing/gloves/marine/icc
	head = /obj/item/clothing/head/helmet/marine/icc
	mask = /obj/item/clothing/mask/gas/icc

/datum/outfit/job/icc/standard
	name = "ICC Standard"
	jobtype = /datum/job/icc

	id = /obj/item/card/id/silver
	gloves = /obj/item/clothing/gloves/marine/icc/insulated
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard
	r_store = /obj/item/storage/pouch/pistol/icc
	l_store = /obj/item/storage/pouch/tools/icc/full
	back = /obj/item/storage/backpack/lightpack/icc


/datum/outfit/job/icc/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)

//ICC Guard
/datum/job/icc/guard
	title = "ICC Guardsman"
	paygrade = "ICC3"
	outfit = /datum/outfit/job/icc/guard

/datum/outfit/job/icc/guard
	name = "ICC Guard"
	jobtype = /datum/job/icc/guard

	shoes = /obj/item/clothing/shoes/marine/icc/guard/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard
	suit_store = /obj/item/weapon/gun/launcher/rocket/som
	back = /obj/item/weapon/gun/rifle/icc_coilgun
	l_store = /obj/item/storage/pouch/explosive/icc
	r_store = /obj/item/storage/pouch/explosive/icc


/datum/outfit/job/icc/guard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/thermobaric, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/thermobaric, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/heat, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/heat, SLOT_IN_L_POUCH)


	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/icc_coilgun, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_ACCESSORY)

//ICC Medic
/datum/job/icc/medic
	title = "ICC Medic"
	paygrade = "ICC2"
	outfit = /datum/outfit/job/icc/medic
	skills_type = /datum/skills/combat_medic/crafty

/datum/outfit/job/icc/medic
	name = "ICC Medic"
	jobtype = /datum/job/icc/guard

	id = /obj/item/card/id/silver
	gloves = /obj/item/clothing/gloves/marine/icc
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness
	back = /obj/item/storage/backpack/lightpack/icc
	l_store = /obj/item/storage/pouch/magazine/large/icc
	r_store = /obj/item/storage/pouch/magazine/large/icc
	belt = /obj/item/storage/belt/lifesaver/icc/ert
	glasses = /obj/item/clothing/glasses/hud/health

/datum/outfit/job/icc/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)


	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/combat_advanced, SLOT_IN_ACCESSORY)

/datum/job/icc/leader
	title = "ICC Leader"
	paygrade = "ICC2"
	outfit = /datum/outfit/job/icc/leader
	skills_type = /datum/skills/sl/icc

/datum/outfit/job/icc/leader
	name = "ICC Leader"
	jobtype = /datum/job/icc/guard

	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard
	suit_store = /obj/item/weapon/gun/shotgun/pump/trenchgun/icc_leader
	belt = /obj/item/storage/belt/shotgun/icc/mixed
	back = /obj/item/storage/backpack/lightpack/icc/guard
	l_store = /obj/item/storage/pouch/medical_injectors/icc/firstaid
	r_store = /obj/item/storage/pouch/construction/icc/full


/datum/outfit/job/icc/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/barcardine, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)

