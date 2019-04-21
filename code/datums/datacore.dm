
/datum/datacore
	var/list/medical = list()
	var/list/general = list()
	var/list/security = list()

/datum/data/record
	name = "record"
	var/list/fields = list()
	var/datum/datacore/holder
	var/list/corelists

/datum/data/record/New(datum/datacore/nholder)
	. = ..()
	if(nholder)
		holder = nholder

/datum/data/record/Destroy()
	holder?.remove_record(src)
	return ..()

/datum/datacore/proc/manifest()
	delete_manifest()

/datum/datacore/proc/delete_manifest()
	QDEL_LIST(general)
	QDEL_LIST(medical)
	QDEL_LIST(security)

/datum/datacore/proc/manifest_update(oldname, newname, assignment, rank, field, value)
	var/datum/data/record/R = find_record(field ? field : "name", value ? value : oldname, general)
	if(!R)
		return FALSE
	if(assignment)
		R.fields["rank"] = assignment
	if(rank)
		R.fields["real_rank"] = rank
	if(newname)
		R.fields["name"] = newname
	return TRUE

/datum/datacore/proc/update_multiple_records(field, oldvalue, newvalue, ...)
	var/list/lrecords = args.Copy(4)
	for(var/A in lrecords)
		var/list/L = A
		var/datum/data/record/R = find_record(field, oldvalue, L)
		if(R)
			R.fields[field] = newvalue
			. = TRUE

/datum/datacore/proc/manifest_eject(mob/living/L, delete = TRUE)
	if(!L)
		return
	var/rID = L.dna?.unique_enzymes ? L.dna.unique_enzymes : null
	var/datum/data/record/G = find_record(rID ? "id" : "name", rID ? rID : L.real_name, general)
	if(!G)
		return
	rID = G.fields["id"]
	remove_record(G, general, delete)
	var/datum/data/record/S = find_record("id", rID, security)
	remove_record(S, security, delete)
	var/datum/data/record/M = find_record("id", rID, medical)
	remove_record(M, medical, delete)

/datum/datacore/proc/remove_record(datum/data/record/R, list/L, delete = TRUE)
	if(!R)
		return
	if(!L)
		if(R in medical)
			medical -= src
		if(R in security)
			security -= src
		if(R in general)
			general -= src
	else
		L -= R
	if(delete)
		qdel(R)

