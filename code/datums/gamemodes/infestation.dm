/datum/game_mode/infestation

/datum/game_mode/infestation/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
	scaled_job.job_points_needed  = 6

	scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/specialist)
	scaled_job.job_points_needed  = 6
