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
	paygrade = "MRC"
	equipment = TRUE

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/mercenary(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/mercenary(H), WEAR_JACKET)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), WEAR_HANDS)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/mercenary(H), WEAR_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)


//Mercenary Miner
/datum/job/mercenaries/miner
	title = "Mercenary Miner"
	paygrade = "MRC"
	equipment = TRUE

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/mercenary/miner(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/mercenary/miner(H), WEAR_JACKET)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), WEAR_HANDS)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/mercenary/miner(H), WEAR_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)


//Mercenary Engineer
/datum/job/mercenaries/engineer
	title = "Mercenary Engineer"
	paygrade = "MRC"
	equipment = TRUE

	generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/dutch(H), WEAR_EAR)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/mercenary/engineer(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer(H), WEAR_JACKET)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), WEAR_HANDS)
		H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), WEAR_WAIST)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer(H), WEAR_HEAD)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(H), WEAR_FACE)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/eng(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/explosive/plastique(H.back), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), WEAR_EYES)