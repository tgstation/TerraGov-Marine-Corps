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
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/command/captain,
		/datum/outfit/job/command/captain/robot,
	)
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP|JOB_FLAG_LOUDER_TTS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to</b> TGMC High Command<br /><br />
		<b>Unlock Requirement</b>: 25 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Lead the TGMC platoon and complete your mission. Support the marines and communicate with your command staff, execute orders.
	"}
	minimap_icon = "captain"

/datum/job/terragov/command/captain/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As the Captain of the [SSmapping.configs[SHIP_MAP].map_name] you are held by higher standard and are expected to act competently.
While you may support Nanotrasen, you report to TGMC High Command, not the company.
Your primary task is the safety of the ship and her crew, and ensuring the survival and success of the Marines.
Your first order of business should be briefing the marines on the mission they are about to undertake.
You should not be voluntarily leaving your vessel under any circumstances. <b>A Captain goes down with their ship.</b>
If you require any help, use <b>Mentorhelp</b> to ask mentors about what you're supposed to do.
Godspeed, Captain! And remember, you are not above the law."}

/datum/job/terragov/command/captain/after_spawn(mob/living/new_mob, mob/user, latejoin)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "O6"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "O7"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "O8"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "O9"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "10"
	new_human.wear_id.update_label()

/datum/job/terragov/command/captain/campaign
	outfit = /datum/outfit/job/command/captain_campaign
	multiple_outfits = FALSE


//Field Commander
/datum/job/terragov/command/fieldcommander
	title = FIELD_COMMANDER
	req_admin_notify = TRUE
	paygrade = "O3"
	comm_title = "FCDR"
	total_positions = 1
	skills_type = /datum/skills/fo
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER
	outfit = /datum/outfit/job/command/fieldcommander
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/command/fieldcommander,
		/datum/outfit/job/command/fieldcommander/robot,
	)
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP|JOB_FLAG_LOUDER_TTS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> Captain<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		<b>Duty</b>: Lead your platoon on the field. Take advantage of the military staff and assets you will need for the mission, keep good relations between command and the marines. Assist the captain if available.
	"}
	minimap_icon = "fieldcommander"

/datum/job/terragov/command/fieldcommander/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are charged with overseeing the operation on the ground, and are the highest-ranked deployed marine.
Your duties are to ensure marines hold when ordered, and push when they are cowering behind barricades.
Do not ask your men to do anything you would not do side by side with them.
Make the TGMC proud!"}

/datum/job/terragov/command/fieldcommander/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	SSdirection.set_leader(TRACKING_ID_MARINE_COMMANDER, new_mob)
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "O3"
		if(1501 to 6000) // 25hrs
			new_human.wear_id.paygrade = "MO4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "MO5"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "MO6"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "M10" //If you play way too much TGMC. 1000 hours.
	new_human.wear_id.update_label()


//Campaign version with specific loadout
/datum/job/terragov/command/fieldcommander/campaign
	outfit = /datum/outfit/job/command/fieldcommander_campaign
	multiple_outfits = FALSE


//Staff Officer
/datum/job/terragov/command/staffofficer
	title = STAFF_OFFICER
	paygrade = "O1"
	comm_title = "SO"
	total_positions = 4
	access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_BRIG, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = ALL_MARINE_ACCESS
	skills_type = /datum/skills/so
	display_order = JOB_DISPLAY_ORDER_STAFF_OFFICER
	outfit = /datum/outfit/job/command/staffofficer
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/command/staffofficer,
		/datum/outfit/job/command/staffofficer/robot,
	)
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Captain<br /><br />
		<b>Unlock Requirement</b>: 3 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Take charge of one of the four squads, be their eyes and ears providing intel and additional shipside support via Orbital Bombardments.
	"}

	minimap_icon = "staffofficer"

/datum/job/terragov/command/staffofficer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to monitor the marines, man the CIC, and listen to your superior officers.
You are in charge of logistics and the overwatch system. You are also in line to take command after the captain."}

