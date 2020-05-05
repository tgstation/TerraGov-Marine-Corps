/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(check_access())
		return TRUE

	if(issilicon(M))
		return TRUE //Silicons can access whatever they want

	if(IsAdminGhost(M))
		return TRUE

	var/obj/item/card/id/I = M.get_idcard() //if they are holding or wearing a card that has access, that works.
	if(check_access(I))
		return TRUE


/obj/proc/check_access(obj/item/card/id/ID)
	if(!LAZYLEN(req_access) && !LAZYLEN(req_one_access))
		return TRUE

	if(!istype(ID))
		return FALSE

	for(var/i in req_access)
		if(!(i in ID.access))
			return FALSE

	if(LAZYLEN(req_one_access))
		for(var/i in req_one_access)
			if(!(i in ID.access))
				continue
			return TRUE
		return FALSE

	return TRUE


/obj/proc/check_access_list(L[])
	if(!req_access  && !req_one_access)	return 1
	if(!islist(req_access)) return 1
	if(!req_access.len && (!req_one_access || !req_one_access.len))	return 1
	if(!islist(L))	return
	var/i
	for(i in req_access)
		if(!(i in L)) return //doesn't have this access
	if(req_one_access && req_one_access.len)
		for(i in req_one_access)
			if(i in L) return 1//has an access from the single access list
		return
	return 1


/proc/get_region_accesses(code)
	switch(code)
		if(0)
			return ALL_ACCESS
		if(1)
			return list(ACCESS_MARINE_WO, ACCESS_MARINE_BRIG)//security
		if(2)
			return list(ACCESS_MARINE_CMO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)//medbay
		if(3)
			return list(ACCESS_MARINE_RESEARCH)//research
		if(4)
			return list(ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING)//engineering and maintenance
		if(5)
			return list(ACCESS_MARINE_CAPTAIN, ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_BRIDGE, ACCESS_MARINE_CARGO)//command
		if(6)
			return list(ACCESS_IFF_MARINE, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_SPECPREP)//spess mahreens
		if(7)
			return list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO, ACCESS_MARINE_CHARLIE, ACCESS_MARINE_DELTA)//squads
		if(8)
			return list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_LOGISTICS, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING)//Civilian


/proc/get_region_accesses_name(code)
	switch(code)
		if(0)
			return "All"
		if(1)
			return "[SSmapping.configs[SHIP_MAP].map_name] Security"//security
		if(2)
			return "[SSmapping.configs[SHIP_MAP].map_name] Medbay"//medbay
		if(3)
			return "[SSmapping.configs[SHIP_MAP].map_name] Research"//research
		if(4)
			return "[SSmapping.configs[SHIP_MAP].map_name] Engineering"//engineering and maintenance
		if(5)
			return "[SSmapping.configs[SHIP_MAP].map_name] Command"//command
		if(6)
			return "Marines"//marine prep
		if(7)
			return "Squads"//squads
		if(8)
			return "Civilian"//Civilian


