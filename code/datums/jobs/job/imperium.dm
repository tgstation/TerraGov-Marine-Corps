/datum/job/imperial
	job_category = JOB_CAT_MARINE
	comm_title = "IMP"
	faction = FACTION_IMP
	skills_type = /datum/skills/imperial
	supervisors = "the sergeant"
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS

/datum/outfit/job/imperial
	name = "Imperial Standard"
	jobtype = /datum/job/imperial

	id = /obj/item/card/id
	//belt =
	ears = /obj/item/radio/headset/distress/imperial
	w_uniform = /obj/item/clothing/under/marine/imperial
	shoes = /obj/item/clothing/shoes/marine/imperial
	//wear_suit =
	gloves = /obj/item/clothing/gloves/marine
	//head =
	//mask =
	//glasses =
	//suit_store =
	//r_store =
	//l_store =
	//back =

/datum/outfit/job/imperial/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.grant_language(/datum/language/imperial)

/datum/job/imperial/guardsman
	title = "Guardsman"
	comm_title = "Guard"
	paygrade = "Guard"
	outfit = /datum/outfit/job/imperial/guardsman

/datum/outfit/job/imperial/guardsman
	name = "Imperial Guardsman"
	jobtype = /datum/job/imperial/guardsman

	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial
	head = /obj/item/clothing/head/helmet/marine/imperial
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/flare/full
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/imperium

/datum/outfit/job/imperial/guardsman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

/datum/job/imperial/guardsman/sergeant
	title = "Guardsman Sergeant"
	comm_title = "Sergeant"
	skills_type = /datum/skills/imperial/sl
	paygrade = "Sergeant"
	outfit = /datum/outfit/job/imperial/sergeant

/datum/outfit/job/imperial/sergeant // don't inherit guardsman equipment
	name = "Guardsman Sergeant"
	jobtype = /datum/job/imperial/guardsman/sergeant

	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/sergeant
	head = /obj/item/clothing/head/helmet/marine/imperial/sergeant
	r_store = /obj/item/storage/pouch/explosive/upp
	l_store = /obj/item/storage/pouch/field_pouch/full
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/imperium

/datum/outfit/job/imperial/sergeant/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

/datum/job/imperial/guardsman/medicae
	title = "Guardsman Medicae"
	comm_title = "Medicae"
	skills_type = /datum/skills/imperial/medicae
	paygrade = "Medicae"
	outfit = /datum/outfit/job/imperial/medicae

/datum/outfit/job/imperial/medicae
	name = "Guardsman Medicae"
	jobtype = /datum/job/imperial/guardsman/medicae

	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/medicae
	head = /obj/item/clothing/head/helmet/marine/imperial
	glasses = /obj/item/clothing/glasses/hud/health
	l_store = /obj/item/storage/pouch/medkit/medic
	r_store = /obj/item/storage/pouch/medical_injectors/medic
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/imperium

/datum/outfit/job/imperial/medicae/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/zoom, SLOT_IN_BELT) // closest thing to combat performance drugs

/datum/job/imperial/guardsman/veteran
	title = "Guardsman Veteran"
	comm_title = "Veteran"
	paygrade = "Guard"
	outfit = /datum/outfit/job/imperial/guardsman/veteran

/datum/outfit/job/imperial/guardsman/veteran
	name = "Guardsman Veteran"
	jobtype = /datum/job/imperial/guardsman/veteran

	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/sergeant/veteran
	head = /obj/item/clothing/head/helmet/marine/imperial/sergeant/veteran
	r_store = /obj/item/storage/pouch/medical_injectors/firstaid
	l_store = /obj/item/storage/pouch/flare/full
	back = /obj/item/storage/backpack/lightpack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/imperium

/datum/outfit/job/imperial/guardsman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

/datum/job/imperial/commissar
	title = "Imperial Commissar"
	comm_title = "Commissar"
	skills_type = /datum/skills/imperial/sl
	paygrade = "Commissar"
	outfit = /datum/outfit/job/imperial/commissar

/datum/outfit/job/imperial/commissar
	name = "Imperial Commissar"
	jobtype = /datum/job/imperial/commissar

	belt = /obj/item/storage/belt/gun/mateba/full //Ideally this can be later replaced with a bolter
	w_uniform = /obj/item/clothing/under/marine/commissar
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/commissar
	gloves = /obj/item/clothing/gloves/marine/commissar
	head = /obj/item/clothing/head/commissar
	l_store = /obj/item/storage/pouch/medkit
	r_store = /obj/item/storage/pouch/magazine/pistol/large/mateba
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/imperial/commissar/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_L_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/enrg_bar, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/claymore/mercsword/commissar_sword, SLOT_S_STORE)
