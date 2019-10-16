/datum/job/freelancer
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/pfc/crafty
	faction = "Freelancers"


//Freelancer Standard
/datum/job/freelancer/standard
	title = "Freelancer Standard"
	paygrade = "FRE1"
	outfit = /datum/outfit/job/freelancer/standard


/datum/outfit/job/freelancer/standard
	name = "Freelancer Standard"
	jobtype = /datum/job/freelancer/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/frelancer
	suit_store = /obj/item/weapon/gun/rifle/m16
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/freelancer/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/verticalgrip, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/extended_barrel, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/b92fs, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/b92fs, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/b92fs, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/b92fs/raffica, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife, SLOT_IN_BOOT)


//Freelancer Medic
/datum/job/freelancer/medic
	title = "Freelancer Medic"
	paygrade = "FRE2"
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/freelancer/medic


/datum/outfit/job/freelancer/medic
	name = "Freelancer Medic"
	jobtype = /datum/job/freelancer/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/combatLifesaver/upp
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/frelancer
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/p90
	r_store = /obj/item/storage/pouch/medkit
	l_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/freelancer/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/suppressor, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/lasersight, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/p90, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/p90, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/p90, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/p90, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/advanced, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/glass/bottle/tricordrazine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/glass/bottle/bicaridine, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife, SLOT_IN_BOOT)


//Freelancer Leader
/datum/job/freelancer/leader
	title = "Freelancer Leader"
	paygrade = "FRE3"
	skills_type = /datum/skills/SL
	outfit = /datum/outfit/job/freelancer/leader


/datum/outfit/job/freelancer/leader
	name = "Freelancer Leader"
	jobtype = /datum/job/freelancer/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/frelancer/beret
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/m16
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/freelancer/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/stick, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/scope, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/bipod, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/extended_barrel, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/advanced/oxycodone, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/advanced/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/glass/bottle/tricordrazine, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife, SLOT_IN_BOOT)
