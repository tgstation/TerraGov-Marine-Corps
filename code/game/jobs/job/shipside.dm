/datum/job/command
	department_flag = J_FLAG_SHIP
	selection_color = "#ddddff"
	supervisors = "the acting captain"
	faction = "Marine"
	spawn_positions = 1
	total_positions = 1


//Captain
/datum/job/command/captain
	title = "Captain"
	paygrade = "O6"
	comm_title = "CPT"
	flag = SHIP_CO
	prefflag = PREF_JOB_CO
	supervisors = "TGMC high command"
	selection_color = "#ccccff"
	skills_type = /datum/skills/captain
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	outfit = /datum/outfit/job/command/captain


/datum/job/command/captain/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"As the captain of the [CONFIG_GET(string/ship_name)] you are held by higher standard and are expected to act competently.
While you may support Nanotrasen, you report to the TGMC High Command, not the corporate office.
Your primary task is the safety of the ship and her crew, and ensuring the survival and success of the marines.
Your first order of business should be briefing the marines on the mission they are about to undertake.
If you require any help, use adminhelp to ask mentors about what you're supposed to do.
Godspeed, captain! And remember, you are not above the law."})


/datum/outfit/job/command/captain
	name = "Captain"
	jobtype = /datum/job/command/captain

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/gun/mateba/cmateba/full
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/command
	shoes = /obj/item/clothing/shoes/marinechief/captain
	gloves = /obj/item/clothing/gloves/marine/techofficer/captain
	head = /obj/item/clothing/head/tgmcberet/tan
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/device/binoculars/tactical
	back = /obj/item/storage/backpack/marine/satchel


//Field Commander
/datum/job/command/fieldcommander
	title = "Field Commander"
	paygrade = "MO4"
	comm_title = "FCDR"
	flag = SHIP_XO
	prefflag = PREF_JOB_FC
	skills_type = /datum/skills/FO
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER
	outfit = /datum/outfit/job/command/fieldcommander


/datum/job/command/fieldcommander/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are charged with overseeing the operation on the ground, and are the highest-ranked deployed marine.
Your dutiesare to ensure marines hold when ordered, and push when they are cowering behind barricades.
Do not ask your men to do anything you would not do side by side with them.
Make the TGMC proud!"})


/datum/outfit/job/command/fieldcommander
	name = "Field Commander"
	jobtype = /datum/job/command/fieldcommander

	id = /obj/item/card/id/dogtag
	belt = /obj/item/storage/belt/gun/m4a3/fieldcommander/
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/exec
	wear_suit = /obj/item/clothing/suit/storage/marine/smartgunner/fancy
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/tgmcberet/fc
	r_store = /obj/item/storage/pouch/general/large/command
	l_store = /obj/item/device/megaphone
	back = /obj/item/smartgun_powerpack/fancy
	suit_store = /obj/item/weapon/gun/smartgun


//Intelligence Officer
/datum/job/command/intelligenceofficer
	title = "Intelligence Officer"
	paygrade = "O3"
	comm_title = "IO"
	flag = SHIP_SO
	prefflag = PREF_JOB_SO
	spawn_positions = 4
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	skills_type = /datum/skills/SO
	display_order = JOB_DISPLAY_ORDER_STAFF_OFFICER
	outfit = /datum/outfit/job/command/intelligenceofficer


/datum/job/command/intelligenceofficer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to monitor the marines, man the CIC, and listen to your superior officers.
You are in charge of logistics and the overwatch system. You are also in line to take command after the captain."})


/datum/outfit/job/command/intelligenceofficer
	name = "Intelligence Officer"
	jobtype = /datum/job/command/intelligenceofficer

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/captain
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/bridge
	shoes = /obj/item/clothing/shoes/marine
	head = /obj/item/clothing/head/tgmccap/ro
	r_store = /obj/item/storage/pouch/general/large
	l_store = /obj/item/device/binoculars/tactical
	back = /obj/item/storage/backpack/marine/satchel


