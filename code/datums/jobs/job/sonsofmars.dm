/datum/job/som
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	faction = FACTION_SOM


/datum/outfit/job/som/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.underwear = 10
	H.undershirt = H.undershirt ? 10 : 0
	H.regenerate_icons()

//Base job for normal gameplay SOM, not ERT.
/datum/job/som/squad
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	supervisors = "the acting squad leader"
	selection_color = "#ffeeee"
	exp_type_department = EXP_TYPE_MARINES

/datum/job/som/squad/radio_help_message(mob/M)
	. = ..()
	if(istype(SSticker.mode, /datum/game_mode/hvh/combat_patrol))
		if(issensorcapturegamemode(SSticker.mode))
			to_chat(M, span_highdanger("Your platoon has orders to defend sensor towers in the AO and prevent them from reactivation by TerraGov forces until heavy reeinforcement arrives. High Command considers the successful prevention of the reactivation of the sensor towers a major victory"))
		else
			to_chat(M, span_highdanger("Your platoon has orders to patrol a remote territory illegally claimed by TerraGov imperialists. Intel suggests TGMC units are similarly trying to press their claims by force. Work with your team and eliminate all TGMC you encounter while preserving your own strength! High Command considers wiping out all enemies a major victory, or inflicting more casualties a minor victory."))
		return

/datum/job/som/squad/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
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

/datum/job/som/squad/equip_spawning_squad(mob/living/carbon/human/new_character, datum/squad/assigned_squad, client/player)
	if(!assigned_squad)
		SSjob.JobDebug("Failed to put marine role in squad. Player: [player.key] Job: [title]")
		return
	assigned_squad.insert_into_squad(new_character)

//SOM Standard
/datum/job/som/squad/standard
	title = SOM_SQUAD_MARINE
	paygrade = "SOM_E1"
	comm_title = "Mar"
	minimap_icon = "private"
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	outfit = /datum/outfit/job/som/squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Easy<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Combat patrol and Sensor Capture<br /><br /><br />
		The backbone of the Sons of Mars are their rank and file marines, trained and equipped to fight the conventional military of their former oppressors. They are fitted with the standard arsenal that the SOM offers, equipped with traditional projectile weaponry as well are less common but more deadly volkite weapons as the SOM's industry allows. They’re often high in numbers and divided into squads, but they’re the lowest ranking individuals, with a low degree of skill, not adapt to engineering or medical roles. Still, they are not limited to the arsenal they can take on the field to deal whatever threat that lurks against the Sons of Mars.
		<br /><br />
		<b>Duty</b>: Carry out orders made by your acting Squad Leader, deal with any threats that oppose the Sons of Mars.
	"}

/datum/job/som/squad/standard/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 600) // starting
			new_human.wear_id.paygrade = "SOM_E1"
		if(601 to 6000) // 10hrs
			new_human.wear_id.paygrade = "SOM_E2"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_E3"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_E4"
		if(30001 to 60000) // 500 hrs
			new_human.wear_id.paygrade = "SOM_E5"
		if(60001 to INFINITY) // 1000 hrs
			new_human.wear_id.paygrade = "SOM_S1"

/datum/job/som/squad/standard/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a rank-and-file soldier of the Sons of Mars, and that is your strength.
What you lack alone, you gain standing shoulder to shoulder with the men and women of the SOM. For Mars!"})

/datum/outfit/job/som/squad/standard
	name = "SOM Standard"
	jobtype = /datum/job/som/squad/standard

	id = /obj/item/card/id/dogtag/som


/datum/job/som/squad/engineer
	title = SOM_SQUAD_ENGINEER
	paygrade = "SOM_E3"
	comm_title = "Eng"
	total_positions = 12
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_SUQAD_ENGINEER
	outfit = /datum/outfit/job/som/squad/engineer
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Combat patrol and Sensor Capture<br /><br /><br />
		A mastermind of on-field construction, often regarded as the answer on whether the FOB succeeds or not, Squad Engineers are the people who construct the Forward Operating Base (FOB) and guard whatever threat that endangers the marines. In addition to this, they are also in charge of repairing power generators on the field as well as mining drills for requisitions. They have a high degree of engineering skill, meaning they can deploy and repair barricades faster than regular marines.
		<br /><br />
		<b>Duty</b>: Construct and reinforce the FOB that has been ordered by your acting Squad Leader, fix power generators and mining drills in the AO and stay on guard for any dangers that threaten your FOB.
	"}
	minimap_icon = "engi"

/datum/job/som/squad/engineer/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_E4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_E5"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_S1"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_S2"

/datum/job/som/squad/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou have the equipment and skill to build fortifications, reroute power lines, and bunker down.
Your squaddies will look to you when it comes to construction in the field of battle."})

/datum/outfit/job/som/squad/engineer
	name = "SOM Engineer"
	jobtype = /datum/job/som/squad/engineer

	id = /obj/item/card/id/dogtag/som


