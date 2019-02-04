var/datum/announcement/minor/captain_announcement = new(do_newscast = 1)

/datum/job/command
	department_flag = ROLEGROUP_MARINE_COMMAND
	selection_color = "#ddddff"
	supervisors = "the acting commander"
	idtype = /obj/item/card/id/silver
	total_positions = 1
	spawn_positions = 1
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT


//Commander
/datum/job/command/commander
	title = "Commander"
	comm_title = "CO"
	paygrade = "O5"
	flag = ROLE_COMMANDING_OFFICER
	supervisors = "TGMC high command"
	selection_color = "#ccccff"
	idtype = /obj/item/card/id/gold
	minimal_player_age = 7
	skills_type = /datum/skills/commander
	equipment = TRUE
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY
	flags_whitelist = WHITELIST_COMMANDER

/datum/job/command/commander/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/command(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/techofficer/commander(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/tan(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/mateba/cmateba/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), SLOT_L_HAND)

/datum/job/command/commander/generate_entry_message()
		return {"As the commander of the [MAIN_SHIP_NAME] you are held by higher standard and are expected to act competently.
While you may support Nanotrasen, you report to the TGMC High Command, not the corporate office.
Your primary task is the safety of the ship and her crew, and ensuring the survival and success of the marines.
Your first order of business should be briefing the marines on the mission they are about to undertake.
If you require any help, use adminhelp to ask mentors about what you're supposed to do.
Godspeed, commander! And remember, you are not above the law."}

/datum/job/command/commander/announce_entry_message(mob/living/carbon/human/H)
	. = ..()
	sleep(15)
	if(H?.loc && flags_startup_parameters & ROLE_ADD_TO_MODE)
		captain_announcement.Announce("All hands, Commander [H.real_name] on deck!")


//Event version
/datum/job/command/commander/nightmare
	flags_startup_parameters = ROLE_ADMIN_NOTIFY|ROLE_WHITELISTED

/datum/job/command/commander/nightmare/generate_entry_message()
		. = {"What the hell did you do to get assigned on this mission? Maybe someone is looking to bump you off for a promotion. Regardless...
The marines need a leader to inspire them and lead them to victory. You'll settle for telling them which side of the gun the bullets come from.
You are a vet, a real badass in your day, but now you're in the thick of it with the grunts. You're plenty sure they are going to die in droves.
Come hell or high water, you are going to be there for them."}


//Executive Officer
/datum/job/command/fieldofficer
	title = "Field Officer"
	comm_title = "FO"
	paygrade = "MAJ"
	flag = ROLE_FIELD_OFFICER
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY
	skills_type = /datum/skills/FO
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	equipment = TRUE

/datum/job/command/executive/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/field(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), SLOT_L_HAND)

/datum/job/command/executive/generate_entry_message(mob/living/carbon/human/H)
		. = {"You are charged with overseeing the operation on the ground, and are in next in the chain of command after the commander.
Your duties are to ensure marines hold when ordered, and push when they are cowering behind barricades. 
Do not ask your men to do anything you would not do side by side with them.
Make the TGMC proud!"}


//Staff Officer
/datum/job/command/bridge
	title = "Staff Officer"
	disp_title = "Staff Officer"
	comm_title = "SO"
	paygrade = "O3"
	flag = ROLE_BRIDGE_OFFICER
	total_positions = 5
	spawn_positions = 5
	scaled = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/SO
	equipment = TRUE

/datum/job/command/bridge/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/bridge(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/ro(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/commander(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/device/binoculars(H), SLOT_L_HAND)

/datum/job/command/bridge/set_spawn_positions(var/count)
	spawn_positions = so_slot_formula(count)

/datum/job/command/bridge/get_total_positions(var/latejoin = 0)
	return (latejoin ? so_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/command/bridge/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to monitor the marines, man the CIC, and listen to your superior officers.
You are in charge of logistics and the overwatch system."}


//Pilot Officer
/datum/job/command/pilot
	title = "Pilot Officer"
	comm_title = "PO"
	paygrade = "WO"
	flag = ROLE_PILOT_OFFICER
	total_positions = 4
	spawn_positions = 4
	scaled = 1
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/pilot
	equipment = TRUE

/datum/job/command/pilot/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/pilot(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest/pilot(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/pilot(H), SLOT_R_HAND)

/datum/job/command/pilot/set_spawn_positions(var/count)
	spawn_positions = po_slot_formula(count)

/datum/job/command/pilot/get_total_positions(var/latejoin = 0)
	return (latejoin ? po_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/command/pilot/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to fly, protect, and maintain the ship's dropship.
While you are a warrant officer, your authority is limited to the dropship, where you have authority over the enlisted personnel.
If you are not piloting, there is an autopilot fallback for command, but don't leave the dropship without reason."}


//Tank Crewmen
/datum/job/command/tank_crew
	title = "Tank Crewman"
	comm_title = "TC"
	paygrade = "E7"
	flag = ROLE_TANK_OFFICER
	total_positions = 2
	spawn_positions = 2
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_TANK)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_TANK)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/tank_crew
	idtype = /obj/item/card/id/dogtag
	equipment = TRUE

/datum/job/command/tank_crew/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/tanker(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/M3P/tanker(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/tanker(H), SLOT_R_HAND)

/datum/job/command/tank_crew/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to operate and maintain the ship's armored vehicles.
While you are a senior NCO, your authority is limited to your own vehicle, where you have authority over the enlisted personnel. You will need MTs to repair and replace hardpoints."}


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
	equipment = TRUE

/datum/job/command/police/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mmpo(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/red(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/mp(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/satchel/sec(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/security/MP/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(H), SLOT_GLASSES)

/datum/job/command/police/set_spawn_positions(var/count)
	spawn_positions = mp_slot_formula(count)

/datum/job/command/police/get_total_positions(var/latejoin = 0)
	return (latejoin ? mp_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/command/police/generate_entry_message(mob/living/carbon/human/H)
	return {"You are held by a higher standard and are required to not abuse your position to severely hinder the progress of the round.
Failure to do so may result in a job ban.
Your primary job is to uphold the <a href='https://tgstation13.org/wiki/TGMC:Military_Law'>Military Law</a>, and peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"}


//Chief MP
/datum/job/command/warrant
	title = "Chief MP"
	comm_title = "CMP"
	paygrade = "E9"
	flag = ROLE_CHIEF_MP
	selection_color = "#ffaaaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_BRIG, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_WO)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CMP
	equipment = TRUE

/datum/job/command/warrant/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/cmpcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cmberet/wo(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/warrant(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/MP/WO(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/security(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/security/MP/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/sechud(H), SLOT_GLASSES)

/datum/job/command/warrant/generate_entry_message(mob/living/carbon/human/H)
	return {"You are held by a higher standard and are required to not abuse your position to severely hinder the progress of the round.
Failure to do so may result in a job ban.
You lead the Military Police, ensure your officers uphold the <a href='https://tgstation13.org/wiki/TGMC:Military_Law'>Military Law</a>,, and maintain peace and stability aboard the ship. Marines can get rowdy after a few weeks of cryosleep!
In addition, you are tasked with the security of high-ranking personnel, including the command staff. Keep them safe!"}


//The logistics branch
/datum/job/logistics
	supervisors = "the acting commander"
	total_positions = 1
	spawn_positions = 1
	idtype = /obj/item/card/id/silver
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

//Chief Engineer
/datum/job/logistics/engineering
	title = "Chief Engineer"
	comm_title = "CE"
	paygrade = "O4"
	flag = ROLE_CHIEF_ENGINEER
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	selection_color = "#ffeeaa"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LOGISTICS, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_LOGISTICS, ACCESS_CIVILIAN_ENGINEERING)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CE
	equipment = TRUE

/datum/job/logistics/engineering/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to maintain the ship's engine and keep everything running.
If you have no idea how to set up the engine, or it's your first time, adminhelp so that a mentor can assist you.
You are also next in the chain of command, should the bridge crew fall in the line of duty."}

/datum/job/logistics/engineering/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/ce(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel/tech(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/electronics(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)


//Requisitions Officer
/datum/job/logistics/requisition
	title = "Requisitions Officer"
	comm_title = "RO"
	paygrade = "CPO"
	flag = ROLE_REQUISITION_OFFICER
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	selection_color = "#9990B2"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/RO
	equipment = TRUE

/datum/job/logistics/requisition/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/ro_suit(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/req(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/gun/m44/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/large(H), SLOT_R_STORE)

/datum/job/logistics/requisition/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to dispense supplies to the marines, including weapon attachments.
Your cargo techs can help you out, but you have final say in your department. Make sure they're not goofing off.
While you may request paperwork for supplies, do not go out of your way to screw with marines, unless you want to get deposed.
A happy ship is a well-functioning ship."}


/datum/job/logistics/tech
	idtype = /obj/item/card/id


//Maintenance Tech
/datum/job/logistics/tech/maint
	title = "Maintenance Tech"
	comm_title = "MT"
	paygrade = "PO"
	flag = ROLE_MAINTENANCE_TECH
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	scaled = 1
	supervisors = "the chief engineer"
	selection_color = "#fff5cc"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/MT
	equipment = TRUE

/datum/job/logistics/tech/maint/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mt(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/engi(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/tool/weldpack(H), SLOT_L_HAND)

/datum/job/logistics/tech/maint/set_spawn_positions(var/count)
	spawn_positions = mt_slot_formula(count)

/datum/job/logistics/tech/maint/get_total_positions(var/latejoin = 0)
	return (latejoin ? mt_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/logistics/tech/maint/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to make sure the ship is clean and the powergrid is operational.
Start with the ship's engine."}


//Cargo Tech
/datum/job/logistics/tech/cargo
	title = "Cargo Technician"
	comm_title = "CT"
	paygrade = "PO"
	flag = ROLE_REQUISITION_TECH
	department_flag = ROLEGROUP_MARINE_ENGINEERING
	total_positions = 2
	spawn_positions = 2
	scaled = 1
	supervisors = "the requisitions officer"
	selection_color = "#BAAFD9"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CARGO)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CT
	equipment = TRUE

/datum/job/logistics/tech/cargo/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/ct(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/beanie(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/pistol/large/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/clothing/tie/holster/m4a3(H), SLOT_ACCESSORY)

/datum/job/logistics/tech/cargo/set_spawn_positions(var/count)
	spawn_positions = ct_slot_formula(count)

/datum/job/logistics/tech/cargo/get_total_positions(var/latejoin = 0)
	return (latejoin ? ct_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/logistics/tech/cargo/generate_entry_message(mob/living/carbon/human/H)
	return {"Your job is to dispense supplies to the marines, including weapon attachments.
Stay in your department when possible to ensure the marines have full access to the supplies they may require.
Listen to the radio in case someone requests a supply drop via the overwatch system."}

/datum/job/medical
	department_flag = ROLEGROUP_MARINE_MED_SCIENCE
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT


/datum/job/medical/professor
	title = "Chief Medical Officer"
	comm_title = "CMO"
	paygrade = "CCMO"
	flag = ROLE_CHIEF_MEDICAL_OFFICER
	total_positions = 1
	spawn_positions = 1
	supervisors = "the acting commander"
	selection_color = "#99FF99"
	idtype = /obj/item/card/id/silver
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/CMO
	equipment = TRUE

/datum/job/medical/professor/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/cmo(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/green(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/surgery/green(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), SLOT_WEAR_SUIT)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/medical(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H), SLOT_L_HAND)
	H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), SLOT_S_STORE)


/datum/job/medical/professor/generate_entry_message()
	return {"You are a civilian, and are not subject to follow military chain of command, but you do work for the TGMC.
You have final authority over the medical department, medications, and treatments.
Make sure that the doctors and nurses are doing their jobs and keeping the marines healthy and strong."}


//Doctor
/datum/job/medical/doctor
	title = "Doctor"
	comm_title = "Doc"
	paygrade = "CD"
	flag = ROLE_CIVILIAN_DOCTOR
	total_positions = 6
	spawn_positions = 6
	scaled = 1
	supervisors = "the chief medical officer"
	selection_color = "#BBFFBB"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/doctor
	equipment = TRUE

/datum/job/medical/doctor/generate_equipment(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/doc(H), SLOT_EARS)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical/green(H), SLOT_W_UNIFORM)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(H), SLOT_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(H), SLOT_WEAR_MASK)
	H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), SLOT_GLASSES)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/surgery/green(H), SLOT_HEAD)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
	H.equip_to_slot_or_del(new /obj/item/storage/belt/medical(H), SLOT_BELT)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit(H), SLOT_R_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), SLOT_L_STORE)
	H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H), SLOT_L_HAND)

/datum/job/medical/doctor/set_spawn_positions(var/count)
	spawn_positions = doc_slot_formula(count)

/datum/job/medical/doctor/get_total_positions(var/latejoin = 0)
	return (latejoin ? doc_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/medical/doctor/generate_entry_message(mob/living/carbon/human/H)
	return {"You are a civilian, and are not subject to follow military chain of command, but you do work for the TGMC.
You are tasked with keeping the marines healthy and strong, usually in the form of surgery.
You are also an expert when it comes to medication and treatment. If you do not know what you are doing, adminhelp so a mentor can assist you."}


//Researcher
/datum/job/medical/researcher
	title = "Researcher"
	disp_title = "Medical Researcher"
	comm_title = "Rsr"
	paygrade = "CD"
	flag = ROLE_CIVILIAN_RESEARCHER
	total_positions = 2
	spawn_positions = 2
	scaled = 1
	supervisors = "chief medical officer"
	selection_color = "#BBFFBB"
	access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/doctor
	equipment = TRUE

/datum/job/medical/researcher/generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/doc(H), SLOT_EARS)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/researcher(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/latex(H), SLOT_GLOVES)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(H), SLOT_WEAR_MASK)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(H), SLOT_GLASSES)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/researcher(H), SLOT_WEAR_SUIT)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
		H.equip_to_slot_or_del(new /obj/item/storage/belt/medical(H), SLOT_BELT)
		H.equip_to_slot_or_del(new /obj/item/storage/pouch/medkit(H), SLOT_R_STORE)
		H.equip_to_slot_or_del(new /obj/item/storage/pouch/medical/full(H), SLOT_L_STORE)
		H.equip_to_slot_or_del(new /obj/item/storage/firstaid/adv(H), SLOT_L_HAND)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), SLOT_S_STORE)

/datum/job/medical/researcher/set_spawn_positions(var/count)
	spawn_positions = rsc_slot_formula(count)

/datum/job/medical/researcher/get_total_positions(var/latejoin = 0)
	return (latejoin ? rsc_slot_formula(get_total_marines()) : spawn_positions)

/datum/job/medical/researcher/generate_entry_message(mob/living/carbon/human/H)
	return {"You are a civilian, and are not subject to follow military chain of command, but you do work for the TGMC.
You are tasked with researching and developing new medical treatments, helping your fellow doctors, and generally learning new things.
Your role involves some roleplaying and gimmickry, but you can perform the function of a regular doctor."}


//Liaison
/datum/job/civilian/liaison
	title = "Corporate Liaison"
	comm_title = "CL"
	paygrade = "NT"
	flag = ROLE_CORPORATE_LIAISON
	department_flag = ROLEGROUP_MARINE_COMMAND
	total_positions = 1
	spawn_positions = 1
	supervisors = "the NT corporate office"
	selection_color = "#ffeedd"
	access = list(ACCESS_IFF_MARINE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_IFF_MARINE, ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	idtype = /obj/item/card/id/silver
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	skills_type = /datum/skills/civilian
	equipment = TRUE

/datum/job/civilian/liaison/generate_entry_conditions(mob/living/carbon/human/H)
		if(ticker && H.mind) ticker.liaison = H.mind //TODO Look into CL tracking in game mode.

/datum/job/civilian/liaison/generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/liaison_suit(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)

/datum/job/civilian/liaison/generate_entry_message(mob/living/carbon/human/H)
		return {"As a representative of Nanotrasen Corporation you are expected to stay professional and loyal to the corporation at all times.
You are not required to follow military orders; however, you cannot give military orders.
Your primary job is to observe and report back your findings to Nanotrasen. Follow regular game rules unless told otherwise by your superiors.
Use your office fax machine to communicate with corporate headquarters or to acquire new directives. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal."}


//Nightmare event verison
/datum/job/civilian/liaison/nightmare
	access = list(ACCESS_IFF_PMC, ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE)
	minimal_access = list(ACCESS_IFF_PMC, ACCESS_NT_PMC_GREEN, ACCESS_NT_PMC_ORANGE, ACCESS_NT_PMC_RED, ACCESS_NT_PMC_BLACK, ACCESS_NT_PMC_WHITE, ACCESS_NT_CORPORATE)
	flags_startup_parameters = NOFLAGS

/datum/job/civilian/liaison/nightmare/generate_entry_message(mob/living/carbon/human/H)
		return {"It was just a regular day in the office when the higher up decided to send you in to this hot mess. If only you called in sick that day...
The NT mercs were hired to protect some important science experiment, and NT expects you to keep them in line.
These are hardened killers, and you write on paper for a living. It won't be easy, that's for damn sure.
Best to let the mercs do the killing and the dying, but remind them who pays the bills."}


/datum/job/civilian/synthetic
	title = "Synthetic"
	comm_title = "Syn"
	paygrade = "???"
	flag = ROLE_SYNTHETIC
	department_flag = ROLEGROUP_MARINE_COMMAND
	total_positions = 1
	spawn_positions = 1
	supervisors = "the acting commander"
	selection_color = "#aaee55"
	idtype = /obj/item/card/id/gold
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE|ROLE_ADMIN_NOTIFY
	flags_whitelist = WHITELIST_SYNTHETIC
	skills_type = /datum/skills/synthetic
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	equipment = TRUE

/datum/job/civilian/synthetic/generate_entry_conditions(mob/living/carbon/human/H)
	. = ..()
	H.set_species(H.client.prefs.synthetic_type)
	if(H.client.prefs.synthetic_type == "Early Synthetic")
		skills_type = /datum/skills/early_synthetic
	//Most of the code below is copypasted from transform_predator().
	if(!H.client.prefs)
		H.client.prefs = new /datum/preferences(H.client) //Let's give them one.
	//They should have these set, but it's possible they don't have them.
	H.real_name = H.client.prefs.synthetic_name
	if(!H.real_name || H.real_name == "Undefined") //In case they don't have a name set or no prefs, there's a name.
		H.real_name = "David"
		spawn(9)
			to_chat(H, "<span class='warning'>You forgot to set your name in your preferences. Please do so next time.</span>")
	H.mind.name = H.real_name
	//update id with new name
	if(H.wear_id)
		var/obj/item/card/id/I = H.wear_id
		I.registered_name = H.real_name
		I.name = "[I.registered_name]'s ID Card ([I.assignment])"
	H.name = H.get_visible_name()

/datum/job/civilian/synthetic/generate_equipment(mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/almayer/mcom(H), SLOT_EARS)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/synthetic(H), SLOT_W_UNIFORM)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), SLOT_GLOVES)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), SLOT_SHOES)
		H.equip_to_slot_or_del(new /obj/item/storage/backpack/marine/satchel(H), SLOT_BACK)
		H.equip_to_slot_or_del(new /obj/item/storage/belt/utility/full(H), SLOT_BELT)
		H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(H), SLOT_R_STORE)
		H.equip_to_slot_or_del(new /obj/item/storage/pouch/general/medium(H), SLOT_L_STORE)

/datum/job/civilian/synthetic/generate_entry_message()
		return {"You are a Synthetic!
Your primary job is to support and assist all TGMC Departments and Personnel on-board.
In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship.
As a Synthetic you answer to the acting commander. Special circumstances may change this!"}
