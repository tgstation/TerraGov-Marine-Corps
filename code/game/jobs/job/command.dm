var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)

/datum/job/command
	department_flag = ROLEGROUP_MARINE_COMMAND
	selection_color = "#ddddff"
	supervisors = "the acting commander"
	idtype = /obj/item/card/id/silver
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
	idtype = /obj/item/card/id/gold
	minimal_player_age = 14
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED
	flags_whitelist = WHITELIST_COMMANDER
	skills_type = /datum/skills/commander

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/command,
				WEAR_FEET = /obj/item/clothing/shoes/marinechief/commander,
				WEAR_HANDS = /obj/item/clothing/gloves/marine/techofficer/commander,
				WEAR_WAIST = /obj/item/storage/belt/gun/mateba/cmateba/full,
				WEAR_HEAD = /obj/item/clothing/head/cmberet/tan,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)
	generate_stored_equipment()
		. = list(
				WEAR_L_HAND = /obj/item/device/binoculars
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
	skills_type = /datum/skills/XO


	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/exec,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/storage/belt/gun/m4a3/vp70,
				WEAR_HEAD = /obj/item/clothing/head/cmcap,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are second in command aboard the ship, and are in next in the chain of command after the commander.
You may need to fill in for other duties if areas are understaffed, and you are given access to do so.
Make the USCM proud!"}

	get_access() return get_all_marine_access()

//Staff Officer
/datum/job/command/bridge
	title = "Staff Officer"
	disp_title = "Staff Officer"
	comm_title = "SO"
	paygrade = "O2"
	flag = ROLE_BRIDGE_OFFICER
	total_positions = 5
	spawn_positions = 5
	scaled = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/SO

	set_spawn_positions(var/count)
		spawn_positions = so_slot_formula(count)

	get_total_positions(var/latejoin = 0)
		return (latejoin ? so_slot_formula(get_total_marines()) : spawn_positions)

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/bridge,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_WAIST = /obj/item/storage/belt/gun/m4a3/commander,
				WEAR_HEAD = /obj/item/clothing/head/cmcap/ro,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)
	generate_stored_equipment()
		. = list(
				WEAR_L_HAND = /obj/item/device/binoculars
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to monitor the marines, man the CIC, and listen to your superior officers.
You are in charge of logistics and the overwatch system. You are also in line to take command after the executive officer."}

//Pilot Officer
/datum/job/command/pilot
	title = "Pilot Officer"
	comm_title = "PO"
	paygrade = "O1" //Technically Second Lieutenant equivalent, but 2ndLT doesn't exist in Marine pay grade, so Ensign
	flag = ROLE_PILOT_OFFICER
	total_positions = 4
	spawn_positions = 4
	scaled = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/pilot

	set_spawn_positions(var/count)
		spawn_positions = po_slot_formula(count)

	get_total_positions(var/latejoin = 0)
		return (latejoin ? po_slot_formula(get_total_marines()) : spawn_positions)

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/pilot,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/storage/belt/gun/m4a3/vp70,
				WEAR_JACKET = /obj/item/clothing/suit/armor/vest/pilot,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)

	generate_stored_equipment()
		. = list(
				WEAR_L_HAND = /obj/item/clothing/glasses/sunglasses,
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

//Tank Crewmen //For now, straight up copied from the pilot officers until their role is more solidified
/datum/job/command/tank_crew
	title = "Tank Crewman"
	comm_title = "TC"
	paygrade = "O1"
	flag = ROLE_TANK_OFFICER
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/tank_crew
	idtype = /obj/item/card/id/dogtag

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/tanker,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/yellow,
				WEAR_WAIST = /obj/item/storage/belt/gun/m4a3/vp70,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/tanker,
				WEAR_BACK = /obj/item/storage/backpack/marine/satchel,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)

	generate_stored_equipment()
		. = list(
				WEAR_R_HAND = /obj/item/clothing/head/helmet/marine/tanker
				)

	get_wearable_equipment()
		var/L[] = list(
						WEAR_EYES = /obj/item/clothing/head/helmet/marine/tanker
						)

		return generate_wearable_equipment() + L

	generate_entry_message(mob/living/carbon/human/H)
		. = {"Your job is to operate and maintain thee ship's armored vehicles.
While you are an officer, your authority is limited to your own vehicle, where you have authority over the enlisted personnel. You will need MTs to repair and replace hardpoints."}

//Military Police
/datum/job/command/police
	title = "Military Police"
	comm_title = "MP"
	paygrade = "E6"
	flag = ROLE_MILITARY_POLICE
	total_positions = 5
	spawn_positions = 5
	scaled = 1
	selection_color = "#ffdddd"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	idtype = /obj/item/card/id
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/MP

	set_spawn_positions(var/count)
		spawn_positions = mp_slot_formula(count)

	get_total_positions(var/latejoin = 0)
		return (latejoin ? mp_slot_formula(get_total_marines()) : spawn_positions)

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/mmpo,
				WEAR_BODY = /obj/item/clothing/under/marine/mp,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/black,
				WEAR_WAIST = /obj/item/storage/belt/security/MP/full,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/MP,
				WEAR_EYES = /obj/item/clothing/glasses/sunglasses/sechud,
				WEAR_HEAD = /obj/item/clothing/head/cmberet/red,
				WEAR_BACK = /obj/item/storage/backpack/satchel/sec,
				WEAR_R_STORE = /obj/item/storage/pouch/general/medium
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are held by a higher standard and are required to obey not only the server rules but the <a href='http://cm-ss13.com/wiki/Marine_Law'>Marine Law</a>.
Failure to do so may result in a job ban or server ban.
Your primary job is to maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"}

//Chief MP
/datum/job/command/warrant
	title = "Chief MP"
	comm_title = "CMP"
	paygrade = "WO"
	flag = ROLE_CHIEF_MP
	selection_color = "#ffaaaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CMP

	generate_wearable_equipment()
		. = list(
				WEAR_EAR = /obj/item/device/radio/headset/almayer/cmpcom,
				WEAR_BODY = /obj/item/clothing/under/marine/officer/warrant,
				WEAR_FEET = /obj/item/clothing/shoes/marine,
				WEAR_HANDS = /obj/item/clothing/gloves/black,
				WEAR_WAIST = /obj/item/storage/belt/security/MP/full,
				WEAR_JACKET = /obj/item/clothing/suit/storage/marine/MP/WO,
				WEAR_EYES = /obj/item/clothing/glasses/sunglasses/sechud,
				WEAR_HEAD = /obj/item/clothing/head/cmberet/wo,
				WEAR_BACK = /obj/item/storage/backpack/security,
				WEAR_R_STORE = /obj/item/storage/pouch/general/large
				)

	generate_entry_message(mob/living/carbon/human/H)
		. = {"You are held by a higher standard and are required to obey not only the server rules but the <a href='http://cm-ss13.com/wiki/Marine_Law'>Marine Law</a>.
Failure to do so may result in a job ban or server ban.
You lead the Military Police, ensure your officers maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"}