/datum/job/terragov/command/staffofficer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "O1"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "O2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "O3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "O4"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "O5"
	new_human.wear_id.update_label()

/datum/job/terragov/command/staffofficer/campaign
	outfit = /datum/outfit/job/command/staffofficer_campaign
	multiple_outfits = FALSE


//Transport Officer
/datum/job/terragov/command/transportofficer
	title = TRANSPORT_OFFICER
	paygrade = "WO"
	comm_title = "TO"
	total_positions = 1
	access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TADPOLE)
	minimal_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_TADPOLE, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/transportofficer
	display_order = JOB_DISPLAY_ORDER_TRANSPORT_OFFICER
	outfit = /datum/outfit/job/command/transportofficer
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 25 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Pilot the Tadpole, a versatile dropship capable of fulfilling roles ranging from ambulance to mobile bunker.
	"}
	minimap_icon = "transportofficer"

/datum/job/terragov/command/transportofficer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "WO"
		if(601 to 3000) // 10 hrs
			new_human.wear_id.paygrade = "CWO"
		if(3001 to 6000) // 50 hrs
			new_human.wear_id.paygrade = "O1"
		if(6001 to INFINITY) // 100 hrs
			new_human.wear_id.paygrade = "O2"
	new_human.wear_id.update_label()

/datum/job/terragov/command/transportofficer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to provide mobile dropship support with the Tadpole, which is capable of both mass-transporting marines as well as holding vast amounts of equipment on it.
Try to ensure the Tadpole's survival. In the case of its destruction, you may request a repair board from requisitions or perform the role of Combat Engineer."}

//Pilot Officer
/datum/job/terragov/command/pilot
	title = PILOT_OFFICER
	paygrade = "O1"
	comm_title = "PO"
	total_positions = 1
	access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT)
	minimal_access = list(ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PILOT, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/pilot
	display_order = JOB_DISPLAY_ORDER_PILOT_OFFICER
	outfit = /datum/outfit/job/command/pilot
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 25 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Pilot the Condor, a modular attack aircraft that provides close air support with a variety of weapons ranging from the inbuilt gatling to wing mounted rockets.
	"}
	minimap_icon = "pilot"

/datum/job/terragov/command/pilot/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "O1"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "O2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "O3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "O4"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "O5"
	new_human.wear_id.update_label()

/datum/job/terragov/command/pilot/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to support marines with close air support via the Condor.
You are expected to use the Condor as the Alamo is able to be ran automatically, though at some points you will be required to take control of the Alamo for the operation's success, though highly unlikely.
Though you are an officer, your authority is limited to the dropship and the Condor, where you have authority over the enlisted personnel."}


//Mech pilot
/datum/job/terragov/command/mech_pilot
	title = MECH_PILOT
	req_admin_notify = TRUE
	paygrade = "E3"
	comm_title = "MCH"
	total_positions = 0
	skills_type = /datum/skills/mech_pilot
	access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_MECH, ACCESS_CIVILIAN_PUBLIC)
	minimal_access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_MECH, ACCESS_CIVILIAN_PUBLIC, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	display_order = JOB_DISPLAY_ORDER_MECH_PILOT
	outfit = /datum/outfit/job/command/mech_pilot
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 25 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Act as the spearhead of the operation
	"}
	minimap_icon = "mech_pilot"

/datum/job/terragov/command/mech_pilot/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are the operator of a very expensive and valuable Mech, and are trained and expected to use it in the field of combat. You can serve your Division in a variety of roles, so choose carefully."

/datum/job/terragov/command/mech_pilot/on_pre_setup()
	if(total_positions)
		return
	var/client_count = length(GLOB.clients)
	if(client_count >= NUCLEAR_WAR_MECH_MINIMUM_POP_REQUIRED)
		client_count = 1 + FLOOR((client_count - NUCLEAR_WAR_MECH_MINIMUM_POP_REQUIRED) / NUCLEAR_WAR_MECH_INTERVAL_PER_SLOT, 1)
		add_job_positions(client_count)

