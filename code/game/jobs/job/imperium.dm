/datum/job/imperial
	special_role = "IMP"
	comm_title = "IMP2"
	faction = "Imperium of Mankind"
	idtype = /obj/item/card/id
	skills_type = /datum/skills/pfc
	access = list() // dunno, left empty for now
	minimal_access = list()
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	

/datum/job/imperial/guardsman
	title = "Guardsman"
	supervisors = "the acting squad leader"
	paygrade = "IMP1"
	equipment = TRUE

// future me, add a really strong but interesting guy
// make bigger pockets
// try to balance armor

// do weapons after that

/datum/job/imperial/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/imperial(H), SLOT_W_UNIFORM)
	
	var/obj/item/clothing/shoes/marine/imperial/S = new /obj/item/clothing/shoes/marine/imperial(H)
	S.knife = new /obj/item/weapon/combat_knife
	H.equip_to_slot_or_del(S, SLOT_SHOES)
	
	var/obj/item/clothing/head/helmet/marine/imperial/Helm = new /obj/item/clothing/head/helmet/marine/imperial(H)
	H.equip_to_slot_or_del(Helm, SLOT_HEAD)
	
	var/obj/item/clothing/suit/storage/marine/imperial/Suit = new /obj/item/clothing/suit/storage/marine/imperial(H)
	Suit.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	Suit.pockets.contents += new /obj/item/explosive/grenade/frag/stick
	H.equip_to_slot_or_del(Suit, SLOT_WEAR_SUIT)
	
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	