//Pilot Officer
/datum/job/command/pilot
	title = "Pilot Officer"
	paygrade = "WO"
	comm_title = "PO"
	flag = SHIP_PO
	prefflag = PREF_JOB_PO
	spawn_positions = 4
	total_positions = 4
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PILOT)
	skills_type = /datum/skills/pilot
	display_order = JOB_DISPLAY_ORDER_PILOT_OFFICER
	outfit = /datum/outfit/job/command/pilot


/datum/job/command/pilot/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to fly, protect, and maintain the ship's dropship.
While you are a warrant officer, your authority is limited to the dropship, where you have authority over the enlisted personnel.
If you are not piloting, there is an autopilot fallback for command, but don't leave the dropship without reason."})


/datum/outfit/job/command/pilot
	name = "Pilot Officer"
	jobtype = /datum/job/command/pilot

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/pilot
	wear_suit = /obj/item/clothing/suit/armor/vest/pilot
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/helmet/marine/pilot
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel


//Tank Crewmen
/datum/job/command/tank_crew
	title = "Tank Crewman"
	paygrade = "E7"
	comm_title = "TC"
	flag = SHIP_TC
	prefflag = PREF_JOB_TC
	spawn_positions = 2
	total_positions = 2
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_TANK)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_TANK)
	skills_type = /datum/skills/tank_crew
	display_order = JOB_DISPLAY_ORDER_TANK_CREWMAN
	outfit = /datum/outfit/job/command/tank_crew


/datum/job/command/tank_crew/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to operate and maintain the ship's armored vehicles.
Your authority is limited to your own vehicle, but you are next in line on the field, after the field commander.
You could use MTs help to repair and replace hardpoints."})



/datum/outfit/job/command/tank_crew
	name = "Tank Crewman"
	jobtype = /datum/job/command/tank_crew

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m4a3/vp70
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/tanker
	wear_suit = /obj/item/clothing/suit/storage/marine/M3P/tanker
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/helmet/marine/tanker
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel


//Military Police
/datum/job/command/masteratarms
	title = "Master at Arms"
	paygrade = "PO"
	comm_title = "MA"
	flag = SHIP_MP
	prefflag = PREF_JOB_MP
	spawn_positions = 5
	total_positions = 5
	selection_color = "#ffdddd"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	skills_type = /datum/skills/MP
	display_order = JOB_DISPLAY_ORDER_MILITARY_POLICE
	outfit = /datum/outfit/job/command/masteratarms


/datum/job/command/masteratarms/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are held by a higher standard and are required to not abuse your position to severely hinder the progress of the round.
Failure to do so may result in a job ban.
Your primary job is to uphold the <a href='https://tgstation13.org/wiki/TGMC:Military_Law'>Military Law</a>, and peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"})



/datum/outfit/job/command/masteratarms
	name = "Master at Arms"
	jobtype = /datum/job/command/masteratarms

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/security/MP/full
	ears = /obj/item/device/radio/headset/almayer/mmpo
	w_uniform = /obj/item/clothing/under/marine/mp
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	glasses = /obj/item/clothing/glasses/sunglasses/sechud
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/tgmcberet/red
	r_store = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/satchel/sec


//Command Master at Arms
/datum/job/command/commandmasteratarms
	title = "Command Master at Arms"
	paygrade = "O3"
	comm_title = "CMA"
	flag = SHIP_CMP
	prefflag = PREF_JOB_CMP
	selection_color = "#ffaaaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	skills_type = /datum/skills/CMP
	display_order = JOB_DISPLAY_ORDER_CHIEF_MP
	outfit = /datum/outfit/job/command/warrant


/datum/job/command/commandmasteratarms/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are held by a higher standard and are required to not abuse your position to severely hinder the progress of the round.
Failure to do so may result in a job ban.
You lead the Military Police, ensure your officers uphold the <a href='https://tgstation13.org/wiki/TGMC:Military_Law'>Military Law</a>,, and maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"})



