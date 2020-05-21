/datum/job/terragov/command
	job_category = JOB_CAT_COMMAND
	selection_color = "#ddddff"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_COMMAND


//Captain
/datum/job/terragov/command/captain
	title = CAPTAIN
	req_admin_notify = TRUE
	paygrade = "O6"
	comm_title = "CPT"
	supervisors = "TGMC high command"
	selection_color = "#ccccff"
	total_positions = 1
	skills_type = /datum/skills/captain
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	outfit = /datum/outfit/job/command/captain
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)

/datum/job/terragov/command/captain/announce(mob/living/announced_mob)
	. = ..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Captain [announced_mob.real_name] on deck!"))

/datum/job/terragov/command/captain/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"As the captain of the [SSmapping.configs[SHIP_MAP].map_name] you are held by higher standard and are expected to act competently.
While you may support Nanotrasen, you report to the TGMC High Command, not the corporate office.
Your primary task is the safety of the ship and her crew, and ensuring the survival and success of the marines.
Your first order of business should be briefing the marines on the mission they are about to undertake.
If you require any help, use adminhelp to ask mentors about what you're supposed to do.
Godspeed, captain! And remember, you are not above the law."})


/datum/outfit/job/command/captain
	name = CAPTAIN
	jobtype = /datum/job/terragov/command/captain

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/gun/mateba/captain/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/command
	shoes = /obj/item/clothing/shoes/marinechief/captain
	gloves = /obj/item/clothing/gloves/marine/techofficer/captain
	head = /obj/item/clothing/head/tgmcberet/tan
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/binoculars/tactical
	back = /obj/item/storage/backpack/marine/satchel


//Field Commander
/datum/job/terragov/command/fieldcommander
	title = FIELD_COMMANDER
	req_admin_notify = TRUE
	paygrade = "MO4"
	comm_title = "FCDR"
	total_positions = 1
	skills_type = /datum/skills/FO
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER
	outfit = /datum/outfit/job/command/fieldcommander
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)

/datum/job/terragov/command/fieldcommander/after_spawn(mob/living/L, mob/M, latejoin)
	. = ..()
	SSdirection.set_leader("marine-sl", L)


/datum/job/terragov/command/fieldcommander/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are charged with overseeing the operation on the ground, and are the highest-ranked deployed marine.
Your duties are to ensure marines hold when ordered, and push when they are cowering behind barricades.
Do not ask your men to do anything you would not do side by side with them.
Make the TGMC proud!"})


/datum/outfit/job/command/fieldcommander
	name = FIELD_COMMANDER
	jobtype = /datum/job/terragov/command/fieldcommander

	id = /obj/item/card/id/dogtag
	belt = /obj/item/storage/belt/gun/m4a3/fieldcommander/
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/exec
	wear_suit = /obj/item/clothing/suit/storage/marine/smartgunner/fancy
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine/officer
	head = /obj/item/clothing/head/tgmcberet/fc
	r_store = /obj/item/storage/pouch/general/large/command
	l_store = /obj/item/megaphone
	back = /obj/item/smartgun_powerpack/fancy
	suit_store = /obj/item/weapon/gun/smartgun


//Staff Officer
/datum/job/terragov/command/staffofficer
	title = STAFF_OFFICER
	paygrade = "O4"
	comm_title = "SO"
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = ALL_MARINE_ACCESS
	skills_type = /datum/skills/SO
	display_order = JOB_DISPLAY_ORDER_STAFF_OFFICER
	outfit = /datum/outfit/job/command/staffofficer
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/command/staffofficer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to monitor the marines, man the CIC, and listen to your superior officers.
You are in charge of logistics and the overwatch system. You are also in line to take command after the captain."})


/datum/outfit/job/command/staffofficer
	name = STAFF_OFFICER
	jobtype = /datum/job/terragov/command/staffofficer

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/officer
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/bridge
	shoes = /obj/item/clothing/shoes/marine
	head = /obj/item/clothing/head/tgmccap/ro
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/binoculars/tactical
	back = /obj/item/storage/backpack/marine/satchel


//Pilot Officer
/datum/job/terragov/command/pilot
	title = PILOT_OFFICER
	paygrade = "WO"
	comm_title = "PO"
	total_positions = 2
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/pilot
	display_order = JOB_DISPLAY_ORDER_PILOT_OFFICER
	outfit = /datum/outfit/job/command/pilot
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/command/pilot/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to fly, protect, and maintain the ship's dropship.
While you are a warrant officer, your authority is limited to the dropship, where you have authority over the enlisted personnel.
If you are not piloting, there is an autopilot fallback for command, but don't leave the dropship without reason."})


