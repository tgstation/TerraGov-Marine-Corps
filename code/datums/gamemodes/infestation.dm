/datum/game_mode/infestation
	var/round_stage = INFESTATION_MARINE_DEPLOYMENT
	var/bioscan_current_interval = 45 MINUTES
	var/bioscan_ongoing_interval = 20 MINUTES
	var/orphan_hive_timer

/datum/game_mode/infestation/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
	scaled_job.job_points_needed  = 20 //For every 10 marine late joins, 1 extra SG
