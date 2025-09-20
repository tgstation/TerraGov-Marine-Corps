//officer roles
/datum/job/som/command
	job_category = JOB_CAT_COMMAND
	selection_color = "#ddddff"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_COMMAND
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

//General
/datum/job/som/command/commander
	title = SOM_COMMANDER
	req_admin_notify = TRUE
	paygrade = "SOM_O7"
	comm_title = "CMDR"
	supervisors = "SOM high command"
	selection_color = "#ccccff"
	total_positions = 1
	skills_type = /datum/skills/captain
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	outfit = /datum/outfit/job/som/command/commander
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP|JOB_FLAG_LOUDER_TTS
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to</b> SOM High Command<br /><br />
		<b>Unlock Requirement</b>: 15 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Lead the SOM forces and complete your mission. Support the marines and communicate with your command staff, execute orders.
	"}
	minimap_icon = "captain" //placeholder

/datum/job/som/command/commander/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As the senior officer in command of this SOM battalion you are held by higher standard and are expected to act competently.
Your primary task is to command and support the SOM marines under your command from the command center in [SSmapping.configs[SHIP_MAP].map_name].
Your first order of business should be briefing the marines on the mission they are about to undertake, and providing them with all the required attrition and asset support they need to succeed.
You should not be voluntarily leaving your base under any circumstances. You are a senior officer, not a field officer.
If you require any help, use <b>Mentorhelp</b> to ask mentors about what you're supposed to do.
Godspeed, Commander! And remember, you are not above the law."}

/datum/job/som/command/commander/after_spawn(mob/living/new_mob, mob/user, latejoin)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_O7"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_G1"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_G2"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_G3"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_G4"

//Field Commander
/datum/job/som/command/fieldcommander
	title = SOM_FIELD_COMMANDER
	req_admin_notify = TRUE
	paygrade = "SOM_O3"
	comm_title = "FCDR"
	total_positions = 1
	skills_type = /datum/skills/fo
	display_order = JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER
	outfit = /datum/outfit/job/som/command/fieldcommander
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP|JOB_FLAG_LOUDER_TTS
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> commanding officer<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Lead your platoon on the field. Take advantage of the military staff and assets you will need for the mission, keep good relations between command and the marines. Assist your commander if available.
	"}
	minimap_icon = "som_fieldcommander"

/datum/job/som/command/fieldcommander/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are charged with overseeing the operation on the ground, and are the highest-ranked deployed SOM marine.
Your duties are to ensure the SOM are following orders and achieving objectives.
Lead by example and support those under your command.
Make the SOM proud!"}

/datum/job/som/command/fieldcommander/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	SSdirection.set_leader(TRACKING_ID_SOM_COMMANDER, new_mob)
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_O3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_O4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_O5"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_O6"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_O7"


//Staff Officer
/datum/job/som/command/staffofficer
	title = SOM_STAFF_OFFICER
	paygrade = "SOM_W5"
	comm_title = "SO"
	total_positions = 4
	access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = ALL_MARINE_ACCESS
	skills_type = /datum/skills/so
	display_order = JOB_DISPLAY_ORDER_STAFF_OFFICER
	outfit = /datum/outfit/job/som/command/staffofficer
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Captain<br /><br />
		<b>Unlock Requirement</b>: 3 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Take charge of one of the four squads, be their eyes and ears providing intel and additional shipside support via Orbital Bombardments.
	"}

	minimap_icon = "staffofficer"

/datum/job/som/command/staffofficer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to monitor the SOM forces on the ground, man the CIC, and listen to your superior officers.
You are in charge of logistics and the overwatch system. You are also in line to take command after the senior officer."}

/datum/job/som/command/staffofficer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_W5"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_O1"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_O2"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_O3"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_O4"


//Pilot Officer
/datum/job/som/command/pilot
	title = SOM_PILOT_OFFICER
	paygrade = "SOM_W2"
	comm_title = "PO"
	total_positions = 2
	access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/pilot
	display_order = JOB_DISPLAY_ORDER_PILOT_OFFICER
	outfit = /datum/outfit/job/som/command/pilot
	exp_requirements = XP_REQ_INTERMEDIATE
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 3 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Choose between the Condor, a modular attack aircraft that provides close air support with a variety of weapons ranging from the inbuilt gatling to wing mounted rockets; or the Tadpole, a versatile dropship capable of fulfilling roles ranging from ambulance to mobile bunker.
	"}
	minimap_icon = "pilot"

