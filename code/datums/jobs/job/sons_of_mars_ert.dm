//ERT roles
/datum/job/som/ert
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty

/datum/outfit/job/som/ert
	id = /obj/item/card/id/dogtag/som

//SOM Standard
/datum/job/som/ert/standard
	title = "SOM Standard"
	paygrade = "SOM_E3"
	outfit = /datum/outfit/job/som/ert/standard/standard_assaultrifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/standard/standard_assaultrifle,
		/datum/outfit/job/som/ert/standard/standard_smg,
		/datum/outfit/job/som/ert/standard/standard_shotgun,
		/datum/outfit/job/som/ert/standard/charger,
	)

//Base SOM standard outfit
/datum/outfit/job/som/ert/standard
	name = "SOM Marine"
	jobtype = /datum/job/som/ert/standard

	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	r_store = /obj/item/storage/pouch/firstaid/som/full
	l_store = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/ert/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/outfit/job/som/ert/standard/standard_assaultrifle
	suit_store = /obj/item/weapon/gun/rifle/som/mag_harness
	belt = /obj/item/storage/belt/marine/som/som_rifle

/datum/outfit/job/som/ert/standard/standard_assaultrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/standard/standard_smg
	suit_store = /obj/item/weapon/gun/smg/som/support
	belt = /obj/item/storage/belt/marine/som/som_smg

/datum/outfit/job/som/ert/standard/standard_smg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/standard/standard_shotgun
	back = /obj/item/storage/backpack/satchel/som
	belt = /obj/item/storage/belt/shotgun/som/mixed
	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/shotgun/som/standard

/datum/outfit/job/som/ert/standard/standard_shotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/standard/charger
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness
	belt = /obj/item/storage/belt/marine/som/volkite

/datum/outfit/job/som/ert/standard/charger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

//SOM Medic
/datum/job/som/ert/medic
	title = "SOM Medic"
	paygrade = "SOM_E4"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/som/ert/medic/standard_assaultrifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/medic/standard_assaultrifle,
		/datum/outfit/job/som/ert/medic/standard_smg,
		/datum/outfit/job/som/ert/medic/standard_shotgun,
	)

//Base SOM medic outfit
/datum/outfit/job/som/ert/medic
	name = "SOM Medic"
	jobtype = /datum/job/som/ert/medic

	belt = /obj/item/storage/belt/lifesaver/som/quick
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/medic/vest
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	glasses = /obj/item/clothing/glasses/hud/health
	r_store = /obj/item/storage/pouch/magazine/large/som
	l_store = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/ert/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tweezers_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/combat_advanced, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/medic/standard_assaultrifle
	suit_store = /obj/item/weapon/gun/rifle/som/mag_harness

/datum/outfit/job/som/ert/medic/standard_assaultrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_R_POUCH)

/datum/outfit/job/som/ert/medic/standard_smg
	suit_store = /obj/item/weapon/gun/smg/som/support

/datum/outfit/job/som/ert/medic/standard_smg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_R_POUCH)

/datum/outfit/job/som/ert/medic/standard_shotgun
	r_store = /obj/item/storage/pouch/shotgun/som
	suit_store = /obj/item/weapon/gun/shotgun/som/support

/datum/outfit/job/som/ert/medic/standard_shotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_R_POUCH)

//SOM Veteran
/datum/job/som/ert/veteran
	title = "SOM Veteran"
	paygrade = "SOM_S1"
	outfit = /datum/outfit/job/som/ert/veteran/charger
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/veteran/charger,
		/datum/outfit/job/som/ert/veteran/breacher_vet,
		/datum/outfit/job/som/ert/veteran/caliver,
		/datum/outfit/job/som/ert/veteran/caliver_pack,
		/datum/outfit/job/som/ert/veteran/culverin,
	)

//Base SOM veteran outfit
/datum/outfit/job/som/ert/veteran
	name = "SOM Veteran"
	jobtype = /datum/job/som/ert/veteran

	belt = /obj/item/storage/belt/marine/som/volkite
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran
	glasses = /obj/item/clothing/glasses/meson
	r_store = /obj/item/storage/pouch/firstaid/som/full
	l_store = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/ert/veteran/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

/datum/outfit/job/som/ert/veteran/charger
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet

/datum/outfit/job/som/ert/veteran/charger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/veteran/breacher_vet
	head = /obj/item/clothing/head/modular/som/lorica
	glasses = /obj/item/clothing/glasses/welding
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	l_hand = /obj/item/weapon/shield/riot/marine/som

/datum/outfit/job/som/ert/veteran/breacher_vet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/veteran/caliver
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet

/datum/outfit/job/som/ert/veteran/caliver/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/veteran/caliver_pack
	belt = /obj/item/storage/belt/grenade/som
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet
	l_store = /obj/item/storage/pouch/pistol/som
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/job/som/ert/veteran/caliver_pack/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_L_POUCH)

/datum/outfit/job/som/ert/veteran/culverin
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/job/som/ert/veteran/culverin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/veteran/rpg
	head = /obj/item/clothing/head/modular/som/bio
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/mithridatius
	suit_store = /obj/item/weapon/gun/smg/som/support
	belt = /obj/item/storage/belt/marine/som
	back = /obj/item/storage/holster/backholster/rpg/som/ert
	l_store = /obj/item/storage/pouch/grenade/som

/datum/outfit/job/som/ert/veteran/rpg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/veteran/pyro
	head = /obj/item/clothing/head/modular/som/hades
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/pyro
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som
	back = /obj/item/ammo_magazine/flamer_tank/backtank
	suit_store = /obj/item/weapon/gun/flamer/som/mag_harness