/datum/outfit/job/command/warrant
	name = "Command Master at Arms"
	jobtype = /datum/job/command/commandmasteratarms

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/security/MP/full
	ears = /obj/item/device/radio/headset/almayer/cmpcom
	w_uniform = /obj/item/clothing/under/marine/officer/warrant
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	glasses = /obj/item/clothing/glasses/sunglasses/sechud
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/tgmcberet/wo
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/security



/datum/job/logistics
	department_flag = J_FLAG_SHIP
	supervisors = "the acting captain"
	spawn_positions = 1
	total_positions = 1
	faction = "Marine"


//Chief Ship Engineer
/datum/job/logistics/engineering
	title = "Chief Ship Engineer"
	paygrade = "O3"
	comm_title = "CSE"
	flag = SHIP_CE
	prefflag = PREF_JOB_CE
	selection_color = "#ffeeaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP)
	skills_type = /datum/skills/CE
	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	outfit = /datum/outfit/job/logistics/engineering


/datum/job/logistics/engineering/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to maintain the ship's engine and keep everything running.
If you have no idea how to set up the engine, or it's your first time, adminhelp so that a mentor can assist you.
You are also next in the chain of command, should the bridge crew fall in the line of duty."})


/datum/outfit/job/logistics/engineering
	name = "Chief Ship Engineer"
	jobtype = /datum/job/logistics/engineering

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/ce
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	glasses = /obj/item/clothing/glasses/welding
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/beret/marine/techofficer
	r_store = /obj/item/storage/pouch/electronics
	back = /obj/item/storage/backpack/marine/satchel/tech


//Requisitions Officer
/datum/job/logistics/requisition
	title = "Requisitions Officer"
	paygrade = "CPO"
	comm_title = "RO"
	flag = SHIP_RO
	prefflag = PREF_JOB_RO
	selection_color = "#9990B2"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	skills_type = /datum/skills/RO
	display_order = JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER
	outfit = /datum/outfit/job/logistics/requisition


/datum/job/logistics/requisition/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to dispense supplies to the marines, including weapon attachments.
Your cargo techs can help you out, but you have final say in your department. Make sure they're not goofing off.
While you may request paperwork for supplies, do not go out of your way to screw with marines, unless you want to get deposed.
A happy ship is a well-functioning ship."})


/datum/outfit/job/logistics/requisition
	name = "Requisitions Officer"
	jobtype = /datum/job/logistics/requisition

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/gun/m44/full
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/rank/ro_suit
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/tgmccap/req
	r_store = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/marine/satchel


//Ship Engineer
/datum/job/logistics/tech/maint
	title = "Ship Engineer"
	comm_title = "SE"
	paygrade = "PO"
	flag = SHIP_MT
	prefflag = PREF_JOB_MT
	spawn_positions = 4
	total_positions = 4
	supervisors = "the chief ship engineer"
	selection_color = "#fff5cc"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/MT
	display_order = JOB_DISPLAY_ORDER_MAINTENANCE_TECH
	outfit = /datum/outfit/job/logistics/tech/maint


/datum/job/logistics/tech/maint/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to make sure the ship is clean and the powergrid is operational.
Start with the ship's engine, and don't forget radiation equipment."})


/datum/outfit/job/logistics/tech/maint
	name = "Ship Engineer"
	jobtype = /datum/job/logistics/tech/maint

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/device/radio/headset/almayer/mt
	w_uniform = /obj/item/clothing/under/marine/officer/engi
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	glasses = /obj/item/clothing/glasses/welding
	head = /obj/item/clothing/head/tgmccap/req
	r_store = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/marine/satchel



//Cargo Tech
/datum/job/logistics/tech/cargo
	title = "Cargo Technician"
	paygrade = "PO"
	comm_title = "CT"
	flag = SHIP_CT
	prefflag = PREF_JOB_CT
	spawn_positions = 2
	total_positions = 2
	supervisors = "the requisitions officer"
	selection_color = "#BAAFD9"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO)
	skills_type = /datum/skills/CT
	display_order = JOB_DISPLAY_ORDER_CARGO_TECH
	outfit = /datum/outfit/job/logistics/tech/cargo