/datum/job/som/command/pilot/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_W2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_W3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_W4"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_W5"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_W6"

/datum/job/som/command/pilot/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to support marines with either close air support via the Condor, or mobile dropship support with the Tadpole.\
While you are in charge of all aerial crafts the Alamo does not require supervision outside of turning automatic mode on or off at crucial times, and you are expected to choose between the Condor and Tadpole.
Though you are a warrant officer, your authority is limited to the dropship and your chosen aerial craft, where you have authority over the enlisted personnel."}

//Mech pilot
/datum/job/som/command/mech_pilot
	title = SOM_MECH_PILOT
	req_admin_notify = TRUE
	paygrade = "SOM_W1"
	comm_title = "MCH"
	total_positions = 0
	skills_type = /datum/skills/mech_pilot
	access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_MECH, ACCESS_CIVILIAN_PUBLIC)
	minimal_access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_MECH, ACCESS_CIVILIAN_PUBLIC, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	display_order = JOB_DISPLAY_ORDER_MECH_PILOT
	outfit = /datum/outfit/job/som/command/mech_pilot
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	job_points_needed = 80
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 15 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Act as the spearhead of the operation
	"}
	minimap_icon = "mech_pilot"

/datum/job/som/command/mech_pilot/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are the operator of a very expensive and valuable Mech, and are trained and expected to use it in the field of combat.
You can serve your Division in a variety of roles, so choose carefully."}

/datum/job/som/command/mech_pilot/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_W1"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_W2"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_W3"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_W4"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_W5"


/datum/job/som/engineering
	job_category = JOB_CAT_ENGINEERING
	selection_color = "#fff5cc"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_ENGINEERING


//Chief Ship Engineer
/datum/job/som/engineering/chief
	title = SOM_CHIEF_ENGINEER
	paygrade = "SOM_W2"
	comm_title = "CE"
	selection_color = "#ffeeaa"
	total_positions = 1
	access = list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/ce
	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	outfit = /datum/outfit/job/som/engineering/chief
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Supervise the engineers and technicians on duty. Overview the ship’s engine. Teach what’s right and what’s wrong about engineering, cut corners and find places in any FOB that can easily be destroyed.
	"}
	minimap_icon = "cse"

/datum/job/som/engineering/chief/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_W2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_W3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_W4"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_W5"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_W6"

/datum/job/som/engineering/chief/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to maintain the ship's engine and keep everything running.
If you have no idea how to set up the engine, or it's your first time, <b>Mentorhelp</b> so that a Mentor can assist you.
You are also next in the chain of command, should the bridge crew fall in the line of duty."}

//Ship Engineer
/datum/job/som/engineering/tech
	title = SOM_TECH
	comm_title = "TECH"
	paygrade = "SOM_E2"
	total_positions = 5
	supervisors = "the chief station engineer and the requisitions officer"
	access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	skills_type = /datum/skills/st
	display_order = JOB_DISPLAY_ORDER_SHIP_TECH
	outfit = /datum/outfit/job/som/engineering/tech
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Chief Ship Engineer<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Maintain the ship, be in charge of the engines. Be the secondary engineer to a forward operating base, prepare the shipside defenses if needed. Help the Pilot Officer in preparing the dropship.
	"}
	minimap_icon = "st"

/datum/job/som/engineering/tech/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_E2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_E3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_E4"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_E5"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_S1"

/datum/job/som/engineering/tech/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "Your job is to make sure the base is operational, you should firstly focus on manning the requisitions line and later on to be ready to send supplies for marines who are groundside."

/datum/job/som/requisitions
	job_category = JOB_CAT_REQUISITIONS
	selection_color = "#BAAFD9"
	supervisors = "the acting commander"
	exp_type_department = EXP_TYPE_REQUISITIONS


