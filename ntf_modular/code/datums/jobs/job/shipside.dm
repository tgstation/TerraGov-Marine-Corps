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

//representatives
//Archercorp Liaison
/datum/job/terragov/civilian/liaison_archercorp
	title = "Archercorp Liaison"
	paygrade = "NT1"
	comm_title = "ACL"
	supervisors = "the Archercorp corporate office, and the corporate council."
	total_positions = 1
	access = ACCESS_NT_CORPORATE
	minimal_access = ACCESS_NT_CORPORATE
	outfit = /datum/outfit/job/civilian/liaison_archercorp
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Archercorp Corporate Office, the CEO.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Create good relations and maintain corporation's image, do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/terragov/civilian/liaison_archercorp/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/terragov/civilian/liaison_archercorp/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of ArcherCorp you are expected to stay professional and loyal to the corporation at all times.
You are expected to make sure the operations are functioning as intended with the interests of ArcherCorp and are a good outlook.
Your primary job is to build good relations, protect the interests of the company and then the corporate council and report critical events to Archercorp. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with corporate headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
Tank crewmen, pilots, engineers and ship engineers are archercorp personnel and you have partial responsibility over them. Archercorp is the leading weapons and spacecraft manufacturer of Phantom City. Known to be the oldest corporation, predating the great war that ended the world thanks to their great space habitat.
Archercorp generally takes a more isolationist approach to diplomacy and are generally mysterious, liberty of isolation granted by their immense power and resources."}

/datum/outfit/job/civilian/liaison_archercorp
	name = "Archercorp Liaison"
	jobtype = /datum/job/terragov/civilian/liaison_archercorp

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/liaison_suit/suspenders
	shoes = /obj/item/clothing/shoes/laceup

//representatives
//Novamed Liaison
/datum/job/terragov/civilian/liaison_novamed
	title = "Novamed Liaison"
	paygrade = "NT1"
	comm_title = "NML"
	supervisors = "the Novamed corporate office, and the corporate council."
	total_positions = 1
	access = ACCESS_NT_CORPORATE
	minimal_access = ACCESS_NT_CORPORATE
	outfit = /datum/outfit/job/civilian/liaison_novamed
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Novamed Corporate Office, the CEO.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Create good relations and maintain corporation's image, do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/terragov/civilian/liaison_novamed/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/terragov/civilian/liaison_novamed/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of Novamed you are expected to stay professional and loyal to the corporation at all times.
You are expected to make sure the operations are functioning as intended with the interests of Novamed and are a good outlook.
Your primary job is to build good relations, protect the interests of the company and then the corporate council and report critical events to Novamed. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with corporate headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
The medics are NM personnel and medical and research divisions are run by Novamed and you have responsibility on them. Novamed has the monopoly over medical, cloning technologies, cybernetics and bioengineering manufactury and appliances of Phantom City and likely the entire new world. Known to be rather secretive in their inner workings, more than the usual megacorp, that is. Perhaps paranoia you don't even know.
Novamed tends to be cooperative with other corporations, especially mutually with Ninetails."}

/datum/outfit/job/civilian/liaison_novamed
	name = "Novamed Liaison"
	jobtype = /datum/job/terragov/civilian/liaison_novamed

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/liaison_suit/formal
	shoes = /obj/item/clothing/shoes/laceup

//TRANSCo Liaison
/datum/job/terragov/civilian/liaison_transco
	title = "TRANSCo Liaison"
	paygrade = "NT1"
	comm_title = "NML"
	supervisors = "the TRANSCo corporate office, and the corporate council."
	total_positions = 1
	access = ACCESS_NT_CORPORATE
	minimal_access = ACCESS_NT_CORPORATE
	outfit = /datum/outfit/job/civilian/liaison_transco
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> TRANSCo Corporate Office, the CEO.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Create good relations and maintain corporation's image, do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/terragov/civilian/liaison_transco/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/terragov/civilian/liaison_transco/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of TRANSCo you are expected to stay professional and loyal to the corporation at all times.
You are expected to make sure the operations are functioning as intended with the interests of TRANSCo and are a good outlook.
Your primary job is to build good relations, protect the interests of the company and then the corporate council and report critical events to TRANSCo. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with corporate headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
TRANSCO is responsible for requisitions and it's staff alongside the transport crewmen. and you have responsibility over them. TRANSCo is the dominating construction, transport, logistics and mining corporation, providing services across the new world and they quickly became essential to any business.
TRANSCo generally tend to be rather hands off with general matters unless they are involved in some way."}

