/datum/job/imperial
	comm_title = "IMP"
	faction = "Imperium of Mankind"
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
	r_store = /obj/item/storage/pouch/firstaid/full
	l_store = /obj/item/storage/pouch/flare/full
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/imperial/guardsman/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)
	
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)
	
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_BACKPACK)
	
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BELT)
	
	var/obj/item/weapon/gun/energy/lasgun/M43/G = new /obj/item/weapon/gun/energy/lasgun/M43(H)
	G.reload(H, new /obj/item/cell/lasgun/M43(G)) // starts out full
	H.equip_to_slot_or_del(G, SLOT_S_STORE)

/datum/job/imperial/guardsman/sergeant
	title = "Guardsman Sergeant"
	comm_title = "Sergeant"
	skills_type = /datum/skills/imperial/SL
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
	
/datum/outfit/job/imperial/sergeant/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)
	
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)
	
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_BACKPACK)
	
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43/highcap, SLOT_IN_BELT)
	
	var/obj/item/weapon/gun/energy/lasgun/M43/G = new /obj/item/weapon/gun/energy/lasgun/M43(H)
	G.reload(H, new /obj/item/cell/lasgun/M43/highcap(G)) // starts out reloaded
	H.equip_to_slot_or_del(G, SLOT_S_STORE)

/datum/job/imperial/guardsman/medicae
	title = "Guardsman Medicae"
	comm_title = "Medicae"
	skills_type = /datum/skills/imperial/medicae
	paygrade = "Medicae"
	outfit = /datum/outfit/job/imperial/medicae

/datum/outfit/job/imperial/medicae
	name = "Guardsman Medicae"
	jobtype = /datum/job/imperial/guardsman/medicae

	belt = /obj/item/storage/belt/combatLifesaver
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/medicae
	head = /obj/item/clothing/head/helmet/marine/imperial
	glasses = /obj/item/clothing/glasses/hud/health
	l_store = /obj/item/storage/pouch/medkit
	r_store = /obj/item/storage/pouch/autoinjector
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/imperial/medicae/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv, SLOT_IN_L_POUCH)
	
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/tricordrazine, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/hypospray/autoinjector/oxycodone, SLOT_IN_HEAD)
	
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/frag, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_SUIT)
	
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_container/food/snacks/eat_bar, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/M43, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/zoom, SLOT_IN_BELT) // closest thing to combat performance drugs

	var/obj/item/weapon/gun/energy/lasgun/M43/G = new /obj/item/weapon/gun/energy/lasgun/M43(H)
	G.reload(H, new /obj/item/cell/lasgun/M43(G)) // starts out reloaded
	H.equip_to_slot_or_del(G, SLOT_S_STORE)

