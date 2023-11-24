GLOBAL_DATUM_INIT(datacore, /datum/datacore, new)

/datum/data
	var/name = "data"


/datum/data/record
	name = "record"
	var/list/fields = list()


/datum/datacore
	var/list/medical = list()
	var/list/general = list()
	var/list/security = list()


// TODO: cleanup
/datum/datacore/proc/get_manifest(monochrome, ooc)
	var/list/eng = list()
	var/list/med = list()
	var/list/mar = list()
	var/list/heads = list()
	var/list/misc = list()
	var/list/isactive = list()
	var/list/squads = list()
	var/list/support = list()

	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"white":"#24252A; background-color:#1B1C1E; color:white"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #123C5E; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #123C5E;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #36373C"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Rank</th><th>Name</th><th>Activity</th></tr>
	"}

	var/even = 0
	// sort mobs

	for(var/datum/data/record/t in GLOB.datacore.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/squad_name = t.fields["squad"]

		if(ooc)
			var/active = 0
			for(var/mob/M in GLOB.player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 * 60 * 10)
					active = 1
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = t.fields["p_stat"]

		var/department = 0
		if(GLOB.jobs_command[rank])
			heads[name] = rank
			department = 1
		if(rank in GLOB.jobs_support)
			support[name] = rank
			department = 1
		if(rank in GLOB.jobs_engineering)
			eng[name] = rank
			department = 1
		if(rank in GLOB.jobs_medical)
			med[name] = rank
			department = 1
		if(rank in GLOB.jobs_marines)
			squads[name] = squad_name
			mar[name] = rank
			department = 1
		if(!department && !(name in heads) && (rank in GLOB.jobs_regular_all))
			misc[name] = rank
	if(length(heads) > 0)
		dat += "<tr><th colspan=3>Command</th></tr>"
		for(var/name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[heads[name]]</td><td>[name]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(support) > 0)
		dat += "<tr><th colspan=3>Auxiliary Support Staff</th></tr>"
		for(var/name in support)
			dat += "<tr[even ? " class='alt'" : ""]><td>[support[name]]</td><td>[name]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(mar) > 0)
		dat += "<tr><th colspan=3>Marine Personnel</th></tr>"
		for(var/j in LAZYACCESS(SSjob.squads_by_name, FACTION_TERRAGOV))
			if(length(squads[j]))
				dat += "<tr><th colspan=3>[j]</th></tr>"
			for(var/name in mar)
				if(squads[name] == j)
					dat += "<tr[even ? " class='alt'" : ""]><td>[mar[name]]</td><td>[name]</td><td>[isactive[name]]</td></tr>"
					even = !even
	if(length(eng) > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(var/name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[eng[name]]</td><td>[name]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(med) > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(var/name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[med[name]]</td><td>[name]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// misc guys
	if(length(misc) > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(var/name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[misc[name]]</td><td>[name]</td><td>[isactive[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = replacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = replacetext(dat, "\t", "")

	return dat


/datum/datacore/proc/manifest()
	medical = list()
	general = list()
	security = list()
	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(!H.job || !(H.job.job_flags & JOB_FLAG_ADDTOMANIFEST))
			continue
		manifest_inject(H)
		CHECK_TICK


/datum/datacore/proc/manifest_update(oldname, newname, rank)
	var/found = FALSE
	for(var/list/L in list(GLOB.datacore.general, GLOB.datacore.medical, GLOB.datacore.security))
		for(var/i in L)
			var/datum/data/record/X = i
			if(X.fields["name"] != oldname)
				continue
			X.fields["name"] = newname
			X.fields["rank"] = rank
			found = TRUE

	return found


/datum/datacore/proc/manifest_modify(name, assignment)
	var/datum/data/record/foundrecord

	for(var/datum/data/record/t in GLOB.datacore.general)
		if (t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment


/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H)
	set waitfor = FALSE
	var/static/list/show_directions = list(SOUTH, WEST)
	if(!H.mind)
		return

	var/assignment
	if(H.job)
		assignment = H.job.title
	else
		assignment = "Unassigned"

	var/id = add_leading("[num2hex(randfloat(1, 1.6777215E7))]", 6, "0")	//this was the best they could come up with? A large random number? *sigh* - actual 4407 code lol

	//General Record
	var/datum/data/record/G = new()
	G.fields["id"] = id
	G.fields["name"] = H.real_name
	G.fields["rank"] = assignment
	G.fields["squad"] = H.assigned_squad ? H.assigned_squad.name : null
	G.fields["age"] = H.age
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["sex"] = H.gender
	G.fields["species"] = H.get_species()
	G.fields["citizenship"] = H.citizenship
	G.fields["religion"] = H.religion
	if(H.gen_record)
		G.fields["notes"] = H.gen_record
	else
		G.fields["notes"] = "No notes found."
	general += G

	//Medical Record
	var/datum/data/record/M = new()
	M.fields["id"] = id
	M.fields["name"] = H.real_name
	M.fields["b_type"] = H.b_type
	M.fields["mi_dis"] = "None"
	M.fields["mi_dis_d"] = "No minor disabilities have been declared."
	M.fields["ma_dis"] = "None"
	M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	M.fields["alg"] = "None"
	M.fields["alg_d"] = "No allergies have been detected in this patient."
	M.fields["cdi"] = "None"
	M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
	M.fields["last_scan_time"] = null
	M.fields["last_scan_result"] = "No scan data on record" // body scanner results
	M.fields["autodoc_data"] = list()
	M.fields["autodoc_manual"] = list()
	if(H.med_record)
		M.fields["notes"] = H.med_record
	else
		M.fields["notes"] = "No notes found."
	medical += M

	//Security Record
	var/datum/data/record/S = new()
	S.fields["id"] = id
	S.fields["name"] = H.real_name
	S.fields["criminal"] = "None"
	S.fields["mi_crim"] = "None"
	S.fields["mi_crim_d"] = "No minor crime convictions."
	S.fields["ma_crim"] = "None"
	S.fields["ma_crim_d"] = "No major crime convictions."
	S.fields["notes"] = "No notes."
	if(H.sec_record)
		S.fields["notes"] = H.sec_record
	else
		S.fields["notes"] = "No notes."
	security += S

/proc/CreateGeneralRecord()
	var/datum/data/record/G = new /datum/data/record()
	G.fields["name"] = "New Record"
	G.fields["id"] = "[num2hex(randfloat(1, 1.6777215E7), 6)]"
	G.fields["rank"] = "Unassigned"
	G.fields["real_rank"] = "Unassigned"
	G.fields["sex"] = "Male"
	G.fields["age"] = "Unknown"
	G.fields["ethnicity"] = "Unknown"
	G.fields["fingerprint"] = "Unknown"
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["species"] = "Human"
	G.fields["citizenship"] = "Unknown"
	G.fields["religion"] = "Unknown"
	G.fields["photo_front"] = null
	G.fields["photo_side"] = null
	GLOB.datacore.general += G
	return G


/proc/CreateSecurityRecord(name, id)
	var/datum/data/record/R = new
	R.fields["name"] = name
	R.fields["id"] = id
	R.name = "Security Record #[id]"
	R.fields["criminal"] = "None"
	R.fields["mi_crim"] = "None"
	R.fields["mi_crim_d"] = "No minor crime convictions."
	R.fields["ma_crim"] = "None"
	R.fields["ma_crim_d"] = "No major crime convictions."
	R.fields["notes"] = "No notes."
	GLOB.datacore.security += R
	return R


/proc/create_medical_record(mob/living/carbon/human/H)
	var/datum/data/record/M = new
	M.fields["id"] = null
	M.fields["name"] = H.real_name
	M.fields["b_type"] = H.b_type
	M.fields["mi_dis"] = "None"
	M.fields["mi_dis_d"] = "No minor disabilities have been declared."
	M.fields["ma_dis"] = "None"
	M.fields["ma_dis_d"] = "No major disabilities have been diagnosed."
	M.fields["alg"] = "None"
	M.fields["alg_d"] = "No allergies have been detected in this patient."
	M.fields["cdi"] = "None"
	M.fields["cdi_d"] = "No diseases have been diagnosed at the moment."
	M.fields["last_scan_time"] = 0
	M.fields["last_scan_result"] = "No scan data on record"
	M.fields["autodoc_data"] = list()
	M.fields["autodoc_manual"] = list()
	GLOB.datacore.medical += M
	return M
