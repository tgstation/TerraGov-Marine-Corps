/datum/job/som
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/commando
	faction = FACTION_SOM


/datum/outfit/job/som/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.undershirt = 3
	H.underwear = 1
	H.regenerate_icons()


//SOM Standard
/datum/job/som/standard
	title = "SFOC-E Operator"
	paygrade = "SOM1"
	outfit = /datum/outfit/job/som/standard

/datum/job/som/standard/hvh
	outfit = /datum/outfit/job/som/standard/hvh


/datum/outfit/job/som/standard
	name = "SFOC-E Operator"
	jobtype = /datum/job/som/standard

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som
	shoes = /obj/item/clothing/shoes/marine/som
	wear_suit = /obj/item/clothing/suit/storage/marine/som
	gloves = /obj/item/clothing/gloves/marine/som
	head = /obj/item/clothing/head/helmet/marine/som
	suit_store = /obj/item/weapon/gun/rifle/tx11/sfoc
	r_store = /obj/item/storage/pouch/firstaid/som/full
	l_store = /obj/item/storage/pouch/pistol
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/standard/hvh
	name = "SFOC-E Operator (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/marine/som/hvh
	r_store = /obj/item/storage/pouch/firstaid/som/full


/datum/outfit/job/som/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/bruise_pack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx11, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911, SLOT_IN_L_POUCH)


//SOM Medic
/datum/job/som/medic
	title = "SFOC-E Terra Intimidator"
	paygrade = "SOM2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/som/medic

/datum/job/som/medic/hvh
	outfit = /datum/outfit/job/som/medic/hvh


/datum/outfit/job/som/medic
	name = "SFOC-E Terra Intimidator"
	jobtype = /datum/job/som/medic

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/combatLifesaver/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/medic
	shoes = /obj/item/clothing/shoes/marine/som
	wear_suit = /obj/item/clothing/suit/storage/marine/som
	gloves = /obj/item/clothing/gloves/marine/som
	head = /obj/item/clothing/head/helmet/marine/som
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/m41a/sfoc
	r_store = /obj/item/storage/pouch/firstaid/som/full
	l_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/medic/hvh
	name = "SFOC-E Terra Intimidator (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/marine/som/hvh


/datum/outfit/job/som/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/cloakbomb, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/tricordrazine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/bicaridine, SLOT_IN_L_POUCH)


//SOM Veteran
/datum/job/som/veteran
	title = "SFOC-E Terra Dominator"
	paygrade = "SOM3"
	outfit = /datum/outfit/job/som/veteran

/datum/job/som/veteran/hvh
	outfit = /datum/outfit/job/som/veteran/hvh


/datum/outfit/job/som/veteran
	name = "SFOC-E Terra Dominator"
	jobtype = /datum/job/som/veteran

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/belt_harness/marine
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran
	shoes = /obj/item/clothing/shoes/marine/som
	wear_suit = /obj/item/clothing/suit/storage/marine/som/veteran
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	head = /obj/item/clothing/head/helmet/marine/som/veteran
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/m412l1_hpr/sfoc
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/firstaid/som/full
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/veteran/hvh
	name = "SFOC-E Terra Dominator (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/marine/som/veteran/hvh


/datum/outfit/job/som/veteran/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/cloakbomb, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/m15, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/m412l1_hpr, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)



//SOM Leader
/datum/job/som/leader
	title = "SFOC-E Terra Elite"
	paygrade = "SOM3"
	outfit = /datum/outfit/job/som/leader

/datum/job/som/leader/hvh
	outfit = /datum/outfit/job/som/leader/hvh


/datum/outfit/job/som/leader
	name = "SFOC-E Terra Elite"
	jobtype = /datum/job/som/leader

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/leader
	shoes = /obj/item/clothing/shoes/marine/som
	wear_suit = /obj/item/clothing/suit/storage/marine/som/leader
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	head = /obj/item/clothing/head/helmet/marine/som/leader
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/m412/elite/sfoc
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/firstaid/som/full
	back = /obj/item/storage/backpack/lightpack/som

/datum/outfit/job/som/leader/hvh
	name = "SFOC-E Terra Elite (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/marine/som/leader/hvh


/datum/outfit/job/som/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/impact, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/m1911, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/ap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/m1911, SLOT_IN_R_POUCH)
