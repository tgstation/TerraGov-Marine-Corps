/datum/job/pmc
	department_flag = J_FLAG_PMC
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	skills_type = /datum/skills/pfc/pmc
	faction = "Nanotrasen"


//PMC Standard
/datum/job/pmc/standard
	title = "PMC Standard"
	paygrade = "PMC1"
	flag = PMC_STANDARD
	outfit = /datum/outfit/job/pmc/standard


/datum/outfit/job/pmc/standard
	name = "PMC Standard"
	jobtype = /datum/job/pmc/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/radio/headset/distress/PMC
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC
	mask = /obj/item/clothing/mask/gas/PMC/leader
	suit_store = /obj/item/weapon/gun/smg/m39/elite
	r_store = /obj/item/storage/pouch/magazine/large/pmc_m39
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/satchel


/datum/outfit/job/pmc/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)


	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/baton, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/handcuffs, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)


//PMC Gunner
/datum/job/pmc/gunner
	title = "PMC Gunner"
	paygrade = "PMC2"
	skills_type = /datum/skills/smartgunner/pmc
	flag = PMC_GUNNER
	outfit = /datum/outfit/job/pmc/gunner


/datum/outfit/job/pmc/gunner
	name = "PMC Gunner"
	jobtype = /datum/job/pmc/gunner

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/radio/headset/distress/PMC
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/gunner
	mask = /obj/item/clothing/mask/gas/PMC
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	suit_store = /obj/item/weapon/gun/smartgun
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/smartgun_powerpack/snow


/datum/outfit/job/pmc/gunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/handcuffs, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/mine/pmc, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)


//PMC Sniper
/datum/job/pmc/sniper
	title = "PMC Sniper"
	paygrade = "PMC3"
	skills_type = /datum/skills/specialist/pmc
	flag = PMC_SNIPER
	outfit = /datum/outfit/job/pmc/sniper


/datum/outfit/job/pmc/sniper
	name = "PMC Sniper"
	jobtype = /datum/job/pmc/sniper

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/radio/headset/distress/PMC
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/sniper
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/sniper
	mask = /obj/item/clothing/mask/gas/PMC
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/sniper/elite
	r_store = /obj/item/storage/pouch/magazine/large/pmc_sniper
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/satchel


/datum/outfit/job/pmc/sniper/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/baton, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/handcuffs, SLOT_IN_BACKPACK)


//PMC Leader
/datum/job/pmc/leader
	title = "PMC Leader"
	paygrade = "PMC4"
	skills_type = /datum/skills/SL/pmc
	flag = PMC_LEADER
	outfit = /datum/outfit/job/pmc/leader


/datum/outfit/job/pmc/leader
	name = "PMC Leader"
	jobtype = /datum/job/pmc/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp78
	ears = /obj/item/radio/headset/distress/PMC
	w_uniform = /obj/item/clothing/under/marine/veteran/PMC/leader
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/PMC/leader
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/marine/veteran/PMC/leader
	mask = /obj/item/clothing/mask/gas/PMC/leader
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/m41a/elite
	r_store = /obj/item/storage/pouch/magazine/large/pmc_rifle
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/satchel


/datum/outfit/job/pmc/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/PMC, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/baton, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/handcuffs, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