/datum/outfit/job/command/pilot
	name = PILOT_OFFICER
	jobtype = /datum/job/terragov/command/pilot

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/pilot
	wear_suit = /obj/item/clothing/suit/armor/vest/pilot
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	glasses = /obj/item/clothing/glasses/sunglasses/aviator
	head = /obj/item/clothing/head/helmet/marine/pilot
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel


//Tank Crewmen
/datum/job/terragov/command/tank_crew
	title = TANK_CREWMAN
	paygrade = "E7"
	comm_title = "TC"
	total_positions = 0
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_TANK)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_TANK, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/tank_crew
	display_order = JOB_DISPLAY_ORDER_TANK_CREWMAN
	outfit = /datum/outfit/job/command/tank_crew
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/command/tank_crew/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to operate and maintain the ship's armored vehicles.
Your authority is limited to your own vehicle, but you are next in line on the field, after the field commander.
You could use MTs help to repair and replace hardpoints."})



/datum/outfit/job/command/tank_crew
	name = TANK_CREWMAN
	jobtype = /datum/job/terragov/command/tank_crew

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/tanker
	wear_suit = /obj/item/clothing/suit/storage/marine/M3P/tanker
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/helmet/marine/tanker
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/terragov/police
	job_category = JOB_CAT_POLICE
	selection_color = "#ffdddd"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_POLICE


//Military Police
/datum/job/terragov/police/officer
	title = MASTER_AT_ARMS
	paygrade = "PO"
	comm_title = "MA"
	total_positions = 5
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_CARGO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/MP
	display_order = JOB_DISPLAY_ORDER_MILITARY_POLICE
	outfit = /datum/outfit/job/police/officer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/police/officer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are held by a higher standard and are required to not abuse your position to severely hinder the progress of the round.
Failure to do so may result in a job ban.
Your primary job is to uphold the <a href='https://tgstation13.org/wiki/TGMC:Military_Law'>Military Law</a>, and peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"})



/datum/outfit/job/police/officer
	name = MASTER_AT_ARMS
	jobtype = /datum/job/terragov/police/officer

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/security/MP/full
	ears = /obj/item/radio/headset/mainship/mmpo
	w_uniform = /obj/item/clothing/under/marine/mp
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	glasses = /obj/item/clothing/glasses/sunglasses/sechud
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/tgmcberet/red
	r_store = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/satchel/sec


//Command Master at Arms
/datum/job/terragov/police/chief
	title = COMMAND_MASTER_AT_ARMS
	paygrade = "O2"
	comm_title = "CMA"
	selection_color = "#ffaaaa"
	total_positions = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RO)
	skills_type = /datum/skills/CMP
	display_order = JOB_DISPLAY_ORDER_CHIEF_MP
	outfit = /datum/outfit/job/police/chief
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/police/chief/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are held by a higher standard and are required to not abuse your position to severely hinder the progress of the round.
Failure to do so may result in a job ban.
You lead the Military Police, ensure your officers uphold the <a href='https://tgstation13.org/wiki/TGMC:Military_Law'>Military Law</a>, and maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"})



/datum/outfit/job/police/chief
	name = COMMAND_MASTER_AT_ARMS
	jobtype = /datum/job/terragov/police/chief

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/security/MP/full
	ears = /obj/item/radio/headset/mainship/cmpcom
	w_uniform = /obj/item/clothing/under/marine/officer/warrant
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	glasses = /obj/item/clothing/glasses/sunglasses/sechud
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/tgmcberet/wo
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/security



/datum/job/terragov/engineering
	job_category = JOB_CAT_ENGINEERING
	selection_color = "#fff5cc"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_ENGINEERING


//Chief Ship Engineer
/datum/job/terragov/engineering/chief
	title = CHIEF_SHIP_ENGINEER
	paygrade = "O2"
	comm_title = "CSE"
	selection_color = "#ffeeaa"
	total_positions = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/CE
	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	outfit = /datum/outfit/job/engineering/chief
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/engineering/chief/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to maintain the ship's engine and keep everything running.
If you have no idea how to set up the engine, or it's your first time, adminhelp so that a mentor can assist you.
You are also next in the chain of command, should the bridge crew fall in the line of duty."})


/datum/outfit/job/engineering/chief
	name = CHIEF_SHIP_ENGINEER
	jobtype = /datum/job/terragov/engineering/chief

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/ce
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	glasses = /obj/item/clothing/glasses/welding/superior
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/beret/marine/techofficer
	r_store = /obj/item/storage/pouch/electronics
	back = /obj/item/storage/backpack/marine/satchel/tech



