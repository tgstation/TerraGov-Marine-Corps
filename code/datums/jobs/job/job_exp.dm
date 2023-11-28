GLOBAL_LIST_EMPTY(exp_to_update)
GLOBAL_PROTECT(exp_to_update)


/datum/job/proc/required_playtime_remaining(client/C)
	if(!C)
		return FALSE
	if(!CONFIG_GET(flag/use_exp_tracking))
		return FALSE
	if(!SSdbcore.Connect())
		return FALSE
	if(!exp_requirements || !exp_type)
		return FALSE
	if(!job_is_xp_locked(src))
		return FALSE
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_other_rights(C, R_ADMIN, FALSE))
		return FALSE
	var/my_exp = C.calc_exp_type(get_exp_req_type())
	var/job_requirement = get_exp_req_amount()
	if(my_exp >= job_requirement)
		return FALSE
	else
		return (job_requirement - my_exp)


/datum/job/proc/get_exp_req_amount()
	if(job_flags & JOB_FLAG_ISCOMMAND)
		var/uerhh = CONFIG_GET(number/use_exp_restrictions_command_hours)
		if(uerhh)
			return uerhh * 60
	return exp_requirements


/datum/job/proc/get_exp_req_type()
	if(job_flags & JOB_FLAG_ISCOMMAND)
		if(CONFIG_GET(flag/use_exp_restrictions_command_department) && exp_type_department)
			return exp_type_department
	return exp_type


/proc/job_is_xp_locked(datum/job/job)
	if(!CONFIG_GET(flag/use_exp_restrictions_command) && job.job_flags & JOB_FLAG_ISCOMMAND)
		return FALSE
	if(!CONFIG_GET(flag/use_exp_restrictions_other) && !(job.job_flags & JOB_FLAG_ISCOMMAND))
		return FALSE
	return TRUE


/client/proc/calc_exp_type(exptype)
	var/list/explist = prefs.exp.Copy()
	var/amount = 0
	var/list/typelist = GLOB.exp_jobsmap[exptype]
	if(!typelist)
		return 0
	for(var/job in typelist["titles"])
		if(job in explist)
			amount += explist[job]
	return amount


/client/proc/get_exp_report()
	if(!CONFIG_GET(flag/use_exp_tracking))
		return "Tracking is disabled in the server configuration file."
	var/list/play_records = prefs.exp
	if(!length(play_records))
		set_exp_from_db()
		play_records = prefs.exp
		if(!length(play_records))
			return "[key] has no records."
	var/return_text = list()
	return_text += "<UL>"
	var/list/exp_data = list()
	for(var/category in SSjob.name_occupations)
		if(!(category in GLOB.jobs_regular_all))
			continue
		if(play_records[category])
			exp_data[category] = text2num(play_records[category])
		else
			exp_data[category] = 0
	for(var/category in GLOB.exp_specialmap)
		if(category == EXP_TYPE_SPECIAL)
			if(GLOB.exp_specialmap[category])
				for(var/innercat in GLOB.exp_specialmap[category])
					if(play_records[innercat])
						exp_data[innercat] = text2num(play_records[innercat])
					else
						exp_data[innercat] = 0
		else
			if(play_records[category])
				exp_data[category] = text2num(play_records[category])
			else
				exp_data[category] = 0

	for(var/dep in exp_data)
		if(exp_data[dep] <= 0)
			continue
		if(exp_data[EXP_TYPE_LIVING] > 0 && (dep == EXP_TYPE_GHOST || dep == EXP_TYPE_LIVING))
			var/percentage = num2text(round(exp_data[dep] / (exp_data[EXP_TYPE_LIVING] + exp_data[EXP_TYPE_GHOST])  * 100))
			return_text += "<LI>[dep] [get_exp_format(exp_data[dep])] ([percentage]%) total.</LI>"
		else if(exp_data[EXP_TYPE_LIVING] > 0 && dep != EXP_TYPE_ADMIN)
			var/percentage = num2text(round(exp_data[dep] / exp_data[EXP_TYPE_LIVING] * 100))
			return_text += "<LI>[dep] [get_exp_format(exp_data[dep])] ([percentage]%) while alive.</LI>"
		else
			return_text += "<LI>[dep] [get_exp_format(exp_data[dep])] </LI>"

	for(var/mob_type AS in GLOB.xeno_caste_datums)
		var/datum/xeno_caste/caste_type = GLOB.xeno_caste_datums[mob_type][XENO_UPGRADE_BASETYPE]
		return_text += "<LI>[caste_type.caste_name] [get_exp_format(play_records[caste_type.caste_name])] while alive.</LI>"

	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_other_rights(src, R_ADMIN, FALSE))
		return_text += "<LI>Admin (all jobs auto-unlocked)</LI>"
	return_text += "</UL>"
	var/list/jobs_locked = list()
	var/list/jobs_unlocked = list()
	for(var/j in SSjob.joinable_occupations)
		var/datum/job/job = j
		if(job.exp_requirements && job.exp_type)
			if(!job_is_xp_locked(job))
				continue
			else if(!job.required_playtime_remaining(mob.client))
				jobs_unlocked += job.title
			else
				var/xp_req = job.get_exp_req_amount()
				jobs_locked += "[job.title] [get_exp_format(text2num(calc_exp_type(job.get_exp_req_type())))] / [get_exp_format(xp_req)] as [job.get_exp_req_type()])"
	if(length(jobs_unlocked))
		return_text += "<BR><BR>Jobs Unlocked:<UL><LI>"
		return_text += jobs_unlocked.Join("</LI><LI>")
		return_text += "</LI></UL>"
	if(length(jobs_locked))
		return_text += "<BR><BR>Jobs Not Unlocked:<UL><LI>"
		return_text += jobs_locked.Join("</LI><LI>")
		return_text += "</LI></UL>"
	return return_text


