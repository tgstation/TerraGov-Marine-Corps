/datum/job/vsd
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_VSD
	minimap_icon = "pmc2"

//VSD Standard
/datum/job/vsd/standard
	title = "VSD Standard"
	paygrade = "VSD1"
	outfit = /datum/outfit/job/vsd/standard/grunt_one
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/standard/grunt_one,
		/datum/outfit/job/vsd/standard/ksg,
		/datum/outfit/job/vsd/standard/grunt_second,
		/datum/outfit/job/vsd/standard/grunt_third,
	)

//outfits
/datum/outfit/job/vsd/standard
	name = "VSD Standard"
	jobtype = /datum/job/vsd/standard

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

/datum/outfit/job/vsd/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BELT)

/datum/outfit/job/vsd/standard/grunt_one
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/desert
	head = /obj/item/clothing/head/helmet/marine/vsd/secondary
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	mask = /obj/item/clothing/mask/gas/vsd

/datum/outfit/job/vsd/standard/grunt_one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_SUIT)

/datum/outfit/job/vsd/standard/ksg
	w_uniform = /obj/item/clothing/under/vsd/shirt/webbing
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/desert
	suit_store = /obj/item/weapon/gun/shotgun/pump/ksg/standard
	l_store = /obj/item/storage/pouch/shotgun

/datum/outfit/job/vsd/standard/ksg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)

/datum/outfit/job/vsd/standard/grunt_second
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	head = /obj/item/clothing/head/vsd

/datum/outfit/job/vsd/standard/grunt_second/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)

/datum/outfit/job/vsd/standard/grunt_third
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard

/datum/outfit/job/vsd/standard/grunt_third/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)

//VSD Engineer
/datum/job/vsd/engineer
	title = "VSD Engineer"
	paygrade = "VSD3"
	skills_type = /datum/skills/combat_engineer
	outfit = /datum/outfit/job/vsd/engineer/l26
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/engineer/l26,
		/datum/outfit/job/vsd/engineer/vsd_rifle,
	)

//outfits
/datum/outfit/job/vsd/engineer
	name = "VSD Engineer"
	jobtype = /datum/job/vsd/engineer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor/desert
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/secondary
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd
	belt = /obj/item/storage/belt/utility/full

/datum/outfit/job/vsd/engineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)

/datum/outfit/job/vsd/engineer/l26
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/engineer

/datum/outfit/job/vsd/engineer/l26/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/buildasentry, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_ACCESSORY)

/datum/outfit/job/vsd/engineer/vsd_rifle
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor
	head = /obj/item/clothing/head/vsd

/datum/outfit/job/vsd/engineer/vsd_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_ACCESSORY)

//VSD Medic
/datum/job/vsd/medic
	title = "VSD Medic"
	paygrade = "VSD2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/vsd/medic/ksg
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/medic/ksg,
		/datum/outfit/job/vsd/medic/vsd_rifle,
		/datum/outfit/job/vsd/medic/vsd_pdw,
	)

//outfits
/datum/outfit/job/vsd/medic
	name = "VSD Medic"
	jobtype = /datum/job/vsd/medic

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	belt = /obj/item/storage/belt/lifesaver/full/upp
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/vsd/medic
	shoes = /obj/item/clothing/shoes/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/medic
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd

/datum/outfit/job/vsd/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tweezers_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/spaceacillin, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/combat_advanced, SLOT_IN_ACCESSORY)

/datum/outfit/job/vsd/medic/ksg
	suit_store = /obj/item/weapon/gun/shotgun/pump/ksg/support
	l_store = /obj/item/storage/pouch/shotgun

/datum/outfit/job/vsd/medic/ksg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_SUIT)


/datum/outfit/job/vsd/medic/vsd_rifle
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle

/datum/outfit/job/vsd/medic/vsd_rifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_SUIT)

/datum/outfit/job/vsd/medic/vsd_pdw
	suit_store = /obj/item/weapon/gun/smg/vsd_pdw/medic

/datum/outfit/job/vsd/medic/vsd_pdw/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/vsd_pdw, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/vsd_pdw, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/vsd_pdw, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/vsd_pdw, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/vsd_pdw, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/vsd_pdw, SLOT_IN_SUIT)


//VSD Spec
/datum/job/vsd/spec
	title = "VSD Specialist"
	paygrade = "VSD4"
	skills_type = /datum/skills/crafty
	outfit = /datum/outfit/job/vsd/spec/flamer
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/spec/flamer,
		/datum/outfit/job/vsd/spec/demolitionist,
		/datum/outfit/job/vsd/spec/gunslinger,
		/datum/outfit/job/vsd/spec/uslspec_one,
		/datum/outfit/job/vsd/spec/uslspec_two,
	)

//outfits
/datum/outfit/job/vsd/spec
	name = "VSD Specialist"
	jobtype = /datum/job/vsd/spec

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack/vsd
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

/datum/outfit/job/vsd/spec/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)


/datum/outfit/job/vsd/spec/flamer
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor
	head = /obj/item/clothing/head/helmet/marine/vsd/pyro
	belt = /obj/item/belt_harness/marine
	suit_store = /obj/item/weapon/gun/flamer/big_flamer/vsd
	back = /obj/item/ammo_magazine/flamer_tank/backtank/X
	w_uniform = /obj/item/clothing/under/vsd/shirt/webbing
	l_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/vsd/spec/flamer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large, SLOT_IN_SUIT)

