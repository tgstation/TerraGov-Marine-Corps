
/proc/get_total_marines()
	var/count = 0
	var/mob/M
	for(M in player_list)
		if(ishuman(M) && M.mind && !M.mind.special_role) count++
	return count

// https://docs.google.com/spreadsheets/d/1PlnIwKhq-bVWWFPoBrzWYh1mWK04pyBSQUtUMEw3qSw/edit#gid=1290768907

/proc/job_slot_formula(var/marine_count,var/factor,var/c,var/min,var/max)
	return round(CLAMP((marine_count/factor)+c, min, max))

/proc/medic_slot_formula(var/playercount)
	return job_slot_formula(playercount,40,1,3,5)

/proc/engi_slot_formula(var/playercount)
	return job_slot_formula(playercount,50,1,2,4)

/proc/mp_slot_formula(var/playercount)
	return job_slot_formula(playercount,25,2,4,8)

/proc/po_slot_formula(var/playercount)
	return job_slot_formula(playercount,35,1,2,4)

/proc/so_slot_formula(var/playercount)
	return job_slot_formula(playercount,50,2,4,5)

/proc/doc_slot_formula(var/playercount)
	return job_slot_formula(playercount,25,1,4,6)

/proc/rsc_slot_formula(var/playercount)
	return job_slot_formula(playercount,60,0,1,2)

/proc/mt_slot_formula(var/playercount)
	return job_slot_formula(playercount,60,1,2,4)

/proc/ct_slot_formula(var/playercount)
	return job_slot_formula(playercount,30,0,2,3)
