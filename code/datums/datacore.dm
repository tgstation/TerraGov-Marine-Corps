GLOBAL_DATUM_INIT(datacore, /datum/datacore, new)


/datum/datacore
	var/list/medical = list()
	var/list/general = list()
	var/list/security = list()


/datum/datacore/proc/get_manifest(monochrome, ooc)
	var/list/eng = list()
	var/list/med = list()
	var/list/mar = list()
	var/list/heads = list()
	var/list/police = list()
	var/list/misc = list()
	var/list/isactive = list()
	var/list/squads = list()

	var/dat = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th><th>Activity</th></tr>
	"}

	var/even = 0
	// sort mobs

	for(var/datum/data/record/t in GLOB.datacore.general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]
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
		if(real_rank in JOBS_COMMAND)
			heads[name] = rank
			department = 1
		if(real_rank in JOBS_POLICE)
			police[name] = rank
			department = 1
		if(real_rank in JOBS_ENGINEERING)
			eng[name] = rank
			department = 1
		if(real_rank in JOBS_MEDICAL)
			med[name] = rank
			department = 1
		if(real_rank in JOBS_MARINES)
			squads[name] = squad_name
			mar[name] = rank
			department = 1
		if(!department && !(name in heads) && (real_rank in JOBS_REGULAR_ALL))
			misc[name] = rank
	if(length(heads) > 0)
		dat += "<tr><th colspan=3>Command Staff</th></tr>"
		for(var/name in heads)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(police) > 0)
		dat += "<tr><th colspan=3>Military Police</th></tr>"
		for(var/name in police)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[police[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(mar) > 0)
		dat += "<tr><th colspan=3>Marines</th></tr>"
		for(var/j in list("Alpha","Bravo","Charlie", "Delta"))
			dat += "<tr><th colspan=3>[j]</th></tr>"
			for(var/name in mar)
				if(squads[name] == j)
					dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[mar[name]]</td><td>[isactive[name]]</td></tr>"
					even = !even
	if(length(eng) > 0)
		dat += "<tr><th colspan=3>Engineering</th></tr>"
		for(var/name in eng)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(med) > 0)
		dat += "<tr><th colspan=3>Medical</th></tr>"
		for(var/name in med)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// misc guys
	if(length(misc) > 0)
		dat += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(var/name in misc)
			dat += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

	dat += "</table>"
	dat = oldreplacetext(dat, "\n", "") // so it can be placed on paper correctly
	dat = oldreplacetext(dat, "\t", "")

	return dat


/datum/datacore/proc/manifest()
	medical = list()
	general = list()
	security = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(!ishumanbasic(H))
			continue
		CHECK_TICK
		manifest_inject(H)


/datum/datacore/proc/manifest_update(oldname, newname, rank)
	var/found = FALSE
	for(var/list/L in list(GLOB.datacore.general, GLOB.datacore.medical, GLOB.datacore.security))
		for(var/i in L)
			var/datum/data/record/X = i
			if(X.fields["name"] != oldname)
				continue
			X.fields["name"] = newname
			X.fields["real_rank"] = rank
			X.fields["rank"] = rank
			found = TRUE

	return found


