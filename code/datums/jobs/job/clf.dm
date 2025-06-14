/datum/job/clf
	access = list(ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	minimal_access = list(ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	skills_type = /datum/skills/crafty
	faction = FACTION_CLF
	shadow_languages = list(/datum/language/xenocommon)
	job_category = JOB_CAT_MARINE

/datum/job/clf/after_spawn(mob/living/carbon/C, mob/M, latejoin = FALSE)
	. = ..()
	C.hivenumber = XENO_HIVE_NORMAL
	SSminimaps.add_marker(C, MINIMAP_FLAG_MARINE_CLF, image('ntf_modular/icons/UI_icons/map_blips.dmi', null, comm_title))
	var/datum/action/minimap/clf/mini = new
	mini.give_action(C)

/datum/job/clf/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"As a CLF member you are a ex NTC worker, now a servant of Xenomorphs, they are superior, evolved beings that you must serve.
You can understand but not speak xeno language but they can understand your language already, Obey your Xenomorph masters.
Your primary goal is to serve the hive, and ultimate goal is to liberate the colonies from all occupational forces so the Xenos may reclaim the lands, and breed your kind forever."}

//CLF Standard
/datum/job/clf/standard
	title = "CLF Standard"
	paygrade = "CLF1"
	comm_title = "CLF1"
	outfit = /datum/outfit/job/clf/standard/uzi
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/standard/uzi,
		/datum/outfit/job/clf/standard/skorpion,
		/datum/outfit/job/clf/standard/mpi_km,
		/datum/outfit/job/clf/standard/shotgun,
		/datum/outfit/job/clf/standard/garand,
		/datum/outfit/job/clf/standard/fanatic,
		/datum/outfit/job/clf/standard/som_smg,
	)

//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	comm_title = "CLF2"
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/clf/medic/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/medic/uzi,
		/datum/outfit/job/clf/medic/skorpion,
		/datum/outfit/job/clf/medic/paladin,
	)
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)

//CLF Specialist
/datum/job/clf/specialist
	title = "CLF Specialist"
	paygrade = "CLF4"
	comm_title = "CLF4"
	skills_type = /datum/skills/crafty
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	outfit = /datum/outfit/job/clf/specialist
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/specialist/dpm,
		/datum/outfit/job/clf/specialist/clf_heavyrifle,
		/datum/outfit/job/clf/specialist/clf_heavymachinegun,
	)


//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF3"
	comm_title = "CLF3"
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	skills_type = /datum/skills/sl/clf
	outfit = /datum/outfit/job/clf/leader/assault_rifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/leader/assault_rifle,
		/datum/outfit/job/clf/leader/mpi_km,
		/datum/outfit/job/clf/leader/som_rifle,
		/datum/outfit/job/clf/leader/upp_rifle,
		/datum/outfit/job/clf/leader/lmg_d,
	)
/datum/job/clf/breeder
	title = "CLF Breeder"
	paygrade = "CLF0"
	comm_title = "CLF0"
	outfit = /datum/outfit/job/clf/breeder
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_ADDTOMANIFEST
	multiple_outfits = FALSE

/datum/job/clf/silicon
	job_category = JOB_CAT_SILICON
	selection_color = "#aaee55"

//synthetic
/datum/job/clf/silicon/synthetic/clf
	title = "CLF Synthetic"
	req_admin_notify = TRUE
	comm_title = "Syn"
	paygrade = "Mk.I"
	supervisors = "the xenomorphs and CLF"
	total_positions = 1
	skills_type = /datum/skills/synthetic
	access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	minimal_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CLF_CARGO, ACCESS_CLF_TADPOLE)
	display_order = JOB_DISPLAY_ORDER_SYNTHETIC
	outfit = /datum/outfit/job/civilian/synthetic/clf
	exp_requirements = XP_REQ_EXPERIENCED
	exp_type = EXP_TYPE_REGULAR_ALL
	job_flags = JOB_FLAG_SPECIALNAME|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_ISCOMMAND|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_ALWAYS_VISIBLE_ON_MINIMAP
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_SHIPSIDE_STRONG,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)
	html_description = {"
		<b>Difficulty</b>: Soul Crushing<br /><br />
		<b>You answer to the</b> acting Command Staff and the human crew<br /><br />
		<b>Unlock Requirement</b>: Starting Role<br /><br />
		<b>Gamemode Availability</b>: Crash, Nuclear War<br /><br /><br />
		<b>Duty</b>: Be a synthussy.
	"}
	minimap_icon = "synth"

/datum/job/clf/silicon/synthetic/clf/get_special_name(client/preference_source)
	return preference_source.prefs.synthetic_name

/datum/job/clf/silicon/synthetic/clf/return_spawn_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /mob/living/carbon/human/species/early_synthetic
	return /mob/living/carbon/human/species/synthetic

/datum/job/clf/silicon/synthetic/clf/return_skills_type(datum/preferences/prefs)
	if(prefs?.synthetic_type == "Early Synthetic")
		return /datum/skills/early_synthetic
	return ..()

/datum/job/clf/silicon/synthetic/clf/after_spawn(mob/living/carbon/new_mob, mob/user, latejoin = FALSE)
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

/datum/job/clf/silicon/synthetic/clf/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"Your primary job is to support and assist all clf departments and personnel on-board.
In addition, being a Synthetic gives you knowledge in every field and specialization possible on-board the ship."}
