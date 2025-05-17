//militia jobs
/datum/job/som/mercenary/militia
	title = "Colonial militia standard"
	paygrade = "militia1"
	comm_title = "MIL"
	minimap_icon = "militia"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	html_description = {"
		<b>Difficulty</b>:Moderate<br /><br />
		<b>You answer to the</b> commanding officer<br /><br />
		<b>Duty</b>: Help defend your colony by supporting your sympathetic faction. Follow their instructions and help achieve their goals.
	"}
	job_cost = 0
	multiple_outfits = TRUE

/datum/job/som/mercenary/militia/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += "You are a volunteer member of a local militia group. You are lending your support to the faction you believe is truly helping your colony. What you lack in equipment and military training you make up in bravery and conviction. Fight for Blood! Fight for home!"

/datum/job/som/mercenary/militia/standard
	outfit = /datum/outfit/job/som/militia/standard/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/militia/standard/uzi,
		/datum/outfit/job/som/militia/standard/skorpion,
		/datum/outfit/job/som/militia/standard/mpi_km,
		/datum/outfit/job/som/militia/standard/shotgun,
		/datum/outfit/job/som/militia/standard/fanatic,
		/datum/outfit/job/som/militia/standard/som_smg,
		/datum/outfit/job/som/militia/standard/mpi_grenadier,
	)

/datum/job/som/mercenary/militia/medic
	title = "Militial Medic"
	paygrade = "militia2"
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/som/militia/medic/uzi
	outfits = list(
		/datum/outfit/job/som/militia/medic/uzi,
		/datum/outfit/job/som/militia/medic/skorpion,
		/datum/outfit/job/som/militia/medic/paladin,
	)

/datum/job/som/mercenary/militia/leader
	title = "Militia Leader"
	paygrade = "militia3"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/som/militia/leader/assault_rifle
	outfits = list(
		/datum/outfit/job/som/militia/leader/assault_rifle,
		/datum/outfit/job/som/militia/leader/mpi_km,
		/datum/outfit/job/som/militia/leader/som_rifle,
		/datum/outfit/job/som/militia/leader/upp_rifle,
		/datum/outfit/job/som/militia/leader/lmg_d,
	)

//Freelancers
/datum/job/freelancer/standard/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "FL"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/freelancer/standard/one/campaign,
		/datum/outfit/job/freelancer/standard/two/campaign,
		/datum/outfit/job/freelancer/standard/three/campaign,
	)

/datum/job/freelancer/medic/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "FL"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfit = /datum/outfit/job/freelancer/medic/campaign

/datum/job/freelancer/grenadier/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "FL"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	outfits = list(
		/datum/outfit/job/freelancer/grenadier/one/campaign,
		/datum/outfit/job/freelancer/grenadier/two/campaign,
	)
	job_cost = 0

/datum/job/freelancer/leader/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "FL"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	outfits = list(
		/datum/outfit/job/freelancer/leader/one/campaign,
		/datum/outfit/job/freelancer/leader/two/campaign,
	)
	job_cost = 0

//PMC
/datum/job/pmc/standard/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "PMC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfit = /datum/outfit/job/pmc/standard/campaign

/datum/job/pmc/gunner/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "PMC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfit = /datum/outfit/job/pmc/gunner/campaign

/datum/job/pmc/leader/campaign_bonus
	faction = FACTION_TERRAGOV
	comm_title = "PMC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfit = /datum/outfit/job/pmc/leader/campaign

//ICC
/datum/job/icc/standard/campaign_bonus
	faction = FACTION_SOM
	comm_title = "ICC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/icc/standard/mpi_km/campaign,
		/datum/outfit/job/icc/standard/icc_pdw/campaign,
		/datum/outfit/job/icc/standard/icc_battlecarbine/campaign,
	)

/datum/job/icc/guard/campaign_bonus
	faction = FACTION_SOM
	comm_title = "ICC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/icc/guard/coilgun/campaign,
		/datum/outfit/job/icc/guard/icc_autoshotgun/campaign,
	)


