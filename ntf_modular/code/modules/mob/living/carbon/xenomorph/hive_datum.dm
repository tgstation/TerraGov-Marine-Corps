/datum/hive_status
	var/req_jelly_progress_required = 110 // 550 seconds =  9.17 minutes per pod
	var/list/req_jelly_pods = list()

/datum/hive_status/corrupted
	req_jelly_progress_required = 220 // 1100 seconds = 18.3 minutes per pod