/datum/game_mode/infestation
	/// How often do the xenos get new larva to spawn from
	var/larva_check_interval = 0
	var/xeno_respawn_wave_timer = 30 MINUTES
	var/xeno_respawn_silo_reduction = 2 MINUTES

/datum/game_mode/infestation/post_setup()
	. = ..()
	spawn_resin_silos()


/datum/game_mode/infestation/process()
	. = ..()
	if(.)
		return
	// Burrowed Larva
	if((flags_round_type & MODE_XENO_RESPAWN_WAVE) && world.time > larva_check_interval)
		scale_burrowed_larva()

/datum/game_mode/infestation/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/terragov/squad/smartgunner)
	scaled_job.job_points_needed  = 20 //For every 10 marine late joins, 1 extra SG

/datum/game_mode/infestation/proc/spawn_resin_silos()
	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/structure/resin/silo(i)

/datum/game_mode/infestation/proc/scale_burrowed_larva()
	larva_check_interval = world.time + xeno_respawn_wave_timer

	var/datum/hive_status/normal/xeno_hive = GLOB.hive_datums[XENO_HIVE_NORMAL]
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/stored_larva = xeno_job.total_positions - xeno_job.current_positions
	var/num_xenos = xeno_hive.get_total_xeno_number() + stored_larva
	var/larvapoints = (get_total_joblarvaworth() - (num_xenos * xeno_job.job_points_needed )) / xeno_job.job_points_needed
	if(!num_xenos)
		if(!length(GLOB.xeno_resin_silos))
			check_finished(TRUE)
			return //RIP benos.
		if(stored_larva)
			return //No need for respawns nor to end the game. They can use their burrowed larvas.
		xeno_job.add_job_positions(max(1, round(larvapoints, 1))) //At least one, rounded to nearest integer if more.
		return
	if(round(larvapoints, 1) < 1)
		return //Things are balanced, no burrowed needed
	xeno_job.add_job_positions(round(larvapoints, 1)) //However many burrowed they can afford to buy, rounded to nearest integer.
