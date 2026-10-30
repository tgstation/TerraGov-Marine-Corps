/datum/job/terragov/squad
	job_category = JOB_CAT_MARINE
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	exp_type_department = EXP_TYPE_MARINES


/datum/job/terragov/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hud_set_job(faction)
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/human_spawn = C
	if(!(human_spawn.species.species_flags & ROBOTIC_LIMBS))
		human_spawn.set_nutrition(250)
	if(!human_spawn.assigned_squad)
		CRASH("after_spawn called for a marine without an assigned_squad")
	to_chat(M, {"\nYou have been assigned to: <b><font size=3 color=[human_spawn.assigned_squad.color]>[lowertext(human_spawn.assigned_squad.name)] squad</font></b>.
Make your way to the cafeteria for some post-cryosleep chow, and then get equipped in your squad's prep room."})
	///yes i know istype(src) is gross but we literally have 1 child type we would want to ignore so
	if(ismarineleaderjob(src))
		return
	if(!(SSticker.mode.round_type_flags & MODE_FORCE_CUSTOMSQUAD_UI))
		return
	if(world.time < SSticker.round_start_time + SSticker.mode.deploy_time_lock)
		human_spawn.RegisterSignal(SSdcs, COMSIG_GLOB_DEPLOY_TIMELOCK_ENDED, TYPE_PROC_REF(/mob/living/carbon/human, suggest_squad_assign))
		return
	addtimer(CALLBACK(GLOB.squad_selector, TYPE_PROC_REF(/datum, interact), human_spawn), 2 SECONDS)

//Squad Marine
/datum/job/terragov/squad/standard
	title = SQUAD_MARINE
	paygrade = "E1"
	comm_title = "Mar"
	access = list(ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Easy<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		TerraGov’s Squad Marines make up the bread and butter of Terra's fighting forces. They are fitted with the standard arsenal that the TGMC offers, and they can take up a variety of roles, being a sniper, a pyrotechnician, a machinegunner, rifleman and more. They’re often high in numbers and divided into squads, but they’re the lowest ranking individuals, with a low degree of skill, not adapt to engineering or medical roles. Still, they are not limited to the arsenal they can take on the field to deal whatever threat that lurks against Terra.
		<br /><br />
		<b>Duty</b>: Carry out orders made by your acting Squad Leader, deal with any threats that oppose the TGMC.
	"}
	minimap_icon = "private"

/datum/job/terragov/squad/standard/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "E1"
		if(601 to 6000) // 10hrs
			new_human.wear_id.paygrade = "E2"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "E3"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "E3E"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "E8" //If you play way too much TGMC. 1000 hours.
	new_human.wear_id.update_label()

/datum/job/terragov/squad/standard/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are a rank-and-file marine of the TGMC, and that is your strength. What you lack alone, you gain standing shoulder to shoulder with the men and women of the TerraGov Marine Corps. Ooh-rah!"

/datum/job/terragov/squad/standard/npc
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/npc/tgmc/standard,
		/datum/outfit/job/npc/tgmc/standard/shotgunner,
	)

//Squad Engineer
/datum/job/terragov/squad/engineer
	title = SQUAD_ENGINEER
	paygrade = "E3"
	comm_title = "Eng"
	total_positions = 4
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_ENGINEERING)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_ENGPREP, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_ENGINEERING)
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_SUQAD_ENGINEER
	outfit = /datum/outfit/job/marine/engineer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	job_points_needed = 5
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		A mastermind of on-field construction, often regarded as the answer on whether the FOB succeeds or not, Squad Engineers are the people who construct the Forward Operating Base (FOB) and guard whatever threat that endangers the marines. In addition to this, they are also in charge of repairing power generators on the field as well as mining drills for requisitions. They have a high degree of engineering skill, meaning they can deploy and repair barricades faster than regular marines.
		<br /><br />
		<b>Duty</b>: Construct and reinforce the FOB that has been ordered by your acting Squad Leader, fix power generators and mining drills in the AO and stay on guard for any dangers that threaten your FOB.
	"}
	minimap_icon = "engi"

/datum/job/terragov/squad/engineer/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You have the equipment and skill to build fortifications, reroute power lines, and bunker down. Your squaddies will look to you when it comes to construction in the field of battle."

/datum/job/terragov/squad/engineer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/terragov/squad/engineer/npc
	outfit = /datum/outfit/job/npc/tgmc/squad_engineer

//Squad Corpsman
/datum/job/terragov/squad/corpsman
	title = SQUAD_CORPSMAN
	paygrade = "E3"
	comm_title = "Med"
	total_positions = 5
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/marine/corpsman
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_MEDIUM,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
	)
	job_points_needed = 5
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		Corpsman are the vital line between life and death of a marine’s life should a marine be wounded in battle, if provided they do not run away. While marines treat themselves, it is the corpsmen who will treat injuries beyond what a normal person can do. With a higher degree of medical skill compared to a normal marine, they are capable of doing medical actions faster and reviving with defibrillators will heal more on each attempt. They can also perform surgery, in an event if there are no acting medical officers onboard.
		<br /><br />
		<b>Duty</b>: Tend the injuries of your fellow marines or related personnel, keep them at fighting strength. Evacuate those who are incapacitated or rendered incapable of fighting due to severe wounds or larvae infections.
	"}
	minimap_icon = "medic"