/datum/outfit/job/civilian/liaison_transco
	name = "TRANSCo Liaison"
	jobtype = /datum/job/terragov/civilian/liaison_transco

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/liaison_suit
	shoes = /obj/item/clothing/shoes/laceup

//Kaizoku Liaison
/datum/job/vsd/liaison_kaizoku
	job_category = JOB_CAT_CIVILIAN
	selection_color = "#ffeedd"
	title = "Kaizoku Liaison"
	paygrade = "NT1"
	comm_title = "NML"
	supervisors = "the Kaizoku corporate office, and the corporate council."
	total_positions = 1
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	outfit = /datum/outfit/job/civilian/liaison_kaizoku
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Kaizoku Corporate Office, the CEO.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Create good relations and maintain corporation's image, do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/vsd/liaison_kaizoku/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/vsd/liaison_kaizoku/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of Kaizoku you are expected to stay professional and loyal to the corporation at all times.
You are expected to make sure the operations are functioning as intended with the interests of Kaizoku and are a good outlook.
Your primary job is to build good relations, protect the interests of the company and then the corporate council and report critical events to Kaizoku. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with corporate headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
Kaizoku Corporation competes in different wings of weapons development against Archercorp, though Archercorp sees them as no opponent due their isolationist behavior. Kaizoku Has no hand in the corporate council ship, they operate seperately in their own ship... Which was not taken well by the council to begin with. Your job is tough.
Kaizoku is secretive and untrustworthy to other corporations, following their own agenda and researching borderline black market cybernetics and neural technologies. Your corporation is the primary developer of the neural implants everyone have today.
Your ranking allows you to know your corporation has vital backing from the criminal syndicate of the slums which leader of also detonated the nuke in center of the corpo plaza. You will have to maintain relationship with the corporate council despite the difficulties or else there is nothing even another nuke can do."}

/datum/outfit/job/civilian/liaison_kaizoku
	name = "Kaizoku Liaison"
	jobtype = /datum/job/vsd/liaison_kaizoku

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/vsd
	w_uniform = /obj/item/clothing/under/liaison_suit/outing
	shoes = /obj/item/clothing/shoes/laceup

//Sons of Mars Liaison
/datum/job/som/civilian/liaison_som
	title = "Sons of Mars Representative"
	paygrade = "NT1"
	comm_title = "NML"
	supervisors = "the Sons of Mars high command."
	total_positions = 1
	access = ALL_SOM_ACCESS
	minimal_access = ALL_SOM_ACCESS
	outfit = /datum/outfit/job/civilian/liaison_som
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Sons of Mars.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Try not to start not-world war 1, do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/som/civilian/liaison_som/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/som/civilian/liaison_som/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of Sons of Mars you are expected to stay professional and loyal to the cause at all times.
You are expected to make sure the operations are functioning as intended with the interests of Sons of Mars and are a good outlook.
Your primary job is to build good relations, protect the interests of the faction and report critical events to Sons of Mars. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
Sons of Mars is driven on the belief the corpos are always will be corrupt in essence and will destroy the world all over again, and any means justify the ends to stop this from happening again. Atleast that's what they tell you...
Sons of Mars originate from the mars prison which upon a riot were taken control of by the prisoners, with no way to leave after the guards fled they started colonizing it. Many years later you are contacted by the syndicate with an offer of a refurbished spaceship which began it all...
You honestly don't know what you are even here to negoitate, AS called terrorists."}

