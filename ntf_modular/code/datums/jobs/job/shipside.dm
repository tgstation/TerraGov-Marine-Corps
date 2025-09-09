//CEO
/datum/job/terragov/command/ceo
	title = CHIEF_EXECUTIVE_OFFICER
	req_admin_notify = TRUE
	paygrade = "CEO"
	comm_title = "CEO"
	supervisors = "Your conscience."
	total_positions = 1
	skills_type = /datum/skills/ceo
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	display_order = JOB_DISPLAY_ORDER_CHIEF_EXECUTIVE_OFFICER
	outfit = /datum/outfit/job/command/ceo
	exp_requirements = XP_REQ_EXPERT
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to</b> NTC High Command<br /><br />
		<b>Unlock Requirement</b>: Being the CEO in lore.<br /><br />
		<b>Gamemode Availability</b>: All<br /><br /><br />
		<b>Duty</b>: Lead your corporation to ensure the operations go flawlessly
		"}
	minimap_icon = "CEO"

//ghetto proc usage why not, just to not edit the job shit
/datum/job/terragov/command/ceo/player_old_enough(client/C)
	if(check_other_rights(usr.client, R_ADMIN, FALSE) && C.key == "CrimsonQuiver")
		return TRUE
	return FALSE

//Corpsec Commander
/datum/job/terragov/command/corpseccommander
	title = CORPSEC_COMMANDER
	req_admin_notify = TRUE
	paygrade = "O3"
	comm_title = "CCDR"
	total_positions = 1
	selection_color = "#80000"
	skills_type = /datum/skills/fo
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_CORPSEC_COMMANDER
	outfit = /datum/outfit/job/command/corpseccommander
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>:Very Hard<br /><br />
		<b>You answer to the</b> Captain and the CEO<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Distress<br /><br /><br />
		<b>Duty</b>: Ensure base security, enforce the law, make sure corpsec is not acting like a legal gang.
	"}
	minimap_icon = "corpseccomm"

/datum/job/terragov/command/corpseccommander/after_spawn(mob/living/L, mob/M, latejoin)
	. = ..()
	SSdirection.set_leader(TRACKING_ID_MARINE_COMMANDER, L)

/datum/job/terragov/command/corpseccommander/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are a veteran, elite operative with leadership skills and experience
	trusted to keep the law and base protection within the front operations of Ninetails Corporation,
	do not let them down."}

/datum/job/terragov/command/corpseccommander/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) //starting
			new_human.wear_id.paygrade = "O4"
		if(1500 to 7500) // 25 hrs
			new_human.wear_id.paygrade = "MO4"
		if(7501 to INFINITY) // 125 hrs
			new_human.wear_id.paygrade = "MO5"

//Vanguard
/datum/job/terragov/command/vanguard
	title = VANGUARD
	paygrade = "E5"
	comm_title = "VNG"
	total_positions = 4
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	display_order = JOB_DISPLAY_ORDER_STAFF_OFFICER
	skills_type = /datum/skills/specialist/vanguard
	outfit = /datum/outfit/job/command/vanguard
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/command/vanguard,
		/datum/outfit/job/command/vanguard/robot,
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
	minimap_icon = "vanguard"

/datum/job/terragov/command/vanguard/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"\nYou are a Vanguard Unit, an elite bodyguard serving under the corporation to guard the command staff and provide tactical assistance to the deployed marines when required.
	You have also been tasked to provide 'special morale support' when needed or requested by a commanding officer.
	You are the lowest command, even though you are trained to be a leader, but you can take control if all the other command are missing, dead or unavailable.
	Though it also means you have likely failed your job as a bodyguard."}

/datum/job/terragov/command/vanguard/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1000) // starting
			new_human.wear_id.paygrade = "E5"
		if(1001 to 2500) // 25 hrs
			new_human.wear_id.paygrade = "O1"
		if(2501 to INFINITY) // 50 hrs
			new_human.wear_id.paygrade = "O2"