/datum/job/terragov/command/mech_pilot/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "E5"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "E6"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "E9A" //If you play way too much TGMC. 1000 hours.
	new_human.wear_id.update_label()

//tank/arty driver+gunner
/datum/job/terragov/command/assault_crewman
	title = ASSAULT_CREWMAN
	req_admin_notify = TRUE
	paygrade = "E3"
	comm_title = "AC"
	total_positions = 0
	max_positions = 2
	skills_type = /datum/skills/assault_crewman
	access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_ARMORED, ACCESS_CIVILIAN_PUBLIC)
	minimal_access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_ARMORED, ACCESS_CIVILIAN_PUBLIC, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	display_order = JOB_DISPLAY_ORDER_MECH_PILOT
	outfit = /datum/outfit/job/command/assault_crewman
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/command/assault_crewman,
		/datum/outfit/job/command/assault_crewman/robot,
	)
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	job_points_needed = 35
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 25 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Provide heavy fire support
	"}
	minimap_icon = "assault_crew"

/datum/job/terragov/command/assault_crewman/on_pre_setup()
	if(total_positions)
		return
	if(length(GLOB.clients) >= NUCLEAR_WAR_TANK_MINIMUM_POP_REQUIRED)
		add_job_positions(2) //always 2 there are, a master and an apprentice

/datum/job/terragov/command/assault_crewman/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are an Assault Crewman. You operate the TGMC's armored assault vehicles along with your partner, and in some cases a \"willing\" loader. Make sure that you work as a team to advance the front!"

/datum/job/terragov/command/assault_crewman/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "E5"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "E6"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "E9A" //If you play way too much TGMC. 1000 hours.
	new_human.wear_id.update_label()


//apc/jeep driver
/datum/job/terragov/command/transport_crewman
	title = TRANSPORT_CREWMAN
	req_admin_notify = TRUE
	paygrade = "E3"
	comm_title = "TC"
	total_positions = 1
	skills_type = /datum/skills/transport_crewman
	access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_ARMORED, ACCESS_CIVILIAN_PUBLIC)
	minimal_access = list(ACCESS_MARINE_WO, ACCESS_MARINE_PREP, ACCESS_MARINE_ARMORED, ACCESS_CIVILIAN_PUBLIC, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	display_order = JOB_DISPLAY_ORDER_MECH_PILOT
	outfit = /datum/outfit/job/command/transport_crewman
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 25 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Transport and support the frontline troops
	"}
	minimap_icon = "transport_crew"

/datum/job/terragov/command/transport_crewman/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are a Transport Crewman. You operate the TGMC's transport vehciles to ensure that marines and equipment gets to the front in a timely and safe manner."

/datum/job/terragov/command/transport_crewman/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "E5"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "E6"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "E9A" //If you play way too much TGMC. 1000 hours.
	new_human.wear_id.update_label()



/datum/job/terragov/engineering
	job_category = JOB_CAT_ENGINEERING
	selection_color = "#fff5cc"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_ENGINEERING


//Chief Ship Engineer
/datum/job/terragov/engineering/chief
	title = CHIEF_SHIP_ENGINEER
	paygrade = "O1"
	comm_title = "CSE"
	selection_color = "#ffeeaa"
	total_positions = 1
	access = list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_BRIDGE, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_PREP, ACCESS_MARINE_RO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/ce
	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	outfit = /datum/outfit/job/engineering/chief
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Supervise the engineers and technicians on duty. Overview the ship’s engine. Teach what’s right and what’s wrong about engineering, cut corners and find places in any FOB that can easily be destroyed.
	"}
	minimap_icon = "cse"

/datum/job/terragov/engineering/chief/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "O1"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "O2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "O3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "O4"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "O5"
	new_human.wear_id.update_label()

/datum/job/terragov/engineering/chief/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to maintain the ship's engine and keep everything running.
If you have no idea how to set up the engine, or it's your first time, <b>mentorhelp</b> so that a mentor can assist you.
You are also next in the chain of command, should the bridge crew fall in the line of duty."}


//Ship Engineer
/datum/job/terragov/engineering/tech
	title = SHIP_TECH
	comm_title = "ST"
	paygrade = "PO3"
	total_positions = 5
	supervisors = "the chief ship engineer and the requisitions officer"
	access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	skills_type = /datum/skills/st
	display_order = JOB_DISPLAY_ORDER_SHIP_TECH
	outfit = /datum/outfit/job/engineering/tech
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Chief Ship Engineer<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Maintain the ship, be in charge of the engines. Be the secondary engineer to a forward operating base, prepare the shipside defenses if needed. Help the Pilot Officer in preparing the dropship.
	"}
	minimap_icon = "st"

/datum/job/terragov/engineering/tech/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "PO3"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "PO2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "PO1"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "CPO"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "SCPO"
	new_human.wear_id.update_label()

/datum/job/terragov/engineering/tech/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "Your job is to make sure the ship is operational, you should firstly focus on manning the requisitions line and later on to be ready to send supplies for marines who are groundside."


/datum/job/terragov/requisitions
	job_category = JOB_CAT_REQUISITIONS
	selection_color = "#BAAFD9"
	supervisors = "the acting captain"
	exp_type_department = EXP_TYPE_REQUISITIONS


//Requisitions Officer
/datum/job/terragov/requisitions/officer
	title = REQUISITIONS_OFFICER
	req_admin_notify = TRUE
	paygrade = "O1"
	comm_title = "RO"
	selection_color = "#9990B2"
	total_positions = 1
	access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)
	minimal_access = list(ACCESS_MARINE_CARGO, ACCESS_MARINE_RO, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_PREP, ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	skills_type = /datum/skills/ro
	display_order = JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER
	outfit = /datum/outfit/job/requisitions/officer
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/requisitions/officer,
		/datum/outfit/job/requisitions/officer/robot,
	)
	exp_requirements = XP_REQ_UNSEASONED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 1 hour playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		Requisition supplies to the battlefield. Ensure that the marines are reparing miners for more points. Supply the marines with deluxe equipment to ensure success.
	"}
	minimap_icon = "requisition"


