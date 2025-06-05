/datum/job/vsd
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_VSD
	minimap_icon = "pmc2"

//VSD Standard
/datum/job/vsd/standard
	title = "VSD Standard"
	paygrade = "VSD1"
	outfit = /datum/outfit/job/vsd/standard/grunt_one
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/standard/grunt_one,
		/datum/outfit/job/vsd/standard/ksg,
		/datum/outfit/job/vsd/standard/grunt_second,
		/datum/outfit/job/vsd/standard/grunt_third,
		/datum/outfit/job/vsd/standard/lmg,
		/datum/outfit/job/vsd/standard/upp,
		/datum/outfit/job/vsd/standard/upp_second,
		/datum/outfit/job/vsd/standard/upp_third,
	)

//VSD Engineer
/datum/job/vsd/engineer
	title = "VSD Engineer"
	paygrade = "VSD3"
	skills_type = /datum/skills/combat_engineer
	outfit = /datum/outfit/job/vsd/engineer/l26
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/engineer/l26,
		/datum/outfit/job/vsd/engineer/vsd_rifle,
	)

//VSD Medic
/datum/job/vsd/medic
	title = "VSD Medic"
	paygrade = "VSD2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/vsd/medic/ksg
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/medic/ksg,
		/datum/outfit/job/vsd/medic/vsd_rifle,
		/datum/outfit/job/vsd/medic/vsd_carbine,
	)

//VSD Spec
/datum/job/vsd/spec
	title = "VSD Specialist"
	paygrade = "VSD4"
	skills_type = /datum/skills/crafty
	outfit = /datum/outfit/job/vsd/spec/demolitionist
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/spec/demolitionist,
		/datum/outfit/job/vsd/spec/gunslinger,
		/datum/outfit/job/vsd/spec/uslspec_one,
		/datum/outfit/job/vsd/spec/uslspec_two,
		/datum/outfit/job/vsd/spec/machinegunner,
	)


//VSD Juggernauts
/datum/job/vsd/juggernaut
	title = "VSD Juggernaut"
	paygrade = "VSD4"
	outfit = /datum/outfit/job/vsd/juggernaut
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/juggernaut/ballistic,
		/datum/outfit/job/vsd/juggernaut/eod,
		/datum/outfit/job/vsd/juggernaut/flamer,
	)

//VSD Squad Leader
/datum/job/vsd/leader
	job_category = JOB_CAT_COMMAND
	title = "VSD Squad Leader"
	paygrade = "VSD5"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/vsd/leader/one
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/vsd/leader/one,
		/datum/outfit/job/vsd/leader/two,
		/datum/outfit/job/vsd/leader/upp_three,
	)
