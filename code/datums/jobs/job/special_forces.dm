/datum/job/special_forces
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/special_forces_standard


//Special forces Standard
/datum/job/special_forces/standard
	title = "Special Response Force Standard"
	outfit = /datum/outfit/job/special_forces/standard


/datum/outfit/job/special_forces/standard
	name = "Special Response Force Standard"
	jobtype = /datum/job/special_forces/standard

	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/balaclava
	w_uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	wear_suit = /obj/item/clothing/suit/armor/bulletproof
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/smg/m25/elite/suppressed
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/special_forces/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/ap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/g22, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/armor_module/storage/uniform/black_vest, SLOT_L_HAND)


//Special Force breacher
/datum/job/special_forces/breacher
	title = "Special Response Force Breacher"
	outfit = /datum/outfit/job/special_forces/breacher

/datum/outfit/job/special_forces/breacher
	name = "Special Response Force Breacher"
	jobtype = /datum/job/special_forces/breacher

	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/pistol/standard_pistol
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/balaclava
	w_uniform = /obj/item/clothing/under/syndicate/tacticool
	shoes = /obj/item/clothing/shoes/combat
	wear_suit = /obj/item/clothing/suit/armor/bulletproof
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/marine/tech
	suit_store = /obj/item/weapon/gun/pistol/standard_heavypistol/suppressed
	r_store = /obj/item/storage/pouch/firstaid/injectors/full
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/special_forces/breacher/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/mgoggles, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/metal, SLOT_R_HAND)


//Special forces Leader
/datum/job/special_forces/leader
	title = "Special Response Force Leader"
	skills_type = /datum/skills/sl/pmc/special_forces
	outfit = /datum/outfit/job/special_forces/leader


/datum/outfit/job/special_forces/leader
	name = "Special Response Force Leader"
	jobtype = /datum/job/special_forces/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/balaclava
	w_uniform = /obj/item/clothing/under/syndicate/tacticool
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/combat
	wear_suit = /obj/item/clothing/suit/armor/bulletproof
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/beret/sec
	suit_store = /obj/item/weapon/gun/rifle/famas/freelancermedic
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/pistol
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/special_forces/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/standard_revolver, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/standard_revolver, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/screwdriver, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/wirecutters, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/multitool, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/standard_revolver, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/armor_module/storage/uniform/black_vest, SLOT_L_HAND)
