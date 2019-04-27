/datum/job/mercenaries
	department_flag = J_FLAG_MERCENARY
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	skills_type = /datum/skills/mercenary
	faction = "Unknown Mercenary Group"


//Mercenary Heavy
/datum/job/mercenaries/heavy
	title = "Mercenary Heavy"
	paygrade = "MRC1"
	flag = MERC_HEAVY
	outfit = /datum/outfit/job/mercenaries/heavy



/datum/outfit/job/mercenaries/heavy
	name = "Mercenary Heavy"
	jobtype = /datum/job/mercenaries/heavy

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/veteran/mercenary
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/mercenary
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/marine/veteran/mercenary
	mask = /obj/item/clothing/mask/gas/PMC
	back = /obj/item/storage/backpack/satchel/norm


//Mercenary Miner
/datum/job/mercenaries/miner
	title = "Mercenary Miner"
	paygrade = "MRC2"
	flag = MERC_MINER
	outfit = /datum/outfit/job/mercenaries/miner


/datum/outfit/job/mercenaries/miner
	name = "Mercenary Miner"
	jobtype = /datum/job/mercenaries/miner

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/veteran/mercenary/miner
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/mercenary/miner
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/marine/veteran/mercenary/miner
	mask = /obj/item/clothing/mask/gas/PMC
	back = /obj/item/storage/backpack/satchel/norm


//Mercenary Engineer
/datum/job/mercenaries/engineer
	title = "Mercenary Engineer"
	paygrade = "MRC3"
	flag = MERC_ENGINEER
	outfit = /datum/outfit/job/mercenaries/engineer


/datum/outfit/job/mercenaries/engineer
	name = "Mercenary Engineer"
	jobtype = /datum/job/mercenaries/engineer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/veteran/mercenary/engineer
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/veteran/PMC
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/helmet/marine/veteran/mercenary/engineer
	glasses = /obj/item/clothing/glasses/welding
	mask = /obj/item/clothing/mask/gas/PMC
	back = /obj/item/storage/backpack/satchel/eng