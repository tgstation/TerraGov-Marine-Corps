var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)

//Commander
/datum/job/captain
	title = "Commander"
	flag = COMMANDER
	department_flag = COMMAND
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 14
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		var/obj/item/clothing/under/U = new /obj/item/clothing/under/marine/officer/commander(H)
		U.hastie = new /obj/item/clothing/tie/medal/gold/captain(U)
		var/obj/item/weapon/storage/backpack/mcommander/BPK = new/obj/item/weapon/storage/backpack/mcommander(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		H.equip_to_slot_or_del(BPK, slot_back,1)
		H.equip_to_slot_or_del(U, slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/commander(H), slot_head)

		captain_announcement.Announce("<i>All hands, Commander [H.real_name] on deck!</i>")

		H.implant_loyalty(src)

		return 1

	get_access()
		return get_all_marine_access()

//Executive Officer
/datum/job/executive_officer
	title = "Executive Officer"
	flag = EXECUTIVE
	department_flag = COMMAND
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	access = list(access_sulaco_logistics, access_sulaco_brig, access_sulaco_armory, access_sulaco_bridge)
	minimal_access = list(access_sulaco_logistics, access_sulaco_brig, access_sulaco_armory, access_sulaco_bridge)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/logistics(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.implant_loyalty(src)
		return 1

//Bridge Officer
/datum/job/bridge_officer
	title = "Bridge Officer"
	flag = BRIDGE
	department_flag = COMMAND
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Commander"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	access = list(access_sulaco_logistics, access_sulaco_bridge)
	minimal_access = list(access_sulaco_logistics, access_sulaco_bridge)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/logistics(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.implant_loyalty(src)
		return 1

/datum/job/liason
	title = "Corporate Liason"
	flag = LIASON
	department_flag = COMMAND
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "your Corporate Overlords"
	selection_color = "#ffeedd"
	access = list(access_centcomm, access_syndicate)
	minimal_access = list(access_centcomm, access_syndicate)
	idtype = /obj/item/weapon/card/id/silver
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0

		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/liason_suit(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
		spawn(10)
			H << "As the representative of Weyland-Yutani Corporation, your job requires you to stay in character at all times."
			H << "You are not required to follow military orders, however you also cannot give them."
			H << "Your primary job is to observe and report back your findings to Weyland Yutani. You still must follow normal rules unless told otherwise."
			H << "Use 'pray' to communicate with them or to acquire new directives, if they are feeling generous."
		return 1