/proc/get_access_desc(A)
	switch(A)
		if(ACCESS_MARINE_WO)
			return "WO's Office"
		if(ACCESS_MARINE_BRIG)
			return "Brig"
		if(ACCESS_MARINE_CMO)
			return "CMO's Office"
		if(ACCESS_MARINE_MEDBAY)
			return "[SSmapping.configs[SHIP_MAP].map_name] Medbay"
		if(ACCESS_MARINE_RESEARCH)
			return "[SSmapping.configs[SHIP_MAP].map_name] Research"
		if(ACCESS_MARINE_CE)
			return "CE's Office"
		if(ACCESS_MARINE_ENGINEERING)
			return "[SSmapping.configs[SHIP_MAP].map_name] Engineering"
		if(ACCESS_MARINE_CAPTAIN)
			return "Captain's Quarters"
		if(ACCESS_MARINE_LOGISTICS)
			return "[SSmapping.configs[SHIP_MAP].map_name] Logistics"
		if(ACCESS_MARINE_BRIDGE)
			return "[SSmapping.configs[SHIP_MAP].map_name] Bridge"
		if(ACCESS_MARINE_PREP)
			return "Marine Prep"
		if(ACCESS_MARINE_ENGPREP)
			return "Marine Squad Engineering"
		if(ACCESS_MARINE_MEDPREP)
			return "Marine Squad Medical"
		if(ACCESS_MARINE_SPECPREP)
			return "Marine Specialist"
		if(ACCESS_MARINE_SMARTPREP)
			return "Marine Smartgunner"
		if(ACCESS_MARINE_LEADER)
			return "Marine Leader"
		if(ACCESS_MARINE_ALPHA)
			return "Alpha Squad"
		if(ACCESS_MARINE_BRAVO)
			return "Bravo Squad"
		if(ACCESS_MARINE_CHARLIE)
			return "Charlie Squad"
		if(ACCESS_MARINE_DELTA)
			return "Delta Squad"
		if(ACCESS_MARINE_CARGO)
			return "Requisitions"
		if(ACCESS_MARINE_DROPSHIP)
			return "Dropship Piloting"
		if(ACCESS_MARINE_PILOT)
			return "Pilot Gear"
		if(ACCESS_MARINE_TANK)
			return "Tank"
		if(ACCESS_CIVILIAN_RESEARCH)
			return "Civilian Research"
		if(ACCESS_CIVILIAN_LOGISTICS)
			return "Civilian Command"
		if(ACCESS_CIVILIAN_ENGINEERING)
			return "Civilian Engineering"
		if(ACCESS_CIVILIAN_PUBLIC)
			return "Civilian"
		if(ACCESS_IFF_MARINE)
			return "[SSmapping.configs[SHIP_MAP].map_name] Identification"

/proc/get_centcom_access_desc(A)
	switch(A)
		if(ACCESS_NT_PMC_GREEN)
			return "NT PMC Green"
		if(ACCESS_NT_PMC_ORANGE)
			return "NT PMC Orange"
		if(ACCESS_NT_PMC_RED)
			return "NT PMC Red"
		if(ACCESS_NT_PMC_BLACK)
			return "NT PMC Black"
		if(ACCESS_NT_PMC_WHITE)
			return "NT PMC White"
		if(ACCESS_NT_CORPORATE)
			return "NT Executive"
		if(ACCESS_IFF_PMC)
			return "NT Identification"


/proc/get_access_job_name(obj/item/card/id/ID)
	var/first_matched
	for(var/i in SSjob.occupations)
		var/datum/job/J = i
		if(J.title == ID.rank)
			return J.title
		if(!first_matched && (J.access ~= ID.access))
			first_matched = J.title
	if(first_matched)
		return first_matched
	else if(length(ID.access))
		return "Custom [ADMIN_VV(ID.access)]"
	else
		return "None"


