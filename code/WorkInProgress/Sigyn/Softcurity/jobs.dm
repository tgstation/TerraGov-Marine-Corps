/datum/job/hos
	title = "Safety Administrator"
	flag = HOS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffdddd"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_sec(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hos(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/administrator(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/device/pda/heads/hos(H), WEAR_WAIST)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), WEAR_EYES)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(H), WEAR_JACKET)
		H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/taser(H), WEAR_J_STORE)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), WEAR_IN_BACK)

		H.implant_loyalty(src) // Will not do so if config is set to disallow.

		return 1



/datum/job/warden
	title = "Correctional Advisor"
	flag = WARDEN
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the safety administrator"
	selection_color = "#ffeeee"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_sec(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/advisor(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/device/pda/warden(H), WEAR_WAIST)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), WEAR_EYES)
		H.equip_to_slot_or_del(new /obj/item/device/flash(H), WEAR_L_STORE)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), WEAR_IN_BACK)

		H.implant_loyalty(src) // // Will not do so if config is set to disallow.

		return 1



/datum/job/detective
	title = "Detective"
	flag = DETECTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the safety administrator"
	selection_color = "#ffeeee"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/det(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/device/pda/detective(H), WEAR_WAIST)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(H), WEAR_HEAD)
		var/obj/item/clothing/mask/cigarette/CIG = new /obj/item/clothing/mask/cigarette(H)
		CIG.light("")
		H.equip_to_slot_or_del(CIG, WEAR_FACE)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), WEAR_HANDS)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/det_suit(H), WEAR_JACKET)
		H.equip_to_slot_or_del(new /obj/item/weapon/flame/lighter/zippo(H), WEAR_L_STORE)

		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/evidence(H), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/device/detective_scanner(H), WEAR_IN_BACK)

		H.implant_loyalty(src) // Will not do so if config is set to disallow.
		return 1



/datum/job/officer
	title = "Crew Supervisor"
	flag = OFFICER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the safety administrator"
	selection_color = "#ffeeee"


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_ears)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_sec(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/supervisor(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/boots(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/device/pda/security(H), WEAR_WAIST)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), WEAR_R_STORE)
		H.equip_to_slot_or_del(new /obj/item/device/flash(H), WEAR_L_STORE)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/weapon/handcuffs(H), WEAR_IN_BACK)

		H.implant_loyalty(src) // Will not do so if config is set to disallow.

		return 1

/datum/job/hop
	title = "Head of Personnel"
	flag = HOP
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	req_admin_notify = 1


	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/hop(H), slot_ears)
		if(H.backbag == 2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), WEAR_BACK)
		if(H.backbag == 3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), WEAR_BACK)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), WEAR_IN_BACK)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/head_of_personnel(H), WEAR_BODY)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), WEAR_FEET)
		H.equip_to_slot_or_del(new /obj/item/device/pda/heads/hop(H), WEAR_WAIST)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/id_kit(H), WEAR_R_HAND)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/id_kit(H.back), WEAR_IN_BACK)
		return 1