/datum/job/som/squad/medic
	title = SOM_SQUAD_CORPSMAN
	paygrade = "SOM_E3"
	comm_title = "Med"
	total_positions = 16
	minimap_icon = "medic"
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_SQUAD_CORPSMAN
	outfit = /datum/outfit/job/som/squad/medic
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Combat patrol and Sensor Capture<br /><br /><br />
		Corpsman are the vital line between life and death of a marine’s life should a marine be wounded in battle, if provided they do not run away. While marines treat themselves, it is the corpsmen who will treat injuries beyond what a normal person can do. With a higher degree of medical skill compared to a normal marine, they are capable of doing medical actions faster and reviving with defibrillators will heal more on each attempt. They can also perform surgery, in an event if there are no acting medical officers onboard.
		<br /><br />
		<b>Duty</b>: Tend the injuries of your fellow marines or related personnel, keep them at fighting strength.
	"}

/datum/job/som/squad/medic/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_E3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_E4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_E5"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_S1"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_S2"

/datum/job/som/squad/medic/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou must tend the wounds of your squad mates and make sure they are healthy and active.
You may not be a fully-fledged doctor, but you stand between life and death when it matters."})

/datum/outfit/job/som/squad/medic
	name = "SOM Medic"
	jobtype = /datum/job/som/squad/medic

	id = /obj/item/card/id/dogtag/som


/datum/job/som/squad/veteran
	title = SOM_SQUAD_VETERAN
	paygrade = "SOM_S1"
	comm_title = "Vet"
	total_positions = 8
	skills_type = /datum/skills/crafty //smarter than the average bear
	display_order = JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER
	minimap_icon = "smartgunner"
	outfit = /datum/outfit/job/som/squad/veteran
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(/datum/job/xenomorph = LARVA_POINTS_REGULAR)
	html_description = {"
		<b>Difficulty</b>: Medium<br /><br />
		<b>You answer to the</b> acting Squad Leader<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Combat patrol and Sensor Capture<br /><br /><br />
		You are a seasoned veteran of the SOM. You have fought and bled for the cause, proving your self a true Son of Mars. As fitting reward for your service, you are entrusted with best arms and equipment the SOM can offer, and you are expected to serve as an example to your fellow soldier.
		<br /><br />
		<b>Duty</b>: Show your comrades how a true Son of Mars acts, and crush our enemies without mercy!.
	"}

/datum/job/som/squad/veteran/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(new_mob))
		return
	var/mob/living/carbon/human/new_human = new_mob
	var/playtime_mins = user?.client?.get_exp(title)
	if(!playtime_mins || playtime_mins < 1 )
		return
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_S1"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_S2"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_S3"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_S4"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_S5"

/datum/job/som/squad/veteran/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are the a Veteran among the SOM. With your long experience (and better training and equipment), your job is to provide special weapons support to bolster the line."})

/datum/outfit/job/som/squad/veteran
	name = "SOM Veteran"
	jobtype = /datum/job/som/squad/veteran
	id = /obj/item/card/id/dogtag/som

/datum/job/som/squad/leader
	title = SOM_SQUAD_LEADER
	req_admin_notify = TRUE
	paygrade = "SOM_S3"
	comm_title = JOB_COMM_TITLE_SQUAD_LEADER
	total_positions = 4
	supervisors = "the acting field commander"
	minimap_icon = "leader"
	skills_type = /datum/skills/sl
	display_order = JOB_DISPLAY_ORDER_SQUAD_LEADER
	outfit = /datum/outfit/job/som/squad/leader
	exp_requirements = XP_REQ_INTERMEDIATE
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Hard<br /><br />
		<b>You answer to the</b> acting Command Staff<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Combat patrol and Sensor Capture<br /><br /><br />
		Squad Leaders are basically the boss of any able-bodied squad. Though while they are not trained compared to engineers, corpsmen and smartgunners, they are (usually) capable of leading the squad. They can issue orders to bolster their soldiers, and are expected to confidentally lead them to victory.
		<br /><br />
		<b>Duty</b>: Be a responsible leader of your squad, make sure your squad communicates frequently all the time and ensure they are working together for the task at hand. Stay safe, as you’re a valuable leader.
	"}

/datum/job/som/squad/leader/after_spawn(mob/living/carbon/C, mob/user, latejoin = FALSE)
	. = ..()
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/new_human = C
	var/playtime_mins = user?.client?.get_exp(title)
	switch(playtime_mins)
		if(0 to 1500) // starting
			new_human.wear_id.paygrade = "SOM_S3"
		if(1501 to 6000) // 25 hrs
			new_human.wear_id.paygrade = "SOM_S4"
		if(6001 to 18000) // 100 hrs
			new_human.wear_id.paygrade = "SOM_S5"
		if(18001 to 30000) // 300 hrs
			new_human.wear_id.paygrade = "SOM_W1"
		if(30001 to INFINITY) // 500 hrs
			new_human.wear_id.paygrade = "SOM_W2"
	if(!latejoin)
		return
	if(!new_human.assigned_squad)
		return
	if(new_human.assigned_squad.squad_leader != new_human)
		if(new_human.assigned_squad.squad_leader)
			new_human.assigned_squad.demote_leader()
		new_human.assigned_squad.promote_leader(new_human)

/datum/job/som/squad/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are responsible for the men and women of your squad. Make sure they are on task, working together, and communicating.
You are also in charge of communicating with command and letting them know about the situation first hand. Keep out of harm's way."})

/datum/outfit/job/som/squad/leader
	name = "SOM Leader"
	jobtype = /datum/job/som/squad/leader

	id = /obj/item/card/id/dogtag/som