/datum/outfit/job/vsd/spec/demolitionist
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor
	head = /obj/item/clothing/head/helmet/marine/vsd
	belt = /obj/item/belt_harness/marine
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/weapon/gun/launcher/rocket/vsd
	l_store = /obj/item/storage/pouch/explosive

/datum/outfit/job/vsd/spec/demolitionist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_L_POUCH)

/datum/outfit/job/vsd/spec/gunslinger
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd
	head = /obj/item/clothing/head/helmet/marine/vsd/secondary
	belt = /obj/item/storage/holster/belt/korovin
	w_uniform = /obj/item/clothing/under/vsd/shirt/webbing

/datum/outfit/job/vsd/spec/gunslinger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/xmdivider/gunslinger(H), SLOT_IN_BELT)

/datum/outfit/job/vsd/spec/uslspec_one
	w_uniform = /obj/item/clothing/under/vsd/upp
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor/upp
	head = /obj/item/clothing/head/helmet/marine/vsd/upp
	mask = /obj/item/clothing/mask/gas/vsd
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer
	l_store = /obj/item/storage/pouch/magazine

/datum/outfit/job/vsd/spec/uslspec_one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BELT)

/datum/outfit/job/vsd/spec/uslspec_two
	w_uniform = /obj/item/clothing/under/vsd/upp
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/marmor/upp
	head = /obj/item/clothing/head/uppcap/beret
	glasses = /obj/item/clothing/glasses/sunglasses/fake
	mask = /obj/item/clothing/mask/gas/vsd
	suit_store = /obj/item/weapon/gun/clf_heavyrifle
	back = /obj/item/shotgunbox/clf_heavyrifle
	l_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/vsd/spec/uslspec_two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BELT)


//VSD Juggernauts
/datum/job/vsd/juggernaut
	title = "VSD Juggernaut"
	paygrade = "VSD4"
	outfit = /datum/outfit/job/vsd/juggernaut
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/juggernaut,
		/datum/outfit/job/vsd/eod,
	)

//juggernaut outfits
/datum/outfit/job/vsd/juggernaut
	name = "VSD Juggernaut"
	jobtype = /datum/job/vsd/juggernaut

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/juggernaut
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/juggernaut
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/juggernaut
	mask = /obj/item/clothing/mask/gas/vsd
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd

/datum/outfit/job/vsd/juggernaut/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)

/datum/outfit/job/vsd/eod
	name = "VSD Juggernaut"
	jobtype = /datum/job/vsd/juggernaut

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/eod
	suit_store = /obj/item/weapon/gun/launcher/rocket/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/vsd/eod
	belt = /obj/item/belt_harness/marine
	mask = /obj/item/clothing/mask/gas/vsd
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/explosive
	back = /obj/item/storage/backpack/lightpack/vsd

/datum/outfit/job/vsd/eod/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/incendiary, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/he, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/incendiary, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/incendiary, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/chemical, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/vsd/chemical, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)


//VSD Squad Leader
/datum/job/vsd/leader
	job_category = JOB_CAT_COMMAND
	title = "VSD Squad Leader"
	paygrade = "VSD5"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/vsd/leader/one
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/leader/one,
		/datum/outfit/job/vsd/leader/two,
		/datum/outfit/job/vsd/leader/upp_three,
	)

//SL outfits
/datum/outfit/job/vsd/leader
	name = "VSD Squad Leader"
	jobtype = /datum/job/vsd/leader

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/vsd
	w_uniform = /obj/item/clothing/under/vsd/webbing
	shoes = /obj/item/clothing/shoes/marine/vsd
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/magazine
	back = /obj/item/storage/backpack/lightpack/vsd

/datum/outfit/job/vsd/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/vsd, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_ACCESSORY)


/datum/outfit/job/vsd/leader/one
	head = /obj/item/clothing/head/vsd/beret
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/desert
	mask = /obj/item/clothing/mask/gas/vsd
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/vsd_rifle/standard
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

/datum/outfit/job/vsd/leader/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_rifle, SLOT_IN_L_POUCH)

/datum/outfit/job/vsd/leader/two
	head = /obj/item/clothing/head/helmet/marine/vsd
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor
	mask = /obj/item/clothing/mask/gas/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/juggernaut
	belt = /obj/item/storage/holster/belt/korovin

/datum/outfit/job/vsd/leader/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/xmdivider, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/xmdivider/gunslinger(H), SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)

/datum/outfit/job/vsd/leader/upp_three
	head = /obj/item/clothing/head/uppcap/beret
	wear_suit = /obj/item/clothing/suit/storage/marine/vsd/harmor/upp
	mask = /obj/item/clothing/mask/gas/vsd
	glasses = /obj/item/clothing/glasses/night/vsd
	suit_store = /obj/item/weapon/gun/rifle/vsd_lmg/juggernaut
	belt = /obj/item/storage/holster/belt/pistol/standard_pistol

/datum/outfit/job/vsd/leader/upp_three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vsd_pistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vsd_pistol/standard(H), SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/vsd_mg, SLOT_IN_L_POUCH)
