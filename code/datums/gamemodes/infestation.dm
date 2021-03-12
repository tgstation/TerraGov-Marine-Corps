/datum/game_mode/infestation

/datum/game_mode/infestation/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
	scaled_job.job_points_needed  = 20 //For every 10 marine late joins, 1 extra SG

/datum/game_mode/infestation/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/synth)
	scaled_job.job_points_needed  = 40 //For every 40 marines there will be 1 extra Synth.