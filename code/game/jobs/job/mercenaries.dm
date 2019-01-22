/datum/job/mercenaries
	special_role = "Mercenary"
	comm_title = "Merc"
	faction = "Unknown Mercenary Group"
	idtype = /obj/item/card/id
	skills_type = /datum/skills/mercenary
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT


//Mercenary Heavy
/datum/job/mercenaries/heavy
	title = "Mercenary Heavy"
	paygrade = "MRC1"
	equipment = TRUE


/datum/job/mercenaries/heavy/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/mercenary(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/mercenary(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/mercenary(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)


//Mercenary Miner
/datum/job/mercenaries/miner
	title = "Mercenary Miner"
	paygrade = "MRC2"
	equipment = TRUE

/datum/job/mercenaries/miner/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/mercenary/miner(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/mercenary/miner(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/mercenary/miner(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/norm(H), SLOT_BACK)


//Mercenary Engineer
/datum/job/mercenaries/engineer
	title = "Mercenary Engineer"
	paygrade = "MRC3"
	equipment = TRUE

/datum/job/mercenaries/engineer/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/mercenary/engineer(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/eng(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)