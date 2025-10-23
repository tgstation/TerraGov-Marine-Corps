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
	outfit = /datum/outfit/job/pmc/standard/val
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/pmc/standard/val,
		/datum/outfit/job/pmc/standard/val/sarge,
		/datum/outfit/job/pmc/standard/val/sargetwo,
		/datum/outfit/job/pmc/standard/val/sargethree,
		/datum/outfit/job/pmc/standard/val/sargefour,
		/datum/outfit/job/pmc/standard/val/joker,
		/datum/outfit/job/pmc/standard/val/jokertwo,
		/datum/outfit/job/pmc/standard/val/stripes,
		/datum/outfit/job/pmc/standard/val/stripestwo,
		/datum/outfit/job/pmc/standard/val/stripesthree,
		/datum/outfit/job/pmc/standard/m416,
		/datum/outfit/job/pmc/standard/m416/sarge,
		/datum/outfit/job/pmc/standard/m416/sargetwo,
		/datum/outfit/job/pmc/standard/m416/sargethree,
		/datum/outfit/job/pmc/standard/m416/sargefour,
		/datum/outfit/job/pmc/standard/m416/joker,
		/datum/outfit/job/pmc/standard/m416/jokertwo,
		/datum/outfit/job/pmc/standard/m416/stripes,
		/datum/outfit/job/pmc/standard/m416/stripestwo,
		/datum/outfit/job/pmc/standard/m416/stripesthree,
	)

/datum/outfit/job/pmc/standard
	name = "PMC Standard"
	jobtype = /datum/job/pmc/standard

	id = /obj/item/card/id/silver/standard
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc
	mask = /obj/item/clothing/mask/gas/pmc/leader
	suit_store = /obj/item/weapon/gun/smg/m25/elite/pmc
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
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

//PMC medic
/datum/job/pmc/medic
	title = "PMC Medic"
	paygrade = "PMC2"
	skills_type = /datum/skills/combat_medic/pmc
	outfit = /datum/outfit/job/pmc/medic

//medic loadout
/datum/outfit/job/pmc/medic
	name = "PMC Medic"
	jobtype = /datum/job/pmc/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/quick
	ears = /obj/item/radio/headset/mainship/marine/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc
	gloves = /obj/item/clothing/gloves/defibrillator
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/m25/elite/pmc
	r_pocket = /obj/item/storage/pouch/medical_injectors/medic
	l_pocket =/obj/item/storage/pouch/pressurized_reagent_pouch/bktt
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/pmc/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tweezers_advanced, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(H), SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)



//PMC Gunner
/datum/job/pmc/gunner
	title = "PMC Gunner"
	paygrade = "PMC2"
	skills_type = /datum/skills/smartgunner/pmc
	outfit = /datum/outfit/job/pmc/gunner
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/pmc/gunner,
		/datum/outfit/job/pmc/gunner/sarge,
		/datum/outfit/job/pmc/gunner/sargetwo,
		/datum/outfit/job/pmc/gunner/sargethree,
		/datum/outfit/job/pmc/gunner/sargefour,
		/datum/outfit/job/pmc/gunner/joker,
		/datum/outfit/job/pmc/gunner/jokertwo,
		/datum/outfit/job/pmc/gunner/jokerthree,
		/datum/outfit/job/pmc/gunner/jokerfour,
		/datum/outfit/job/pmc/gunner/stripes,
		/datum/outfit/job/pmc/gunner/stripestwo,
		/datum/outfit/job/pmc/gunner/stripesthree,
		/datum/outfit/job/pmc/gunner/stripes/four,
	)
//PMC Sniper
/datum/job/pmc/sniper
	title = "PMC Sniper"
	paygrade = "PMC3"
	skills_type = /datum/skills/specialist/pmc
	outfit = /datum/outfit/job/pmc/sniper

//PMC Leader
/datum/job/pmc/leader
	job_category = JOB_CAT_COMMAND
	title = "PMC Leader"
	paygrade = "PMC4"
	skills_type = /datum/skills/sl/pmc
	outfit = /datum/outfit/job/pmc/leader/m416
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/pmc/leader/m416,
		/datum/outfit/job/pmc/leader/gunner,
	)
