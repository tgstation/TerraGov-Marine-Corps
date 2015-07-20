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
		var/obj/item/clothing/under/U = new /obj/item/clothing/under/marine/officer/CO(H)
		var/obj/item/weapon/storage/backpack/mcommander/BPK = new/obj/item/weapon/storage/backpack/mcommander(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		H.equip_to_slot_or_del(BPK, slot_back,1)
		H.equip_to_slot_or_del(U, slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/commander(H), slot_head)
		H.implant_loyalty(src)
		spawn(10)
			H << "\red You are the Sulaco Commander!"
			H << "Your job is HEAVY ROLE PLAY and requires you to stay IN CHARACTER at all times."
			H << "You are hired by Weyland-Yutani to investigate the archaeology dig site Lazarus Landing."
			H << "Your primary task is the safety of the Sulaco and its crew, and ensuring the survival of the Marines."
			H << "Your first order of business should be briefing the Marines east of the ladder hallway."
			H << "If you require any help, use adminhelp to talk to game staff about what you're supposed to do."
			H << "Don't fuck up!"
		spawn(15)
			captain_announcement.Announce("All hands, Commander [H.real_name] on deck!")

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
	access = list()
	minimal_access = list() //Meh. See below
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		var/obj/item/weapon/storage/backpack/BPK = new(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/XO(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		//H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.implant_loyalty(src)
		spawn(10)
			H << "\red You are the Executive Officer of the USS Sulaco!"
			H << "You are second in command aboard the ship and are in charge of all personnel except the Commander."
			H << "You may need to fill in for other duties if areas are understaffed."
			H << "If the Commander bites it, you're in charge!"
		return 1

	get_access()
		return get_all_marine_access() //fuckit

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
		var/obj/item/weapon/storage/backpack/BPK = new(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		//H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/logistics(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		//H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.implant_loyalty(src)
		spawn(10)
			H << "\red You are a bridge officer of the USS Sulaco!"
			H << "Your job is to monitor the marines, and ensure the ship's survival."
			H << "You are also in charge of Logistics, including giving new IDs, manning the supply bay and sending dropships."
		return 1

//Liason
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
			H << "\red You are the Corporate Liason!"
			H << "As the representative of Weyland-Yutani Corporation, your job requires you to stay in character at all times."
			H << "You are not required to follow military orders, however you also cannot give them."
			H << "Your primary job is to observe and report back your findings to Weyland Yutani. You still must follow normal rules unless told otherwise."
			H << "Use 'pray' to communicate with them or to acquire new directives, if they are feeling generous."
		return 1

//Requisitions Officer
/datum/job/req_officer
	title = "Requisitions Officer"
	flag = REQUI
	department_flag = COMMAND
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander, the Executive Officer"
	selection_color = "#aa85ff"
	access = list(access_sulaco_cargo)
	minimal_access = list(access_sulaco_cargo)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		var/obj/item/weapon/storage/backpack/BPK = new(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/ro_suit(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/soft/ro_cap(H), slot_head)
		H.implant_loyalty(src)
		spawn(10)
			H << "\red You are the Requisitions Officer!"
			H << "Your job is to dispense basic weapon attachments and extra supplies."
			H << "Squad leaders are allowed THREE attachments just by asking. You should ask marines for a stamped form from Logistics."
			H << "Commanders and Executive Officers have full access to the vendor."
			H << "You don't have to stay in your department all the time, but you should go if someone needs something."
		return 1