/proc/get_paygrades(paygrade, size, gender)
	if(!paygrade)
		return
	switch(paygrade)
		if("C")
			. = size ? "" : "Civilian"
		if("CD")
			. = size ? "Dr. " : "Doctor"
		if("CCMO")
			. = size ? "Prof. " : "Professor"
		if("CMN")
			. = size ? "CMN" : "Crewman"
		if("PMC1")
			. = size ? "PMC " : "PM Contractor"
		if("PMC2")
			. = size ? "PMSC " : "PM Senior Contractor"
		if("PMC3")
			. = size ? "PMSC " : "PM Senior Contractor"
		if("PMC4")
			. = size ? "PMTL " : "PM Team Leader"
		if("PMCDS")
			. = size ? "APS " : "Assets Protection Specialist"
		if("PMCDSL")
			. = size ? "APTL " : "Assets Protection Team Leader"
		if("NT")
			. = size ? (gender == "female" ? "Ms. " : "Mr. ") : "Junior Executive"
		if("E1")
			. = size ? "PVT " : "Private"
		if("E2")
			. = size ? "PFC " : "Private First Class"
		if("E3")
			. = size ? "LCPL " : "Lance Corporal"
		if("E4")
			. = size ? "CPL " : "Corporal"
		if("E5")
			. = size ? "SGT " : "Sergeant"
		if("E6")
			. = size ? "SSGT " : "Staff Sergeant"
		if("E7")
			. = size ? "GYSGT " : "Gunnery Sergeant"
		if("E8")
			. = size ? "MSGT " : "Master Sergeant"
		if("E8E")
			. = size ? "FSGT " : "First Sergeant"
		if("E9")
			. = size ? "SGM " : "Sergeant Major"
		if("E9E")
			. = size ? "CSGM " : "Command Sergeant Major"
		if("O1")
			. = size ? "ENS " : "Ensign"
		if("O2")
			. = size ? "LTJG " : "Lieutenant Junior Grade"
		if("O3")
			. = size ? "LT " : "Lieutenant"
		if("O4")
			. = size ? "LCDR " : "Lieutenant Commander"
		if("O5")
			. = size ? "CDR " : "Commander"
		if("O6")
			. = size ? "CPT " : "Captain"
		if("O7")
			. = size ? "COMM " : "Commodore"
		if("O8")
			. = size ? "RADM " : "Rear Admiral"
		if("O9")
			. = size ? "VADM " : "Vice Admiral"
		if("10")
			. = size ? "ADM " : "Admiral"
		if("11")
			. = size ? "FADM " : "Fleet Admiral"
		if("WO")
			. = size ? "WO " : "Warrant Officer"
		if("CWO")
			. = size ? "CWO " : "Chief Warrant Officer"
		if("PO")
			. = size ? "PO " : "Petty Officer"
		if("CPO")
			. = size ? "CPO " : "Chief Petty Officer"
		if("MO4")
			. = size ? "MAJ " : "Major"
		if("UPP1")
			. = size ? "UPVT " : "UPP Private"
		if("UPP2")
			. = size ? "UPFC " : "UPP Private First Class"
		if("UPP3")
			. = size ? "UCPL " : "UPP Corporal"
		if("UPP4")
			. = size ? "ULCPL " : "UPP Lance Corporal"
		if("UPP5")
			. = size ? "USGT " : "UPP Sergeant"
		if("UPP6")
			. = size ? "USSGT " : "UPP Staff Sergeant"
		if("UPP7")
			. = size ? "UENS " : "UPP Ensign"
		if("UPP8")
			. = size ? "ULT " : "UPP Lieutenant"
		if("UPP9")
			. = size ? "ULCDR " : "UPP Lieutenant Commander"
		if("UPP10")
			. = size ? "UCDR " : "UPP Commander"
		if("UPP11")
			. = size ? "UADM " : "UPP Admiral"
		if("UPPC1")
			. = size ? "UPPC " : "UPP Commando Standard"
		if("UPPC2")
			. = size ? "UPPC " : "UPP Commando Medic"
		if("UPPC3")
			. = size ? "UPPC " : "UPP Commando Leader"
		if("FRE1")
			. = size ? "FRE " : "Freelancer Standard"
		if("FRE2")
			. = size ? "FRE " : "Freelancer Medic"
		if("FRE3")
			. = size ? "FRE " : "Freelancer Leader"
		if("CLF1")
			. = size ? "CLF " : "CLF Standard"
		if("CLF2")
			. = size ? "CLF " : "CLF Medic"
		if("CLF3")
			. = size ? "CLF " : "CLF Leader"
		if("SOM1")
			. = size ? "SOM " : "SOM Standard"
		if("SOM2")
			. = size ? "SOM " : "SOM Medic"
		if("SOM3")
			. = size ? "SOM " : "SOM Veteran"
		if("SOM4")
			. = size ? "SOM " : "SOM Leader"
		if("MRC1")
			. = size ? "MERC " : "MERC Heavy"
		if("MRC2")
			. = size ? "MERC " : "MERC Miner"
		if("MRC3")
			. = size ? "MERC " : "MERC Engineer"
		else
			. = paygrade + " " //custom paygrade