/client/proc/get_exp(role)
	var/list/play_records = prefs.exp
	if(!length(play_records))
		return 0
	return text2num(play_records[role])

/client/proc/get_exp_living(pure_numeric = FALSE)
	if(!prefs.exp)
		return pure_numeric ? 0 :"No data"
	var/exp_living = text2num(prefs.exp[EXP_TYPE_LIVING])
	return pure_numeric ? exp_living : get_exp_format(exp_living)


/proc/get_exp_format(expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h" + num2text(round(expnum % 60)) + "m"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "0h"


/proc/update_exp(mins, ann = FALSE)
	if(!SSdbcore.Connect())
		return -1
	for(var/client/L in GLOB.clients)
		if(L.is_afk())
			continue
		L.update_exp_list(mins, ann)


/proc/update_exp_db()
	set waitfor = FALSE
	var/list/old_minutes = GLOB.exp_to_update
	GLOB.exp_to_update = null
	SSdbcore.MassInsert(format_table_name("role_time"), old_minutes, duplicate_key = "ON DUPLICATE KEY UPDATE minutes = minutes + VALUES(minutes)")


/client/proc/set_exp_from_db()
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	var/datum/db_query/exp_read = SSdbcore.NewQuery("SELECT job, minutes FROM [format_table_name("role_time")] WHERE ckey = :ckey", list("ckey" = ckey))
	if(!exp_read.Execute(async = TRUE))
		qdel(exp_read)
		return -1
	var/list/play_records = list()
	while(exp_read.NextRow())
		play_records[exp_read.item[1]] = text2num(exp_read.item[2])
	qdel(exp_read)

	for(var/rtype in SSjob.name_occupations)
		if(!play_records[rtype])
			play_records[rtype] = 0
	for(var/rtype in GLOB.exp_specialmap)
		if(!play_records[rtype])
			play_records[rtype] = 0

	prefs.exp = play_records


/client/proc/update_exp_list(minutes, announce_changes = FALSE)
	if(!CONFIG_GET(flag/use_exp_tracking))
		return -1
	if(!SSdbcore.Connect())
		return -1
	if(!isnum(minutes))
		return -1
	var/list/play_records = list()

	if(holder && !holder.deadmined)
		play_records[EXP_TYPE_ADMIN] += minutes
		if(announce_changes)
			to_chat(src,span_notice("You got: [minutes] Admin EXP!"))

	if(isliving(mob))
		var/mob/living/living_mob = mob
		if(mob.stat != DEAD)
			play_records[EXP_TYPE_LIVING] += minutes
			if(announce_changes)
				to_chat(src,span_notice("You got: [minutes] Living EXP!"))
			if(living_mob.job)
				if(!istype(living_mob.job, /datum/job/fallen))
					if(isxeno(living_mob))
						var/mob/living/carbon/xenomorph/xeno = living_mob
						play_records[xeno.xeno_caste.caste_name] += minutes
					play_records[living_mob.job.title] += minutes
					if(announce_changes)
						to_chat(src,span_notice("You got: [minutes] [living_mob.job] EXP!"))
				else
					play_records["Valhalla"] += minutes
			else
				play_records["Unknown"] += minutes
		else
			play_records[EXP_TYPE_GHOST] += minutes
			if(announce_changes)
				to_chat(src,span_notice("You got: [minutes] Ghost EXP!"))
	else if(isobserver(mob))
		play_records[EXP_TYPE_GHOST] += minutes
		if(announce_changes)
			to_chat(src,span_notice("You got: [minutes] Ghost EXP!"))
	else if(minutes)	//Let "refresh" checks go through
		return

	for(var/jtype in play_records)
		var/jvalue = play_records[jtype]
		if (!jvalue)
			continue
		if (!isnum(jvalue))
			CRASH("invalid job value [jtype]:[jvalue]")
		LAZYINITLIST(GLOB.exp_to_update)
		GLOB.exp_to_update.Add(list(list(
			"job" = jtype,
			"ckey" = ckey,
			"minutes" = jvalue)))
		prefs.exp[jtype] += jvalue
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(update_exp_db)), 20, TIMER_OVERRIDE|TIMER_UNIQUE)


/proc/queen_age_check(client/C)
	if(!C.prefs?.exp)
		return FALSE
	if(!CONFIG_GET(flag/use_exp_tracking))
		return FALSE
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_other_rights(C, R_ADMIN, FALSE))
		return FALSE
	var/my_exp = C.prefs.exp[ROLE_XENOMORPH]
	return my_exp < XP_REQ_UNSEASONED
