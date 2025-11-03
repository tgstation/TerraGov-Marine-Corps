/datum/hive_status
	var/req_jelly_progress_required = 110 // 550 seconds =  9.17 minutes per pod
	var/list/req_jelly_pods = list()
	var/health_mulitiplier = 1
	var/melee_multiplier = 1
	var/aura_multiplier = 1

/datum/hive_status/proc/set_health_multiplier(new_health_multiplier)
	health_mulitiplier = new_health_multiplier
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[hivenumber])
		xeno.apply_health_stat_buff()

/datum/hive_status/proc/set_melee_multiplier(new_melee_multiplier)
	melee_multiplier = new_melee_multiplier
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[hivenumber])
		xeno.apply_melee_stat_buff()

/datum/hive_status/corrupted
	health_mulitiplier = 0.8
	aura_multiplier = 0.95
	req_jelly_progress_required = 220 // 1100 seconds = 18.3 minutes per pod

/mob/living/proc/transfer_to_hive(_hivenumber)
	hivenumber = _hivenumber
