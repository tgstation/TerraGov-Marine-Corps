//Military Police
/datum/job/military_police
	title = "Military Police"
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
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine, slot_belt)
		return 1
