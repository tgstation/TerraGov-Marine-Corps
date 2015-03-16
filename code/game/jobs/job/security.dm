//Military Police
/datum/job/military_police
	title = "Military Police"
	flag = MPOLICE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the commander"
	selection_color = "#ffdddd"
	access = list(access_logistics, access_sulaco_brig, access_sulaco_cells)
	minimal_access = list(access_logistics, access_sulaco_brig, access_sulaco_cells)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mmpo(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/mp(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine, slot_belt)
		return 1