/datum/outfit/job/som/ert/veteran/pyro/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/burst(H), SLOT_IN_HOLSTER)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_SUIT)

/datum/outfit/job/som/ert/veteran/shotgunner
	belt = /obj/item/storage/belt/shotgun/som/flechette
	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/shotgun/som/burst/ert

/datum/outfit/job/som/ert/veteran/shotgunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

//SOM Specialist - special weapon vets
/datum/job/som/ert/specialist
	title = "SOM Specialist"
	paygrade = "SOM_S2"
	outfit = /datum/outfit/job/som/ert/veteran/culverin
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/veteran/culverin,
		/datum/outfit/job/som/ert/veteran/rpg,
		/datum/outfit/job/som/ert/veteran/pyro,
		/datum/outfit/job/som/ert/veteran/shotgunner,
	)

//SOM Leader
/datum/job/som/ert/leader
	job_category = JOB_CAT_COMMAND
	title = "SOM Leader"
	paygrade = "SOM_S4"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/som/ert/leader/charger
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/leader/standard_assaultrifle,
		/datum/outfit/job/som/ert/leader/charger,
		/datum/outfit/job/som/ert/leader/caliver,
		/datum/outfit/job/som/ert/leader/caliver_pack,
	)

//Base SOM leader outfit
/datum/outfit/job/som/ert/leader
	name = "SOM Leader"
	jobtype = /datum/job/som/ert/leader

	belt = /obj/item/storage/belt/marine/som/volkite
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/leader/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/leader/valk
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/leader
	glasses = /obj/item/clothing/glasses/hud/health
	r_store = /obj/item/storage/pouch/firstaid/som/combat_patrol_leader
	l_store = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/ert/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/outfit/job/som/ert/leader/standard_assaultrifle
	suit_store = /obj/item/weapon/gun/rifle/som/veteran
	belt = /obj/item/storage/belt/marine/som/som_rifle_ap

/datum/outfit/job/som/ert/leader/standard_assaultrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/leader/charger
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet

/datum/outfit/job/som/ert/leader/charger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/som, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/leader/caliver
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet

/datum/outfit/job/som/ert/leader/caliver/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/leader/caliver_pack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	belt = /obj/item/belt_harness
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/job/som/ert/leader/caliver_pack/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)


//Breacher ERT

//SOM breacher
/datum/job/som/ert/breacher
	title = "SOM Breacher"
	paygrade = "SOM_S2"
	outfit = /datum/outfit/job/som/ert/veteran/breacher_melee
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/veteran/breacher_melee,
		/datum/outfit/job/som/ert/veteran/breacher_vet,
	)

/datum/outfit/job/som/ert/veteran/breacher_melee
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som

/datum/outfit/job/som/ert/veteran/breacher_melee/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/burst(H), SLOT_IN_HOLSTER)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

/datum/job/som/ert/breacher/specialist
	title = "SOM Breacher Specialist"
	paygrade = "SOM_S3"
	outfit = /datum/outfit/job/som/ert/veteran/breacher_rpg
	outfits = list(
		/datum/outfit/job/som/ert/veteran/breacher_rpg,
		/datum/outfit/job/som/ert/veteran/breacher_flamer,
		/datum/outfit/job/som/ert/veteran/breacher_culverin,
	)

/datum/outfit/job/som/ert/veteran/breacher_rpg
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/belt/grenade/som
	back = /obj/item/storage/holster/backholster/rpg/som/ert
	l_store = /obj/item/storage/pouch/explosive/som

/datum/outfit/job/som/ert/veteran/breacher_rpg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/thermobaric, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/thermobaric, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/heat, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/som/rad, SLOT_IN_L_POUCH)

/datum/outfit/job/som/ert/veteran/breacher_flamer
	head = /obj/item/clothing/head/modular/som/hades
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/pyro
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/belt/sparepouch/som
	back = /obj/item/weapon/gun/flamer/som/mag_harness

/datum/outfit/job/som/ert/veteran/breacher_flamer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/som, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/som, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/veteran/breacher_culverin
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/job/som/ert/veteran/breacher_culverin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/som, SLOT_IN_ACCESSORY)

//breacher medic
/datum/job/som/ert/medic/breacher
	title = "SOM Breacher Medic"
	paygrade = "SOM_E5"
	outfit = /datum/outfit/job/som/ert/medic/breacher
	multiple_outfits = FALSE

/datum/outfit/job/som/ert/medic/breacher
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	l_hand = /obj/item/weapon/shield/riot/marine/som

/datum/outfit/job/som/ert/medic/breacher/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_R_POUCH)

//SOM Leader
/datum/job/som/ert/leader/breacher
	title = "SOM Breacher Leader"
	paygrade = "SOM_O1"
	outfit = /datum/outfit/job/som/ert/leader/breacher_melee
	outfits = list(
		/datum/outfit/job/som/ert/leader/breacher_melee,
		/datum/outfit/job/som/ert/leader/breacher_ranged,
	)

/datum/outfit/job/som/ert/leader/breacher_melee
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som

/datum/outfit/job/som/ert/leader/breacher_melee/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_HOLSTER)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/burst(H), SLOT_IN_HOLSTER)

	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_ACCESSORY)

/datum/outfit/job/som/ert/leader/breacher_ranged
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	l_hand = /obj/item/weapon/shield/riot/marine/som

/datum/outfit/job/som/ert/leader/breacher_ranged/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new/obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_ACCESSORY)
