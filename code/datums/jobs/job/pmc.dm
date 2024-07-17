/datum/job/pmc
	job_category = JOB_CAT_MARINE
	access = ALL_PMC_ACCESS
	minimal_access = ALL_PMC_ACCESS
	skills_type = /datum/skills/pmc
	faction = FACTION_NANOTRASEN
	minimap_icon = "pmc"


//PMC Standard
/datum/job/pmc/standard
	title = "PMC Standard"
	paygrade = "PMC1"
	outfit = /datum/outfit/job/pmc/standard


/datum/outfit/job/pmc/standard
	name = "PMC Standard"
	jobtype = /datum/job/pmc/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/veteran/pmc
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc
	mask = /obj/item/clothing/mask/gas/pmc/leader
	suit_store = /obj/item/weapon/gun/smg/m25/elite/pmc
	r_store = /obj/item/storage/pouch/grenade
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel


/datum/outfit/job/pmc/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(H), SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)


//PMC Gunner
/datum/job/pmc/gunner
	title = "PMC Gunner"
	paygrade = "PMC2"
	skills_type = /datum/skills/smartgunner/pmc
	outfit = /datum/outfit/job/pmc/gunner


/datum/outfit/job/pmc/gunner
	name = "PMC Gunner"
	jobtype = /datum/job/pmc/gunner

	id = /obj/item/card/id/silver
	belt = /obj/item/belt_harness/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/veteran/pmc
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc
	r_store = /obj/item/storage/pouch/explosive
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/pmc/gunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(H), SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/mine/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/mine/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_R_POUCH)


//PMC Sniper
/datum/job/pmc/sniper
	title = "PMC Sniper"
	paygrade = "PMC3"
	skills_type = /datum/skills/specialist/pmc
	outfit = /datum/outfit/job/pmc/sniper


/datum/outfit/job/pmc/sniper
	name = "PMC Sniper"
	jobtype = /datum/job/pmc/sniper

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp70_pmc
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/webbing
	shoes = /obj/item/clothing/shoes/veteran/pmc
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/sniper
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/sniper
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/sniper/elite
	r_store = /obj/item/storage/pouch/magazine/large/pmc_sniper
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel


/datum/outfit/job/pmc/sniper/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/sniper/elite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread, SLOT_IN_BACKPACK)


//PMC Leader
/datum/job/pmc/leader
	job_category = JOB_CAT_COMMAND
	title = "PMC Leader"
	paygrade = "PMC4"
	skills_type = /datum/skills/sl/pmc
	outfit = /datum/outfit/job/pmc/leader


/datum/outfit/job/pmc/leader
	name = "PMC Leader"
	jobtype = /datum/job/pmc/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/leader/holster
	shoes = /obj/item/clothing/shoes/veteran/pmc
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/leader
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/leader
	mask = /obj/item/clothing/mask/gas/pmc/leader
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/m412/elite
	r_store = /obj/item/storage/pouch/grenade
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel


/datum/outfit/job/pmc/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp78, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp78/pmc(H), SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