/datum/job/terragov/requisitions/officer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "O1"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "O2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "O3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "O4"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "O5"
	new_human.wear_id.update_label()

/datum/job/terragov/requisitions/officer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your job is to dispense supplies to the marines, including weapon attachments.
While you may request paperwork for supplies, do not go out of your way to screw with marines, unless you want to get deposed.
A happy ship is a well-functioning ship."}



/datum/job/terragov/medical
	job_category = JOB_CAT_MEDICAL
	selection_color = "#BBFFBB"
	exp_type_department = EXP_TYPE_MEDICAL


/datum/job/terragov/medical/professor
	title = CHIEF_MEDICAL_OFFICER
	req_admin_notify = TRUE
	comm_title = "CMO"
	paygrade = "SP"
	total_positions = 1
	supervisors = "the acting captain"
	selection_color = "#99FF99"
	access = list(ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_LOGISTICS)
	skills_type = /datum/skills/cmo
	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	outfit = /datum/outfit/job/medical/professor
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/medical/professor,
		/datum/outfit/job/medical/professor/robot,
	)
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		<b>Duty</b>: Communicate and lead your fellow medical staff (if available), supervise the medical department. Coordinate and teach fellow medical staff and corpsmen what they’re doing for treating an injury. Be the sole doctor in the Canterbury.
	"}
	minimap_icon = "chief_medical"


/datum/job/terragov/medical/professor/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are the chief medical officer aboard the [SSmapping.configs[SHIP_MAP].map_name] and supervisor to the medical department.
You have final authority over the medical department, medications, and treatments.
Make sure that the doctors and nurses are doing their jobs and keeping the marines healthy and strong."}

/datum/job/terragov/medical/professor/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "SP"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "HP"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "MSPVR"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "MDR"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "CMO"
	new_human.wear_id.update_label()