/datum/job/icc/medic/campaign_bonus
	faction = FACTION_SOM
	comm_title = "ICC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/icc/medic/icc_machinepistol/campaign,
		/datum/outfit/job/icc/medic/icc_sharpshooter/campaign,
	)

/datum/job/icc/leader/campaign_bonus
	faction = FACTION_SOM
	comm_title = "ICC"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/icc/leader/icc_heavyshotgun/campaign,
		/datum/outfit/job/icc/leader/icc_confrontationrifle/campaign,
	)

/datum/outfit/job/icc/leader/icc_heavyshotgun/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/leader/icc_confrontationrifle/campaign
	ears = /obj/item/radio/headset/mainship/som

//TGMC combat robots
/datum/job/terragov/squad/standard/campaign_robot
	title = SQUAD_ROBOT
	outfit = /datum/outfit/job/tgmc/campaign_robot
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/tgmc/campaign_robot/machine_gunner,
		/datum/outfit/job/tgmc/campaign_robot/guardian,
		/datum/outfit/job/tgmc/campaign_robot/jetpack,
		/datum/outfit/job/tgmc/campaign_robot/laser_mg,
	)
	job_cost = 0

/datum/job/terragov/squad/standard/campaign_robot/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are a cold, unfeeling machine built for war, controlled by TGMC.
Your metal body is immune to pain and chemical warfare, and resistant against fire and radiation, although you lack the mobility of your human counterparts.
Fight for TGMC, and attempt to achieve all objectives given to you."}


//VSD
/datum/job/vsd/standard/campaign_bonus
	faction = FACTION_SOM
	comm_title = "VSD"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/vsd/standard/grunt_one/campaign,
		/datum/outfit/job/vsd/standard/ksg/campaign,
		/datum/outfit/job/vsd/standard/grunt_second/campaign,
		/datum/outfit/job/vsd/standard/grunt_third/campaign,
		/datum/outfit/job/vsd/standard/lmg/campaign,
		/datum/outfit/job/vsd/standard/upp/campaign,
		/datum/outfit/job/vsd/standard/upp_second/campaign,
		/datum/outfit/job/vsd/standard/upp_third/campaign,
	)


/datum/job/vsd/spec/campaign_bonus
	faction = FACTION_SOM
	comm_title = "VSD"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/vsd/spec/demolitionist/campaign,
		/datum/outfit/job/vsd/spec/gunslinger/campaign,
		/datum/outfit/job/vsd/spec/uslspec_one/campaign,
		/datum/outfit/job/vsd/spec/uslspec_two/campaign,
		/datum/outfit/job/vsd/spec/machinegunner/campaign,
	)

/datum/job/vsd/medic/campaign_bonus
	faction = FACTION_SOM
	comm_title = "VSD"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/vsd/medic/ksg/campaign,
		/datum/outfit/job/vsd/medic/vsd_rifle/campaign,
		/datum/outfit/job/vsd/medic/vsd_carbine/campaign,
	)


/datum/job/vsd/engineer/campaign_bonus
	faction = FACTION_SOM
	comm_title = "VSD"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/vsd/engineer/l26/campaign,
		/datum/outfit/job/vsd/engineer/vsd_rifle/campaign,
	)


/datum/job/vsd/juggernaut/campaign_bonus
	faction = FACTION_SOM
	comm_title = "VSD"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/vsd/juggernaut/ballistic/campaign,
		/datum/outfit/job/vsd/juggernaut/eod/campaign,
		/datum/outfit/job/vsd/juggernaut/flamer/campaign,
	)


/datum/job/vsd/leader/campaign_bonus
	faction = FACTION_SOM
	comm_title = "VSD"
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS
	job_cost = 0
	outfits = list(
		/datum/outfit/job/vsd/leader/one/campaign,
		/datum/outfit/job/vsd/leader/two/campaign,
		/datum/outfit/job/vsd/leader/upp_three/campaign,
	)


