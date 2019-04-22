/datum/job/deathsquad
	department_flag = J_FLAG_PMC
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/SL/pmc
	faction = "Deathsquad"


//Deathsquad Standard
/datum/job/deathsquad/standard
	title = "Deathsquad Standard"
	paygrade = "DS"
	flag = PMC_DS_STANDARD
	outfit = /datum/outfit/job/deathsquad/standard


/datum/outfit/job/deathsquad/standard
	name = "Deathsquad Standard"
	jobtype = /datum/job/deathsquad/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/mateba/admiral
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/commando
	shoes = /obj/item/clothing/shoes/veteran/PMC/commando
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC/commando
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	mask = /obj/item/clothing/mask/gas/PMC
	glasses = /obj/item/clothing/glasses/m42_goggles
	suit_store = /obj/item/weapon/gun/rifle/m41a/elite
	r_store = /obj/item/storage/pouch/magazine/large/pmc_rifle
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/commando


/datum/outfit/job/deathsquad/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)


//Deathsquad Leader
/datum/job/deathsquad/leader
	title = "Deathsquad Leader"
	paygrade = "DSL"
	flag = PMC_DS_LEADER
	outfit = /datum/outfit/job/deathsquad/leader


/datum/outfit/job/deathsquad/leader
	name = "Deathsquad Leader"
	jobtype = /datum/job/deathsquad/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/mateba/admiral
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/commando
	shoes = /obj/item/clothing/shoes/veteran/PMC/commando
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC/commando
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/commando
	mask = /obj/item/clothing/mask/gas/PMC
	glasses = /obj/item/clothing/glasses/m42_goggles
	suit_store = /obj/item/weapon/gun/launcher/rocket/m57a4
	r_store = /obj/item/storage/pouch/explosive
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/commando


/datum/outfit/job/deathsquad/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)