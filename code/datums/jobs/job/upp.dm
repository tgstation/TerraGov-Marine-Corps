/datum/job/upp
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_USL

//USL Gunner
/datum/job/upp/standard
	title = "USL Gunner"
	paygrade = "UPP1"
	outfit = /datum/outfit/job/upp/standard

/datum/job/upp/standard/hvh
	outfit = /datum/outfit/job/upp/standard/hvh


/datum/outfit/job/upp/standard
	name = "USL Gunner"
	jobtype = /datum/job/upp/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/UPP
	mask = /obj/item/clothing/mask/gas/PMC/leader
	suit_store = /obj/item/weapon/gun/rifle/type71
	r_store = /obj/item/storage/pouch/pistol
	l_store = /obj/item/storage/pouch/magazine/pistol/large
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/upp/standard/hvh
	name = "USL Gunner (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/hvh


/datum/outfit/job/upp/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tramadol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/c99, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/c99, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//SL Surgeon
/datum/job/upp/medic
	title = "USL Surgeon"
	paygrade = "UPP2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/upp/medic

/datum/job/upp/medic/hvh
	outfit = /datum/outfit/job/upp/medic/hvh


/datum/outfit/job/upp/medic
	name = "USL Surgeon"
	jobtype = /datum/job/upp/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/upp
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP/medic
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/upp/medic/hvh
	name = "USL Surgeon (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/hvh


/datum/outfit/job/upp/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/tricordrazine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/tricordrazine, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//USL Powder Monkey
/datum/job/upp/heavy
	title = "USL Powder Monkey"
	paygrade = "UPP3"
	skills_type = /datum/skills/specialist/upp
	outfit = /datum/outfit/job/upp/heavy

/datum/job/upp/heavy/hvh
	outfit = /datum/outfit/job/upp/heavy/hvh


/datum/outfit/job/upp/heavy
	name = "USL Powder Monkey"
	jobtype = /datum/job/upp/heavy

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/UPP/heavy
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer
	r_store = /obj/item/storage/pouch/explosive
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/upp/heavy/hvh
	name = "USL Powder Monkey (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy/hvh


/datum/outfit/job/upp/heavy/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//USL Captain
/datum/job/upp/leader
	job_category = JOB_CAT_COMMAND
	title = "USL Captain"
	paygrade = "UPP4"
	skills_type = /datum/skills/sl/upp
	outfit = /datum/outfit/job/upp/leader

/datum/job/upp/leader/hvh
	outfit = /datum/outfit/job/upp/leader/hvh

/datum/outfit/job/upp/leader
	name = "USL Captain"
	jobtype = /datum/job/upp/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/korovin/standard
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap/beret
	suit_store = /obj/item/weapon/gun/rifle/type71
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/upp/leader/hvh
	name = "USL Captain (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy/hvh


/datum/outfit/job/upp/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)