/datum/datacore/proc/manifest_modify(name, assignment, rank)
	var/datum/data/record/foundrecord

	for(var/datum/data/record/t in GLOB.datacore.general)
		if (t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["real_rank"] = rank


/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H)
	if(!H.mind)
		return

	var/assignment
	if(H.mind.assigned_role)
		assignment = H.mind.assigned_role
	else if(H.job)
		assignment = H.job
	else
		assignment = "Unassigned"

	var/id = add_zero(num2hex(rand(1, 1.6777215E7)), 6)	//this was the best they could come up with? A large random number? *sigh*

	var/icon/front = new(get_id_photo(H), dir = SOUTH)
	var/icon/side = new(get_id_photo(H), dir = WEST)
	//General Record
	var/datum/data/record/G = new()
	G.fields["id"]			= id
	G.fields["name"]		= H.real_name
	G.fields["real_rank"]	= H.mind.assigned_role
	G.fields["rank"]		= assignment
	G.fields["squad"]		= H.assigned_squad ? H.assigned_squad.name : null
	G.fields["age"]			= H.age
	G.fields["p_stat"]		= "Active"
	G.fields["m_stat"]		= "Stable"
	G.fields["sex"]			= H.gender
	G.fields["species"]		= H.get_species()
	G.fields["home_system"]	= H.home_system
	G.fields["citizenship"]	= H.citizenship
	G.fields["faction"]		= H.personal_faction
	G.fields["religion"]	= H.religion
	G.fields["photo_front"]	= front
	G.fields["photo_side"]	= side
	if(H.gen_record)
		G.fields["notes"] = H.gen_record
	else
		G.fields["notes"] = "No notes found."
	general += G

	//Medical Record
	var/datum/data/record/M = new()
	M.fields["id"]			= id
	M.fields["name"]		= H.real_name
	M.fields["b_type"]		= H.b_type
	M.fields["mi_dis"]		= "None"
	M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
	M.fields["ma_dis"]		= "None"
	M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
	M.fields["alg"]			= "None"
	M.fields["alg_d"]		= "No allergies have been detected in this patient."
	M.fields["cdi"]			= "None"
	M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
	M.fields["last_scan_time"]		= null
	M.fields["last_scan_result"]		= "No scan data on record" // body scanner results
	M.fields["autodoc_data"] = list()
	M.fields["autodoc_manual"] = list()
	if(H.med_record)
		M.fields["notes"] = H.med_record
	else
		M.fields["notes"] = "No notes found."
	medical += M

	//Security Record
	var/datum/data/record/S = new()
	S.fields["id"]			= id
	S.fields["name"]		= H.real_name
	S.fields["criminal"]	= "None"
	S.fields["mi_crim"]		= "None"
	S.fields["mi_crim_d"]	= "No minor crime convictions."
	S.fields["ma_crim"]		= "None"
	S.fields["ma_crim_d"]	= "No major crime convictions."
	S.fields["notes"]		= "No notes."
	if(H.sec_record)
		S.fields["notes"] = H.sec_record
	else
		S.fields["notes"] = "No notes."
	security += S


/proc/get_id_photo(mob/living/carbon/human/H, client/C, show_directions = list(SOUTH))
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	var/datum/preferences/P
	if(!C)
		C = H.client
	if(C)
		P = C.prefs
	return get_flat_human_icon(null, J, P, DUMMY_HUMAN_SLOT_MANIFEST, show_directions)


/proc/CreateGeneralRecord()
	var/datum/data/record/G = new /datum/data/record()
	G.fields["name"] = "New Record"
	G.fields["id"] = "[num2hex(rand(1, 1.6777215E7), 6)]"
	G.fields["rank"] = "Unassigned"
	G.fields["real_rank"] = "Unassigned"
	G.fields["sex"] = "Male"
	G.fields["age"] = "Unknown"
	G.fields["ethnicity"] = "Unknown"
	G.fields["fingerprint"] = "Unknown"
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["species"] = "Human"
	G.fields["home_system"]	= "Unknown"
	G.fields["citizenship"]	= "Unknown"
	G.fields["faction"]		= "Unknown"
	G.fields["religion"]	= "Unknown"
	G.fields["photo_front"] = new /icon()
	G.fields["photo_side"] = new /icon()
	GLOB.datacore.general += G
	return G


/proc/CreateSecurityRecord(name, id)
	var/datum/data/record/R = new
	R.fields["name"] = name
	R.fields["id"] = id
	R.name = text("Security Record #[id]")
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
	M.fields["id"]			= null
	M.fields["name"]		= H.real_name
	M.fields["b_type"]		= H.b_type
	M.fields["mi_dis"]		= "None"
	M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
	M.fields["ma_dis"]		= "None"
	M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
	M.fields["alg"]			= "None"
	M.fields["alg_d"]		= "No allergies have been detected in this patient."
	M.fields["cdi"]			= "None"
	M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
	M.fields["last_scan_time"] = 0
	M.fields["last_scan_result"] = "No scan data on record"
	M.fields["autodoc_data"] = list()
	M.fields["autodoc_manual"] = list()
	GLOB.datacore.medical += M
	return M