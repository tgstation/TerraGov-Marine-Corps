var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)

/datum/job/command
	department_flag = ROLEGROUP_MARINE_COMMAND
	selection_color = "#ddddff"
	supervisors = "the acting commander"
	idtype = /obj/item/weapon/card/id/silver
	total_positions = 1
	spawn_positions = 1
	minimal_player_age = 7

//Commander
/datum/job/command/commander
	title = "Commander"
	comm_title = "CO"
	paygrade = "O4"
	flag = ROLE_COMMANDING_OFFICER
	supervisors = "USCM high command"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	minimal_player_age = 14
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED
	flags_whitelist = WHITELIST_COMMANDER

	generate_wearable_equipment()
		. = list(
				WEAR_L_EAR = /obj/item/device/radio/headset/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/command,
				WEAR_FEET = /obj/item/clothing/shoes/marinechief/commander,
				WEAR_HANDS = /obj/item/clothing/gloves/marine/techofficer/commander,
				WEAR_WAIST = /obj/item/weapon/storage/belt/gun/m4a3/commander,
				WEAR_HEAD = /obj/item/clothing/head/cmberet/tan,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel
				)


	generate_entry_message()
		. = {"Your job is HEAVY ROLE PLAY and requires you to stay IN CHARACTER at all times.
While you support Weyland-Yutani, you report to the USCM High Command, not the corporate office.
Your primary task is the safety of the ship and her crew, and ensuring the survival and success of the marines.
Your first order of business should be briefing the marines on the mission they are about to undertake.
If you require any help, use adminhelp to talk to game staff about what you're supposed to do.
Godspeed, commander!"}

	announce_entry_message(mob/living/carbon/human/H)
		..()
		sleep(15)
		if(H && H.loc && flags_startup_parameters & ROLE_ADD_TO_MODE) captain_announcement.Announce("All hands, Commander [H.real_name] on deck!")

	get_access() return get_all_marine_access()

/datum/job/command/commander/nightmare
	flags_startup_parameters = ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED

	generate_entry_message()
		. = {"What the hell did you do to get assigned on this mission? Maybe someone is looking to bump you off for a promotion. Regardless...
The marines need a leader to inspire them and lead them to victory. You'll settle for telling them which side of the gun the bullets come from.
You are a vet, a real badass in your day, but now you're in the thick of it with the grunts. You're plenty sure they are going to die in droves.
Come hell or high water, you are going to be there for them."}

//Executive Officer
/datum/job/command/executive
	title = "Executive Officer"
	comm_title = "XO"
	paygrade = "O3"
	flag = ROLE_EXECUTIVE_OFFICER
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY

	generate_wearable_equipment()
		. = list(
				WEAR_L_EAR = /obj/item/device/radio/headset/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/exec,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/weapon/storage/belt/gun/m44/full,
				WEAR_HEAD = /obj/item/clothing/head/cmcap,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are second in command aboard the ship, and are in next in the chain of command after the commander.
You may need to fill in for other duties if areas are understaffed, and you are given access to do so.
Make the USCM proud!"}

	get_access() return get_all_marine_access()

//Bridge Officer
/datum/job/command/bridge
	title = "Bridge Officer"
	comm_title = "BO"
	paygrade = "O2"
	flag = ROLE_BRIDGE_OFFICER
	total_positions = 3
	spawn_positions = 3
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE

	generate_wearable_equipment()
		. = list(
				WEAR_L_EAR = /obj/item/device/radio/headset/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/logistics,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/weapon/storage/belt/gun/m4a3/full,
				WEAR_HEAD = /obj/item/clothing/head/cmcap/ro,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to monitor the marines, and ensure the ship's theirs and the ship's survival.
You are also in charge of logistics, the overwatch system. You are also in line to take command after the executive officer."}

//Pilot Officer
/datum/job/command/pilot
	title = "Pilot Officer"
	comm_title = "PO"
	paygrade = "O1" //Technically Second Lieutenant equivalent, but 2ndLT doesn't exist in Marine pay grade, so Ensign
	flag = ROLE_PILOT_OFFICER
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE

	generate_wearable_equipment()
		. = list(
				WEAR_L_EAR = /obj/item/device/radio/headset/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/pilot,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/weapon/storage/belt/gun/m39/full,
				WEAR_JACKET = /obj/item/clothing/suit/armor/vest/pilot,
				WEAR_BACK = /obj/item/weapon/storage/backpack/marine/satchel
				)

	generate_stored_equipment()
		. = list(
				WEAR_L_STORE = /obj/item/clothing/glasses/sunglasses,
				WEAR_R_HAND = /obj/item/clothing/head/helmet/marine/pilot
				)

	get_wearable_equipment()
		var/L[] = list(
						WEAR_EYES = /obj/item/clothing/head/helmet/marine/pilot,
						WEAR_HEAD = /obj/item/clothing/glasses/sunglasses
						)

		return generate_wearable_equipment() + L

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to fly, protect, and maintain the ship's dropship.
While you are an officer, your authority is limited to the dropship, where you have authority over the enlisted personnel.
If you are not piloting, there is an autopilot fallback for command, but don't leave the dropship without reason."}

//Military Police
/datum/job/command/police
	title = "Military Police"
	comm_title = "MP"
	paygrade = "E6"
	flag = ROLE_MILITARY_POLICE
	total_positions = 4
	spawn_positions = 4
	selection_color = "#ffdddd"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	idtype = /obj/item/weapon/card/id
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE

	get_total_positions()
		var/count = 0
		var/mob/M
		for(M in player_list)
			if(ishuman(M) && M.mind && !M.mind.special_role) count++
		. = max(4, min(round(count/12), 6))

	generate_wearable_equipment()
		. = list(
				WEAR_L_EAR = /obj/item/device/radio/headset/mmpo,
				WEAR_BODY = /obj/item/clothing/under/marine/mp,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/weapon/storage/belt/security/MP/full,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/MP,
				WEAR_EYES = /obj/item/clothing/glasses/sunglasses/sechud,
				WEAR_HEAD = /obj/item/clothing/head/cmberet/red,
				WEAR_BACK = /obj/item/weapon/storage/backpack/security
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are held by a higher standard and are required to obey not only the server rules but the <a href='http://www.colonial-marines.com/wiki/Marine_Law'>Marine Law</a>.
Failure to do so may result in a job ban or server ban.
Your primary job is to maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"}

//Warrant Officer
/datum/job/command/warrant
	title = "Warrant Officer"
	comm_title = "WO"
	paygrade = "O2"
	flag = ROLE_WARRANT_OFFICER
	selection_color = "#ffaaaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE

	generate_wearable_equipment()
		. = list(
				WEAR_L_EAR = /obj/item/device/radio/headset/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/warrant,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/weapon/storage/belt/security/MP/full,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/MP/WO,
				WEAR_EYES = /obj/item/clothing/glasses/sunglasses/sechud,
				WEAR_HEAD = /obj/item/clothing/head/cmberet/wo,
				WEAR_BACK = /obj/item/weapon/storage/backpack/security
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are held by a higher standard and are required to obey not only the server rules but the <a href='http://www.colonial-marines.com/wiki/Marine_Law'>Marine Law</a>.
Failure to do so may result in a job ban or server ban.
You lead the Military Police, ensure your officers maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"}