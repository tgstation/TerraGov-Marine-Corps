//Military Police
/datum/job/military_police
	title = "Military Police"
	comm_title = "MP"
	flag = MPOLICE
	department_flag = COMMAND
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the commander"
	selection_color = "#ffdddd"
	access = list(access_sulaco_brig, access_sulaco_bridge)
	minimal_access = list(access_sulaco_brig, access_sulaco_bridge)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mmpo(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/mp(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/security/MP/full, slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/red(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(H), slot_glasses)
		spawn(10)
			H << "\red You are a Military Police Officer!"
			H << "Your primary job is to maintain peace and stability on board the Sulaco."
			H << "Marines can get rowdy after a few weeks of cryosleep!"
			H << "In addition, you are tasked with the security of high-ranking personnel. Keep them safe!"
		return 1