/datum/datacore/proc/get_manifest(monochrome, OOC)
	. = {"
	<head><style>
		.manifest {border-collapse:collapse;}
		.manifest td, th {border:1px solid [monochrome?"black":"#DEF; background-color:white; color:black"]; padding:.25em}
		.manifest th {height: 2em; [monochrome?"border-top-width: 3px":"background-color: #48C; color:white"]}
		.manifest tr.head th { [monochrome?"border-top-width: 1px":"background-color: #488;"] }
		.manifest td:first-child {text-align:right}
		.manifest tr.alt td {[monochrome?"border-top-width: 2px":"background-color: #DEF"]}
	</style></head>
	<table class="manifest" width='350px'>
	<tr class='head'><th>Name</th><th>Rank</th></tr>
	"}
	. += get_crewlist(OOC)
	. += "</table>"
	. = oldreplacetext(., "\n", "") // so it can be placed on paper correctly
	. = oldreplacetext(., "\t", "")

/datum/datacore/proc/get_crewlist(OOC)
	return

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

	var/id = NEW_DATACORE_ID

	var/icon/front = new(get_id_photo(H), dir = SOUTH)
	var/icon/side = new(get_id_photo(H), dir = WEST)
	//General Record
	var/datum/data/record/G = new(src)
	G.fields["id"]			= id
	G.fields["name"]		= H.real_name
	G.fields["real_rank"]	= H.mind.assigned_role
	G.fields["rank"]		= assignment
	G.fields["squad"]		= H.assigned_squad ? H.assigned_squad.name : null
	G.fields["age"]			= H.age
	G.fields["fingerprint"]	= md5(H.dna.uni_identity)
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
	LAZYADD(general, G)

	//Medical Record
	var/datum/data/record/M = new(src)
	M.fields["id"]			= id
	M.fields["name"]		= H.real_name
	M.fields["b_type"]		= H.b_type
	M.fields["b_dna"]		= H.dna.unique_enzymes
	M.fields["mi_dis"]		= "None"
	M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
	M.fields["ma_dis"]		= "None"
	M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
	M.fields["alg"]			= "None"
	M.fields["alg_d"]		= "No allergies have been detected in this patient."
	M.fields["cdi"]			= "None"
	M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
	M.fields["last_scan_time"]	= null
	M.fields["last_scan_result"]		= "No scan data on record" // body scanner results
	M.fields["autodoc_data"] = list()
	M.fields["autodoc_manual"] = list()
	if(H.med_record)
		M.fields["notes"] = H.med_record
	else
		M.fields["notes"] = "No notes found."
	LAZYADD(medical, M)

	//Security Record
	var/datum/data/record/S = new(src)
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
	LAZYADD(security, S)

	record_paperwork(G, M, S)

/datum/datacore/proc/record_paperwork(datum/data/record/G, datum/data/record/M, datum/data/record/S)
	return

/proc/get_id_photo(mob/living/carbon/human/H, client/C, show_directions = list(SOUTH))
	var/datum/job/J = SSjob.GetJob(H.mind.assigned_role)
	var/datum/preferences/P
	if(!C)
		C = H.client
	if(C)
		P = C.prefs
	return get_flat_human_icon(null, J, P, DUMMY_HUMAN_SLOT_MANIFEST, show_directions)

/datum/datacore/crew

/datum/datacore/crew/record_paperwork(datum/data/record/G, datum/data/record/M, datum/data/record/S)
	for(var/A in GLOB.records_cabinets[GLOB.crew_datacore])
		var/obj/structure/filingcabinet/records/R = A
		R.sort_record(G, M, S)

/datum/datacore/colony/manifest()
	. = ..()
	for(var/var/mob/living/carbon/human/H in GLOB.player_list)
		CHECK_TICK
		var/datum/job/J = SSjob.name_occupations[H.job]
		if(!J || J.get_datacore() != GLOB.crew_datacore)
			continue
		manifest_inject(H)

/datum/datacore/crew/get_crewlist(OOC)
	var/list/eng = list()
	var/list/med = list()
	var/list/mar = list()
	var/list/heads = list()
	var/list/police = list()
	var/list/misc = list()
	var/list/isactive = list()
	var/list/squads = list()

	var/even = FALSE
	for(var/datum/data/record/t in general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		var/real_rank = t.fields["real_rank"]
		var/squad_name = t.fields["squad"]

		if(OOC)
			var/active = FALSE
			for(var/mob/M in GLOB.player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 MINUTES)
					active = TRUE
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = t.fields["p_stat"]

		var/department = FALSE
		if(real_rank in JOBS_COMMAND)
			heads[name] = rank
			department = TRUE
		if(real_rank in JOBS_POLICE)
			police[name] = rank
			department = TRUE
		if(real_rank in JOBS_ENGINEERING)
			eng[name] = rank
			department = TRUE
		if(real_rank in JOBS_MEDICAL)
			med[name] = rank
			department = TRUE
		if(real_rank in JOBS_MARINES)
			squads[name] = squad_name
			mar[name] = rank
			department = TRUE
		if(!department && !(name in heads))
			misc[name] = rank
	if(length(heads))
		. += "<tr><th colspan=3>Command Staff</th></tr>"
		for(var/name in heads)
			. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[heads[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(police))
		. += "<tr><th colspan=3>Military Police</th></tr>"
		for(var/name in police)
			. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[police[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(mar))
		. += "<tr><th colspan=3>Marines</th></tr>"
		for(var/j in list("Alpha","Bravo","Charlie", "Delta"))
			. += "<tr><th colspan=3>[j]</th></tr>"
			for(var/name in mar)
				if(squads[name] == j)
					. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[mar[name]]</td><td>[isactive[name]]</td></tr>"
					even = !even
	if(length(eng))
		. += "<tr><th colspan=3>Engineering</th></tr>"
		for(var/name in eng)
			. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[eng[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	if(length(med))
		. += "<tr><th colspan=3>Medical</th></tr>"
		for(var/name in med)
			. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[med[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even
	// misc guys
	if(length(misc))
		. += "<tr><th colspan=3>Miscellaneous</th></tr>"
		for(var/name in misc)
			. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[misc[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even


/datum/datacore/colony

/datum/datacore/colony/record_paperwork(datum/data/record/G, datum/data/record/M, datum/data/record/S)
	for(var/A in GLOB.records_cabinets[GLOB.colony_datacore])
		var/obj/structure/filingcabinet/records/R = A
		R.sort_record(G, M, S)

/datum/datacore/colony/manifest()
	. = ..()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		CHECK_TICK
		var/datum/job/J = SSjob.name_occupations[H.job]
		if(!J || J.get_datacore() != GLOB.colony_datacore)
			continue
		manifest_inject(H)

/datum/datacore/colony/get_crewlist(OOC)
	var/list/survivors = list()
	var/list/isactive = list()
	var/even = FALSE
	for(var/datum/data/record/t in general)
		var/name = t.fields["name"]
		var/rank = t.fields["rank"]
		if(OOC)
			var/active = FALSE
			for(var/mob/M in GLOB.player_list)
				if(M.real_name == name && M.client && M.client.inactivity <= 10 MINUTES)
					active = TRUE
					break
			isactive[name] = active ? "Active" : "Inactive"
		else
			isactive[name] = t.fields["p_stat"]
		survivors[name] = rank
	if(length(survivors))
		. += "<tr><th colspan=3>Survivors</th></tr>"
		for(var/name in survivors)
			. += "<tr[even ? " class='alt'" : ""]><td>[name]</td><td>[survivors[name]]</td><td>[isactive[name]]</td></tr>"
			even = !even

