/datum/game_mode/infestation

	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/silicon/synthetic)
	scaled_job.job_points_needed  = 40 //For every 40 marines there will be 1 extra Synth