/datum/job/logistics/tech/cargo/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your job is to dispense supplies to the marines, including weapon attachments.
Stay in your department when possible to ensure the marines have full access to the supplies they may require.
Listen to the radio in case someone requests a supply drop via the overwatch system."})


/datum/outfit/job/logistics/tech/cargo
	name = "Cargo Technician"
	jobtype = /datum/job/logistics/tech/cargo

	id = /obj/item/card/id/silver
	belt = /obj/item/clothing/tie/holster/m4a3
	ears = /obj/item/device/radio/headset/almayer/ct
	w_uniform = /obj/item/clothing/under/rank/cargotech
	wear_suit = /obj/item/clothing/suit/storage/marine/MP
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/yellow
	head = /obj/item/clothing/head/beanie
	r_store = /obj/item/storage/pouch/general/medium
	l_store = /obj/item/storage/pouch/magazine/pistol/large/full
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/medical
	department_flag = J_FLAG_SHIP
	faction = "Marine"


/datum/job/medical/professor
	title = "Chief Medical Officer"
	comm_title = "CMO"
	paygrade = "O3"
	flag = SHIP_CMO
	prefflag = PREF_JOB_CMO
	spawn_positions = 1
	total_positions = 1
	supervisors = "the acting captain"
	selection_color = "#99FF99"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	skills_type = /datum/skills/CMO
	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	outfit = /datum/outfit/job/medical/professor


/datum/job/medical/professor/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are the chief medical officer aboard the Theseus, navy officer and supervisor to the medical department.
You have final authority over the medical department, medications, and treatments.
Make sure that the doctors and nurses are doing their jobs and keeping the marines healthy and strong."})


/datum/outfit/job/medical/professor
	name = "Chief Medical Officer"
	jobtype = /datum/job/medical/professor

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/medical
	ears = /obj/item/device/radio/headset/almayer/cmo
	w_uniform = /obj/item/clothing/under/rank/medical/green
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/surgery/green
	suit_store = /obj/item/device/flashlight/pen
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pouch/medical/full
	back = /obj/item/storage/backpack/marine/satchel


//Medical Officer
/datum/job/medical/medicalofficer
	title = "Medical Officer"
	comm_title = "MO"
	paygrade = "O1"
	flag = SHIP_DOCTOR
	prefflag = PREF_JOB_DOCTOR
	spawn_positions = 6
	total_positions = 6
	supervisors = "the chief medical officer"
	selection_color = "#BBFFBB"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	skills_type = /datum/skills/doctor
	display_order = JOB_DISPLAY_ORDER_DOCTOR
	outfit = /datum/outfit/job/medical/medicalofficer


/datum/job/medical/medicalofficer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are a military doctor stationed aboard the Theseus.
You are tasked with keeping the marines healthy and strong, usually in the form of surgery.
You are also an expert when it comes to medication and treatment. If you do not know what you are doing, adminhelp so a mentor can assist you."})


/datum/outfit/job/medical/medicalofficer
	name = "Medical Officer"
	jobtype = /datum/job/medical/medicalofficer

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/medical
	ears = /obj/item/device/radio/headset/almayer/doc
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
/datum/job/medical/researcher
	title = "Medical Researcher"
	comm_title = "Rsr"
	paygrade = "CD"
	spawn_positions = 2
	total_positions = 2
	supervisors = "the NT corporate office"
	selection_color = "#BBFFBB"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	flag = SHIP_RESEARCHER
	prefflag = PREF_JOB_RESEARCHER
	skills_type = /datum/skills/doctor
	display_order = JOB_DISPLAY_ORDER_MEDIAL_RESEARCHER
	outfit = /datum/outfit/job/medical/researcher


