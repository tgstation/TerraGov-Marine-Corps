/datum/job/deathsquad
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/sl/deathsquad
	faction = FACTION_DEATHSQUAD

//Deathsquad Standard
/datum/job/deathsquad/standard
	title = "Deathsquad Standard"
	paygrade = "DS"
	skills_type = /datum/skills/deathsquad
	outfit = /datum/outfit/job/deathsquad/standard

/datum/outfit/job/deathsquad/standard
	name = "Deathsquad Standard"
	jobtype = /datum/job/deathsquad/standard
	id = /obj/item/card/id/silver
	belt = /obj/item/weapon/gun/energy/lasgun/pulse
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/commando
	shoes = /obj/item/clothing/shoes/marine/deathsquad
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc/commando
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/commando
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/flamer/big_flamer/marinestandard/deathsquad
	r_store = /obj/item/storage/pouch/medkit
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/commando
	implants = list(/obj/item/implant/suicide_dust)

/datum/outfit/job/deathsquad/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/cohiba, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/hypervene, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/ryetalyn, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/chunk, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/pulse, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/deathsquad, SLOT_IN_BACKPACK)

//Deathsquad Leader
/datum/job/deathsquad/leader
	title = "Deathsquad Leader"
	paygrade = "DSL"
	skills_type = /datum/skills/sl/deathsquad
	outfit = /datum/outfit/job/deathsquad/leader

/datum/outfit/job/deathsquad/leader
	name = "Deathsquad Leader"
	jobtype = /datum/job/deathsquad/leader
	id = /obj/item/card/id/silver
	belt = /obj/item/weapon/gun/energy/lasgun/pulse
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/commando
	shoes = /obj/item/clothing/shoes/marine/deathsquad
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc/commando
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/commando
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/launcher/rocket/m57a4/deathsquad
	r_store = /obj/item/storage/pouch/medkit
	l_store = /obj/item/storage/pouch/explosive
	back = /obj/item/storage/backpack/commando
	implants = list(/obj/item/implant/suicide_dust)

/datum/outfit/job/deathsquad/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/cohiba, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/pinpointer, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/hypervene, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/ryetalyn, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/chunk, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/pulse, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rocket/m57a4/ds, SLOT_IN_BACKPACK)

//Deathsquad Gunner
/datum/job/deathsquad/gunner
	title = "Deathsquad Gunner"
	paygrade = "DS"
	skills_type = /datum/skills/smartgunner/deathsquad
	outfit = /datum/outfit/job/deathsquad/gunner

/datum/outfit/job/deathsquad/gunner
	name = "Deathsquad Gunner"
	jobtype = /datum/job/deathsquad/gunner
	id = /obj/item/card/id/silver
	belt = /obj/item/weapon/gun/energy/lasgun/pulse
	ears = /obj/item/radio/headset/distress/commando
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/commando
	shoes = /obj/item/clothing/shoes/marine/deathsquad
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc/commando
	mask = /obj/item/clothing/mask/gas/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/commando
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/deathsquad
	r_store = /obj/item/storage/pouch/medkit
	l_store = /obj/item/storage/pouch/magazine/drum
	back = /obj/item/storage/backpack/commando
	implants = list(/obj/item/implant/suicide_dust)

/datum/outfit/job/deathsquad/gunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/pmc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/drain, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/cohiba, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/hypervene, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/ryetalyn, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/elite, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/wrapped/chunk, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/energy/sword/deathsquad, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/shield/energy, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/pulse, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)

