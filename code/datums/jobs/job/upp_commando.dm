/datum/job/upp/commando
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/commando
	faction = FACTION_USL


//USL Elite Powder Monkey
/datum/job/upp/commando/standard
	title = "USL Elite Powder Monkey"
	paygrade = "UPPC1"
	outfit = /datum/outfit/job/upp/commando/standard


/datum/outfit/job/upp/commando/standard
	name = "USL Elite Powder Monkey"
	jobtype = /datum/job/upp/commando/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap
	mask = /obj/item/clothing/mask/gas/PMC/upp
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles/upp
	suit_store = /obj/item/weapon/gun/rifle/type71/commando
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/commando/standard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/chameleon, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/restraints/handcuffs, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/chloralhydrate, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/sleeptoxin, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//USL Elite Surgeon
/datum/job/upp/commando/medic
	title = "USL Elite Surgeon"
	paygrade = "UPPC2"
	skills_type = /datum/skills/commando/medic
	outfit = /datum/outfit/job/upp/commando/medic


/datum/outfit/job/upp/commando/medic
	name = "USL Elite Surgeon"
	jobtype = /datum/job/upp/commando/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/full/upp
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP/medic
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap
	mask = /obj/item/clothing/mask/gas/PMC/upp
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles/upp
	suit_store = /obj/item/weapon/gun/smg/skorpion
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/commando/medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/healthanalyzer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/chameleon, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/skorpion, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/suppressor, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/attachable/reddot, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/tricordrazine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/glass/bottle/tricordrazine, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)


//USL Elite Captain
/datum/job/upp/commando/leader
	job_category = JOB_CAT_COMMAND
	title = "USL Elite Captain"
	paygrade = "UPPC3"
	skills_type = /datum/skills/commando/leader
	outfit = /datum/outfit/job/upp/commando/leader


/datum/outfit/job/upp/commando/leader
	name = "USL Elite Captain"
	jobtype = /datum/job/upp/commando/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/korovin/tranq
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/PMC
	head = /obj/item/clothing/head/uppcap/beret
	mask = /obj/item/clothing/mask/gas/PMC/upp
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles/upp
	suit_store = /obj/item/weapon/gun/rifle/type71/commando
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack


/datum/outfit/job/upp/commando/leader/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/upp, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/radio, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/crowbar/red, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/phosphorus/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/medium_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/small_stack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/chameleon, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/type71, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/weapon/combat_knife/upp, SLOT_IN_BOOT)