/datum/job/medical/researcher/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are a civilian, working for the Nanotrasen Corporation, and are not subject to the military chain of command.
You are tasked with researching and developing new medical treatments, weapons, conducting xenomorph studies, and learning new things.
Your role involves some roleplaying and gimmickry, but you can perform the function of a regular doctor.
While the Corporate Liaison is not your boss, it would be wise to consult them on your findings or ask to use their NT fax machine."})


/datum/outfit/job/medical/researcher
	name = "Medical Researcher"
	jobtype = /datum/job/medical/researcher

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/medical
	ears = /obj/item/device/radio/headset/almayer/doc
	w_uniform = /obj/item/clothing/under/marine/officer/researcher
	wear_suit = /obj/item/clothing/suit/storage/labcoat/researcher
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	suit_store = /obj/item/device/flashlight/pen
	r_store = /obj/item/storage/pouch/medkit/full
	l_store = /obj/item/storage/pouch/medical/full
	back = /obj/item/storage/backpack/marine/satchel


/datum/job/civilian
	department_flag = J_FLAG_SHIP
	spawn_positions = 1
	total_positions = 1
	faction = "Marine"


//Liaison
/datum/job/civilian/liaison
	title = "Corporate Liaison"
	paygrade = "NT"
	comm_title = "CL"
	flag = SHIP_CL
	prefflag = PREF_JOB_CL
	supervisors = "the NT corporate office"
	selection_color = "#ffeedd"
	access = list(ACCESS_IFF_MARINE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	outfit = /datum/outfit/job/civilian/liaison


/datum/job/civilian/liaison/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"As a representative of Nanotrasen Corporation you are expected to stay professional and loyal to the corporation at all times.
You are not required to follow military orders; however, you cannot give military orders.
Your primary job is to observe and report back your findings to Nanotrasen. Follow regular game rules unless told otherwise by your superiors.
Use your office fax machine to communicate with corporate headquarters or to acquire new directives. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal."})


/datum/outfit/job/civilian/liaison
	name = "Corporate Liaison"
	jobtype = /datum/job/civilian/liaison

	id = /obj/item/card/id/silver
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/liaison_suit
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack/marine/satchel


//Synthetic
/datum/job/civilian/synthetic
	title = "Synthetic"
	comm_title = "Syn"
	flag = SHIP_SYNTH
	prefflag = PREF_JOB_SYNTH
	supervisors = "the acting captain"
	selection_color = "#aaee55"
	skills_type = /datum/skills/synthetic
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	display_order = JOB_DISPLAY_ORDER_SYNTHETIC
	outfit = /datum/outfit/job/civilian/synthetic


/datum/job/civilian/synthetic/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, datum/outfit/outfit_override = null, client/preference_source)
	. = ..()
	if(!H)
		return FALSE
	if(preference_source?.prefs)
		H.set_species(preference_source.prefs.synthetic_type)
		if(preference_source.prefs.synthetic_type == "Early Synthetic")
			H.mind.cm_skills = new /datum/skills/early_synthetic
		H.real_name = preference_source.prefs.synthetic_name
	if(!H.real_name || H.real_name == "Undefined") //In case they don't have a name set or no prefs, there's a name.
		H.real_name = "David"
		to_chat(H, "<span class='warning'>You forgot to set your name in your preferences. Please do so next time.</span>")
	if(H.mind)
		H.mind.name = H.real_name
	if(H.wear_id)
		var/obj/item/card/id/I = H.wear_id
		I.registered_name = H.real_name
		I.update_label()
	H.name = H.get_visible_name()


/datum/job/civilian/synthetic/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your primary job is to support and assist all TGMC Departments and Personnel on-board.
In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship.
As a Synthetic you answer to the acting captain. Special circumstances may change this!"})


/datum/outfit/job/civilian/synthetic
	name = "Synthetic"
	jobtype = /datum/job/civilian/synthetic

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/device/radio/headset/almayer/mcom
	w_uniform = /obj/item/clothing/under/rank/synthetic
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/yellow
	r_store = /obj/item/storage/pouch/general/medium
	l_store = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/marine/satchel