//Medical Officer
/datum/job/terragov/medical/medicalofficer
	title = MEDICAL_DOCTOR
	comm_title = "MD"
	paygrade = "MS"
	total_positions = 4
	supervisors = "the chief medical officer"
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/doctor
	display_order = JOB_DISPLAY_ORDER_DOCTOR
	outfit = /datum/outfit/job/medical/medicalofficer
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/medical/medicalofficer,
		/datum/outfit/job/medical/medicalofficer/robot,
	)
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Chief Medical Officer<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Tend severely wounded patients to your aid in the form of surgery, repair broken bones and damaged organs, fix internal bleeding and prevent the birth of a xenomorph larva. Develop superior healing medicines.
	"}
	minimap_icon = "medical"

/datum/job/terragov/medical/medicalofficer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "MS"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "JR"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SR"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "GP"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "AP"
	new_human.wear_id.update_label()

/datum/job/terragov/medical/medicalofficer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are a doctor stationed aboard the [SSmapping.configs[SHIP_MAP].map_name].
You are tasked with keeping the marines healthy and strong, usually in the form of surgery.
You are also an expert when it comes to medication and treatment. If you do not know what you are doing, <b>mentorhelp</b> so a mentor can assist you."}

//Researcher
/datum/job/terragov/medical/researcher
	title = MEDICAL_RESEARCHER
	comm_title = "Rsr"
	paygrade = "RSRA"
	total_positions = 2
	supervisors = "the NT corporate office"
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_ENGINEERING, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_CARGO, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/researcher
	display_order = JOB_DISPLAY_ORDER_MEDICAL_RESEARCHER
	outfit = /datum/outfit/job/medical/researcher
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/medical/researcher,
		/datum/outfit/job/medical/researcher/robot,
	)
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> Nanotrasen Corporate Office<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Research extraterrestrial life aboard the ship if provided by Nanotrasen/TerraGov, synthesize chemicals for the benefit of the marines. Find out the cause of why and when. Learn new things for humankind. Act as a secondary medical officer in practice.
	"}
	minimap_icon = "researcher"


/datum/job/terragov/medical/researcher/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are a civilian, working for the Nanotrasen Corporation, but you are still subject to the military chain of command.
You are tasked with deploying with the marines and researching the remains of the colony to get funding for Requisitions.
You are free to use any new technology you discover as you want, or give them out to the marines.
If shipside medbay is unstaffed, you should consider working as a regular doctor until someone else is available to take over.
It is also recommended that you gear up like a regular marine, or your 'internship' might be ending early..."}

/datum/job/terragov/medical/researcher/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "RSRA"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "RSR"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "LECT"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "APROF"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "PROF"
	new_human.wear_id.update_label()


/datum/job/terragov/civilian
	job_category = JOB_CAT_CIVILIAN
	selection_color = "#ffeedd"


//Liaison
/datum/job/terragov/civilian/liaison
	title = CORPORATE_LIAISON
	paygrade = "NT1"
	comm_title = "CL"
	supervisors = "the NT corporate office"
	total_positions = 1
	access = list(ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS)
	minimal_access = list(ACCESS_NT_CORPORATE, ACCESS_ILLEGAL_PIRATE, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_RESEARCH, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO, ACCESS_MARINE_MEDBAY)
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	outfit = /datum/outfit/job/civilian/liaison
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Nanotrasen Corporate Office<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Manage relations between Nanotrasen and TerraGov Marine Corps. Report your findings via faxes. Reply if you’re called.
	"}
	minimap_icon = "cl"

/datum/job/terragov/civilian/liaison/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return

	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "NT1"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "NT2"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "NT3"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "NT4"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "NT5"
	new_human.wear_id.update_label()

/datum/job/terragov/civilian/liaison/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of Nanotrasen Corporation you are expected to stay professional and loyal to the corporation at all times.
You are not required to follow military orders; however, you cannot give military orders.
Your primary job is to observe and report back your findings to Nanotrasen. Follow regular game rules unless told otherwise by your superiors.
Use your office fax machine to communicate with corporate headquarters or to acquire new directives. You may not receive anything back (especially if the game staff are absent or otherwise busy), and this is normal."}

