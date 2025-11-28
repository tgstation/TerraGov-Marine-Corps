/datum/hive_status
	var/req_jelly_progress_required = 110 // 550 seconds =  9.17 minutes per pod
	var/list/req_jelly_pods = list()
	var/health_mulitiplier = 1
	var/melee_multiplier = 1
	var/aura_multiplier = 1
	COOLDOWN_DECLARE(silo_shock_cooldown)

/datum/hive_status/proc/set_health_multiplier(new_health_multiplier)
	health_mulitiplier = new_health_multiplier
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[hivenumber])
		xeno.apply_health_stat_buff()

/datum/hive_status/proc/set_melee_multiplier(new_melee_multiplier)
	melee_multiplier = new_melee_multiplier
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[hivenumber])
		xeno.apply_melee_stat_buff()

/datum/hive_status/proc/trigger_silo_shock(obj/structure/xeno/silo/last_silo)
	if(!COOLDOWN_FINISHED(src, silo_shock_cooldown))
		return
	COOLDOWN_START(src, silo_shock_cooldown, 4 MINUTES)
	for(var/mob/living/carbon/xenomorph/xeno AS in GLOB.alive_xeno_list_hive[hivenumber])
		xeno.Paralyze(50 SECONDS) // 10 seconds after xeno stun resistance
		xeno.apply_status_effect(/datum/status_effect/shatter, 60 SECONDS)
		xeno.apply_status_effect(/datum/status_effect/nohealthregen, 40 SECONDS)
	xeno_message("Our last silo [last_silo] is besieged at [AREACOORD_NO_Z(last_silo)]! The shock of sustaining it brings us to our knees!", "xenoannounce", 7, TRUE, last_silo.loc, 'sound/voice/alien/help2.ogg',FALSE, null, /atom/movable/screen/arrow/silo_damaged_arrow)

/datum/hive_status/corrupted
	health_mulitiplier = 0.8
	aura_multiplier = 0.95
	req_jelly_progress_required = 220 // 1100 seconds = 18.3 minutes per pod

/mob/living/proc/transfer_to_hive(_hivenumber)
	hivenumber = _hivenumber