/datum/outfit/job/civilian/liaison_som
	name = "Sons of Mars Representative"
	jobtype = /datum/job/som/civilian/liaison_som

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/som/command
	w_uniform = /obj/item/clothing/under/som
	shoes = /obj/item/clothing/shoes/laceup

//Colonial Militia Liaison
/datum/job/icc/liaison_cm
	job_category = JOB_CAT_CIVILIAN
	selection_color = "#ffeedd"
	title = "Colonial Militia Representative"
	paygrade = "NT1"
	comm_title = "NML"
	supervisors = "the Colonial Militia high command."
	total_positions = 1
	access = ALL_ICC_ACCESS
	minimal_access = ALL_ICC_ACCESS
	outfit = /datum/outfit/job/civilian/liaison_cm
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Colonial Militia High Command.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Create good relations, ensure safety of survivors and your faction. do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/icc/liaison_cm/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/icc/liaison_cm/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of Colonial Militia you are expected to stay professional and loyal to the cause at all times.
You are expected to make sure the operations are functioning as intended with the interests of Colonial Militia and a good outlook.
Your primary job is to build good relations, protect the interests of the company and then the corporate council and report critical events to Colonial Militia. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
Colonial Militia is formed out of surviving colonists against the initial Xenomorph assaults and som ransacking, armed by a bunch of NTC armories which were thankfully in the colonies.
Almost all of CM members were colonisers hired by the NTC before all of this happened, It is unknown if they knew about the xenomorphs or not but they seem to care about the survivors so CM naturally has a positive inclination towards Ninetails."}

/datum/outfit/job/civilian/liaison_cm
	name = "Colonial Militia Representative"
	jobtype = /datum/job/icc/liaison_cm

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/marine/icc
	w_uniform = /obj/item/clothing/under/marine/camo
	shoes = /obj/item/clothing/shoes/marine

//Colonial Militia Liaison
/datum/job/clf/liaison_clf
	job_category = JOB_CAT_CIVILIAN
	selection_color = "#ffeedd"
	title = "CLF Representative"
	paygrade = "NT1"
	comm_title = "NML"
	supervisors = "the CLF high command."
	total_positions = 1
	access = ALL_ICC_ACCESS
	minimal_access = ALL_ICC_ACCESS
	outfit = /datum/outfit/job/civilian/liaison_clf
	html_description = {"
		<b>Difficulty</b>: Hard (varies)<br /><br />
		<b>You answer to the</b> Colonial Liberation Force High Command.<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Nuclear War<br /><br /><br />
		<b>Duty</b>: Create good relations, ensure safety of survivors and your faction. do paperwork, have sex during meetings...? Reply if you’re called.
	"}
	skills_type = /datum/skills/civilian
	display_order = JOB_DISPLAY_ORDER_CORPORATE_LIAISON
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "cl"

/datum/job/clf/liaison_clf/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/clf/liaison_clf/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a representative of Colonial Liberation Force you are expected to stay professional and loyal to the cause at all times.
You are expected to make sure the operations are functioning as intended with the interests of CLF and a good outlook.
Your primary job is to build good relations, protect the interests of the company and then the corporate council and report critical events to CLF. Follow regular game rules unless told otherwise by your superiors.
Use a fax machine to communicate with headquarters or to acquire new directives when in doubt. You may not receive anything back (especially if the game staff is absent or otherwise busy), and this is normal.
CLF is formed out of people realizing the evolutionary superiority of xenomorphs or people brainwashed into thinking so or... not thinking at all, becoming breed stock. Various reasons but one cause...
To serve the xenomorphs and join the ascended ones. (willingly or not, depends on the person.)"}

/datum/outfit/job/civilian/liaison_clf
	name = "CLF Representative"
	jobtype = /datum/job/clf/liaison_clf

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/marine/icc
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine
