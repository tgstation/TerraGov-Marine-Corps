SUBSYSTEM_DEF(spawning_pool)
	name = "spawning pool"
	wait = 1 MINUTES
	can_fire = FALSE
	init_order = INIT_ORDER_SPAWNING_POOL
	///The max amount of spawning pools that can spawn free larvas
	var/max_spawning_pool_spawning = 0

/datum/controller/subsystem/spawning_pool/Initialize(timeofday)
	addtimer(VARSET_CALLBACK(src, can_fire, TRUE), START_FREE_SPAWNING)

/datum/controller/subsystem/spawning_pool/fire(resumed = 0)
	if(!CHECK_BITFIELD(SSticker.mode.flags_round_type, MODE_XENO_FREE_RESPAWN))
		can_fire = FALSE
		return
	adjust_max_spawning_pool_number()
	add_larvas()


///Adjust the maxinum number of spawning_pool able to spawn larvas for free, to preven xenos to just spawn them
/datum/controller/subsystem/spawning_pool/proc/adjust_max_spawning_pool_number()
	switch(TGS_CLIENT_COUNT)
		if(0 to 20)
			max_spawning_pool_spawning = 3
		if(20 to 40)
			max_spawning_pool_spawning = 4
		if(40 to 60)
			max_spawning_pool_spawning = 6
		if(60 to INFINITY)
			max_spawning_pool_spawning = 8	

///Add larvas job 
/datum/controller/subsystem/spawning_pool/proc/add_larvas()
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	xeno_job.add_job_points(min(LARVA_SPAWN_RATE*GLOB.xeno_resin_spawning_pools.len, LARVA_SPAWN_RATE*MAX_NUMBER_SPAWNING_POOL_GENERATING))	
