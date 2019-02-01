/datum/job/imperial
	special_role = "IMP"
	comm_title = "IMP"
	faction = "Imperium of Mankind"
	idtype = /obj/item/card/id
	skills_type = /datum/skills/imperial
	supervisors = "the sergeant"
	access = list() // dunno, left empty for now
	minimal_access = list()
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

/datum/job/imperial/generate_equipment(mob/living/carbon/human/H)
	// uniform, shoes, headset
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/imperial(H), SLOT_W_UNIFORM)
	
	var/obj/item/clothing/shoes/marine/imperial/S = new /obj/item/clothing/shoes/marine/imperial(H)
	S.knife = new /obj/item/weapon/combat_knife
	S.update_icon()
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/imperial(H), SLOT_EARS)

/datum/job/imperial/guardsman
	title = "Guardsman"
	comm_title = "Guard"
	paygrade = "Guard"
	equipment = TRUE

// future me, add a really strong but interesting guy
// make bigger pockets
// try to balance armor

// do weapons after that

/datum/job/imperial/guardsman/generate_equipment(mob/living/carbon/human/H)
	. = ..()
	// Guardsman armour, helmet. Lasgun, 6 mags belt, first aid pouch, flare pouch.
	// helmet w_class = 1, 2 slots, 3 max space, can hold glasses and flask
	// suit w_class = 2, 6 space, 2 slots, rifle, smg, sniper, lasgun mags bypass w limit
	// autoinjector is w_class = 1, grenades are w_class = 2
	
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/flare/full(H), SLOT_L_STORE)
	
	var/obj/item/clothing/head/helmet/marine/imperial/Helm = new /obj/item/clothing/head/helmet/marine/imperial(H)
	// custom injectors
	
	var/obj/item/reagent_container/hypospray/autoinjector/AI = new /obj/item/reagent_container/hypospray/autoinjector
	AI.name = "Imperial autoinjector"
	AI.desc = "An autoinjector filled with pain and healing medication together."
	AI.list_reagents = 
	
	H.equip_to_slot_or_del(Helm, SLOT_HEAD)
	
	var/obj/item/clothing/suit/storage/marine/imperial/Suit = new /obj/item/clothing/suit/storage/marine/imperial(H)
	
	H.equip_to_slot_or_del(Suit, SLOT_WEAR_SUIT)
	
	var/obj/item/storage/belt/marine/Belt = new /obj/item/storage/belt/marine(H)
	Belt.contents += new /obj/item/cell/lasgun/M43
	Belt.contents += new /obj/item/cell/lasgun/M43
	Belt.contents += new /obj/item/cell/lasgun/M43
	Belt.contents += new /obj/item/cell/lasgun/M43
	Belt.contents += new /obj/item/cell/lasgun/M43
	
	var/obj/item/weapon/gun/energy/lasgun/M43/stripped/G = new /obj/item/weapon/gun/energy/lasgun/M43/stripped(H)
	G.reload(H, new /obj/item/cell/lasgun/M43(G))
	H.equip_to_slot_or_del(G, SLOT_S_STORE)

/datum/job/imperial/guardsman/sergeant
	title = "Guardsman Sergeant"
	comm_title = "Sergeant"
	skills_type = /datum/skills/imperial/SL
	paygrade = "Sergeant"
	equipment = TRUE

/datum/job/imperial/guardsman/sergeant/generate_equipment(mob/living/carbon/human/H)
	
	

/datum/job/imperial/guardsman/apothecary
	title = "Guardsman Apothecary"
	comm_title = "Apothecary"
	skills_type = /datum/skills/imperial/apothecary
	paygrade = "Apothecary"
	equipment = TRUE

/datum/job/imperial/guardsman/apothecary/generate_equipment(mob/living/carbon/human/H)
	
	
	

