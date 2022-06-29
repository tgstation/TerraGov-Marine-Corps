/datum/job/deathsquad
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/sl/pmc
	faction = FACTION_DEATHSQUAD


//Deathsquad Standard
/datum/job/deathsquad/standard
	title = "Deathsquad Standard"
	paygrade = "DS"
	outfit = /datum/outfit/job/deathsquad/standard


/datum/outfit/job/deathsquad/standard
	name = "Deathsquad Standard (Kinetic)"
	jobtype = /datum/job/deathsquad/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/mateba/notmarine
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/commando
	shoes = /obj/item/clothing/shoes/veteran/PMC/commando
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC/commando
	mask = /obj/item/clothing/mask/gas/PMC
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	glasses = /obj/item/clothing/glasses/night/tx8
	suit_store = /obj/item/weapon/gun/rifle/m412/elite
	r_store = /obj/item/storage/pouch/magazine/large/pmc_rifle
	l_store = /obj/item/storage/pouch/medkit
	back = /obj/item/storage/backpack/commando


/datum/outfit/job/deathsquad/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/chunk, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/blue, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)

//Deathsquad Energy
/datum/job/deathsquad/standard/energy
	outfit = /datum/outfit/job/deathsquad/standard/energy


/datum/outfit/job/deathsquad/standard/energy
	name = "Deathsquad Standard (Energy)"
	jobtype = /datum/job/deathsquad/standard/energy

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/mateba/notmarine
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/commando
	shoes = /obj/item/clothing/shoes/veteran/PMC/commando
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC/commando
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	mask = /obj/item/clothing/mask/gas/PMC
	glasses = /obj/item/clothing/glasses/night/tx8
	suit_store = /obj/item/weapon/gun/energy/lasgun/pulse
	r_store = /obj/item/storage/pouch/explosive
	l_store = /obj/item/storage/pouch/medkit
	back = /obj/item/storage/backpack/commando


/datum/outfit/job/deathsquad/standard/energy/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/blue, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)

//Deathsquad Leader
/datum/job/deathsquad/leader
	title = "Deathsquad Leader"
	paygrade = "DSL"
	outfit = /datum/outfit/job/deathsquad/leader


/datum/outfit/job/deathsquad/leader
	name = "Deathsquad Leader"
	jobtype = /datum/job/deathsquad/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/mateba/notmarine
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/commando
	shoes = /obj/item/clothing/shoes/veteran/PMC/commando
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC/commando
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	mask = /obj/item/clothing/mask/gas/PMC
	glasses = /obj/item/clothing/glasses/night/tx8
	suit_store = /obj/item/weapon/gun/launcher/rocket/m57a4
	r_store = /obj/item/storage/pouch/explosive
	l_store = /obj/item/storage/pouch/medkit
	back = /obj/item/storage/backpack/commando


/datum/outfit/job/deathsquad/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/chunk, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/blue, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)

//Deathsquad Gunner
/datum/job/deathsquad/gunner
	title = "Deathsquad Gunner"
	paygrade = "DS"
	skills_type = /datum/skills/smartgunner/pmc
	outfit = /datum/outfit/job/deathsquad/gunner

/datum/outfit/job/deathsquad/gunner
	name = "Deathsquad Gunner"
	jobtype = /datum/job/deathsquad/gunner
	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/mateba/notmarine
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/commando
	shoes = /obj/item/clothing/shoes/veteran/PMC/commando
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC/commando
	mask = /obj/item/clothing/mask/gas/PMC
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun
	r_store = /obj/item/storage/pouch/magazine/drum
	l_store = /obj/item/storage/pouch/medkit
	back = /obj/item/storage/backpack/commando


/datum/outfit/job/deathsquad/gunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/chunk, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/blue, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)