//Requisitions Officer
/datum/job/som/requisitions/officer
	title = SOM_REQUISITIONS_OFFICER
	req_admin_notify = TRUE
	paygrade = "SOM_W1"
	comm_title = "RO"
	selection_color = "#9990B2"
	total_positions = 1
	access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = list(ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	skills_type = /datum/skills/ro
	display_order = JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER
	outfit = /datum/outfit/job/som/requisitions/officer
	exp_requirements = XP_REQ_UNSEASONED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 1 hour playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		Supply the SOM with deluxe equipment to ensure success.
	"}
	minimap_icon = "requisition"

/datum/job/som/requisitions/officer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_W1"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_W2"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_W3"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_W4"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_W5"

/datum/job/som/requisitions/officer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to dispense supplies to the SOM.
While you may request paperwork for supplies, do not go out of your way to screw with marines, unless you want to get deposed.
A happy base is a well-functioning base."}

/datum/job/som/medical
	job_category = JOB_CAT_MEDICAL
	selection_color = "#BBFFBB"
	exp_type_department = EXP_TYPE_MEDICAL


/datum/job/som/medical/professor
	title = SOM_CHIEF_MEDICAL_OFFICER
	req_admin_notify = TRUE
	comm_title = "CMO"
	paygrade = "CHO"
	total_positions = 1
	supervisors = "the acting commander"
	selection_color = "#99FF99"
	access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	skills_type = /datum/skills/cmo
	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	outfit = /datum/outfit/job/som/medical/professor
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Communicate and lead your fellow medical staff (if available), supervise the medical department. Coordinate and teach fellow medical staff and corpsmen what they’re doing for treating an injury. Be the sole doctor in the Canterbury.
	"}
	minimap_icon = "chief_medical"

/datum/job/som/medical/professor/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are the chief medical officer stationed behind the frontlines and supervisor to the medical department.
You have final authority over the medical department, medications, and treatments.
Make sure that the doctors and nurses are doing their jobs and keeping the SOM healthy and strong."}

/datum/job/som/medical/professor/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 3000) // starting
			new_human.wear_id.paygrade = "CHO"
		if(3001 to INFINITY) // 50 hrs
			new_human.wear_id.paygrade = "CMO"


//Medical Officer
/datum/job/som/medical/medicalofficer
	title = SOM_MEDICAL_DOCTOR
	comm_title = "MD"
	paygrade = "RES"
	total_positions = 6
	supervisors = "the chief medical officer"
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/doctor
	display_order = JOB_DISPLAY_ORDER_DOCTOR
	outfit = /datum/outfit/job/som/medical/medicalofficer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Chief Medical Officer<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Tend severely wounded patients to your aid in the form of surgery, repair broken bones and damaged organs, fix internal bleeding and prevent the birth of a xenomorph larva. Develop superior healing medicines.
	"}
	minimap_icon = "medical"

/datum/job/som/medical/medicalofficer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 3000) // starting
			new_human.wear_id.paygrade = "RES"
		if(3001 to INFINITY) // 50 hrs
			new_human.wear_id.paygrade = "MD"

/datum/job/som/medical/medicalofficer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are a SOM medical doctor stationed behind the frontlines.
You are tasked with keeping the SOM healthy and strong, usually in the form of surgery.
You are also an expert when it comes to medication and treatment. If you do not know what you are doing, <b>mentorhelp</b> so a mentor can assist you."}

/datum/job/som/civilian
	job_category = JOB_CAT_CIVILIAN
	selection_color = "#ffeedd"

/datum/job/som/civilian/chef
	title = SOM_CHEF
	comm_title = "CHEF"
	paygrade = "SOM_E1"
	total_positions = 2
	supervisors = "the acting commander"
	display_order = JOB_DISPLAY_ORDER_DOCTOR
	outfit = /datum/outfit/job/som/civilian/chef
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting SOM commander<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Campaign<br /><br /><br />
		<b>Duty</b>: Keep the SOM well fed and happy. Fight for your team if things get desperate.
	"}
	minimap_icon = "medical"

/datum/job/som/civilian/chef/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 3000) // starting
			new_human.wear_id.paygrade = "SOM_E1"
		if(3001 to INFINITY) // 50 hrs
			new_human.wear_id.paygrade = "SOM_E2"

/datum/job/som/civilian/chef/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are a chef stationed behind the frontlines.
You are tasked with keeping the SOM well fed and happy, usually in the form of delicious food.
You are also an expert when it comes to botany and hydroponics. If you do not know what you are doing, <b>mentorhelp</b> so a mentor can assist you."}