//Ship Engineer
/datum/job/terragov/engineering/tech
	title = SHIP_TECH
	comm_title = "ST"
	paygrade = "PO"
	total_positions = 5
	supervisors = "the chief ship engineer and the requisitions officer"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	skills_type = /datum/skills/ST
	display_order = JOB_DISPLAY_ORDER_SHIP_TECH
	outfit = /datum/outfit/job/engineering/tech
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/engineering/tech/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to make sure the ship is operational, you should firstly focus on manning the
requisitions line and later on to be ready to send supplies for marines who are groundside."})


/datum/outfit/job/engineering/tech
	name = SHIP_TECH
	jobtype = /datum/job/terragov/engineering/tech

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/st
	w_uniform = /obj/item/clothing/under/marine/officer/engi
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	glasses = /obj/item/clothing/glasses/welding/flipped
	head = /obj/item/clothing/head/tgmccap/req
	r_store = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/marine/satchel



/datum/job/terragov/requisitions
	job_category = JOB_CAT_REQUISITIONS
	selection_color = "#BAAFD9"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_REQUISITIONS


//Requisitions Officer
/datum/job/terragov/requisitions/officer
	title = REQUISITIONS_OFFICER
	req_admin_notify = TRUE
	paygrade = "CPO"
	comm_title = "RO"
	selection_color = "#9990B2"
	total_positions = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/RO
	display_order = JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER
	outfit = /datum/outfit/job/requisitions/officer
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/requisitions/officer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to dispense supplies to the marines, including weapon attachments.
Your cargo techs can help you out, but you have final say in your department. Make sure they're not goofing off.
While you may request paperwork for supplies, do not go out of your way to screw with marines, unless you want to get deposed.
A happy ship is a well-functioning ship."})


/datum/outfit/job/requisitions/officer
	name = REQUISITIONS_OFFICER
	jobtype = /datum/job/terragov/requisitions/officer

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m44/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/rank/ro_suit
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/tgmccap/req
	l_store = /obj/item/supplytablet
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/terragov/medical
	job_category = JOB_CAT_MEDICAL
	selection_color = "#BBFFBB"
	exp_type_department = EXP_TYPE_MEDICAL


/datum/job/terragov/medical/professor
	title = CHIEF_MEDICAL_OFFICER
	req_admin_notify = TRUE
	comm_title = "CMO"
	paygrade = "O3"
	total_positions = 1
	supervisors = "the acting captain"
	selection_color = "#99FF99"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/CMO
	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	outfit = /datum/outfit/job/medical/professor
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/medical/professor/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are the chief medical officer aboard the [SSmapping.configs[SHIP_MAP].map_name], navy officer and supervisor to the medical department.
You have final authority over the medical department, medications, and treatments.
Make sure that the doctors and nurses are doing their jobs and keeping the marines healthy and strong."})


/datum/outfit/job/medical/professor
	name = CHIEF_MEDICAL_OFFICER
	jobtype = /datum/job/terragov/medical/professor

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/medical
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/rank/marine_cmo
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/cmo
	suit_store = /obj/item/flashlight/pen
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pouch/medical/full
	back = /obj/item/storage/backpack/marine/satchel


//Medical Officer
/datum/job/terragov/medical/medicalofficer
	title = MEDICAL_OFFICER
	comm_title = "MO"
	paygrade = "O1"
	total_positions = 6
	supervisors = "the chief medical officer"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/doctor
	display_order = JOB_DISPLAY_ORDER_DOCTOR
	outfit = /datum/outfit/job/medical/medicalofficer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)

/datum/job/terragov/medical/medicalofficer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are a military doctor stationed aboard the [SSmapping.configs[SHIP_MAP].map_name].
You are tasked with keeping the marines healthy and strong, usually in the form of surgery.
You are also an expert when it comes to medication and treatment. If you do not know what you are doing, adminhelp so a mentor can assist you."})


/datum/outfit/job/medical/medicalofficer
	name = MEDICAL_OFFICER
	jobtype = /datum/job/terragov/medical/medicalofficer

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/medical
	ears = /obj/item/radio/headset/mainship/doc
	w_uniform = /obj/item/clothing/under/rank/medical/green
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/surgery/green
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pouch/medical/full
	back = /obj/item/storage/backpack/marine/satchel


