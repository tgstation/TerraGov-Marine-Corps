/datum/job/upp
	department_flag = J_FLAG_UPP
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/pfc/crafty
	faction = "Union of Progressive People"


//UPP Standard
/datum/job/upp/standard
	title = "UPP Standard"
	paygrade = "UPP1"
	flag = UPP_STANDARD
	outfit = /datum/outfit/job/upp/standard


/datum/outfit/job/upp/standard
	name = "UPP Standard"
	jobtype = /datum/job/upp/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/bears
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/UPP
	mask = /obj/item/clothing/mask/gas/PMC/leader
	suit_store = /obj/item/weapon/gun/rifle/type71
	r_store = /obj/item/storage/pouch/bayonet
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/stanard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//UPP Medic
/datum/job/upp/medic
	title = "UPP Medic"
	paygrade = "UPP2"
	skills_type = /datum/skills/combat_medic/crafty
	flag = UPP_MEDIC
	outfit = /datum/outfit/job/upp/medic


/datum/outfit/job/upp/medic
	name = "UPP Medic"
	jobtype = /datum/job/upp/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/combatLifesaver/upp
	ears = /obj/item/radio/headset/distress/bears
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP/medic
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion/upp
	r_store = /obj/item/storage/pouch/medkit
	l_store = /obj/item/storage/pouch/medical/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//UPP Heavy
/datum/job/upp/heavy
	title = "UPP Heavy"
	paygrade = "UPP3"
	skills_type = /datum/skills/specialist/upp
	flag = UPP_HEAVY
	outfit = /datum/outfit/job/upp/heavy


/datum/outfit/job/upp/heavy
	name = "UPP Heavy"
	jobtype = /datum/job/upp/heavy

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/bears
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/helmet/UPP/heavy
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer
	r_store = /obj/item/storage/pouch/explosive
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/heavy/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/radio/detpack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/cloakbomb, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//UPP Leader
/datum/job/upp/leader
	title = "UPP Leader"
	paygrade = "UPP4"
	skills_type = /datum/skills/SL/upp
	outfit = /datum/outfit/job/upp/leader


/datum/outfit/job/upp/leader
	name = "UPP Heavy"
	jobtype = /datum/job/upp/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/korovin/standard
	ears = /obj/item/radio/headset/distress/bears
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap/beret
	suit_store = /obj/item/weapon/gun/rifle/type71/carbine
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/firstaid/full
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/m94, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)