/datum/job/terragov/silicon
	job_category = JOB_CAT_SILICON
	selection_color = "#aaee55"


//Synthetic
/datum/job/terragov/silicon/synthetic
	title = SYNTHETIC
	req_admin_notify = TRUE
	comm_title = "Syn"
	paygrade = "Mk.I"
	supervisors = "the acting captain"
	total_positions = 1
	skills_type = /datum/skills/synthetic
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	display_order = JOB_DISPLAY_ORDER_SYNTHETIC
	outfit = /datum/outfit/job/civilian/synthetic
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	job_points_needed = 40
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Soul Crushing<br /><br />
		<b>You answer to the</b> acting Command Staff and the human crew<br /><br />
		<b>Unlock Requirement</b>: 10 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		<b>Duty</b>: Support and assist in every department of the TerraGov Marine Corps, use your incredibly developed skills to help the marines during their missions. You can talk to other synthetics or the AI on the :n channel. Serve your purpose.
	"}
	minimap_icon = "synth"

/datum/job/terragov/silicon/synthetic/get_special_name(client/preference_source)
	return preference_source.prefs.synthetic_name

/datum/job/terragov/silicon/synthetic/return_spawn_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /mob/living/carbon/human/species/early_synthetic
	return /mob/living/carbon/human/species/synthetic

/datum/job/terragov/silicon/synthetic/return_skills_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /datum/skills/early_synthetic
	return ..()

/datum/job/terragov/silicon/synthetic/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "Mk.I"
		if(601 to 1500) // 10hrs
			new_human.wear_id.paygrade = "Mk.II"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "Mk.III"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "Mk.IV"
		if(18001 to INFINITY) // 300 hrs
			new_human.wear_id.paygrade = "Mk.V"
	new_human.wear_id.update_label()

/datum/job/terragov/silicon/synthetic/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "Your primary job is to support and assist all TGMC departments and personnel on-board. \
		In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship."

/datum/job/terragov/silicon/ai
	title = SILICON_AI
	job_category = JOB_CAT_SILICON
	req_admin_notify = TRUE
	comm_title = "AI"
	total_positions = 1
	selection_color = "#92c255"
	supervisors = "your laws and the human crew"
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	exp_type_department = EXP_TYPE_SILICON
	display_order = JOB_DISPLAY_ORDER_AI
	skills_type = /datum/skills/ai
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Easy<br /><br />
		<b>You answer to the</b> acting Command Staff and the human crew<br /><br />
		<b>Unlock Requirement</b>: 3 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Assist the crew whenever you’re needed, be the doorknob of the ship. Recon the areas for threats via cameras, report your findings to the crew at various communication channels. Follow your laws.
	"}


/datum/job/terragov/silicon/ai/get_special_name(client/preference_source)
	return preference_source.prefs.ai_name


/datum/job/terragov/silicon/ai/return_spawn_type(datum/preferences/prefs)
	return /mob/living/silicon/ai

/datum/job/terragov/silicon/ai/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your primary job is to support and assist all TGMC departments and personnel on-board.
However, your vision is limited through cameras from the ship or to marines groundside.
Recon any threats and report findings at various communication channels.
If you require any help, use <b>Mentorhelp</b> to ask mentors about what you're supposed to do."}

/datum/job/terragov/silicon/ai/announce(mob/living/announced_mob)
	. = ..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), "[announced_mob] has been downloaded to an empty bluespace-networked AI core at [AREACOORD(announced_mob)].", "Attention:", TRUE))


/datum/job/terragov/silicon/ai/config_check()
	return CONFIG_GET(flag/allow_ai)

// Silicons only need a very basic preview since there is no customization for them.
/datum/job/terragov/silicon/ai/handle_special_preview(client/parent)
	parent.show_character_previews(image('icons/mob/ai.dmi', icon_state = "ai", dir = SOUTH))
	return TRUE