//Researcher
/datum/job/terragov/medical/researcher
	title = MEDICAL_RESEARCHER
	comm_title = "Rsr"
	paygrade = "CD"
	total_positions = 2
	supervisors = "the NT corporate office"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/doctor
	display_order = JOB_DISPLAY_ORDER_MEDIAL_RESEARCHER
	outfit = /datum/outfit/job/medical/researcher
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/medical/researcher/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are a civilian, working for the Nanotrasen Corporation, and are not subject to the military chain of command.
You are tasked with researching and developing new medical treatments, weapons, conducting xenomorph studies, and learning new things.
Your role involves some roleplaying and gimmickry, but you can perform the function of a regular doctor.
While the Corporate Liaison is not your boss, it would be wise to consult them on your findings or ask to use their NT fax machine."})


/datum/outfit/job/medical/researcher
	name = MEDICAL_RESEARCHER
	jobtype = /datum/job/terragov/medical/researcher

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/medical
	ears = /obj/item/radio/headset/mainship/doc
	w_uniform = /obj/item/clothing/under/marine/officer/researcher
	wear_suit = /obj/item/clothing/suit/storage/labcoat/researcher
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	suit_store = /obj/item/flashlight/pen
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pouch/medical/full
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/terragov/civilian
	job_category = JOB_CAT_CIVILIAN
	selection_color = "#ffeedd"


//Liaison
/datum/job/terragov/civilian/liaison
	title = CORPORATE_LIAISON
	paygrade = "NT"
	comm_title = "CL"
	supervisors = "the NT corporate office"
	total_positions = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	outfit = /datum/outfit/job/civilian/liaison
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/civilian/liaison/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"As a representative of Nanotrasen Corporation you are expected to stay professional and loyal to the corporation at all times.
You are not required to follow military orders; however, you cannot give military orders.
Your primary job is to observe and report back your findings to Nanotrasen. Follow regular game rules unless told otherwise by your superiors.
Use your office fax machine to communicate with corporate headquarters or to acquire new directives. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal."})


/datum/outfit/job/civilian/liaison
	name = CORPORATE_LIAISON
	jobtype = /datum/job/terragov/civilian/liaison

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/liaison_suit
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/terragov/silicon
	job_category = JOB_CAT_SILICON
	selection_color = "#aaee55"


//Synthetic
/datum/job/terragov/silicon/synthetic
	title = SYNTHETIC
	req_admin_notify = TRUE
	comm_title = "Syn"
	supervisors = "the acting captain"
	total_positions = 1
	skills_type = /datum/skills/synthetic
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	display_order = JOB_DISPLAY_ORDER_SYNTHETIC
	outfit = /datum/outfit/job/civilian/synthetic
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/silicon/synthetic/get_special_name(client/preference_source)
	return preference_source.prefs.synthetic_name

/datum/job/terragov/silicon/synthetic/return_spawn_type(datum/preferences/prefs)
	if(prefs && prefs.synthetic_type == "Early Synthetic")
		return /mob/living/carbon/human/species/synthetic/old
	return /mob/living/carbon/human/species/synthetic

/datum/job/terragov/silicon/synthetic/return_skills_type(datum/preferences/prefs)
	if(prefs && prefs.synthetic_type == "Early Synthetic")
		return /datum/skills/early_synthetic
	return ..()

/datum/job/terragov/silicon/synthetic/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your primary job is to support and assist all TGMC Departments and Personnel on-board.
In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship.
As a Synthetic you answer to the acting captain. Special circumstances may change this!"})


/datum/outfit/job/civilian/synthetic
	name = SYNTHETIC
	jobtype = /datum/job/terragov/silicon/synthetic

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/rank/synthetic
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/yellow
	r_store = /obj/item/storage/pouch/general/medium
	l_store = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/terragov/silicon/ai
	title = SILICON_AI
	job_category = JOB_CAT_SILICON
	req_admin_notify = TRUE
	comm_title = "AI"
	total_positions = 1
	selection_color = "#92c255"
	supervisors = "your laws"
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	exp_type_department = EXP_TYPE_SILICON
	display_order = JOB_DISPLAY_ORDER_AI
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE, /datum/job/terragov/squad/specialist = SPEC_POINTS_REGULAR, /datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR)


/datum/job/terragov/silicon/ai/get_special_name(client/preference_source)
	return preference_source.prefs.ai_name


/datum/job/terragov/silicon/ai/return_spawn_type(datum/preferences/prefs)
	return /mob/living/silicon/ai


/datum/job/terragov/silicon/ai/announce(mob/living/announced_mob)
	. = ..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "[announced_mob] has been downloaded to an empty bluespace-networked AI core at [AREACOORD(announced_mob)]."))


/datum/job/terragov/silicon/ai/config_check()
	return CONFIG_GET(flag/allow_ai)

// Silicons only need a very basic preview since there is no customization for them.
/datum/job/terragov/silicon/ai/handle_special_preview(client/parent)
	parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = "ai", dir = SOUTH))
	return TRUE