/datum/job/terragov/squad/corpsman/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You must tend the wounds of your squad mates and make sure they are healthy and active. You may not be a fully-fledged doctor, but you stand between life and death when it matters."

/datum/job/terragov/squad/corpsman/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/terragov/squad/corpsman/npc
	outfit = /datum/outfit/job/npc/tgmc/corpsman

//Squad Smartgunner
/datum/job/terragov/squad/smartgunner
	title = SQUAD_SMARTGUNNER
	paygrade = "E3"
	comm_title = "SGnr"
	total_positions = 4
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/smartgunner
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	outfit = /datum/outfit/job/marine/smartgunner
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
	)
	job_points_needed = 10 //Redefined via config.
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		When it comes to heavy firepower during the early stages of an operation, TGMC has provided the squad with Smartgunners. They are those who trained to operate smart weapons, built-in IFF weapons that provides covering and suppressive fire even directly behind the marines. Squad Smartgunners are best when fighting behind marines, as they can act as shields or during a hectic crossfire.
		<br /><br />
		<b>Duty</b>: Be the backline of your pointmen, provide heavy weapons support with your smart weapon.
	"}
	minimap_icon = "smartgunner"

/datum/job/terragov/squad/smartgunner/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "Your job is to provide IFF weapons support. <b>Your bullets cannot hit friendlies,</b> and for this reason it's advisable to stay behind your fellow marines unless they are stagnant."

/datum/job/terragov/squad/smartgunner/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/terragov/squad/smartgunner/npc
	outfit = /datum/outfit/job/npc/tgmc/smartgunner

//Squad Specialist
/datum/job/terragov/squad/specialist
	title = SQUAD_SPECIALIST
	req_admin_notify = TRUE
	paygrade = "E4" // Dead
	comm_title = "Spec"
	total_positions = 0
	max_positions = 0
	access = list(ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	skills_type = /datum/skills/specialist
	outfit = /datum/outfit/job/marine/specialist
	exp_requirements = XP_REQ_UNSEASONED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
	)
	job_points_needed = 10 //Redefined via config.


/datum/job/terragov/squad/specialist/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are the very rare and valuable weapon expert, trained to use special equipment. You can serve a variety of roles, so choose carefully."

//Squad Leader
/datum/job/terragov/squad/leader
	title = SQUAD_LEADER
	req_admin_notify = TRUE
	paygrade = "E5"
	comm_title = JOB_COMM_TITLE_SQUAD_LEADER
	total_positions = 4
	supervisors = "the acting field commander"
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_TADPOLE)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_TADPOLE)
	skills_type = /datum/skills/sl
	display_order = JOB_DISPLAY_ORDER_SQUAD_LEADER
	outfit = /datum/outfit/job/marine/leader
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_LOUDER_TTS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_HIGH,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: 3 hours playtime (any role)<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		Squad Leaders are basically the boss of any able-bodied squad. Though while they are not trained compared to engineers, corpsmen and smartgunners, they are (usually) capable of leading the squad. They have access to command assets such as a ship railgun, orbital bombardment as examples.
		<br /><br />
		<b>Duty</b>: Be a responsible leader of your squad, make sure your squad communicates frequently all the time and ensure they are working together for the task at hand. Stay safe, as you’re a valuable leader.
	"}
	minimap_icon = "leader"

/datum/job/terragov/squad/leader/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating. You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."

/datum/job/terragov/squad/leader/after_spawn(mob/living/carbon/C, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/new_human = C
	var/playtime_mins = user?.client?.get_exp(title)
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "E7"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "E7E"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "E8E"
		if(18001 to 60000) // 300 hrs
			new_human.wear_id.paygrade = "E9"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "E9E" //If you play way too much TGMC. 1000 hours.
	new_human.wear_id.update_label()
	if(SSticker.mode.round_type_flags & MODE_FORCE_CUSTOMSQUAD_UI)
		addtimer(CALLBACK(GLOB.squad_manager, TYPE_PROC_REF(/datum, interact), new_human), 2 SECONDS)
	if(!latejoin)
		return
	if(!new_human.assigned_squad)
		return
	if(!ismarineleaderjob(new_human.assigned_squad?.squad_leader?.job)) //If there's no proper SL already in the squad, promote to leader
		new_human.assigned_squad.promote_leader(new_human)

/datum/job/terragov/squad/leader/npc
	outfit = /datum/outfit/job/npc/tgmc/squad_leader


/datum/job/terragov/squad/vatgrown
	title = SQUAD_MARINE
	paygrade = "VM"
	comm_title = "Mar"
	access = list(ACCESS_MARINE_PREP)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_DROPSHIP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	outfit = /datum/outfit/job/marine/vatgrown
	total_positions = 0
	job_flags = JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	minimap_icon = "private"

/datum/job/terragov/squad/vatgrown/return_spawn_type(datum/preferences/prefs)
	return /mob/living/carbon/human/species/vatgrown

