// Also see \code\modules\client\preferences.dm and change "limit" if any jobs become unselectable. Currently 16 max in each section (ENGSEC, MEDSCI, etc)

/proc/guest_jobbans(var/job)
	return (job in ROLES_COMMAND)

/*
/proc/get_job_datums()
	var/list/occupations = list()
	var/list/all_jobs = typesof(/datum/job)

	for(var/A in all_jobs)
		var/datum/job/job = new A()
		if(!job)	continue
		occupations += job

	return occupations

/proc/get_alternate_titles(var/job)
	var/list/jobs = get_job_datums()
	var/list/titles = list()

	for(var/datum/job/J in jobs)
		if(J.title == job)
			titles = J.alt_titles

	return titles

var/command_positions[] = list(
						"Commander",
						"Executive Officer",
						"Staff Officer",
						"Pilot Officer",
						"Military Police",
						"Corporate Liaison",
						"Requisitions Officer",
						"Chief Engineer",
						"Chief Medical Officer"
							)

var/engineering_positions[] = list(
							"Chief Engineer",
							"Maintenance Tech"
								)

var/cargo_positions[] = list(
						"Requisitions Officer",
						"Cargo Technician"
							)

var/medical_positions[] = list(
						"Chief Medical Officer",
						"Doctor",
						"Researcher"
							)

var/marine_squad_positions[] = list(
							"Squad Leader",
							"Squad Medic",
							"Squad Engineer",
							"Squad Marine",
							"Squad Specialist"
								)

var/all_squad_positions[] = list(
							"Alpha",
							"Bravo",
							"Charlie",
							"Delta"
							)

var/marine_unassigned_positions[] = list(
									"Squad Marine"
										)

*/