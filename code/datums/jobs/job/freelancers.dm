/datum/job/freelancer
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_FREELANCERS
	minimap_icon = "freelancer"
	outfit = /datum/outfit/job/freelancer

//What all freelancers have shared in between them
/datum/outfit/job/freelancer
	name = "Freelancer"
	jobtype = /datum/job/freelancer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/rebreather/scarf/freelancer
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer
	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/frelancer
	back = /obj/item/storage/backpack/lightpack
	l_store = /obj/item/storage/pouch/medkit/firstaid

/datum/outfit/job/freelancer/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife, SLOT_IN_BOOT)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/burger/tofu, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/flask/marine, SLOT_IN_BACKPACK)

//Freelancer Standard
/datum/job/freelancer/standard
	title = "Freelancer Standard"
	paygrade = "FRE1"
	outfit = /datum/outfit/job/freelancer/standard
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/standard/one,
		/datum/outfit/job/freelancer/standard/two,
		/datum/outfit/job/freelancer/standard/three,
	)

/datum/outfit/job/freelancer/standard
	name = "Freelancer Standard"
	jobtype = /datum/job/freelancer/standard

/datum/outfit/job/freelancer/standard/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/freelancer/standard/one
	suit_store = /obj/item/weapon/gun/rifle/m16/freelancer
	r_store = /obj/item/storage/pouch/shotgun

/datum/outfit/job/freelancer/standard/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)

///m16 ugl
/datum/outfit/job/freelancer/standard/two
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl
	r_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/freelancer/standard/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///tx11
/datum/outfit/job/freelancer/standard/three
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	r_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/freelancer/standard/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

//Freelancer Medic
/datum/job/freelancer/medic
	title = "Freelancer Medic"
	paygrade = "FRE2"
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/freelancer/medic

/datum/outfit/job/freelancer/medic
	name = "Freelancer Medic"
	jobtype = /datum/job/freelancer/medic

	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/medic
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/famas/freelancermedic
	r_store = /obj/item/storage/pouch/medical_injectors/medic
	l_store = /obj/item/storage/pouch/magazine/large

/datum/outfit/job/freelancer/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/g22, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/famas, SLOT_IN_L_POUCH)

//Freelancer Veteran. Generic term for 'better equipped dude'
/datum/job/freelancer/grenadier
	title = "Freelancer Veteran"
	paygrade = "FRE3"
	outfit = /datum/outfit/job/freelancer/grenadier
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/grenadier/one,
		/datum/outfit/job/freelancer/grenadier/two,
		/datum/outfit/job/freelancer/grenadier/three,
	)

/datum/outfit/job/freelancer/grenadier
	name = "Freelancer Veteran"
	jobtype = /datum/job/freelancer/grenadier

/datum/outfit/job/freelancer/grenadier/one
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/veteran
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/freelancer
	r_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/freelancer/grenadier/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///machine gunner
/datum/outfit/job/freelancer/grenadier/two
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/m412l1_hpr/freelancer

/datum/outfit/job/freelancer/grenadier/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///actual grenadier
/datum/outfit/job/freelancer/grenadier/three
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer
	r_store = /obj/item/storage/pouch/magazine/large

/datum/outfit/job/freelancer/grenadier/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)

//Freelancer Leader
/datum/job/freelancer/leader
	title = "Freelancer Leader"
	paygrade = "FRE4"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/freelancer/leader
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/leader/one,
		/datum/outfit/job/freelancer/leader/two,
		/datum/outfit/job/freelancer/leader/three,
	)

/datum/outfit/job/freelancer/leader
	name = "Freelancer Leader"
	jobtype = /datum/job/freelancer/leader

/datum/outfit/job/freelancer/leader
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/veteran
	head = /obj/item/clothing/head/frelancer/beret
	glasses = /obj/item/clothing/glasses/hud/health

/datum/outfit/job/freelancer/leader/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)

/datum/outfit/job/freelancer/leader/one
	belt = /obj/item/storage/belt/grenade/b17
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/leader
	suit_store = /obj/item/weapon/gun/rifle/m16/freelancer
	r_store = /obj/item/storage/pouch/shotgun

/datum/outfit/job/freelancer/leader/one/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m16, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_R_POUCH)

///tx11
/datum/outfit/job/freelancer/leader/two
	belt = /obj/item/belt_harness/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/leader/two
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancertwo
	r_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/freelancer/leader/two/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_R_POUCH)

///tx55
/datum/outfit/job/freelancer/leader/three
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/leader/three
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer
	r_store = /obj/item/storage/pouch/magazine/large

/datum/outfit/job/freelancer/leader/three/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_R_POUCH)
