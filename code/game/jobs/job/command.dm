var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)

//Commander
/datum/job/captain
	title = "Commander"
	comm_title = "CO"
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
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marinesatchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/techofficer/commander(H), slot_gloves)

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
	comm_title = "XO"
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
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marinesatchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/exec(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
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
	comm_title = "BO"
	flag = BRIDGE
	department_flag = COMMAND
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Commander"
	selection_color = "#ddddff"
	idtype = /obj/item/weapon/card/id/silver
	access = list(access_sulaco_logistics, access_sulaco_bridge, access_sulaco_brig)
	minimal_access = list(access_sulaco_logistics, access_sulaco_bridge, access_sulaco_brig)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marinesatchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/logistics(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/ro(H), slot_head)
		H.implant_loyalty(src)
		spawn(10)
			H << "\red You are a bridge officer of the USS Sulaco!"
			H << "Your job is to monitor the marines, and ensure the ship's survival."
			H << "You are also in charge of Logistics, including giving new IDs, manning the supply bay and sending dropships."
		return 1

//Liaison
/datum/job/liaison
	title = "Corporate Liaison"
	comm_title = "CL"
	flag = LIASON
	department_flag = COMMAND
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "your Corporate Overlords"
	selection_color = "#ffeedd"
	access = list(access_centcomm, access_syndicate, access_sulaco_bridge, access_sulaco_logistics, access_sulaco_research)
	minimal_access = list(access_centcomm, access_syndicate, access_sulaco_bridge, access_sulaco_logistics, access_sulaco_research)
	idtype = /obj/item/weapon/card/id/silver
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), slot_shoes)
		//H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
		spawn(10)
			H << "\red You are the Corporate Liaison!"
			H << "As the representative of Weyland-Yutani Corporation, your job requires you to stay in character at all times."
			H << "You are not required to follow military orders, however you also cannot give them."
			H << "Your primary job is to observe and report back your findings to Weyland Yutani. You still must follow normal rules unless told otherwise."
			H << "Use your office fax machine to communicate with them or to acquire new directives, if they are feeling generous."
		return 1



