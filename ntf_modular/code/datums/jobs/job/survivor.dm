//Non-Deployed Operative Survivor
/datum/job/survivor/non_deployed_operative
	title = "Non-Deployed Operative Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/non_deployed_operative

//Prisoner Survivor
/datum/job/survivor/prisoner
	title = "Prisoner Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/prisoner

//Stripper Survivor
/datum/job/survivor/stripper
	title = "Stripper Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/stripper

//Maid Survivor
/datum/job/survivor/maid
	title = "Maid Survivor"
	skills_type = /datum/skills/civilian/survivor
	outfit = /datum/outfit/job/survivor/maid


//Robot(ic) Survivor
/datum/job/survivor/synth
	title = "Synthetic Survivor"
	paygrade = "Mk.I"
	supervisors = "the acting captain, Ninetails."
	skills_type = /datum/skills/synthetic
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
	outfit = /datum/outfit/job/survivor/synth
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP

	html_description = {"
		<b>Difficulty</b>: Soul Crushing<br /><br />
		<b>You answer to the</b> acting Command Staff and the NTC<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		<b>Duty</b>: Support and assist other survivors and the Nine Tailed Fox, use your incredibly developed skills to help the marines during their missions. You can talk to other synthetics or the AI on the :n channel. Serve your purpose.
	"}
	minimap_icon = "synth"

/datum/job/survivor/synth/get_special_name(client/preference_source)
	return preference_source.prefs.synthetic_name

/datum/job/survivor/synth/return_spawn_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /mob/living/carbon/human/species/early_synthetic
	if(prefs?.synthetic_type == "Robot")
		switch(prefs?.robot_type)
			if("Basic")
				return /mob/living/carbon/human/species/robot
			if("Hammerhead")
				return /mob/living/carbon/human/species/robot/alpharii
			if("Chilvaris")
				return /mob/living/carbon/human/species/robot/charlit
			if("Ratcher")
				return /mob/living/carbon/human/species/robot/deltad
			if("Sterling")
				return /mob/living/carbon/human/species/robot/bravada
	return /mob/living/carbon/human/species/synthetic

/datum/job/survivor/synth/return_skills_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /datum/skills/early_synthetic
	return ..()

/datum/job/survivor/synth/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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
	. += "Your primary job is to support and assist all survivors, NTC departments and personnel. \
		In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship."
